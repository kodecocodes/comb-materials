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
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACTa, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import XCTest
import Combine

class CombineOperatorsTests: XCTestCase {
  var subscriptions = Set<AnyCancellable>()

  override func tearDown() {
    subscriptions = []
  }

  func test_collect() {
    // Given
    let values = [0, 1, 2]
    let publisher = values.publisher

    // When
    publisher
      .collect()
      .sink(receiveValue: {
        // Then
        XCTAssert(
         $0 == values,
         "Result was expected to be \(values) but was \($0)"
        )
      })
      .store(in: &subscriptions)
  }

  func test_flatMapWithMax2Publishers() {
    // Given
    // 1
    let intSubject1 = PassthroughSubject<Int, Never>()
    let intSubject2 = PassthroughSubject<Int, Never>()
    let intSubject3 = PassthroughSubject<Int, Never>()

    // 2
    let publisher = CurrentValueSubject<PassthroughSubject<Int, Never>, Never>(intSubject1)
    
    // 3
    let expected = [1, 2, 4]
    var results = [Int]()

    // 4
    publisher
      .flatMap(maxPublishers: .max(2)) { $0 }
      .sink(receiveValue: {
        results.append($0)
      })
      .store(in: &subscriptions)

    // When
    // 5
    intSubject1.send(1)

    // 6
    publisher.send(intSubject2)
    intSubject2.send(2)

    // 7
    publisher.send(intSubject3)
    intSubject3.send(3)
    intSubject2.send(4)

    // 8
    publisher.send(completion: .finished)

    // Then
    XCTAssert(
      results == expected,
      "Results expected to be \(expected) but were \(results)"
    )
  }

  func test_timerPublish() {
    // Given
    // 1
    func normalized(_ ti: TimeInterval) -> TimeInterval {
      return Double(round(ti * 10) / 10)
    }

    // 2
    let now = Date().timeIntervalSinceReferenceDate
    // 3
    let expectation = self.expectation(description: #function)
    // 4
    let expected = [0.5, 1, 1.5]
    var results = [TimeInterval]()

    // 5
    let publisher = Timer
      .publish(every: 0.5, on: .main, in: .common)
      .autoconnect()
      .prefix(3)

    // When
    publisher
      .sink(
        receiveCompletion: { _ in expectation.fulfill() },
        receiveValue: {
          results.append(
            normalized($0.timeIntervalSinceReferenceDate - now)
          )
        }
      )
      .store(in: &subscriptions)

    // Then
    // 6
    waitForExpectations(timeout: 2, handler: nil)

    // 7
    XCTAssert(
      results == expected,
      "Results expected to be \(expected) but were \(results)"
    )
  }

  func test_shareReplay() {
    // Given
    // 1
    let subject = PassthroughSubject<Int, Never>()
    // 2
    let publisher = subject.shareReplay(capacity: 2)
    // 3
    let expected = [0, 1, 2, 1, 2, 3, 3]
    var results = [Int]()

    // When
    // 4
    publisher
      .sink(receiveValue: { results.append($0) })
      .store(in: &subscriptions)

    // 5
    subject.send(0)
    subject.send(1)
    subject.send(2)

    // 6
    publisher
      .sink(receiveValue: { results.append($0) })
      .store(in: &subscriptions)

    // 7
    subject.send(3)

    XCTAssert(
      results == expected,
      "Results expected to be \(expected) but were \(results)"
    )
  }
}
