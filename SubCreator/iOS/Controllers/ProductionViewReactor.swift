//
//  ProductionViewReactor.swift
//  SubCreator
//
//  Created by ripple_k on 2019/9/24.
//  Copyright © 2019 ripple_k. All rights reserved.
//

import ReactorKit

class ProductionViewReactor: Reactor {
    enum ReactorType {
        case collect
        case creation
    }
    
    enum Action {
        
    }
    
    enum Mutation {
        
    }
    
    struct State {
        var creationData: [ImageWrapper]
        var collectData: [Materials]
        let type: ReactorType
    }
    
    var initialState: State
    
    init(_ type: ReactorType) {
        
        switch type {
        case .collect:
            //            let images = CollectCacher.shared.loads()
            initialState = State(creationData: [], collectData: [], type: type)
        case .creation:
            let images = CreationCacher.shared.loads()
            initialState = State(creationData: images, collectData: [], type: type)
        }
    }
}
