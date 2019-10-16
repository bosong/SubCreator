//
//  CollectViewReactor.swift
//  SubCreator
//
//  Created by rpple_k on 2019/8/3.
//  Copyright © 2019 ripple_k. All rights reserved.
//

import RxSwift
import ReactorKit

class CollectViewReactor: Reactor {
    typealias Item = CollectViewController.Item
    typealias Section = CollectViewController.Section
    
    enum Action {
        case reload
        case delete([IndexPath], alert: () -> ())
    }
    
    enum Mutation {
        case setData([Section])
    }
    
    struct State {
        var data: [Section]
    }
    
    var initialState: State
    
    init() {
        var sections: [Section] = []
        let materialItems = CollectMaterialsCacher.shared.loads().map { Item.material($0) }
        let subtitleItems = CollectSubtitlesCacher.shared.loads().map { Item.subtitle($0) }
        if materialItems.isNotEmpty {
            sections.append(Section(model: "模板", items: materialItems))
        }
        if subtitleItems.isNotEmpty {
            sections.append(Section(model: "作品", items: subtitleItems))
        }
        
        initialState = State(data: sections)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .reload:
            var sections: [Section] = []
            let materialItems = CollectMaterialsCacher.shared.loads().map { Item.material($0) }
            let subtitleItems = CollectSubtitlesCacher.shared.loads().map { Item.subtitle($0) }
            if materialItems.isNotEmpty {
                sections.append(Section(model: "模板", items: materialItems))
            }
            if subtitleItems.isNotEmpty {
                sections.append(Section(model: "作品", items: subtitleItems))
            }
            return Observable.just(Mutation.setData(sections))
            
        case .delete(let ip, let alert):
            ip.map { CollectSubtitlesCacher.shared.loads()[$0.item] }
                .forEach { CollectSubtitlesCacher.shared.remove($0) }
            alert()
            let subtitleItems = CollectSubtitlesCacher.shared.loads().map { Item.subtitle($0) }
            return Observable.just(Mutation.setData([Section(model: "作品", items: subtitleItems)]))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case .setData(let data):
            state.data = data
        }
        return state
    }
}
