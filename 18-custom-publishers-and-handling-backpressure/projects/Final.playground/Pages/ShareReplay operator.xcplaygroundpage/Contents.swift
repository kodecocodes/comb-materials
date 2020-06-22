import Foundation
import Combine

// 1
fileprivate final class ShareReplaySubscription<Output, Failure: Error>: Subscription {
  // 2
  let capacity: Int
  // 3
  var subscriber: AnySubscriber<Output,Failure>? = nil
  // 4
  var demand: Subscribers.Demand = .none
  // 5
  var buffer: [Output]
  // 6
  var completion: Subscribers.Completion<Failure>? = nil

  init<S>(subscriber: S,
          replay: [Output],
          capacity: Int,
          completion: Subscribers.Completion<Failure>?)
          where S: Subscriber,
                Failure == S.Failure,
                Output == S.Input {
    // 7
    self.subscriber = AnySubscriber(subscriber)
    // 8
    self.buffer = replay
    self.capacity = capacity
    self.completion = completion
  }

  private func complete(with completion: Subscribers.Completion<Failure>) {
    // 9
    guard let subscriber = subscriber else { return }
    self.subscriber = nil
    // 10
    self.completion = nil
    self.buffer.removeAll()
    // 11
    subscriber.receive(completion: completion)
  }

  private func emitAsNeeded() {
    guard let subscriber = subscriber else { return }
    // 12
    while self.demand > .none && !buffer.isEmpty {
      // 13
      self.demand -= .max(1)
      // 14
      let nextDemand = subscriber.receive(buffer.removeFirst())
      // 15
      if nextDemand != .none {
        self.demand += nextDemand
      }
    }
    // 16
    if let completion = completion {
      complete(with: completion)
    }
  }

  func request(_ demand: Subscribers.Demand) {
    if demand != .none {
      self.demand += demand
    }
    emitAsNeeded()
  }

  func receive(_ input: Output) {
    guard subscriber != nil else { return }
    // 17
    buffer.append(input)
    if buffer.count > capacity {
      // 18
      buffer.removeFirst()
    }
    // 19
    emitAsNeeded()
  }

  func receive(completion: Subscribers.Completion<Failure>) {
    guard let subscriber = subscriber else { return }
    self.subscriber = nil
    self.buffer.removeAll()
    subscriber.receive(completion: completion)
  }

  func cancel() {
    complete(with: .finished)
  }
}

extension Publishers {
  // 20
  final class ShareReplay<Upstream: Publisher>: Publisher {
    // 21
    typealias Output = Upstream.Output
    typealias Failure = Upstream.Failure

    // 22
    private let lock = NSRecursiveLock()
    // 23
    private let upstream: Upstream
    // 24
    private let capacity: Int
    // 25
    private var replay = [Output]()
    // 26
    private var subscriptions = [ShareReplaySubscription<Output, Failure>]()
    // 27
    private var completion: Subscribers.Completion<Failure>? = nil

    init(upstream: Upstream, capacity: Int) {
      self.upstream = upstream
      self.capacity = capacity
    }

    func receive<S: Subscriber>(subscriber: S)
      where Failure == S.Failure,
            Output == S.Input {
      lock.lock()
      defer { lock.unlock() }

      // 34
      let subscription = ShareReplaySubscription(
        subscriber: subscriber,
        replay: replay,
        capacity: capacity,
        completion: completion)

      // 35
      subscriptions.append(subscription)
      // 36
      subscriber.receive(subscription: subscription)

      // 37
      guard subscriptions.count == 1 else { return }
      // 38
      let sink = AnySubscriber(
        // 39
        receiveSubscription: { subscription in
          // 40
          subscription.request(.unlimited)
        },
        receiveValue: { [weak self] (value: Output) -> Subscribers.Demand in
            self?.relay(value)
            return .none
          },
          receiveCompletion: { [weak self] in
            self?.complete($0)
        }
      )

      upstream.subscribe(sink)
    }

    private func relay(_ value: Output) {
      // 28
      lock.lock()
      defer { lock.unlock() }

      // 29
      guard completion == nil else { return }

      // 30
      replay.append(value)
      if replay.count > capacity {
        replay.removeFirst()
      }
      // 31
      subscriptions.forEach {
        _ = $0.receive(value)
      }
    }

    private func complete(_ completion: Subscribers.Completion<Failure>) {
      lock.lock()
      defer { lock.unlock() }
      // 32
      self.completion = completion
      // 33
      subscriptions.forEach {
        _ = $0.receive(completion: completion)
      }
    }
  }
}

extension Publisher {
  func shareReplay(capacity: Int = .max) -> Publishers.ShareReplay<Self> {
    return Publishers.ShareReplay(upstream: self, capacity: capacity)
  }
}

// 41
var logger = TimeLogger(sinceOrigin: true)
// 42
let subject = PassthroughSubject<Int,Never>()
// 43
let publisher = subject
  .print("shareReplay")
  .shareReplay(capacity: 2)
// 44
subject.send(0)

let subscription1 = publisher.sink(
  receiveCompletion: {
    print("subscription2 completed: \($0)", to: &logger)
  },
  receiveValue: {
    print("subscription2 received \($0)", to: &logger)
  }
)

subject.send(1)
subject.send(2)
subject.send(3)

let subscription2 = publisher.sink(
  receiveCompletion: {
    print("subscription2 completed: \($0)", to: &logger)
  },
  receiveValue: {
    print("subscription2 received \($0)", to: &logger)
  }
)

subject.send(4)
subject.send(5)
subject.send(completion: .finished)

var subscription3: Cancellable? = nil

DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
  print("Subscribing to shareReplay after upstream completed")
  subscription3 = publisher.sink(
    receiveCompletion: {
      print("subscription3 completed: \($0)", to: &logger)
    },
    receiveValue: {
      print("subscription3 received \($0)", to: &logger)
    }
  )
}

//: [Next](@next)
/*:
 Copyright (c) 2019 Razeware LLC

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 distribute, sublicense, create a derivative work, and/or sell copies of the
 Software in any work that is designed, intended, or marketed for pedagogical or
 instructional purposes related to programming, coding, application development,
 or information technology.  Permission for such use, copying, modification,
 merger, publication, distribution, sublicensing, creation of derivative works,
 or sale is expressly withheld.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */
