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

import SwiftUI

extension Color {
  static func normalized(hex: String) -> String? {
    var normalizedHex = hex
    
    if hex.hasPrefix("#") == false {
      normalizedHex.insert("#", at: normalizedHex.startIndex)
    }
    
    guard normalizedHex.count > 6, normalizedHex.count < 10 else { return nil }
    return normalizedHex.padding(toLength: 9, withPad: "F", startingAt: 0)
  }
  
  static func opacityString(forHex hex: String) -> String {
    guard let opacity = redGreenBlueOpacity(forHex: hex)?.3 else { return "" }
    return "\(Int(opacity * 100))%"
  }
  
  static func redGreenBlueOpacity(forHex hex: String)
    -> (Double, Double, Double, Double)? {
    guard let adjustedHex = normalized(hex: hex) else { return nil }
    
    let red, green, blue, opacity: Double
    let start = adjustedHex.index(adjustedHex.startIndex, offsetBy: 1)
    let hexString = String(adjustedHex[start...])
    let scanner = Scanner(string: hexString)
    var hexNumber: UInt64 = 0
    
    guard scanner.scanHexInt64(&hexNumber) else { return nil }
    
    red = Double((hexNumber & 0xff000000) >> 24) / 255
    green = Double((hexNumber & 0x00ff0000) >> 16) / 255
    blue = Double((hexNumber & 0x0000ff00) >> 8) / 255
    opacity = Double(hexNumber & 0x000000ff) / 255
    
    return (red, green, blue, opacity)
  }
  
  init?(hex: String) {
    guard let adjustedHex = Color.normalized(hex: hex),
      let (red, green, blue, opacity) = Color.redGreenBlueOpacity(forHex: adjustedHex)
      else { return nil }
    
    self.init(.displayP3, red: red, green: green, blue: blue, opacity: opacity)
  }
  
  init(values: (red: Double, green: Double, blue: Double, opacity: Double)) {
    self.init(
      .displayP3,
      red: values.red,
      green: values.green,
      blue: values.blue,
      opacity: values.opacity
    )
  }
}
