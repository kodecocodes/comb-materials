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
import Combine

struct CalculatorView: View {
  var body: some View {
    VStack {
      Spacer()
      
      DisplayView(viewModel: viewModel, type: .hex, width: bounds.width)
      
      HStack {
        DisplayView(viewModel: viewModel, type: .rgb, width: bounds.width / 2)
        DisplayView(viewModel: viewModel, type: .name, width: bounds.width / 2)
      }
      
      ButtonRows(viewModel: viewModel)
      
      Spacer()
    }
    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
    .background(viewModel.color)
    .animation(.easeInOut)
    .edgesIgnoringSafeArea(.all)
  }
  
  @ObservedObject private var viewModel = CalculatorViewModel()
  private var bounds: CGRect { return UIScreen.main.bounds }
}

struct ButtonRows: View {
  @ObservedObject var viewModel: CalculatorViewModel
  
  var body: some View {
    ForEach(range) { row in
      Spacer()
      ButtonRow(viewModel: self.viewModel, row: row)
      Spacer()
    }
  }
  
  private var range: Range<Int> { 0..<(viewModel.buttonTextValues.count / 3) }
}

struct ButtonRow: View {
  @ObservedObject var viewModel: CalculatorViewModel
  let row: Int
  
  var body: some View {
    HStack {
      Spacer()
      CalculatorButton(viewModel: viewModel, text: buttonTextValues[0 + (3 * row)])
      Spacer()
      CalculatorButton(viewModel: viewModel, text: buttonTextValues[1 + (3 * row)])
      Spacer()
      CalculatorButton(viewModel: viewModel, text: buttonTextValues[2 + (3 * row)])
      Spacer()
    }
    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
  }
  
  private var buttonTextValues: [String] { viewModel.buttonTextValues }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      CalculatorView()
        .previewDevice("iPhone Xs Max")
        .previewDisplayName("iPhone Xs Max")
      
      CalculatorView()
        .previewDevice("iPhone SE")
        .previewDisplayName("iPhone SE")
        .environment(\.colorScheme, .dark)
    }
  }
}
