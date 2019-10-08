//
//  SearchHistoryCacher.swift
//  SubCreator
//
//  Created by ripple_k on 2019/9/26.
//  Copyright © 2019 ripple_k. All rights reserved.
//

import Foundation

public class SearchHistoryCacher {
    public static let creationCacherUrl = URL(fileURLWithPath: NSHomeDirectory() + "/Library/Caches/Collect/SearchHistory")
    
    var path: String {
        return SearchHistoryCacher.creationCacherUrl.path
    }
    
    /// shared
    public static let shared = SearchHistoryCacher()
    
    /// Cacher
    private lazy var _cacher = Cacher(destination: .custom(path))
    
    /// loadImageWrappers
    ///
    /// - Returns: ImageWrapper
    func loads() -> [SearchResult] {
        
        var result: [SearchResult] = []
        for file in _cacher.findFiles(path: path) {
            if let model: SearchResult = _cacher.load(fileName: file) {
                result.append(model)
            }
        }
        return result.sorted(by: { $0.timestamp > $1.timestamp })
    }
    
    /// addImageWrapper
    ///
    /// - Parameter draft: ImageWrapper
    func add(_ model: SearchResult) {
        _cacher.persist(item: model) { (_, error) in
            if let error = error {
                log.error(error.localizedDescription)
            }
        }
    }
    
    /// removeImageWrapper
    ///
    /// - Parameter draft: ImageWrapper
    func remove(_ model: SearchResult) {
        _cacher.remove(fileName: model.fileName)
    }
    
    /// clearImageWrapper
    func clear() {
        for draftFile in _cacher.findFiles(path: path) {
            _cacher.remove(fileName: draftFile)
        }
    }
}
