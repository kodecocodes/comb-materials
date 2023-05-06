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
import Photos
import Combine

struct PhotosView: View {
  @EnvironmentObject var model: CollageNeueModel
  @Environment(\.presentationMode) var presentationMode
  
  let columns: [GridItem] = [.init(.adaptive(minimum: 100, maximum: 200))]
  
  @State private var subscriptions = [AnyCancellable]()
  
  @State private var photos = PHFetchResult<PHAsset>()
  @State private var imageManager = PHCachingImageManager()
  @State private var isDisplayingError = false

  var body: some View {
    NavigationView {
      ScrollView {
        LazyVGrid(columns: columns, spacing: 2) {
          ForEach((0..<photos.count), id: \.self) { index in
            let asset = photos[index]
            let _ = model.enqueueThumbnail(asset: asset)
            
            Button(action: {
              model.selectImage(asset: asset)
            }, label: {
              Image(uiImage: model.thumbnails[asset.localIdentifier] ?? UIImage(named: "IMG_1907")!)
                .resizable()
                .aspectRatio(1, contentMode: .fill)
                .clipShape(
                  RoundedRectangle(cornerRadius: 5)
                )
                .padding(4)
            })
          }
        }
        .padding()
      }
      .navigationTitle("Photos")
      .toolbar {
        Button("Close", role: .cancel) {
          self.presentationMode.wrappedValue.dismiss()
        }
      }
    }
    .alert("No access to Camera Roll", isPresented: $isDisplayingError, actions: { }, message: {
      Text("You can grant access to Collage Neue from the Settings app")
    })
    .onAppear {
      // Check for Photos access authorization and reload the list if authorized.
      PHPhotoLibrary.fetchAuthorizationStatus { status in
        if status {
          DispatchQueue.main.async {
            self.photos = model.loadPhotos()
          }
        }
      }
      
      model.bindPhotoPicker()
    }
    .onDisappear {
      model.selectedPhotosSubject.send(completion: .finished)
    }
  }
}
