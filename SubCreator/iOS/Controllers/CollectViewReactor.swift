//
//  CollectViewReactor.swift
//  SubCreator
//
//  Created by rpple_k on 2019/8/3.
//  Copyright © 2019 ripple_k. All rights reserved.
//

import ReactorKit

class CollectViewReactor: Reactor {
    typealias Action = NoEvent
    typealias Item = CollectViewController.Item
    typealias Section = CollectViewController.Section
    
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
}
