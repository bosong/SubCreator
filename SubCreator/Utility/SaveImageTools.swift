//
//  SaveImageTools.swift
//  BGIM
//
//  Created by xiao5 on 2019/4/22.
//  Copyright © 2019 sks. All rights reserved.
//

import Foundation
import PhotosUI

class SaveImageTools {
    private var assetCollection: PHAssetCollection!
    private var albumFound: Bool = false
    private var collection: PHAssetCollection!
    private var assetColPlaceholder: PHObjectPlaceholder!
    static var albumName = "SubCreator"
    private var image: UIImage!

    static let shared = SaveImageTools()
    
    private init() { }

    func creatAlbum(completed: ((_ error: Error?) -> Void)?) {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate.init(format: "title = %@", type(of: self).albumName)
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        if collection.firstObject != nil {
            self.albumFound = true
            assetCollection = collection.firstObject
            self.saveImage(completed: completed)
        } else {
            PHPhotoLibrary.shared().performChanges({
                let creatAlbumRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: type(of: self).albumName)
                self.assetColPlaceholder = creatAlbumRequest.placeholderForCreatedAssetCollection
            }) { (result, error) in
                if result {
                    self.albumFound = result
                    let collResult = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [self.assetColPlaceholder.localIdentifier], options: nil)
                    self.assetCollection = collResult.firstObject
                    self.saveImage(completed: completed)
                } else {
                    completed?(error)
                }
            }
        }
    }

    private func saveImage(completed: ((_ error: Error?) -> Void)?) {
        PHPhotoLibrary.shared().performChanges({
            let assetRequest = PHAssetChangeRequest.creationRequestForAsset(from: self.image)
            let assetPlaceholder = assetRequest.placeholderForCreatedAsset
            let albumChangeRequest = PHAssetCollectionChangeRequest.init(for: self.assetCollection)
            albumChangeRequest?.addAssets([assetPlaceholder!] as NSArray)

        }) { (_, error) in
            completed?(error)
        }
    }

    func saveImage(_ image: UIImage, completed: ((_ error: Error?) -> Void)?) {
        self.image = image
        if Permission.photos.status == .authorized {
            creatAlbum(completed: completed)
        } else if Permission.photos.status == .notDetermined {
            Permission.photos.request { [weak self] (status) in
                if case .authorized = status {
                    self?.creatAlbum(completed: completed)
                }
            }
        } else {
            self.showAlertView(title: "没有开启相册授权", message: "打开设置允许使用相册")
        }
    }

    //该相册内最新一张图片asset
    func getTheCollectFistAsset() -> PHAsset? {
        let options = PHFetchOptions()
        if #available(iOS 9.0, *) {
            options.includeAssetSourceTypes = [.typeUserLibrary]
        }

        let results = PHAsset.fetchAssets(in: self.assetCollection, options: options)
        let asset = results.lastObject

        return asset
    }

    private func showAlertView(title: String, message: String) {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let setting = UIAlertAction(title: "设置", style: .default) { (action) in
            guard let url = URL(string: UIApplication.openSettingsURLString) else {return}

            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }

        alertController.addAction(setting)
        alertController.addAction(cancel)
        UIApplication.shared.presentViewController(alertController, animated: true, completion: nil)
    }
}
