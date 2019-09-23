//
//  HomepageViewReactor.swift
//  SubCreator
//
//  Created by rpple_k on 2019/7/30.
//  Copyright © 2019 ripple_k. All rights reserved.
//

import ReactorKit
import RxSwift
import RxCocoa

class HomepageViewReactor: Reactor {
    
    enum Action {
        case loadData
        case loadMore
    }
    
    enum Mutation {
        case setData([Material])
        case addData([Material])
        case setLoading(Bool)
    }
    
    struct State {
        var data: [Material] = []
        var isLoading = false
    }
    
    var initialState: State
    
    init() {
        initialState = State()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .loadData:
            guard !currentState.isLoading else { return .empty() }
            let start = Observable.just(Mutation.setLoading(true))
            let end = Observable.just(Mutation.setLoading(false))
            let data = Service.shared
                .materialList(limit: 30, skip: 0)
                .asObservable()
                .map(Mutation.setData)
            return .concat([start, data, end])
            
        case .loadMore:
            guard !currentState.isLoading else { return .empty() }
            let start = Observable.just(Mutation.setLoading(true))
            let end = Observable.just(Mutation.setLoading(false))
            let data = Service.shared
                .materialList(limit: 30, skip: currentState.data.count)
                .asObservable()
                .map(Mutation.addData)
            return .concat([start, data, end])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case .setData(let data):
            state.data = data
        case .addData(let data):
            state.data += data
        case .setLoading(let loading):
            state.isLoading = loading
        }
        return state
    }
}
