//
//  API.swift
//  SubCreator
//
//  Created by rpple_k on 2019/8/3.
//  Copyright © 2019 ripple_k. All rights reserved.
//
//  swiftlint:disable type_name

import Foundation
import Moya

enum API {
    case homeList(limit: Int, skip: Int)
    case materialList(limit: Int, skip: Int)
    case materialRefers(id: String, limit: Int, skip: Int)
    case upload(id: String, data: Data)
}

extension API: APITargetType {
    var router: Router {
        switch self {
        case .homeList:
            return .get("/home")
        case .materialList:
            return .get("v1/user/material")
        case .materialRefers:
            return .get("v1/user/material/refers")
        case .upload:
            return .post("v1/user/share")
        }
        
    }
    
    var parameters: Parameters? {
        switch self {
        case let .homeList(limit, skip):
            return ["limit": limit, "skip": skip]
        case let .materialList(limit, skip):
            return ["limit": limit, "skip": skip]
        case let .materialRefers(id, limit, skip):
            return ["mid": id, "limit": limit, "skip": skip]
        case let .upload(id, _):
            return ["mid": id]
        }
    }
    
    var task: Task {
        switch self {
        case let .upload(id, data):
            let multipart = MultipartFormData(provider: .data(data), name: "file", fileName: "\(id).png", mimeType: "")
            return .uploadCompositeMultipart([multipart], urlParameters: parametersDefault.values)
        default:
            return .requestParameters(parameters: parametersDefault.values, encoding: parametersDefault.encoding)
        }
    }
}
