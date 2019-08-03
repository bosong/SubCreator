//
//  CollectCacher.swift
//  SubCreator
//
//  Created by rpple_k on 2019/8/3.
//  Copyright © 2019 ripple_k. All rights reserved.
//

import Foundation

public class CollectCacher {
    public static let creationCacherUrl = URL(fileURLWithPath: NSHomeDirectory() + "/Library/Caches/Collect")
    
    var path: String {
        return CreationCacher.creationCacherUrl.path
    }
    
    /// shared
    public static let shared = CollectCacher()
    
    /// Cacher
    private lazy var _cacher = Cacher(destination: .custom(path))
    
    /// loadImageWrappers
    ///
    /// - Returns: ImageWrapper
    func loads() -> [HomeItem] {
        
        var result: [HomeItem] = []
        for file in _cacher.findFiles(path: path) {
            if let model: HomeItem = _cacher.load(fileName: file) {
                result.append(model)
            }
        }
        return result
    }
    
    /// addImageWrapper
    ///
    /// - Parameter draft: ImageWrapper
    func add(_ model: HomeItem) {
        _cacher.persist(item: model) { (_, error) in
            if let error = error {
                log.error(error.localizedDescription)
            }
        }
    }
    
    /// removeImageWrapper
    ///
    /// - Parameter draft: ImageWrapper
    func remove(_ model: HomeItem) {
        _cacher.remove(fileName: model.fileName)
    }
    
    /// clearImageWrapper
    func clearImageWrappers() {
        for draftFile in _cacher.findFiles(path: path) {
            _cacher.remove(fileName: draftFile)
        }
    }
}
