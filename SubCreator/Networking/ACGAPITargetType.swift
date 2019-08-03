//
//  APITargetType.swift
//  DramaDataKit
//
//  Created by MorningStar on 2018/11/18.
//  Copyright © 2018 FeiZaoTai. All rights reserved.
//

import Moya

var kBaseURL: URL {
    #if DEBUG
    return URL(string: "http://draw.voidtech.com.cn:8765")!
    #else
    return URL(string: "http://draw.voidtech.com.cn:8765")!
    #endif
}

public protocol APITargetType: TargetType {
    
    var router: Router { get }
    
    var parameters: Parameters? { get }
    
    var parametersDefault: Parameters { get }
}

extension APITargetType {
    
    public var baseURL: URL {
        return kBaseURL
    }
    
    public var path: String {
        return router.path
    }
    
    public var method: Moya.Method {
        return router.method
    }
    
    public var task: Task {
        return .requestParameters(parameters: parametersDefault.values, encoding: parametersDefault.encoding)
    }
    
    public var parametersDefault: Parameters {
        guard var parameters = self.parameters else { return [:] }
        parameters.values["c"] = "iOS"
        parameters.values["device"] = UIDevice.current
            .identifierForVendor?.description ?? ""
        parameters.values["i"] = Bundle.main.infoDictionary?["CFBundleShortVersionString"]
        return parameters
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var headers: [String: String]? {
//        application/x-www-form-urlencoded
        let headerParameters = ["Accept": "application/json",
                "Content-Type": "application/json"]
        return headerParameters
    }
}
