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
import Combine

struct MainView: View {
  @EnvironmentObject var model: CollageNeueModel
  
  @State private var isDisplayingSavedMessage = false

  @State private var lastErrorMessage = "" {
    didSet {
      isDisplayingErrorMessage = true
    }
  }
  @State private var isDisplayingErrorMessage = false
  
  @State private var isDisplayingPhotoPicker = false

  @State private(set) var saveIsEnabled = true
  @State private(set) var clearIsEnabled = true
  @State private(set) var addIsEnabled = true
  @State private(set) var title = ""

  var body: some View {
    VStack {
      HStack {
        Text(title)
          .font(.title)
          .fontWeight(.bold)
        Spacer()
        
        Button(action: {
          model.add()
          isDisplayingPhotoPicker = true
        }, label: {
          Text("＋").font(.title)
        })
        .disabled(!addIsEnabled)
      }
      .padding(.bottom)
      .padding(.bottom)
      
      Image(uiImage: model.imagePreview ?? UIImage())
        .resizable()
        .frame(height: 200, alignment: .center)
        .border(Color.gray, width: 2)
      
      Button(action: model.clear, label: {
        Text("Clear")
          .fontWeight(.bold)
          .frame(maxWidth: .infinity)
      })
        .disabled(!clearIsEnabled)
        .buttonStyle(.bordered)
        .padding(.vertical)
      
      Button(action: model.save, label: {
        Text("Save")
          .fontWeight(.bold)
          .frame(maxWidth: .infinity)
      })
        .disabled(!saveIsEnabled)
        .buttonStyle(.borderedProminent)
      
    }
    .padding()
    .onChange(of: model.lastSavedPhotoID, perform: { lastSavedPhotoID in
      isDisplayingSavedMessage = true
    })
    .alert("Saved photo with id: \(model.lastSavedPhotoID)", isPresented: $isDisplayingSavedMessage, actions: { })
    .alert(lastErrorMessage, isPresented: $isDisplayingErrorMessage, actions: { })
    .sheet(isPresented: $isDisplayingPhotoPicker, onDismiss: {
      
    }) {
      PhotosView().environmentObject(model)
    }
    .onAppear(perform: model.bindMainView)
    .onReceive(model.updateUISubject, perform: updateUI)
  }
  
  func updateUI(photosCount: Int) {
    saveIsEnabled = photosCount > 0 && photosCount % 2 == 0
    clearIsEnabled = photosCount > 0
    addIsEnabled = photosCount < 6
    title = photosCount > 0 ? "\(photosCount) photos" : "Collage Neue"
  }
}
