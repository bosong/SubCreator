//
//  Cacher.swift
//  ACG
//
//  Created by 张坤 on 2019/4/12.
//  Copyright © 2019 SoapVideo. All rights reserved.
//

import Foundation

/// `Cacher` is a super simple cross platform solution to persist `Cachable` types into the filesystem.
public class Cacher {
    /// The path in the filesystem that will hold all the persisted items
    let destination: URL
    private let queue = OperationQueue()
    
    /// A type for the type of persistance options.
    ///
    /// - temporary: stores `Cachable` types into the temporary folder of the OS.
    /// - atFolder: stores `Cachable` types into a specific folder in the OS.
    public enum CacheDestination {
        /// Stores items in `NSHomeDirectory() + "/Library/Caches"`
        case cache
        /// Stores items in `NSHomeDirectory() + "/Library/Caches/"`
        case atCache(String)
        /// Stores items in `NSTemporaryDirectory`
        case temporary
        /// Stores items at a specific location
        case atFolder(String)
        
        case custom(String)
    }
    
    // MARK: Initialization
    
    /// Initializes a newly created `Cacher` instance using the specified storage destination.
    /// *Note* If using `.atFolder(String)` make sure the destination is valid.
    ///
    /// - Parameter destination: path to the location where `Cacher` will persist its `Cachable` items.
    public init(destination: CacheDestination) {
        switch destination {
        case .cache:
            self.destination = URL(fileURLWithPath: NSHomeDirectory() + "/Library/Caches")
        case .atCache(let folder):
            let cacheFolder = URL(fileURLWithPath: NSHomeDirectory() + "/Library/Caches")
            self.destination = cacheFolder.appendingPathComponent(folder)
        case .temporary:
            self.destination = URL(fileURLWithPath: NSTemporaryDirectory())
        case .atFolder(let folder):
            let documentFolder = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            self.destination = URL(fileURLWithPath: documentFolder).appendingPathComponent(folder, isDirectory: true)
        case .custom(let destination):
            self.destination = URL(fileURLWithPath: destination)
        }
        
        try? FileManager.default.createDirectory(at: self.destination, withIntermediateDirectories: true, attributes: nil)
    }
    
    /// Store a `Cachable` object in the directory selected by this `Cacher` instance.
    ///
    /// - Parameters:
    ///   - item: `Cachable` object to persist in the filesystem
    ///   - completion: callback invoked when the persistance finishes, it will either contain the `URL` of the persisted item, or the `Error` raised while trying to.
    public func persist(item: Cachable, completion: @escaping (_ url: URL?, _ error: Error?) -> Void) {
        var url: URL?
        var error: Error?
        
        // Create an operation to process the request.
        let operation = BlockOperation {
            do {
                url = try self.persist(data: item.transform(), at: self.destination.appendingPathComponent(item.fileName, isDirectory: false))
            } catch let persistError {
                error = persistError
            }
        }
        
        // Set the operation's completion block to call the request's completion handler.
        operation.completionBlock = {
            completion(url, error)
        }
        
        // Add the operation to the queue to start the work.
        queue.addOperation(operation)
    }
    
    /// Load cached data from the directory
    ///
    /// - Parameter fileName: of the cached data stored in the file system
    /// - Returns: the decoded cached data (if any)
    public func load<T: Cachable & Codable>(fileName: String) -> T? {
        guard
            let data = try? Data(contentsOf: destination.appendingPathComponent(fileName, isDirectory: false))
            else { return nil }
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch let error {
            log.error(error.localizedDescription)
        }
        return nil
    }
    
    /// clear cached data from directory
    ///
    /// - Parameter fileName: of the cached data stored in the file system
    /// - Returns: removed fileName
    /// - Throws: error
    @discardableResult
    public func remove(fileName: String) -> String? {
        do {
            try FileManager.default.removeItem(at: destination.appendingPathComponent(fileName, isDirectory: false))
            return fileName
        } catch let error {
            log.error(error.localizedDescription)
            return nil
        }
    }
    
    // MARK: Private
    
    private func persist(data: Data, at url: URL) throws -> URL {
        do {
            try data.write(to: url, options: [.atomicWrite])
            return url
        } catch let error {
            throw error
        }
    }
    
    public func findFiles(path: String, filterTypes: [String] = []) -> [String] {
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: path)
            if filterTypes.count > 0 {
                let filteredfiles = NSArray(array: files).pathsMatchingExtensions(filterTypes)
                return filteredfiles
            }
            return files
        } catch let error {
            log.error(error.localizedDescription)
            return []
        }
    }
}

/// A type that can persist itself into the filesystem.
public protocol Cachable {
    /// The item's name in the filesystem.
    var fileName: String { get }
    
    /// Returns a `Data` encoded representation of the item.
    ///
    /// - Returns: `Data` representation of the item.
    func transform() -> Data
}

extension Cachable where Self: Codable {
    public func transform() -> Data {
        do {
            let encoded = try JSONEncoder().encode(self)
            return encoded
        } catch let error {
            fatalError("Unable to encode object: \(error)")
        }
    }
}
