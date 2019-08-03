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
