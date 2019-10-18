//
//  Model.swift
//  SubCreator
//
//  Created by ripple_k on 2019/8/3.
//  Copyright © 2019 ripple_k. All rights reserved.
//

import Foundation

struct HomeItem: Codable {
    let uid: String
    let url: String
}

extension HomeItem: Cachable {
    var fileName: String {
        return uid
    }
}

extension HomeItem: Equatable { }
struct Material: Codable {
    let materials: [Materials]
    let teleplayId: String
    let teleplayName: String
//    private enum CodingKeys: String, CodingKey {
//        case materials
//        case teleplayId = "teleplay_id"
//        case teleplayName = "teleplay_name"
//    }
}

struct Materials: Codable {
    let materialId: String
    let teleplayId: String
    let url: String
//    private enum CodingKeys: String, CodingKey {
//        case materialId = "material_id"
//        case teleplayId = "teleplay_id"
//        case url
//    }
}

extension Materials: Cachable, Equatable {
    var fileName: String {
        return materialId
    }
}

struct Subtitle: Codable {
    let teleplayId: String
    let teleplayName: String
//    let total: Int
    
    let subtitles: [Subtitles]
//    private enum CodingKeys: String, CodingKey {
//        case teleplayId = "teleplay_id"
//        case teleplayName = "teleplay_name"
//        case total
//        case subtitles
//    }
}

extension Subtitles: Equatable {
    static func == (lhs: Subtitles, rhs: Subtitles) -> Bool {
        return lhs.teleplayId == rhs.teleplayId &&
            lhs.subtitleId == rhs.subtitleId &&
            lhs.materialId == rhs.materialId &&
            lhs.materialUrl == rhs.materialUrl
    }
}

struct Subtitles: Codable {
    let teleplayId: String
    let subtitleId: String
    let materialId: String
    let materialUrl: String
    let url: String
    var timestamp: TimeInterval
//    let createAt: Date
    private enum CodingKeys: String, CodingKey {
        case teleplayId
        case subtitleId
        case materialId
        case materialUrl
        case url
        case timestamp
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        teleplayId = try container.decodeIfPresent(String.self, forKey: .teleplayId) ?? ""
        subtitleId = try container.decodeIfPresent(String.self, forKey: .subtitleId) ?? ""
        materialId = try container.decodeIfPresent(String.self, forKey: .materialId) ?? ""
        materialUrl = try container.decodeIfPresent(String.self, forKey: .materialUrl) ?? ""
        url = try container.decodeIfPresent(String.self, forKey: .url) ?? ""
        timestamp = try container.decodeIfPresent(TimeInterval.self, forKey: .timestamp) ?? 0
    }
}

extension Subtitles: Cachable {
    var fileName: String {
        return subtitleId
    }
}

struct SearchResult: Codable {
    let teleplayId: String
    let teleplayName: String
    var timestamp: TimeInterval
    
    private enum CodingKeys: String, CodingKey {
        case teleplayId
        case teleplayName = "name"
        case timestamp
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        teleplayId = try container.decodeIfPresent(String.self, forKey: .teleplayId) ?? ""
        teleplayName = try container.decodeIfPresent(String.self, forKey: .teleplayName) ?? ""
        timestamp = try container.decodeIfPresent(TimeInterval.self, forKey: .timestamp) ?? 0
    }
}

extension SearchResult: Cachable, Equatable {
    var fileName: String {
        return teleplayId + teleplayName
    }
}
