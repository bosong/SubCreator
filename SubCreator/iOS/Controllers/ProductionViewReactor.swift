//
//  ProductionViewReactor.swift
//  SubCreator
//
//  Created by ripple_k on 2019/9/24.
//  Copyright © 2019 ripple_k. All rights reserved.
//

import ReactorKit

class ProductionViewReactor: Reactor {
    enum Action {
        
    }
    
    enum Mutation {
        
    }
    
    struct State {
        var creationData: [ImageWrapper]
    }
    
    var initialState: State
    
    init() {
        let images = CreationCacher.shared.loads()
        initialState = State(creationData: images)
    }
}
