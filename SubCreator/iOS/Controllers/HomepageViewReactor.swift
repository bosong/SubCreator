//
//  HomepageViewReactor.swift
//  SubCreator
//
//  Created by ripple_k on 2019/7/30.
//  Copyright © 2019 ripple_k. All rights reserved.
//

import ReactorKit
import RxSwift
import RxCocoa

class HomepageViewReactor: Reactor {
    
    enum Action {
        case materialList
        case materialListMore
        case subtitleList
        case subtitleListMore
        case reloadSubtitleList
    }
    
    enum Mutation {
        case setMaterial([Material])
        case addMaterial([Material])
        case setSubtitle([Subtitle])
        case addSubtitle([Subtitle])
        case setLoading(Bool)
    }
    
    struct State {
        var material: [Material] = []
        var subtitle: [Subtitle] = []
        var isLoading = false
    }
    
    var initialState: State
    
    init() {
        initialState = State()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .materialList:
            guard !currentState.isLoading else { return .empty() }
            let start = Observable.just(Mutation.setLoading(true))
            let end = Observable.just(Mutation.setLoading(false))
            let data = Service.shared
                .materialList(limit: 30, skip: 0)
                .asObservable()
                .map(Mutation.setMaterial)
            return .concat([start, data, end])
            
        case .materialListMore:
            guard !currentState.isLoading else { return .empty() }
            let start = Observable.just(Mutation.setLoading(true))
            let end = Observable.just(Mutation.setLoading(false))
            let data = Service.shared
                .materialList(limit: 30, skip: currentState.material.count)
                .asObservable()
                .map(Mutation.addMaterial)
            return .concat([start, data, end])
            
        case .subtitleList:
            guard !currentState.isLoading else { return .empty() }
            let start = Observable.just(Mutation.setLoading(true))
            let end = Observable.just(Mutation.setLoading(false))
            let data = Service.shared
                .subtitleList(limit: 30, skip: 0)
                .asObservable()
                .map(Mutation.setSubtitle)
            return .concat([start, data, end])
        case .subtitleListMore:
            guard !currentState.isLoading else { return .empty() }
            let start = Observable.just(Mutation.setLoading(true))
            let end = Observable.just(Mutation.setLoading(false))
            let data = Service.shared
                .subtitleList(limit: 30, skip: currentState.subtitle.count)
                .asObservable()
                .map(Mutation.addSubtitle)
            return .concat([start, data, end])
        case .reloadSubtitleList:
            return Observable.just(Mutation.setSubtitle(currentState.subtitle))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case .setMaterial(let data):
            state.material = data
        case .addMaterial(let data):
            state.material += data
        case .setSubtitle(let data):
            state.subtitle = filterShielding(data)
        case .addSubtitle(let data):
            state.subtitle += filterShielding(data)
        case .setLoading(let loading):
            state.isLoading = loading
        }
        return state
    }
    
    private func filterShielding(_ subtitle: [Subtitle]) -> [Subtitle] {
        return subtitle.map { (subtitle) -> Subtitle in
            var subtitle = subtitle
            subtitle.subtitles = subtitle.subtitles.compactMap { element -> Subtitles? in
                if ShieldingSubtitlesCacher.shared.loads().contains(element) {
                    return nil
                }
                return element
            }
            return subtitle
        }
    }
}
