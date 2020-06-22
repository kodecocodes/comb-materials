import Foundation
import Combine

/// Sample data we use to feed a subject, simulating a user typing "Hello World"
public let typingHelloWorld: [(TimeInterval, String)] = [
  (0.0, "H"),
  (0.1, "He"),
  (0.2, "Hel"),
  (0.3, "Hell"),
  (0.5, "Hello"),
  (0.6, "Hello "),
  (2.0, "Hello W"),
  (2.1, "Hello Wo"),
  (2.2, "Hello Wor"),
  (2.4, "Hello Worl"),
  (2.5, "Hello World")
]

public extension Subject where Output == String {
  /// A function that can feed delayed values to a subject for testing and simulation purposes
  func feed(with data: [(TimeInterval, String)]) {
    var lastDelay: TimeInterval = 0
    for entry in data {
      lastDelay = entry.0
      DispatchQueue.main.asyncAfter(deadline: .now() + entry.0) { [unowned self] in
        self.send(entry.1)
      }
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + lastDelay + 1.5) { [unowned self] in
      self.send(completion: .finished)
    }
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

