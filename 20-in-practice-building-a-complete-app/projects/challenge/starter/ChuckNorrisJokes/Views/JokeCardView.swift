/// Copyright (c) 2023 Kodeco Inc.
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
import ChuckNorrisJokesModel

struct JokeCardView: View {
  @ObservedObject var viewModel: JokesViewModel
    
  var body: some View {
    ZStack {
      VStack(alignment: .leading, spacing: 20) {
        Text(viewModel.joke.value)
          .font(.largeTitle)
          .foregroundColor(.primary)
          .minimumScaleFactor(0.2)
          .allowsTightening(true)
          .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
          .animation(.easeInOut)
      }
      .frame(width: min(300, bounds.width * 0.7), height: min(400, bounds.height * 0.6))
      .padding(20)
      .cornerRadius(20)
    }
  }
  
  private var bounds: CGRect { UIScreen.main.bounds }
  
  private var repeatingAnimation: Animation {
    Animation.linear(duration: 1)
      .repeatForever()
  }
}

#if DEBUG
struct JokeCardView_Previews: PreviewProvider {
  static var previews: some View {
    JokeCardView(viewModel: JokesViewModel())
      .previewLayout(.sizeThatFits)
  }
}
#endif
