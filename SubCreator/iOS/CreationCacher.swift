//
//  CreationCacher.swift
//  SubCreator
//
//  Created by ripple_k on 2019/8/3.
//  Copyright © 2019 ripple_k. All rights reserved.
//

import Foundation

public class CreationCacher {
    public static let creationCacherUrl = URL(fileURLWithPath: NSHomeDirectory() + "/Library/Caches/Creation")
    
    var path: String {
        return CreationCacher.creationCacherUrl.path
    }
    
    /// shared
    public static let shared = CreationCacher()
    
    /// Cacher
    private lazy var _cacher = Cacher(destination: .custom(path))
    
    /// loadImageWrappers
    ///
    /// - Returns: ImageWrapper
    func loads() -> [ImageWrapper] {
        
        var result: [ImageWrapper] = []
        for file in _cacher.findFiles(path: path) {
            if let model: ImageWrapper = _cacher.load(fileName: file) {
                result.append(model)
            }
        }
        return result
    }
    
    /// addImageWrapper
    ///
    /// - Parameter draft: ImageWrapper
    func add(_ model: ImageWrapper) {
        _cacher.persist(item: model) { (_, error) in
            if let error = error {
                log.error(error.localizedDescription)
            }
        }
    }
    
    /// removeImageWrapper
    ///
    /// - Parameter draft: ImageWrapper
    func remove(_ model: ImageWrapper) {
        _cacher.remove(fileName: model.fileName)
    }
    
    /// clearImageWrapper
    func clearImageWrappers() {
        for draftFile in _cacher.findFiles(path: path) {
            _cacher.remove(fileName: draftFile)
        }
    }
}

extension ImageWrapper: Cachable {
    public var fileName: String {
        return timestamp.description
    }
}

public struct ImageWrapper: Codable {
    enum StorageError: Error {
        case decodingFailed
        case encodingFailed
    }
    
    public typealias Image = UIImage
    public let image: Image
    public let timestamp: TimeInterval
    
    public enum CodingKeys: String, CodingKey {
        case image
        case timestamp
    }
    
    // Image is a standard UI/NSImage conditional typealias
    public init(image: Image, timestamp: TimeInterval) {
        self.image = image
        self.timestamp = timestamp
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let data = try container.decode(Data.self, forKey: CodingKeys.image)
        guard let image = Image(data: data) else {
            throw StorageError.decodingFailed
        }
        
        self.image = image
        timestamp = try container.decodeIfPresent(TimeInterval.self, forKey: .timestamp) ?? 0
    }
    
    // cache_toData() wraps UIImagePNG/JPEGRepresentation around some conditional logic with some whipped cream and sprinkles.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        guard let data = image.pngData() else {
            throw StorageError.encodingFailed
        }
        
        try container.encode(data, forKey: CodingKeys.image)
        try container.encode(timestamp, forKey: CodingKeys.timestamp)
    }
}
