//
//  HomepageViewReactor.swift
//  SubCreator
//
//  Created by rpple_k on 2019/7/30.
//  Copyright © 2019 ripple_k. All rights reserved.
//

import ReactorKit

class HomepageViewReactor: Reactor {
    
    enum Action {
        
    }
    
    enum Mutation {
        
    }
    
    struct State {
        var data: [UIImage]
    }
    
    var initialState: State
    
    init() {
        let imgs = Array(repeating: R.image.图()!, count: 100)
        initialState = State(data: imgs)
    }
}
