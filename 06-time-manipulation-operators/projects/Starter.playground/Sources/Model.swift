import SwiftUI
import Combine

/// A basic event we want to represent in the timeline view
/// We don't need to keep the value data around as we'll only
/// be interested in displaying the value index in the values sequence
public enum Event: Equatable {
  case value
  case completion
  case failure
}

/// Representation of an event emitted by a Publisher at a given point in time
/// the TimeInterval represents the time since we started capturing events
/// We use `groupTime` to visually group very close events vertically, to represent
/// simultaneous events.
public struct CombineEvent {
  public let index: Int
  public let time: TimeInterval
  public let event: Event

  public var groupTime: Int { Int(floor(time * 10.0)) }
  public var isValue: Bool { self.event == .value }
  public var isCompletion: Bool { self.event == .completion }

  public init(index: Int, time: TimeInterval, event: Event) {
    self.index = index
    self.time = time
    self.event = event
  }
}

/// A group of events that occur at the same or very close time
struct CombineEvents: Identifiable {
  let events: [CombineEvent]

  var time: TimeInterval { events[0].time }
  var id: Int { (events[0].groupTime << 16) | events.count } // make Identifiable identifier for combine events properly unique
}

/// A holder class we use to grow our events list stored inside the
/// immutable TimelineView structure
class EventsHolder {
  var events = [CombineEvent]()
  var startDate = Date()
  var nextIndex = 1

  init() { }

  init(events: [CombineEvent]) {
    self.events = events
  }

  func capture(_ event: Event) {
    let time = Date().timeIntervalSince(startDate)
    if case .completion = event, let lastEvent = events.last, (time - lastEvent.time) < 1.0 {
      events.append(CombineEvent(index: nextIndex, time: lastEvent.time + 1.0, event: event))
    } else {
      events.append(CombineEvent(index: nextIndex, time: time, event: event))
    }
    nextIndex += 1

    // clean up old events from the store
    // as they likely moved out of the screen after 15s
    while let e = events.first {
      guard (time - e.time) > 15.0 else { break }
      events.removeFirst()
    }
  }
}

/// The timer we use to refresh the view and animate it
public final class DisplayTimer: ObservableObject {
  @Published var current: CGFloat = 0
  var cancellable: Cancellable? = nil

  public init() {
    DispatchQueue.main.async {
      self.cancellable = self.start()
    }
  }

  public func start() -> Cancellable {
    return Timer
      .publish(every: 1.0 / 30, on: .main, in: .common)
      .autoconnect()
      .scan(CGFloat(0)) { (counter, _) in counter + 1 }
      .sink { counter in
        self.current = counter
    }
  }

  public func stop(after: TimeInterval) {
    DispatchQueue.main.asyncAfter(deadline: .now() + after) {
      self.cancellable?.cancel()
    }
  }
}


/*:
 Copyright (c) 2021 Razeware LLC

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

