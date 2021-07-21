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

enum ColorName: String {
  case aliceBlue = "F0F8FF"
  case antiqueWhite = "FAEBD7"
  case aqua = "0080FF"
  case aquamarine = "7FFFD4"
  case azure = "F0FFFF"
  case beige = "F5F5DC"
  case bisque = "FFE4C4"
  case black = "000000"
  case blanchedAlmond = "FFEBCD"
  case blue = "0000FF"
  case blueViolet = "8A2BE2"
  case brown = "A52A2A"
  case burlyWood = "DEB887"
  case cadetBlue = "5F9EA0"
  case cyan = "00FFFF"
  case chartreuse = "7FFF00"
  case chocolate = "D2691E"
  case coral = "FF7F50"
  case cornflowerBlue = "6495ED"
  case cornSilk = "FFF8DC"
  case crimson = "DC143C"
  case darkBlue = "00008B"
  case darkCyan = "008B8B"
  case darkGoldenRod = "B8860B"
  case darkGray = "A9A9A9"
  case darkGreen = "006400"
  case darkKhaki = "BDB76B"
  case darkMagenta = "8B008B"
  case darkOliveGreen = "556B2F"
  case darkOrange = "FF8C00"
  case darkOrchid = "9932CC"
  case darkRed = "8B0000"
  case darkSalmon = "E9967A"
  case darkSeaGreen = "8FBC8F"
  case darkSlateBlue = "483D8B"
  case darkSlateGray = "2F4F4F"
  case darkTurquoise = "00CED1"
  case darkViolet = "9400D3"
  case deepPink = "FF1493"
  case deepSkyBlue = "00BFFF"
  case dimGray = "696969"
  case dodgerBlue = "1E90FF"
  case fireBrick = "B22222"
  case floralWhite = "FFFAF0"
  case forestGreen = "228B22"
  case fuchsia_magenta = "FF00FF"
  case gainsboro = "DCDCDC"
  case ghostWhite = "F8F8FF"
  case gold = "FFD700"
  case goldenRod = "DAA520"
  case gray = "808080"
  case green = "008000"
  case greenYellow = "ADFF2F"
  case honeyDew = "F0FFF0"
  case hotPink = "FF69B4"
  case indianRed = "CD5C5C"
  case indigo = "4B0082"
  case ivory = "FFFFF0"
  case khaki = "F0E68C"
  case lavender = "E6E6FA"
  case lavenderBlush = "FFF0F5"
  case lawnGreen = "7CFC00"
  case lemonChiffon = "FFFACD"
  case lightBlue = "ADD8E6"
  case lightCoral = "F08080"
  case lightCyan = "E0FFFF"
  case lightGoldenRodYellow = "FAFAD2"
  case lightGray = "D3D3D3"
  case lightGreen = "90EE90"
  case lightPink = "FFB6C1"
  case lightSalmon = "FFA07A"
  case lightSeaGreen = "20B2AA"
  case lightSkyBlue = "87CEFA"
  case lightSlateGray = "778899"
  case lightSteelBlue = "B0C4DE"
  case lightYellow = "FFFFE0"
  case lime = "00FF00"
  case limeGreen = "32CD32"
  case linen = "FAF0E6"
  case maroon = "800000"
  case mediumAquamarine = "66CDAA"
  case mediumBlue = "0000CD"
  case mediumOrchid = "BA55D3"
  case mediumPurple = "9370D8"
  case mediumSeaGreen = "3CB371"
  case mediumSlateBlue = "7B68EE"
  case mediumSpringGreen = "00FA9A"
  case mediumTurquoise = "48D1CC"
  case mediumVioletRed = "C71585"
  case midnightBlue = "191970"
  case mintCream = "F5FFFA"
  case mistyRose = "FFE4E1"
  case moccasin = "FFE4B5"
  case navajoWhite = "FFDEAD"
  case navy = "000080"
  case oldLace = "FDF5E6"
  case olive = "808000"
  case oliveDrab = "6B8E23"
  case orange = "FFA500"
  case orangeRed = "FF4500"
  case orchid = "DA70D6"
  case paleGoldenRod = "EEE8AA"
  case paleGreen = "98FB98"
  case paleTurquoise = "AFEEEE"
  case paleVioletRed = "D87093"
  case papayaWhip = "FFEFD5"
  case peachPuff = "FFDAB9"
  case peru = "CD853F"
  case pink = "FFC0CB"
  case plum = "DDA0DD"
  case powderBlue = "B0E0E6"
  case purple = "800080"
  case rwGreen = "006636"
  case rebeccaPurple = "663399"
  case red = "FF0000"
  case rosyBrown = "BC8F8F"
  case royalBlue = "4169E1"
  case saddleBrown = "8B4513"
  case salmon = "FA8072"
  case sandyBrown = "F4A460"
  case seaGreen = "2E8B57"
  case seaShell = "FFF5EE"
  case sienna = "A0522D"
  case silver = "C0C0C0"
  case skyBlue = "87CEEB"
  case slateBlue = "6A5ACD"
  case slateGray = "708090"
  case snow = "FFFAFA"
  case springGreen = "00FF7F"
  case steelBlue = "4682B4"
  case tan = "D2B48C"
  case teal = "008080"
  case thistle = "D8BFD8"
  case tomato = "FF6347"
  case turquoise = "40E0D0"
  case violet = "EE82EE"
  case wheat = "F5DEB3"
  case white = "FFFFFF"
  case whiteSmoke = "F5F5F5"
  case yellow = "FFFF00"
  case yellowGreen = "9ACD32"
  
  init?(hex: String) {
    let adjustedHex = (hex.hasPrefix("#") ? String(hex.dropFirst()) : hex).prefix(6)
    self.init(rawValue: String(adjustedHex))
  }
}
