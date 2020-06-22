import SwiftUI
import Combine

struct EventValueView: View {
  let index: Int
  var body: some View {
    Text("\(self.index)")
      .padding(3.0)
      .frame(width: 28.0, height: 28.0)
      .allowsTightening(true)
      .minimumScaleFactor(0.1)
      .foregroundColor(.white)
      .background(Circle().fill(Color.blue))
      .fixedSize()
  }
}

struct EventCompletedView: View {
  var body: some View {
    Rectangle()
      .frame(width: 4, height: 38.0)
      .offset(x:0, y: -3)
      .foregroundColor(.gray)
  }
}

struct EventFailureView: View {
  var body: some View {
    Text("X")
      .padding(3.0)
      .frame(width: 28.0, height: 28.0)
      .foregroundColor(.white)
      .background(Circle().fill(Color.red))
  }
}

struct EventView: View {
  let event: CombineEvent

  var body: some View {
    switch self.event.event {
    case .value:
      return AnyView(EventValueView(index: self.event.index))
    case .completion:
      return AnyView(EventCompletedView())
    case .failure:
      return AnyView(EventFailureView())
    }
  }
}

/// A view that displays events happening simultaneously in a vertical stack
struct SimultaneousEventsView: View {
  let events: [CombineEvent]

  var body: some View {
    VStack(alignment: .center, spacing: 0) {
      ForEach(0 ..< self.events.count) {
        EventView(event: self.events[$0])
      }
    }
  }
}

extension SimultaneousEventsView: Identifiable {
  var id: Int { return events[0].groupTime }
}

/// An animated view that displays events from a Combine publisher.
///
/// Usage example:
/// ```
/// let publisher = [1,2,3].publisher()
/// let timelineView = TimelineView(title: "Example")
/// publisher.displayEvents(in: timelineView)
/// ```
public struct TimelineView: View {
  @ObservedObject var time = DisplayTimer()
  let holder: EventsHolder
  let title: String

  // group events that occur in a very close timeframe (< 0.1 second)
  var groupedEvents: [CombineEvents] {
    let d = Dictionary<Int,[CombineEvent]>(grouping: self.holder.events) { $0.groupTime }
    return d.keys.sorted().map { CombineEvents(events: d[$0]!.sorted { $0.index < $1.index }) }
  }

  public init(title: String) {
    self.title = title
    self.holder = EventsHolder()
  }

  public init(title: String, events: [CombineEvent]) {
    self.title = title
    self.holder = EventsHolder(events: events)
  }

  public var body: some View {
    VStack(alignment: .leading) {
      Text(title)
        .fixedSize(horizontal: false, vertical: true)
        .padding(.bottom, 8)
      ZStack(alignment: .topTrailing) {
        Rectangle()
          .frame(height: 2)
          .foregroundColor(.gray)
          .offset(x: 0, y: 14)
        ForEach(groupedEvents) { group in
          SimultaneousEventsView(events: group.events)
            .offset(x: CGFloat(group.time) * 30.0 - self.time.current - 32, y: 0)
        }
      }
      .frame(minHeight: 32)
      .onReceive(time.objectWillChange) { _ in
        if self.holder.events.contains(where: { $0.event != .value }) {
          // we observe the contents of the events holder and
          // terminate the display timer when we see a .completion or .failure event
          self.time.stop(after: 0.5)
        }
      }
    }
  }

  // this internal function captures events from a Publisher and fills up
  // our events list. Note that we never cancel our subscription, but the
  // body generator notices when a completion or failure occurs and stops
  // the rendering timer
  func capture<T,F>(publisher: AnyPublisher<T,F>) {
    let observer = AnySubscriber(receiveSubscription: { subscription in
      subscription.request(.unlimited)
    }, receiveValue: { (value: T) -> Subscribers.Demand in
      self.holder.capture(.value)
      return .unlimited
    }, receiveCompletion: { (completion: Subscribers.Completion<F>) in
      switch completion {
      case .finished:
        self.holder.capture(.completion)
      case .failure:
        self.holder.capture(.failure)
      }
    })
    publisher
      .subscribe(on: DispatchQueue.main)
      .subscribe(observer)
  }
}

public extension Publisher {
  func displayEvents(in view: TimelineView) {
    view.capture(publisher: self.eraseToAnyPublisher())
  }
}


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

