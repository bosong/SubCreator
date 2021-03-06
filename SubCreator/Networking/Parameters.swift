//
//  Parameters.swift
//  DramaDataKit
//
//  Created by ripple_k on 2018/11/18.
//  Copyright © 2018 VoidTech. All rights reserved.
//

import Alamofire

public struct Parameters {
    public var encoding: Alamofire.ParameterEncoding
    public var values: [String: Any]
    
    public init(encoding: Alamofire.ParameterEncoding, values: [String: Any?]) {
        self.encoding = encoding
        self.values = filterNil(values)
    }
}

extension Parameters: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, Any?)...) {
        var values: [String: Any?] = [:]
        for (key, value) in elements {
            values[key] = value
        }
        self.init(encoding: Alamofire.URLEncoding(), values: values)
    }
}

infix operator =>

public func => (encoding: Alamofire.ParameterEncoding, values: [String: Any?]) -> Parameters {
    return Parameters(encoding: encoding, values: values)
}

/// Returns a new dictinoary by filtering out nil values.
private func filterNil(_ dictionary: [String: Any?]) -> [String: Any] {
    var newDictionary: [String: Any] = [:]
    for (key, value) in dictionary {
        guard let value = value else { continue }
        newDictionary[key] = value
    }
    return newDictionary
}
