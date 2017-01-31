//
//  DGDiscogsReleaseFormat.swift
//  DGDiscogsHelper
//
//  Created by Daven Gomes on 16/11/2016.
//  Copyright © 2016 Daven Gomes. All rights reserved.
//

import Foundation

import SwiftyJSON

extension DGDiscogsRelease {
    
    public struct Format {
        
        public let text: String?
        public let descriptions: [String]?
        public let name: String!
        public let quantity: Int
        
        init?(json : JSON?) {
            
            guard let
                json = json,
                let name = json["name"].string
                else { return nil }
            
            self.descriptions = json["descriptions"].arrayObject as? [String]
            self.name = name
            self.quantity = Int(json["qty"].string ?? "0") ?? 0
            self.text = json["text"].string
        }
        
        static func items(from array: [JSON]?) -> [Format]? {
            
            guard let array = array else { return nil }
            
            var items : [Format] = []
            
            for item in array {
                if let dgItem = self.init(json: item) {
                    items.append(dgItem)
                }
            }
            return items
        }
    }
}
