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
import UIKit

extension UIImage {

  static func collage(images: [UIImage], size: CGSize) -> UIImage {
    let rows = images.count < 3 ? 1 : 2
    let columns = Int(round(Double(images.count) / Double(rows)))
    let tileSize = CGSize(width: round(size.width / CGFloat(columns)),
                          height: round(size.height / CGFloat(rows)))

    UIGraphicsBeginImageContextWithOptions(size, true, 0)
    UIColor.white.setFill()
    UIRectFill(CGRect(origin: .zero, size: size))

    for (index, image) in images.enumerated() {
      image.scaled(tileSize).draw(at: CGPoint(
        x: CGFloat(index % columns) * tileSize.width,
        y: CGFloat(index / columns) * tileSize.height
      ))
    }

    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image ?? UIImage()
  }

  func scaled(_ newSize: CGSize) -> UIImage {
    guard size != newSize else {
      return self
    }

    let ratio = max(newSize.width / size.width, newSize.height / size.height)
    let width = size.width * ratio
    let height = size.height * ratio

    let scaledRect = CGRect(
      x: (newSize.width - width) / 2.0,
      y: (newSize.height - height) / 2.0,
      width: width, height: height)

    UIGraphicsBeginImageContextWithOptions(scaledRect.size, false, 0.0);
    defer { UIGraphicsEndImageContext() }

    draw(in: scaledRect)

    return UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
  }
}
