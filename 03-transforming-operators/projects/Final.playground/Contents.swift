import Foundation
import Combine

var subscriptions = Set<AnyCancellable>()

// MARK: - Collecting values

example(of: "collect") {
  ["A", "B", "C", "D", "E"].publisher
    .collect(2)
    .sink(receiveCompletion: { print($0) },
          receiveValue: { print($0) })
    .store(in: &subscriptions)
}

// MARK: - Mapping values

example(of: "map") {
  // 1
  let formatter = NumberFormatter()
  formatter.numberStyle = .spellOut

  // 2
  [123, 4, 56].publisher
    // 3
    .map {
      formatter.string(for: NSNumber(integerLiteral: $0)) ?? ""
    }
    .sink(receiveValue: { print($0) })
    .store(in: &subscriptions)
}

example(of: "map key paths") {
  // 1
  let publisher = PassthroughSubject<Coordinate, Never>()
        
  // 2
  publisher
    // 3
    .map(\.x, \.y)
    .sink(receiveValue: { x, y in
      // 4
      print(
        "The coordinate at (\(x), \(y)) is in quadrant",
        quadrantOf(x: x, y: y)
      )
    })
    .store(in: &subscriptions)
  
  // 5
  publisher.send(Coordinate(x: 10, y: -8))
  publisher.send(Coordinate(x: 0, y: 5))
}

example(of: "tryMap") {
  // 1
  Just("Directory name that does not exist")
    // 2
    .tryMap { try FileManager.default.contentsOfDirectory(atPath: $0) }
    // 3
    .sink(receiveCompletion: { print($0) },
          receiveValue: { print($0) })
    .store(in: &subscriptions)
}

// MARK: - Flattening publishers

example(of: "flatMap") {
  // 1
  let charlotte = Chatter(name: "Charlotte", message: "Hi, I'm Charlotte!")
  let james = Chatter(name: "James", message: "Hi, I'm James!")

  // 2
  let chat = CurrentValueSubject<Chatter, Never>(charlotte)

  // 3
  chat
    // 6
    .flatMap(maxPublishers: .max(2)) { $0.message }
    // 7
    .sink(receiveValue: { print($0) })
    .store(in: &subscriptions)

  // 4
  charlotte.message.value = "Charlotte: How's it going?"

  // 5
  chat.value = james

  james.message.value = "James: Doing great. You?"
  charlotte.message.value = "Charlotte: I'm doing fine thanks."

  // 8
  let morgan = Chatter(name: "Morgan",
                       message: "Hey guys, what are you up to?")
  
  // 9
  chat.value = morgan

  // 10
  charlotte.message.value = "Did you hear something?"
}

// MARK: - Replacing upstream output

example(of: "replaceNil") {
  // 1
  ["A", nil, "C"].publisher
    .replaceNil(with: "-") // 2
    .map { $0! }
    .sink(receiveValue: { print($0) }) // 3
    .store(in: &subscriptions)
}

example(of: "replaceEmpty(with:)") {
  // 1
  let empty = Empty<Int, Never>()

  // 2
  empty
    .replaceEmpty(with: 1)
    .sink(receiveCompletion: { print($0) },
          receiveValue: { print($0) })
    .store(in: &subscriptions)
}

example(of: "scan") {
  // 1
  var dailyGainLoss: Int { .random(in: -10...10) }

  // 2
  let august2019 = (0..<22)
    .map { _ in dailyGainLoss }
    .publisher

  // 3
  august2019
    .scan(50) { latest, current in
      max(0, latest + current)
    }
    .sink(receiveValue: { _ in })
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
