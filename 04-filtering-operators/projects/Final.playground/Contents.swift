import Foundation
import Combine

var subscriptions = Set<AnyCancellable>()

// MARK: - Filtering basics
example(of: "filter") {
  // 1
  let numbers = (1...10).publisher
  // 2
  numbers
    .filter { $0.isMultiple(of: 3) }
    .sink(receiveValue: { n in
      print("\(n) is a multiple of 3!")
    })
    .store(in: &subscriptions)
}

example(of: "removeDuplicates") {
  // 1
  let words = "hey hey there! want to listen to mister mister ?"
                  .components(separatedBy: " ")
                  .publisher
  // 2
  words
    .removeDuplicates()
    .sink(receiveValue: { print($0) })
    .store(in: &subscriptions)
}

// MARK: - Compacting and ignoring

example(of: "compactMap") {
  // 1
  let strings = ["a", "1.24", "3",
                 "def", "45", "0.23"].publisher
  
  // 2
  strings
    .compactMap { Float($0) }
    .sink(receiveValue: {
      // 3
      print($0)
    })
    .store(in: &subscriptions)
}

example(of: "ignoreOutput") {
  // 1
  let numbers = (1...10_000).publisher
  
  // 2
  numbers
    .ignoreOutput()
    .sink(receiveCompletion: { print("Completed with: \($0)") },
          receiveValue: { print($0) })
    .store(in: &subscriptions)
}

// MARK: - Finding values

example(of: "first(where:)") {
  // 1
  let numbers = (1...9).publisher
  
  // 2
  numbers
    .print("numbers")
    .first(where: { $0 % 2 == 0 })
    .sink(receiveCompletion: { print("Completed with: \($0)") },
          receiveValue: { print($0) })
    .store(in: &subscriptions)
}

example(of: "last(where:)") {
  let numbers = PassthroughSubject<Int, Never>()
  
  numbers
    .last(where: { $0 % 2 == 0 })
    .sink(receiveCompletion: { print("Completed with: \($0)") },
          receiveValue: { print($0) })
    .store(in: &subscriptions)
  
  numbers.send(1)
  numbers.send(2)
  numbers.send(3)
  numbers.send(4)
  numbers.send(5)
  numbers.send(completion: .finished)
}

// MARK: - Dropping values

example(of: "dropFirst") {
  // 1
  let numbers = (1...10).publisher
  
  // 2
  numbers
    .dropFirst(8)
    .sink(receiveValue: { print($0) })
    .store(in: &subscriptions)
}

example(of: "drop(while:)") {
  // 1
  let numbers = (1...10).publisher
  
  // 2
  numbers
    .drop(while: {
      print("x")
      return $0 % 5 != 0
    })
    .sink(receiveValue: { print($0) })
    .store(in: &subscriptions)
}

example(of: "drop(untilOutputFrom:)") {
  // 1
  let isReady = PassthroughSubject<Void, Never>()
  let taps = PassthroughSubject<Int, Never>()
  
  // 2
  taps
    .drop(untilOutputFrom: isReady)
    .sink(receiveValue: { print($0) })
    .store(in: &subscriptions)
  
  // 3
  (1...5).forEach { n in
    taps.send(n)
    
    if n == 3 {
      isReady.send()
    }
  }
}

// MARK: - Limiting values

example(of: "prefix") {
  // 1
  let numbers = (1...10).publisher
  
  // 2
  numbers
    .prefix(2)
    .sink(receiveCompletion: { print("Completed with: \($0)") },
          receiveValue: { print($0) })
    .store(in: &subscriptions)
}

example(of: "prefix(while:)") {
  // 1
  let numbers = (1...10).publisher
  
  // 2
  numbers
    .prefix(while: { $0 < 3 })
    .sink(receiveCompletion: { print("Completed with: \($0)") },
          receiveValue: { print($0) })
    .store(in: &subscriptions)
}

example(of: "prefix(untilOutputFrom:)") {
  // 1
  let isReady = PassthroughSubject<Void, Never>()
  let taps = PassthroughSubject<Int, Never>()
  
  // 2
  taps
    .prefix(untilOutputFrom: isReady)
    .sink(receiveCompletion: { print("Completed with: \($0)") },
          receiveValue: { print($0) })
    .store(in: &subscriptions)
  
  // 3
  (1...5).forEach { n in
    taps.send(n)
    
    if n == 2 {
      isReady.send()
    }
  }
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
