import Combine
import Foundation

// sample data!
let samples: [(TimeInterval, Int)] = [
  (0.05, 67), (0.10, 111), (0.15, 109), (0.20, 98), (0.25, 105), (0.30, 110), (0.35, 101),
  (1.50, 105), (1.55, 115),
  (2.60, 99), (2.65, 111), (2.70, 111), (2.75, 108), (2.80, 33)
]

public func startFeeding<S>(subject: S) where S: Subject, S.Output == Int {
  var lastDelay: TimeInterval = 0
  for entry in samples {
    lastDelay = entry.0
    DispatchQueue.main.asyncAfter(deadline: .now() + entry.0) {
      subject.send(entry.1)
    }
  }
  DispatchQueue.main.asyncAfter(deadline: .now() + lastDelay + 0.5) {
    subject.send(completion: .finished)
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
