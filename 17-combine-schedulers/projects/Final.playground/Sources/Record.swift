/// Copyright (c) 2019 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Foundation
import Combine
import SwiftUI

/// A small bit of data we generate with the first `follow(_:)` operator and augment with each subsquent follow so as to get a complete picture of threading + timing
public struct RecorderData {
  public let time = Date()
  public let index: Int
  public let value: Any?
  public let event: Event
  public let context: String
  public let thread: Int
  public let previous: [RecorderData]

  public init(index: Int, value: Any?, context: String) {
    self.index = index
    self.value = value
    self.event = .value
    self.context = context
    self.thread = Thread.current.number
    self.previous = []
  }

  public init(index: Int, value: Any?, event: Event, context: String, comesAfter: RecorderData?) {
    self.index = index
    self.value = value
    self.event = event
    self.context = context
    self.thread = Thread.current.number
    if let chain = comesAfter {
      var previous = chain.previous
      previous.append(chain)
      self.previous = previous
    } else {
      self.previous = []
    }
  }

  public init(value: Any?, updating previous: RecorderData) {
    self.index = previous.index
    self.value = value
    self.event = .value
    self.context = previous.context
    self.thread = previous.thread
    self.previous = previous.previous
  }

  /// a trimmed time to group event occurring around the same time (1/10s resolution)
  var groupTime: Int { Int(floor(time.timeIntervalSinceReferenceDate * 10.0)) }

  /// call this function to keep the RecordThread context but update the value (i.e. for a `map` operation)
  func continueWith(value: Any) -> RecorderData {
    return RecorderData(value: value, updating: self)
  }

  func continueWith(context: String) -> RecorderData {
    return RecorderData(index: index, value: self.value, event: self.event, context: context, comesAfter: self)
  }

  func next(value: Any, context: String, event: Event = .value) -> RecorderData {
    return RecorderData(index: index, value: value, event: event, context: context, comesAfter: self)
  }
}

extension RecorderData: Identifiable {
  public var id: TimeInterval { return time.timeIntervalSinceReferenceDate }
}

extension RecorderData: CustomDebugStringConvertible {
  public var debugDescription: String {
    let chain: String
    if let last = previous.last {
      chain = last.debugDescription + " -> "
    } else {
      chain = ""
    }
    return context.isEmpty ? "\(chain)thread \(thread) (\(event))" : "\(chain)\(context) thread \(thread) (\(event))"
  }
}

/// A single "chain" of followers for the same initial value, made Identifiable for SwiftUI to use
struct RecorderDataChain: Identifiable {
  let index: Int
  let data: [RecorderData]
  var id: Int { return index }
}

/// A `BindableObject` for SwiftUI code that delivers updates whenever a new event data arrives
public final class ThreadRecorder: ObservableObject {
  public let objectWillChange = ObservableObjectPublisher()

  private var events = [RecorderData]()
  private var lock = NSRecursiveLock()
  public var subscription: Cancellable? = nil

  public init() { }

  func start(with closure: SetupClosure) {
    if subscription == nil {
      subscription = closure(self).sink { _ in }
    }
  }

  func append(data: RecorderData) {
    // we need to go to main thread for SwiftUI to work correctly
    DispatchQueue.main.async {
      self.lock.lock()
      self.objectWillChange.send()
      self.events.removeAll { $0.index == data.index }
      self.events.append(data)
      self.lock.unlock()
    }
  }

  var chains: [RecorderDataChain] {
    lock.lock()
    defer { lock.unlock() }
    return events
      .map { $0.index }
      .sorted()
      .map { RecorderDataChain(index: $0, data: self.receivedEvents(index: $0)) }
  }

  func receivedEvents(index: Int) -> [RecorderData] {
    lock.lock()
    defer { lock.unlock() }
    return events
      .filter { $0.index == index }
      .flatMap { (event: RecorderData) -> [RecorderData] in
        if event.previous.isEmpty {
          return [event]
        }
        var array = event.previous
        array.append(event)
        return array
    }
  }
}


extension Publishers {
  public struct RecordThread<Upstream>: Publisher where Upstream: Publisher {
    public typealias Output = RecorderData
    public typealias Failure = Upstream.Failure

    let upstream: Upstream
    let context: String
    let observer: ThreadRecorder

    public func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
      var isFollowing = false
      var nextIndex = 1

      let sink = AnySubscriber<Upstream.Output, Upstream.Failure>(
        receiveSubscription: { subscription in
          subscriber.receive(subscription: subscription)
      },
        receiveValue: { value in
          if let previous = value as? RecorderData {
            isFollowing = true
            let data = previous.continueWith(context: self.context)
            self.observer.append(data: data)
            return subscriber.receive(data)
          } else {
            defer { nextIndex += 1 }
            let data = RecorderData(index: nextIndex, value: value, context: self.context)
            self.observer.append(data: data)
            return subscriber.receive(data)
          }
      },
        receiveCompletion: { completion in
          switch completion {
          case .failure(let error):
            if !isFollowing {
              let data = RecorderData(index: nextIndex, value: nil, event: .failure, context: self.context, comesAfter: nil)
              self.observer.append(data: data)
              _ = subscriber.receive(data)
            }
            subscriber.receive(completion: .failure(error))
          case .finished:
            if !isFollowing {
              let data = RecorderData(index: nextIndex, value: nil, event: .completion, context: self.context, comesAfter: nil)
              self.observer.append(data: data)
              _ = subscriber.receive(data)
            }
            subscriber.receive(completion: .finished)
          }
          nextIndex += 1
      })
      self.upstream.subscribe(sink)
    }
  }
}

extension Publisher {
  public func recordThread(using observer: ThreadRecorder, context: String = "") -> Publishers.RecordThread<Self> {
    return Publishers.RecordThread(upstream: self, context: context, observer: observer)
  }
}

