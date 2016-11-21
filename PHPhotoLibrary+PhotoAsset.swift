//
//  PHPhotoLibrary+PhotoAsset.swift
//
//
//  https://github.com/kv2/PHPhotoLibrary-PhotoAsset.swift
//

import Foundation
import Photos

public extension PHPhotoLibrary {
    
    
    typealias PhotoAsset = PHAsset
    typealias PhotoAlbum = PHAssetCollection
    
    static func saveImage(imageUrl: URL, albumName: String, completion: @escaping (PHAsset?)->()) {
        if let album = self.findAlbum(albumName: albumName) {
            saveImage(imageUrl: imageUrl, album: album, completion: completion)
            return
        }
        createAlbum(albumName: albumName) { album in
            if let album = album {
                self.saveImage(imageUrl: imageUrl, album: album, completion: completion)
            }
            else {
                assert(false, "Album is nil")
            }
        }
    }
    
    static func saveVideo(videoUrl: URL, albumName: String, completion: @escaping (PHAsset?)->()) {
        if let album = self.findAlbum(albumName: albumName) {
            saveVideo(videoUrl: videoUrl, album: album, completion: completion)
            return
        }
        createAlbum(albumName: albumName) { album in
            if let album = album {
                self.saveVideo(videoUrl: videoUrl, album: album, completion: completion)
            }
            else {
                assert(false, "Album is nil")
            }
        }
    }
    
    static private func saveImage(imageUrl: URL, album: PhotoAlbum, completion: @escaping (PHAsset?)->()) {
        var placeholder: PHObjectPlaceholder?
        PHPhotoLibrary.shared().performChanges({
            // Request creating an asset from the image
            guard let createAssetRequest = PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: imageUrl) else {
                assert(false, "Error with image url")
                return
            }
            // Request editing the album
            guard let albumChangeRequest = PHAssetCollectionChangeRequest(for: album) else {
                assert(false, "Album change request failed")
                return
            }
            // Get a placeholder for the new asset and add it to the album editing request
            guard let photoPlaceholder = createAssetRequest.placeholderForCreatedAsset else {
                assert(false, "Placeholder is nil")
                return
            }
            placeholder = photoPlaceholder
            let fastEnumeration = NSArray(array: [placeholder!] as [PHObjectPlaceholder])
            albumChangeRequest.addAssets(fastEnumeration)
        }, completionHandler: { success, error in
            guard let placeholder = placeholder else {
                assert(false, "Placeholder is nil")
                completion(nil)
                return
            }
            
            if success {
                completion(PHAsset.ah_fetchAssetWithLocalIdentifier(identifier: placeholder.localIdentifier, options:nil))
            }
            else {
                print(error)
                completion(nil)
            }
        })
    }
    
    static private func saveVideo(videoUrl: URL, album: PhotoAlbum, completion: @escaping (PHAsset?)->()) {
        
        var placeholder: PHObjectPlaceholder?
        
        PHPhotoLibrary.shared().performChanges({
            
            // Request creating an asset from the image
            let createAssetRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoUrl)
            // Request editing the album
            guard let albumChangeRequest = PHAssetCollectionChangeRequest(for: album) else {
                assert(false, "Album change request failed")
                return
            }
            
            // Get a placeholder for the new asset and add it to the album editing request
            guard let videoPlaceholder = createAssetRequest!.placeholderForCreatedAsset else {
                assert(false, "Placeholder is nil")
                return
            }
            
            placeholder = videoPlaceholder
            let fastEnumeration = NSArray(array: [videoPlaceholder] as [PHObjectPlaceholder])
            albumChangeRequest.addAssets(fastEnumeration)
        }, completionHandler: { success, error in
            guard let placeholder = placeholder else {
                assert(false, "Placeholder is nil")
                completion(nil)
                return
            }
            
            if success {
                completion(PHAsset.ah_fetchAssetWithLocalIdentifier(identifier: placeholder.localIdentifier, options:nil))
            }
            else {
                print(error)
                completion(nil)
            }
        })
        
        
    }
    
    
    static func findAlbum(albumName: String) -> PhotoAlbum? {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        let fetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: fetchOptions)
        guard let photoAlbum = fetchResult.firstObject else {
            return nil
        }
        return photoAlbum
    }
    
    static func createAlbum(albumName: String, completion: @escaping (PhotoAlbum?)->()) {
        var albumPlaceholder: PHObjectPlaceholder?
        PHPhotoLibrary.shared().performChanges({
            // Request creating an album with parameter name
            let createAlbumRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName)
            // Get a placeholder for the new album
            albumPlaceholder = createAlbumRequest.placeholderForCreatedAssetCollection
        }, completionHandler: { success, error in
            guard let placeholder = albumPlaceholder else {
                assert(false, "Album placeholder is nil")
                completion(nil)
                return
            }
            
            let fetchResult = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [placeholder.localIdentifier], options: nil)
            guard let album = fetchResult.firstObject else {
                assert(false, "FetchResult has no PHAssetCollection")
                completion(nil)
                return
            }
            
            if success {
                completion(album)
            }
            else {
                print(error)
                completion(nil)
            }
        })
    }
    
    static func loadThumbnailFromLocalIdentifier(localIdentifier: String, completion: @escaping (UIImage?)->()) {
        guard let asset = PHAsset.ah_fetchAssetWithLocalIdentifier(identifier: localIdentifier, options:nil) else {
            completion(nil)
            return
        }
        loadThumbnailFromAsset(asset: asset, completion: completion)
    }
    
    static func loadThumbnailFromAsset(asset: PhotoAsset, completion: @escaping (UIImage?)->()) {
        PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: 100.0, height: 100.0), contentMode: .aspectFit, options: PHImageRequestOptions(), resultHandler: { result, info in
            completion(result)
        })
    }
    
}