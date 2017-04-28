//
//  DGDiscogsPriceSuggestions.swift
//  DGDiscogsHelper
//
//  Created by Daven Gomes on 28/04/2017.
//
//

import Foundation

import SwiftyJSON

public struct DGDiscogsPriceSuggestions {
    
    public struct Suggestion {
        
        public let currency: String?
        public let value: Double?
        
        init(json: JSON) {
            self.currency = json["currency"].string
            self.value = json["value"].double
        }
    }
    
    private let priceSuggestions: [String : Suggestion]
    
    public var conditions: [String] {
        return Array(priceSuggestions.keys)
    }
    
    public subscript(condition: String) -> Suggestion? {
        get {
            return priceSuggestions[condition]
        }
    }
    
    init(json: JSON) {
    
        var priceSuggestions: [String : Suggestion] = [:]
        
        for (key, json) in json {
            priceSuggestions[key] = Suggestion(json: json)
        }
        
        self.priceSuggestions = priceSuggestions
    }
}
