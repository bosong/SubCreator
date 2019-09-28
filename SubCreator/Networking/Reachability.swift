//
//  Reachability.swift
//  SubCreator
//
//  Created by ripple_k on 2019/9/28.
//  Copyright © 2019 ripple_k. All rights reserved.
//

import RxSwift
import Reachability

// MARK: - ReachabilityManager
let reachabilityManager = ReachabilityManager()

// An observable that completes when the app gets online (possibly completes immediately).
func connectedToInternetOrStubbing() -> Observable<Bool> {
    return reachabilityManager?.reach ?? Observable.just(false)
}

class ReachabilityManager {
    
    private let reachability: Reachability
    
    let _reach = ReplaySubject<Bool>.create(bufferSize: 1)
    var isReach: Bool
    var reach: Observable<Bool> {
        return _reach.asObservable()
    }
    
    init?() {
        guard let r = Reachability() else {
            return nil
        }
        self.reachability = r
        self.isReach = self.reachability.connection != .none
        
        do {
            try self.reachability.startNotifier()
        } catch {
            return nil
        }
        
        self._reach.onNext(self.reachability.connection != .none)
        
        self.reachability.whenReachable = { _ in
            DispatchQueue.main.async {
                self.isReach = true
                self._reach.onNext(true)
            }
        }
        
        self.reachability.whenUnreachable = { _ in
            DispatchQueue.main.async {
                self.isReach = false
                self._reach.onNext(false)
            }
        }
    }
    
    deinit {
        reachability.stopNotifier()
    }
}
