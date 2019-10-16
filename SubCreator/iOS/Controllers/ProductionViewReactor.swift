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
        case delete([IndexPath], alert: () -> ())
    }
    
    enum Mutation {
        case setData([ImageWrapper])
    }
    
    struct State {
        var creationData: [ImageWrapper]
    }
    
    var initialState: State
    
    init() {
        let images = CreationCacher.shared.loads().sorted { (left, right) -> Bool in
            return left.timestamp > right.timestamp
        }
        initialState = State(creationData: images)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .delete(let ip, let alert):
            ip.map { [weak self] in self?.currentState.creationData[$0.item] }
                .forEach { (wrapper) in
                    if let wrapper = wrapper {
                        CreationCacher.shared.remove(wrapper)
                    }
                }
            alert()
            return Observable.just(Mutation.setData(CreationCacher.shared.loads().sorted { (left, right) -> Bool in
                return left.timestamp > right.timestamp
            }))
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
