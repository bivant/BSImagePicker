// The MIT License (MIT)
//
// Copyright (c) 2019 Joakim Gyllström
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
import Photos

/// Closure convenience API.
/// Keep this simple enough for most users. More niche features can be added to ImagePickerControllerDelegate.
@objc extension UIViewController {
    
    /// Present a image picker
    ///
    /// - Parameters:
    ///   - imagePicker: The image picker to present
    ///   - animated: Should presentation be animated
    ///   - select: Selection callback
    ///   - deselect: Deselection callback
    ///   - cancel: Cancel callback
    ///   - finish: Finish callback
    ///   - completion: Presentation completion callback
    public func presentImagePicker(_ imagePicker: ImagePickerController, animated: Bool = true, select: ((_ asset: PHAsset) -> Void)?, deselect: ((_ asset: PHAsset) -> Void)?, cancel: (([PHAsset]) -> Void)?, finish: (([PHAsset]) -> Void)?, completion: (() -> Void)? = nil) {
		let presentClosure = { (accessLevel: PHAuthorizationStatus) in
			// Set closures
			imagePicker.onSelection = select
			imagePicker.onDeselection = deselect
			imagePicker.onCancel = cancel
			imagePicker.onFinish = finish
			
			// And since we are using the blocks api. Set ourselfs as delegate
			imagePicker.imagePickerDelegate = imagePicker
			var haveAccess: Bool
			if #available(iOS 14, *) {
				haveAccess = accessLevel == .authorized || accessLevel == .limited
			} else {
				haveAccess = accessLevel == .authorized
			}
			if haveAccess  {
				imagePicker.updateSettingsOnAccessGranted?()
			}
			
			// Present
			self.present(imagePicker, animated: animated, completion: completion)
		}
		if #available(iOS 14, *) {
			let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
			if imagePicker.settings.permission.enabled && status != .notDetermined {
				DispatchQueue.main.async {
					presentClosure(status)
				}
				return
			}
			switch status {
			case .authorized:
				presentClosure(status)
			case .limited:
				if imagePicker.settings.permission.enabled {
					presentClosure(status)
					return
				}
				fallthrough
			case .notDetermined:
				PHPhotoLibrary.requestAuthorization(for: .readWrite) { (newStatus) in
					switch newStatus {
					case .authorized, .limited:
						DispatchQueue.main.async { presentClosure(status) }
					default:
						break
					}
				}
			default:
				break
			}
		} else {
			authorize { status in
				presentClosure(status)
			}
		}
    }

	private func authorize(_ authorized: @escaping (_: PHAuthorizationStatus) -> Void) {
        PHPhotoLibrary.requestAuthorization { (status) in
            switch status {
            case .authorized:
				DispatchQueue.main.async { authorized(status) }
            default:
                break
            }
        }
    }
}

extension ImagePickerController {
    public static var currentAuthorization : PHAuthorizationStatus {
        return PHPhotoLibrary.authorizationStatus()
    }
}

/// ImagePickerControllerDelegate closure wrapper
extension ImagePickerController: ImagePickerControllerDelegate {
    public func imagePicker(_ imagePicker: ImagePickerController, didSelectAsset asset: PHAsset) {
        onSelection?(asset)
    }

    public func imagePicker(_ imagePicker: ImagePickerController, didDeselectAsset asset: PHAsset) {
        onDeselection?(asset)
    }

    public func imagePicker(_ imagePicker: ImagePickerController, didFinishWithAssets assets: [PHAsset]) {
        onFinish?(assets)
    }

    public func imagePicker(_ imagePicker: ImagePickerController, didCancelWithAssets assets: [PHAsset]) {
        onCancel?(assets)
    }

    public func imagePicker(_ imagePicker: ImagePickerController, didReachSelectionLimit count: Int) {
        
    }
}
