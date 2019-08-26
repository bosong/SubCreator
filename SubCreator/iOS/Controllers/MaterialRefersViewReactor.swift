//
//  MaterialRefersViewReactor.swift
//  SubCreator
//
//  Created by rpple_k on 2019/8/26.
//  Copyright © 2019 ripple_k. All rights reserved.
//

import ReactorKit
import RxSwift
import RxCocoa

class MaterialRefersViewReactor: Reactor {
    
    enum Action {
        case loadData
        case loadMore
    }
    
    enum Mutation {
        case setData([HomeItem])
        case addData([HomeItem])
        case setLoading(Bool)
    }
    
    struct State {
        var data: [HomeItem] = []
        var isLoading = false
        let id: String
        
        init(id: String) {
            self.id = id
        }
    }
    
    var initialState: State
    
    init(id: String) {
        initialState = State(id: id)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .loadData:
            guard !currentState.isLoading else { return .empty() }
            let start = Observable.just(Mutation.setLoading(true))
            let end = Observable.just(Mutation.setLoading(false))
            let data = Service.shared
                .materialRefers(id: currentState.id, limit: 50, skip: 0)
                .asObservable()
                .map { Mutation.setData($0) }
            return .concat([start, data, end])
            
        case .loadMore:
            guard !currentState.isLoading else { return .empty() }
            let start = Observable.just(Mutation.setLoading(true))
            let end = Observable.just(Mutation.setLoading(false))
            let data = Service.shared
                .materialRefers(id: currentState.id, limit: 50, skip: currentState.data.count)
                .asObservable()
                .map { Mutation.addData($0) }
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
