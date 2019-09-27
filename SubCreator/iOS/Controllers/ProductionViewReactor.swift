//
//  ProductionViewReactor.swift
//  SubCreator
//
//  Created by ripple_k on 2019/9/24.
//  Copyright © 2019 ripple_k. All rights reserved.
//

import UIKit
import RxSwift
import ReactorKit

class ProductionViewReactor: Reactor {
    enum Action {
        case delete([IndexPath])
    }
    
    enum Mutation {
        case setData([ImageWrapper])
    }
    
    struct State {
        var creationData: [ImageWrapper]
    }
    
    var initialState: State
    
    init() {
        let images = CreationCacher.shared.loads()
        initialState = State(creationData: images)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .delete(let ip):
            ip.map { [weak self] in self?.currentState.creationData[$0.item] }
                .forEach { (wrapper) in
                    if let wrapper = wrapper {
                        CreationCacher.shared.remove(wrapper)
                    }
                }
            return Observable.just(Mutation.setData(CreationCacher.shared.loads()))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case .setData(let data):
            state.creationData = data
        }
        return state
    }
}