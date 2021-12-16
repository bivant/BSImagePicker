// The MIT License (MIT)
//
// Copyright (c) 2015 Joakim Gyllström
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import UIKit
import BSImagePicker
import Photos

class ViewController: UIViewController {
    
    @IBAction func showImagePicker(_ sender: UIButton) {
        let imagePicker = ImagePickerController()
        imagePicker.settings.selection.max = 5
        imagePicker.settings.theme.selectionStyle = .numbered
        imagePicker.settings.fetch.assets.supportedMediaTypes = [.image, .video]
        imagePicker.settings.selection.unselectOnReachingMax = true

        let start = Date()
        self.presentImagePicker(imagePicker, select: { (asset) in
            print("Selected: \(asset)")
        }, deselect: { (asset) in
            print("Deselected: \(asset)")
        }, cancel: { (assets) in
            print("Canceled with selections: \(assets)")
        }, finish: { (assets) in
            print("Finished with selections: \(assets)")
        }, completion: {
            let finish = Date()
            print(finish.timeIntervalSince(start))
        })
    }

    private var lastSelectedAlbum: String?
    @IBAction func showImagePickerWithAlbums(_ sender: UIButton) {
        let imagePicker = ImagePickerController()
        imagePicker.settings.selection.max = 3
        imagePicker.settings.theme.selectionStyle = .checked
        imagePicker.settings.fetch.assets.supportedMediaTypes = [.image, .video]
        imagePicker.settings.selection.unselectOnReachingMax = false
		imagePicker.settings.permission.enabled = true

        imagePicker.selectedAlbumIdentifier = lastSelectedAlbum
        //Show the "Recent" album and all other ones available
        let options = imagePicker.settings.fetch.album.options
        imagePicker.settings.fetch.album.fetchResults = [
            PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: options),
            PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: options),
        ]

        let start = Date()
        self.presentImagePicker(imagePicker, select: { (asset) in
            print("Selected: \(asset)")
        }, deselect: { (asset) in
            print("Deselected: \(asset)")
        }, cancel: { [weak self] (assets) in
            self?.lastSelectedAlbum = imagePicker.selectedAlbumIdentifier
            print("Canceled with selections: \(assets)")
        }, finish: { [weak self] (assets) in
            self?.lastSelectedAlbum = imagePicker.selectedAlbumIdentifier
            print("Finished with selections: \(assets)")
        }, completion: {
            let finish = Date()
            print(finish.timeIntervalSince(start))
        })
    }
    
    @IBAction func showCustomImagePicker(_ sender: UIButton) {
        let imagePicker = ImagePickerController()
        imagePicker.settings.selection.max = 1
        imagePicker.settings.selection.unselectOnReachingMax = true
        imagePicker.settings.fetch.assets.supportedMediaTypes = [.image, .video]
        imagePicker.albumButton.tintColor = UIColor.green
        imagePicker.cancelButton.tintColor = UIColor.red
        imagePicker.doneButton.tintColor = UIColor.purple
        imagePicker.navigationBar.barTintColor = .black
        imagePicker.settings.theme.backgroundColor = .black
        imagePicker.settings.theme.selectionFillColor = UIColor.gray
        imagePicker.settings.theme.selectionStrokeColor = UIColor.yellow
        imagePicker.settings.theme.selectionShadowColor = UIColor.red
        imagePicker.settings.theme.previewTitleAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),NSAttributedString.Key.foregroundColor: UIColor.white]
        imagePicker.settings.theme.previewSubtitleAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12),NSAttributedString.Key.foregroundColor: UIColor.white]
        imagePicker.settings.theme.albumTitleAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18),NSAttributedString.Key.foregroundColor: UIColor.white]
        imagePicker.settings.list.cellsPerRow = {(verticalSize: UIUserInterfaceSizeClass, horizontalSize: UIUserInterfaceSizeClass) -> Int in
            switch (verticalSize, horizontalSize) {
            case (.compact, .regular): // iPhone5-6 portrait
                return 2
            case (.compact, .compact): // iPhone5-6 landscape
                return 2
            case (.regular, .regular): // iPad portrait/landscape
                return 3
            default:
                return 2
            }
        }
        
        self.presentImagePicker(imagePicker, select: { (asset) in
            print("Selected: \(asset)")
        }, deselect: { (asset) in
            print("Deselected: \(asset)")
        }, cancel: { (assets) in
            print("Canceled with selections: \(assets)")
        }, finish: { (assets) in
            print("Finished with selections: \(assets)")
        })
    }
    
    @IBAction func showImagePickerWithSelectedAssets(_ sender: UIButton) {
        let allAssets = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: nil)
        var evenAssets = [PHAsset]()
        
        allAssets.enumerateObjects({ (asset, idx, stop) -> Void in
            if idx % 2 == 0 {
                evenAssets.append(asset)
            }
        })
        
        let imagePicker = ImagePickerController(selectedAssets: evenAssets)
        imagePicker.settings.fetch.assets.supportedMediaTypes = [.image]
        
        self.presentImagePicker(imagePicker, select: { (asset) in
            print("Selected: \(asset)")
        }, deselect: { (asset) in
            print("Deselected: \(asset)")
        }, cancel: { (assets) in
            print("Canceled with selections: \(assets)")
        }, finish: { (assets) in
            print("Finished with selections: \(assets)")
        })
    }
    
    func showImagePickerWithPermissionHandling() {
        let imagePicker = ImagePickerController()
        imagePicker.settings.selection.max = 5
        imagePicker.settings.theme.selectionStyle = .numbered
        imagePicker.settings.fetch.assets.supportedMediaTypes = [.image, .video]
        imagePicker.settings.selection.unselectOnReachingMax = true
        imagePicker.settings.permission.enabled = true
        
        imagePicker.imagePickerDelegate = self
        self.present(imagePicker, animated: true, completion: nil)
    }
}


extension ViewController: ImagePickerControllerDelegate {
    func imagePicker(_ imagePicker: ImagePickerController, didSelectAsset asset: PHAsset) {
        print("Selected: \(asset)")
    }
    
    func imagePicker(_ imagePicker: ImagePickerController, didDeselectAsset asset: PHAsset) {
        print("Deselected: \(asset)")
    }
    
    func imagePicker(_ imagePicker: ImagePickerController, didFinishWithAssets assets: [PHAsset]) {
        print("Finished with selections: \(assets)")
    }
    
    func imagePicker(_ imagePicker: ImagePickerController, didCancelWithAssets assets: [PHAsset]) {
        print("Canceled with selections: \(assets)")
    }
    
    func imagePicker(_ imagePicker: ImagePickerController, didReachSelectionLimit count: Int) {
        
    }
}
