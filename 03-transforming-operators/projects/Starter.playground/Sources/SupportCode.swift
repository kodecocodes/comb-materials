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

public func example(of description: String,
                    action: () -> Void) {
  print("\n——— Example of:", description, "———")
  action()
}

public struct Coordinate {
  public let x: Int
  public let y: Int
  
  public init(x: Int, y: Int) {
    self.x = x
    self.y = y
  }
}

public func quadrantOf(x: Int, y: Int) -> String {
  var quadrant = ""
  
  switch (x, y) {
  case (1..., 1...):
    quadrant = "1"
  case (..<0, 1...):
    quadrant = "2"
  case (..<0, ..<0):
    quadrant = "3"
  case (1..., ..<0):
    quadrant = "4"
  default:
    quadrant = "boundary"
  }
  
  return quadrant
}

public struct Chatter {
  public let name: String
  public let message: CurrentValueSubject<String, Never>
  
  public init(name: String, message: String) {
    self.name = name
    self.message = CurrentValueSubject(message)
  }
}
