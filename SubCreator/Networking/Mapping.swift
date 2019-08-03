//
//  Mapping.swift
//  ACG
//
//  Created by 张坤 on 2019/4/15.
//  Copyright © 2019 SoapVideo. All rights reserved.
//
//  swiftlint:disable vertical_parameter_alignment

import Moya
import RxSwift

let successRequestCode = 200

extension PrimitiveSequence where TraitType == SingleTrait, ElementType == Response {
    public func mapCommonable<D: Codable> (_ type: D.Type,
                                 file: StaticString = #file,
                                 function: StaticString = #function,
                                 line: UInt = #line) -> Single<D> {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        jsonDecoder.dateDecodingStrategy = .secondsSince1970
        return self
            .map(Commonable<D>.self, atKeyPath: nil, using: jsonDecoder, failsOnEmptyData: true)
            .do(onSuccess: { (res) in
                if res.code != successRequestCode {
                    log.error(res.msg)
                }
            })
            .do(onError: { (error) in
                log.error(error, file: file, function: function, line: line)
            })
            .map { $0.data }
    }
    
    public func mapList<D: Codable> (_ type: D.Type,
                                       file: StaticString = #file,
                                       function: StaticString = #function,
                                       line: UInt = #line) -> Single<[D]> {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        jsonDecoder.dateDecodingStrategy = .secondsSince1970
        return self
            .map(CommonableList<D>.self, atKeyPath: nil, using: jsonDecoder, failsOnEmptyData: true)
            .do(onSuccess: { (res) in
                if res.code != successRequestCode {
                    log.error(res.msg)
                }
            })
            .do(onError: { (error) in
                log.error(error, file: file, function: function, line: line)
            })
            .catchErrorJustReturn(CommonableList<D>.empty)
            .map { $0.data.list }
    }
    
    public func mapLogMessage(_ file: StaticString = #file,
                                function: StaticString = #function,
                                line: UInt = #line) -> Single<LogMessage> {
        return self
            .map(LogMessage.self, atKeyPath: nil, using: JSONDecoder(), failsOnEmptyData: true)
            .do(onSuccess: { (res) in
                if res.code != successRequestCode {
                    log.error(res.message)
                }
            })
            .do(onError: { (error) in
                log.error(error, file: file, function: function, line: line)
            })
    }
}
