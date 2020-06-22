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

final class ComputationSubscription<Output>: Subscription {
  private let duration: TimeInterval
  private let sendCompletion: () -> Void
  private let sendValue: (Output) -> Subscribers.Demand
  private let finalValue: Output
  private var cancelled = false

  init(duration: TimeInterval, sendCompletion: @escaping () -> Void, sendValue: @escaping (Output) -> Subscribers.Demand, finalValue: Output) {
    self.duration = duration
    self.finalValue = finalValue
    self.sendCompletion = sendCompletion
    self.sendValue = sendValue
  }

  func request(_ demand: Subscribers.Demand) {
    if !cancelled {
      print("Beginning expensive computation on thread \(Thread.current.number)")
    }
    Thread.sleep(until: Date(timeIntervalSinceNow: duration))
    if !cancelled {
      print("Completed expensive computation on thread \(Thread.current.number)")
      _ = self.sendValue(self.finalValue)
      self.sendCompletion()
    }
  }

  func cancel() {
    cancelled = true
  }
}

extension Publishers {

  public struct ExpensiveComputation: Publisher {
    public typealias Output = String
    public typealias Failure = Never

    public let duration: TimeInterval

    public init(duration: TimeInterval) {
      self.duration = duration
    }

    public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
      Swift.print("ExpensiveComputation subscriber received on thread \(Thread.current.number)")
      let subscription = ComputationSubscription(duration: duration,
                                                 sendCompletion: { subscriber.receive(completion: .finished) },
                                                 sendValue: { subscriber.receive($0) },
                                                 finalValue: "Computation complete")

      subscriber.receive(subscription: subscription)
    }
  }
}
