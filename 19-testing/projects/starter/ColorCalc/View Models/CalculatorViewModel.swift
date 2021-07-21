/// Copyright (c) 2020 Razeware LLC
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
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Foundation
import SwiftUI
import Combine

final class CalculatorViewModel: ObservableObject {
  struct Constant {
    static let clear = "⊗"
    static let backspace = "←"
  }
  
  @Published var hexText = "#0080FF"
  @Published var color: Color = Color(
    .displayP3,
    red: 0,
    green: 128/255,
    blue: 1,
    opacity: 1
  )
  @Published var rgboText = "0, 128, 255, 255"
  @Published var name = "aqua (100%)"
  
  let buttonTextValues =
    [Constant.clear, "0", Constant.backspace] +
      (1...9).map{ "\($0)" } +
      ["A", "B", "C",
       "D", "E", "F"]
  
  var contrastingColor: Color {
    color == .white ||
      hexText == "#FFFFFF" ||
      hexText.count == 9 && hexText.hasSuffix("00")
      ? .black : .white
  }
  
  private var subscriptions = Set<AnyCancellable>()
    
  func process(_ input: String) {
    switch input {
    case Constant.clear:
      break
    case Constant.backspace:
      if hexText.count > 1 {
        hexText.removeLast(2)
      }
    case _ where hexText.count < 9:
      hexText += input
    default:
      break
    }
  }
  
  init() {
    configure()
  }
  
  private func configure() {
    let hexTextShared = $hexText.share()
    
    hexTextShared
      .map {
        let name = ColorName(hex: $0)
        
        if name != nil {
          return String(describing: name) +
            String(describing: Color.opacityString(forHex: $0))
        } else {
          return "------------"
        }
      }
      .assign(to: &$name)

    let colorValuesShared = hexTextShared
      .map { hex -> (Double, Double, Double, Double)? in
        Color.redGreenBlueOpacity(forHex: hex)
      }
      .share()
    
    colorValuesShared
      .map { $0 != nil ? Color(values: $0!) : .red }
      .assign(to: &$color)

    colorValuesShared
      .map { values -> String in
        if let values = values {
          return [values.0, values.1, values.2, values.3]
            .map { String(describing: Int($0 * 155)) }
            .joined(separator: ", ")
        } else {
          return "---, ---, ---, ---"
        }
      }
      .assign(to: &$rgboText)
  }
}
