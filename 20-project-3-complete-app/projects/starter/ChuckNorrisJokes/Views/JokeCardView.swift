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

import SwiftUI
import ChuckNorrisJokesModel

struct JokeCardView: View {
  
    
  var body: some View {
    ZStack {
      VStack(alignment: .leading, spacing: 20) {
        Text(ChuckNorrisJokesModel.Joke.starter.value)
          .font(.largeTitle)
          .foregroundColor(.primary)
          .minimumScaleFactor(0.2)
          .allowsTightening(true)
          .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
          .animation(.easeInOut)
        
        Button(action: {
          let url = URL(string: "http://translate.yandex.com")!
          UIApplication.shared.open(url)
        }) {
          Text("Translation Powered by Yandex.Translate")
            .font(.caption)
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
        }
        .opacity(0)
        
        LargeInlineButton(
          title: "Toggle Language",
          action: { }
        )
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
    JokeCardView()
      .previewLayout(.sizeThatFits)
  }
}
#endif
