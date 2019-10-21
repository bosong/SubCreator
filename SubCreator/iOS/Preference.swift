//
//  Preference.swift
//  SubCreator
//
//  Created by ripple_k on 2019/10/21.
//  Copyright © 2019 ripple_k. All rights reserved.
//

import Foundation

struct PreferenceKey {
    static let preferences = "preferences"
}

struct Preferences: Codable {
    var agreePrivacyPolicyView: Bool?
    var installation: Bool
    
    static var current: Preferences? {
        return UserDefaults.standard.get(objectType: Preferences.self, forKey: PreferenceKey.preferences)
    }
    
    static func update(_ preferences: Preferences?) {
        guard let preferences = preferences else {
            UserDefaults.standard.removeObject(forKey: PreferenceKey.preferences)
            UserDefaults.standard.synchronize()
            return
        }
        UserDefaults.standard.set(object: preferences, forKey: PreferenceKey.preferences)
        UserDefaults.standard.synchronize()
    }
}

public extension UserDefaults {
    func set<T: Codable>(object: T, forKey: String) {
        let jsonData = try? JSONEncoder().encode(object)
        set(jsonData, forKey: forKey)
    }
    
    func get<T: Codable>(objectType: T.Type, forKey: String) -> T? {
        guard let reuslt = value(forKey: forKey) as? Data else {
            return nil
        }
        let result = try? JSONDecoder().decode(objectType, from: reuslt)
        return result
    }
}
