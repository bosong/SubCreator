//
//  CollectCacher.swift
//  SubCreator
//
//  Created by ripple_k on 2019/8/3.
//  Copyright © 2019 ripple_k. All rights reserved.
//

import Foundation

public class CollectMaterialsCacher {
    public static let creationCacherUrl = URL(fileURLWithPath: NSHomeDirectory() + "/Library/Caches/Collect/Materials")
    
    var path: String {
        return CollectMaterialsCacher.creationCacherUrl.path
    }
    
    /// shared
    public static let shared = CollectMaterialsCacher()
    
    /// Cacher
    private lazy var _cacher = Cacher(destination: .custom(path))
    
    /// loadImageWrappers
    ///
    /// - Returns: ImageWrapper
    func loads() -> [Materials] {
        
        var result: [Materials] = []
        for file in _cacher.findFiles(path: path) {
            if let model: Materials = _cacher.load(fileName: file) {
                result.append(model)
            }
        }
        return result
    }
    
    /// addImageWrapper
    ///
    /// - Parameter draft: ImageWrapper
    func add(_ model: Materials) {
        _cacher.persist(item: model) { (_, error) in
            if let error = error {
                log.error(error.localizedDescription)
            }
        }
    }
    
    /// removeImageWrapper
    ///
    /// - Parameter draft: ImageWrapper
    func remove(_ model: Materials) {
        _cacher.remove(fileName: model.fileName)
    }
    
    /// clearImageWrapper
    func clearImageWrappers() {
        for draftFile in _cacher.findFiles(path: path) {
            _cacher.remove(fileName: draftFile)
        }
    }
}

public class CollectSubtitlesCacher {
    public static let creationCacherUrl = URL(fileURLWithPath: NSHomeDirectory() + "/Library/Caches/Collect/Subtitles")
    
    var path: String {
        return CollectSubtitlesCacher.creationCacherUrl.path
    }
    
    /// shared
    public static let shared = CollectSubtitlesCacher()
    
    /// Cacher
    private lazy var _cacher = Cacher(destination: .custom(path))
    
    /// loadImageWrappers
    ///
    /// - Returns: ImageWrapper
    func loads() -> [Subtitles] {
        
        var result: [Subtitles] = []
        for file in _cacher.findFiles(path: path) {
            if let model: Subtitles = _cacher.load(fileName: file) {
                result.append(model)
            }
        }
        return result.sorted(by: { $0.timestamp > $1.timestamp })
    }
    
    /// addImageWrapper
    ///
    /// - Parameter draft: ImageWrapper
    func add(_ model: Subtitles) {
        _cacher.persist(item: model) { (_, error) in
            if let error = error {
                log.error(error.localizedDescription)
            }
        }
    }
    
    /// removeImageWrapper
    ///
    /// - Parameter draft: ImageWrapper
    func remove(_ model: Subtitles) {
        _cacher.remove(fileName: model.fileName)
    }
    
    /// clearImageWrapper
    func clearImageWrappers() {
        for draftFile in _cacher.findFiles(path: path) {
            _cacher.remove(fileName: draftFile)
        }
    }
}

public class ShieldingSubtitlesCacher {
    public static let creationCacherUrl = URL(fileURLWithPath: NSHomeDirectory() + "/Library/Caches/Shielding/Subtitles")
    
    var path: String {
        return ShieldingSubtitlesCacher.creationCacherUrl.path
    }
    
    /// shared
    public static let shared = ShieldingSubtitlesCacher()
    
    /// Cacher
    private lazy var _cacher = Cacher(destination: .custom(path))
    
    /// loadImageWrappers
    ///
    /// - Returns: ImageWrapper
    func loads() -> [Subtitles] {
        
        var result: [Subtitles] = []
        for file in _cacher.findFiles(path: path) {
            if let model: Subtitles = _cacher.load(fileName: file) {
                result.append(model)
            }
        }
        return result.sorted(by: { $0.timestamp > $1.timestamp })
    }
    
    /// addImageWrapper
    ///
    /// - Parameter draft: ImageWrapper
    func add(_ model: Subtitles) {
        _cacher.persist(item: model) { (_, error) in
            if let error = error {
                log.error(error.localizedDescription)
            }
        }
    }
    
    /// removeImageWrapper
    ///
    /// - Parameter draft: ImageWrapper
    func remove(_ model: Subtitles) {
        _cacher.remove(fileName: model.fileName)
    }
    
    /// clearImageWrapper
    func clearImageWrappers() {
        for draftFile in _cacher.findFiles(path: path) {
            _cacher.remove(fileName: draftFile)
        }
    }
}
