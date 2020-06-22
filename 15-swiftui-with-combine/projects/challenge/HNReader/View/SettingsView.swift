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

fileprivate struct SettingsBarItems: View {
  let add: () -> Void
  var body: some View {
    HStack(spacing: 20) {
      Button(action: add) {
        Image(systemName: "plus")
      }
      EditButton()
    }
  }
}

/// A settings view showing a list of filter keywrods.
struct SettingsView: View {
  @EnvironmentObject var settings: Settings
  @State var presentingAddKeywordSheet = false
  
  var body: some View {
    NavigationView {
      List {
        Section(header: Text("Filter keywords")) {
          ForEach(settings.keywords) { keyword in
            HStack(alignment: .top) {
              Image(systemName: "star")
                .resizable()
                .frame(width: 24, height: 24)
                .scaleEffect(0.67)
                .background(Color.yellow)
                .cornerRadius(5)
              Text(keyword.value)
            }
          }
          .onMove(perform: moveKeyword)
          .onDelete(perform: deleteKeyword)
        }
      }
      .sheet(isPresented: $presentingAddKeywordSheet) {
        AddKeywordView(completed: { newKeyword in
          let new = FilterKeyword(value: newKeyword.lowercased())
          self.settings.keywords.append(new)
          self.presentingAddKeywordSheet = false
        })
        .frame(minHeight: 0, maxHeight: 400, alignment: .center)
      }
      .navigationBarTitle(Text("Settings"))
      .navigationBarItems(trailing: SettingsBarItems(add: addKeyword))
    }
  }
  
  private func addKeyword() {
    presentingAddKeywordSheet = true
  }
  
  private func moveKeyword(from source: IndexSet, to destination: Int) {
    guard let source = source.first,
          destination != settings.keywords.endIndex else { return }

    settings.keywords
      .swapAt(source,
              source > destination ? destination : destination - 1)
  }
  
  private func deleteKeyword(at index: IndexSet) {
    settings.keywords.remove(at: index.first!)
  }
}

#if DEBUG
struct SettingsView_Previews: PreviewProvider {
  static var previews: some View {
    SettingsView()
  }
}
#endif

