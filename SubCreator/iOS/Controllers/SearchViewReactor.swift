//
//  SearchViewReactor.swift
//  SubCreator
//
//  Created by ripple_k on 2019/9/25.
//  Copyright © 2019 ripple_k. All rights reserved.
//

import RxSwift
import ReactorKit

class SearchViewReactor: Reactor {
    enum Action {
        case search(keyword: String)
    }
    
    enum Mutation {
        case setResult([SearchResult])
    }
    
    struct State {
        var result: [SearchResult] = []
    }
    
    var initialState: State
    let service = Service.shared
    init() {
        initialState = State()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .search(keyword):
            return service
                .search(keyword: keyword)
                .asObservable()
                .map(Mutation.setResult)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case .setResult(let data):
            state.result = data
        }
        return state
    }
}
