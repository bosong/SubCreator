//
//  Networking.swift
//  ABTest
//
//  Created by ripple_k on 2018/7/25.
//  Copyright © 2018 SoapVideo. All rights reserved.
//

import Foundation
import Moya
import RxSwift

//typealias ABTestNetworking = Networking<ABTestAPI>

open class Networking<Target: TargetType>: MoyaProvider<Target> {

    enum ApiError: Error {
        case invalidKey
        case serverFailure
        case tokenExpired
    }

    init(plugins: [PluginType] = []) {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = Manager.defaultHTTPHeaders
        configuration.timeoutIntervalForRequest = 20
        
        let manager = Manager(configuration: configuration)
        manager.startRequestsImmediately = false
        super.init(manager: manager, plugins: plugins)
    }
    
    func request(
        _ target: Target,
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line
        ) -> Single<Response> {
        let requestString = "\(target.method) \(target.path) )"
        return self.rx.request(target)
            //            .filterSuccessfulStatusCodes()
            .map { response in
                if 200 ..< 300 ~= response.statusCode {
                    return response
                } else if response.statusCode == 403 {
                    throw ApiError.tokenExpired
                } else if response.statusCode == 404 {
                    throw ApiError.invalidKey
                } else {
                    throw MoyaError.statusCode(response)
                }
            }
            .do(onSuccess: { (value) in
                let message = "SUCCESS: \(requestString) (\(value.statusCode))"
                log.debug(message, file: file, function: function, line: line)
            }, onError: { (error) in
                if let response = (error as? MoyaError)?.response {
                    if let jsonObject = try? response.mapJSON(failsOnEmptyData: false) {
                        let message = "FAILURE: \(requestString) (\(response.statusCode))\n\(jsonObject)"
                        log.warning(message, file: file, function: function, line: line)
                    } else if let rawString = String(data: response.data, encoding: .utf8) {
                        let message = "FAILURE: \(requestString) (\(response.statusCode))\n\(rawString)"
                        log.warning(message, file: file, function: function, line: line)
                    } else {
                        let message = "FAILURE: \(requestString) (\(response.statusCode))"
                        log.warning(message, file: file, function: function, line: line)
                    }
                } else {
                    let message = "FAILURE: \(requestString)\n\(error)"
                    log.warning(message, file: file, function: function, line: line)
                }
            }, onSubscribe: {
                let message = "REQUEST: \(requestString)"
                log.debug(message, file: file, function: function, line: line)
            })
    }
}
