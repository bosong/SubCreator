//
//  Model.swift
//  SubCreator
//
//  Created by rpple_k on 2019/8/3.
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
    let teleplayId: String?
    let teleplayName: String?
//    private enum CodingKeys: String, CodingKey {
//        case materials
//        case teleplayId = "teleplay_id"
//        case teleplayName = "teleplay_name"
//    }
}

struct Materials: Codable {
    let materialId: String?
    let teleplayId: String?
    let url: String
//    private enum CodingKeys: String, CodingKey {
//        case materialId = "material_id"
//        case teleplayId = "teleplay_id"
//        case url
//    }
}

extension Materials: Cachable, Equatable {
    var fileName: String {
        return teleplayId ?? url
    }
}
