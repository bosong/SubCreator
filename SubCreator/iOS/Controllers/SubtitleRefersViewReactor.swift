//
//  SubtitleRefersViewReactor.swift
//  SubCreator
//
//  Created by ripple_k on 2019/9/26.
//  Copyright © 2019 ripple_k. All rights reserved.
//

import RxSwift
import ReactorKit

class SubtitleRefersViewReactor: Reactor {
    enum Action {
        case loadData
        case loadMore
    }
    
    enum Mutation {
        case setData([Subtitles])
        case addData([Subtitles])
        case setLoading(Bool)
    }
    
    struct State {
        var data: [Subtitles] = []
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
                .subtitleListMore(id: currentState.id, limit: 50, skip: 0)
                .asObservable()
                .map { $0.first?.subtitles }
                .filterNil()
                .map { Mutation.setData($0) }
            return .concat([start, data, end])
            
        case .loadMore:
            guard !currentState.isLoading else { return .empty() }
            let start = Observable.just(Mutation.setLoading(true))
            let end = Observable.just(Mutation.setLoading(false))
            let data = Service.shared
                .subtitleListMore(id: currentState.id, limit: 50, skip: currentState.data.count)
                .asObservable()
                .map { $0.first?.subtitles }
                .filterNil()
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
