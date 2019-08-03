//
//  Service.swift
//  SubCreator
//
//  Created by rpple_k on 2019/8/3.
//  Copyright © 2019 ripple_k. All rights reserved.
//

import RxSwift
import Foundation

protocol ServiceType {
    func homeList(limit: Int, skip: Int) -> Single<[HomeItem]>
}

class Service: ServiceType {
    static let shared = Service()
    
    private let networkng = Networking<API>()
    
    func homeList(limit: Int, skip: Int) -> Single<[HomeItem]> {
        return networkng
            .request(.homeList(limit: limit, skip: skip))
            .mapCommonable([HomeItem].self)
    }
}
