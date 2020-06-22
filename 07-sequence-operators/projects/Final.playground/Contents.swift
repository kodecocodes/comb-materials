import Foundation
import Combine

var subscriptions = Set<AnyCancellable>()

// MARK: - Finding values

example(of: "min") {
  // 1
  let publisher = [1, -50, 246, 0].publisher

  // 2
  publisher
    .print("publisher")
    .min()
    .sink(receiveValue: { print("Lowest value is \($0)") })
    .store(in: &subscriptions)
}

example(of: "min non-Comparable") {
  // 1
  let publisher = ["12345",
                   "ab",
                   "hello world"]
    .compactMap { $0.data(using: .utf8) } // [Data]
    .publisher // Publisher<Data, Never>

  // 2
  publisher
    .print("publisher")
    .min(by: { $0.count < $1.count })
    .sink(receiveValue: { data in
      // 3
      let string = String(data: data, encoding: .utf8)!
      print("Smallest data is \(string), \(data.count) bytes")
    })
    .store(in: &subscriptions)
}

example(of: "max") {
  // 1
  let publisher = ["A", "F", "Z", "E"].publisher

  // 2
  publisher
    .print("publisher")
    .max()
    .sink(receiveValue: { print("Highest value is \($0)") })
    .store(in: &subscriptions)
}

example(of: "first") {
  // 1
  let publisher = ["A", "B", "C"].publisher

  // 2
  publisher
    .print("publisher")
    .first()
    .sink(receiveValue: { print("First value is \($0)") })
    .store(in: &subscriptions)
}

example(of: "first(where:)") {
  // 1
  let publisher = ["J", "O", "H", "N"].publisher

  // 2
  publisher
    .print("publisher")
    .first(where: { "Hello World".contains($0) })
    .sink(receiveValue: { print("First match is \($0)") })
    .store(in: &subscriptions)
}

example(of: "last") {
  // 1
  let publisher = ["A", "B", "C"].publisher

  // 2
  publisher
    .print("publisher")
    .last()
    .sink(receiveValue: { print("Last value is \($0)") })
    .store(in: &subscriptions)
}

example(of: "output(at:)") {
  // 1
  let publisher = ["A", "B", "C"].publisher

  // 2
  publisher
    .print("publisher")
    .output(at: 1)
    .sink(receiveValue: { print("Value at index 1 is \($0)") })
    .store(in: &subscriptions)
}

example(of: "output(in:)") {
  // 1
  let publisher = ["A", "B", "C", "D", "E"].publisher

  // 2
  publisher
    .output(in: 1...3)
    .sink(receiveCompletion: { print($0) },
          receiveValue: { print("Value in range: \($0)") })
    .store(in: &subscriptions)
}

// MARK: - Querying the publisher

example(of: "count") {
  // 1
  let publisher = ["A", "B", "C"].publisher

  // 2
  publisher
    .print("publisher")
    .count()
    .sink(receiveValue: { print("I have \($0) items") })
    .store(in: &subscriptions)
}

example(of: "contains") {
  // 1
  let publisher = ["A", "B", "C", "D", "E"].publisher
  let letter = "F"

  // 2
  publisher
    .print("publisher")
    .contains(letter)
    .sink(receiveValue: { contains in
      // 3
      print(contains ? "Publisher emitted \(letter)!"
                     : "Publisher never emitted \(letter)!")
    })
    .store(in: &subscriptions)
}

example(of: "contains(where:)") {
  // 1
  struct Person {
    let id: Int
    let name: String
  }

  // 2
  let people = [
    (456, "Scott Gardner"),
    (123, "Shai Mishali"),
    (777, "Marin Todorov"),
    (214, "Florent Pillet")
  ]
  .map(Person.init)
  .publisher

  // 3
  people
    .contains(where: { $0.id == 800 || $0.name == "Marin Todorov" })
    .sink(receiveValue: { contains in
      // 4
      print(contains ? "Criteria matches!"
                     : "Couldn't find a match for the criteria")
    })
    .store(in: &subscriptions)
}

example(of: "allSatisfy") {
  // 1
  let publisher = stride(from: 0, to: 5, by: 1).publisher

  // 2
  publisher
    .print("publisher")
    .allSatisfy { $0 % 2 == 0 }
    .sink(receiveValue: { allEven in
      print(allEven ? "All numbers are even"
                    : "Something is odd...")
    })
    .store(in: &subscriptions)
}

example(of: "reduce") {
  // 1
  let publisher = ["Hel", "lo", " ", "Wor", "ld", "!"].publisher

  publisher
    .print("publisher")
    .reduce("", +)
    .sink(receiveValue: { print("Reduced into: \($0)") })
    .store(in: &subscriptions)
}

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
