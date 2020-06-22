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

import UIKit
import Photos

class PhotosViewController: UICollectionViewController {
  
  // MARK: - Public properties
  
  
  // MARK: - Private properties
    
  private lazy var photos = PhotosViewController.loadPhotos()
  private lazy var imageManager = PHCachingImageManager()
  
  private lazy var thumbnailSize: CGSize = {
    let cellSize = (self.collectionViewLayout as! UICollectionViewFlowLayout).itemSize
    return CGSize(width: cellSize.width * UIScreen.main.scale,
                  height: cellSize.height * UIScreen.main.scale)
  }()
  
  // MARK: - View controller
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Check for Photos access authorization and reload the list if authorized.
    PHPhotoLibrary.fetchAuthorizationStatus { [weak self] status in
      if status {
        self?.photos = PhotosViewController.loadPhotos()
        
        DispatchQueue.main.async {
          self?.collectionView.reloadData()
        }
      }
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
  }
    
  // MARK: - UICollectionViewDataSource
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return photos.count
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let asset = photos.object(at: indexPath.item)
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PhotoCell

    cell.representedAssetIdentifier = asset.localIdentifier
    imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
      if cell.representedAssetIdentifier == asset.localIdentifier {
        cell.preview?.image = image
      }
    })
    
    return cell
  }
  
  // MARK: - UICollectionViewDelegate
  
  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let asset = photos.object(at: indexPath.item)
    
    if let cell = collectionView.cellForItem(at: indexPath) as? PhotoCell {
      cell.flash()
    }
    
    imageManager.requestImage(for: asset, targetSize: view.frame.size, contentMode: .aspectFill, options: nil, resultHandler: { [weak self] image, info in
      guard let self = self,
        let image = image,
        let info = info
        else { return }
      
      if let isThumbnail = info[PHImageResultIsDegradedKey as String] as? Bool, isThumbnail {
        // Skip the thumbnail version of the asset
        return
      }
      
      // Send the selected photo
      
    })
  }

}

// MARK: - Fetch assets
extension PhotosViewController {
  
  static func loadPhotos() -> PHFetchResult<PHAsset> {
    let allPhotosOptions = PHFetchOptions()
    allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
    return PHAsset.fetchAssets(with: allPhotosOptions)
  }
  
}
