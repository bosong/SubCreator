//
//  API.swift
//  SubCreator
//
//  Created by rpple_k on 2019/8/3.
//  Copyright © 2019 ripple_k. All rights reserved.
//

import Foundation
import Moya

enum API {
    case homeList(limit: Int, skip: Int)
    case materialList(limit: Int, skip: Int)
    case materialMoreList(tid: String, limit: Int, skip: Int)
    case subtitleList(limit: Int, skip: Int)
    case subtitleMoreList(tid: String, limit: Int, skip: Int)
    case materialRefers(id: String, limit: Int, skip: Int)
    case search(keyword: String)
    case upload(name: String, tid: String, mid: String, data: Data)
}

extension API: APITargetType {
    var router: Router {
        switch self {
        case .homeList:
            return .get("/home")
        case .materialList:
            return .get("v1/teleplay/material")
        case .materialMoreList:
            return .get("v1/teleplay/material/more")
        case .subtitleList:
            return .get("v1/teleplay/subtitle")
        case .subtitleMoreList:
            return .get("v1/teleplay/subtitle/more")
        case .materialRefers:
            return .get("v1/user/material/refers")
        case .search:
            return .get("v1/teleplay/material/search")
        case .upload:
            return .post("v1/teleplay/subtitle")
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case let .homeList(limit, skip):
            return ["limit": limit, "skip": skip]
        case let .materialList(limit, skip):
            return ["limit": limit, "skip": skip]
        case let .materialMoreList(tid, limit, skip):
            return ["tid": tid,  "limit": limit, "skip": skip]
        case let .subtitleList(limit, skip):
            return ["limit": limit, "skip": skip]
        case let .subtitleMoreList(tid, limit, skip):
            return ["tid": tid,  "limit": limit, "skip": skip]
        case let .materialRefers(id, limit, skip):
            return ["mid": id, "limit": limit, "skip": skip]
        case let .search(keyword):
            return ["keyword": keyword]
        case let .upload(name, tid, mid, _):
            return ["name": name, "tid": tid, "mid": mid]
        }
    }
    
    var task: Task {
        switch self {
        case let .upload(name, tid, mid, data):
            let multipart = MultipartFormData(provider: .data(data), name: "file", fileName: "\(name)\(mid)\(tid).jpg", mimeType: "")
            return .uploadCompositeMultipart([multipart], urlParameters: parametersDefault.values)
        default:
            return .requestParameters(parameters: parametersDefault.values, encoding: parametersDefault.encoding)
        }
    }
}
