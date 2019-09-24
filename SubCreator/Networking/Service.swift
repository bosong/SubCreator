//
//  Service.swift
//  SubCreator
//
//  Created by rpple_k on 2019/8/3.
//  Copyright © 2019 ripple_k. All rights reserved.
//

import RxSwift
import Foundation
import Moya

protocol ServiceType {
    func homeList(limit: Int, skip: Int) -> Single<[HomeItem]>
    func materialList(limit: Int, skip: Int) -> Single<[Material]>
    func subtitleList(limit: Int, skip: Int) -> Single<[Subtitle]>
    func materialRefers(id: String, limit: Int, skip: Int) -> Single<[HomeItem]>
    func upload(id: String, data: Data) -> Single<Response>
}

class Service: ServiceType {
    static let shared = Service()
    
    private let networkng = Networking<API>()
    
    func homeList(limit: Int, skip: Int) -> Single<[HomeItem]> {
        return networkng
            .request(.homeList(limit: limit, skip: skip))
            .mapCommonable([HomeItem].self)
            .catchErrorJustReturn([])
    }
    
    func materialList(limit: Int, skip: Int) -> Single<[Material]> {
        return networkng
            .request(.materialList(limit: limit, skip: skip))
            .mapCommonable([Material].self)
            .catchErrorJustReturn([])
    }
    
    func subtitleList(limit: Int, skip: Int) -> Single<[Subtitle]> {
        return networkng
            .request(.subtitleList(limit: limit, skip: skip))
            .mapCommonable([Subtitle].self)
            .catchErrorJustReturn([])
    }
    
    func materialRefers(id: String, limit: Int, skip: Int) -> Single<[HomeItem]> {
        return networkng
            .request(.materialRefers(id: id, limit: limit, skip: skip))
            .mapCommonable([HomeItem].self)
            .catchErrorJustReturn([])
    }
    
    func upload(id: String, data: Data) -> Single<Response> {
        return networkng
            .request(.upload(id: id, data: data))
    }
}
