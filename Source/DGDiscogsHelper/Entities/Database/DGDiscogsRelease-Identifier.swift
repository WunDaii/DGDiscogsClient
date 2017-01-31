//
//  DGDiscogsReleaseIdentifier.swift
//  DGDiscogsHelper
//
//  Created by Daven Gomes on 16/11/2016.
//  Copyright © 2016 Daven Gomes. All rights reserved.
//

import Foundation

import SwiftyJSON

extension DGDiscogsRelease {
    
    public struct Identifier {
        
        public let type: String!
        public let description: String?
        public let value: String?
        
        init?(json : JSON?) {
            
            guard let
                json = json,
                let type = json["type"].string
                else { return nil }
            
            self.type = type
            self.description = json["description"].string
            self.value = json["value"].string
        }
        
        static func items(from array: [JSON]?) -> [Identifier]? {
            
            guard let array = array else { return nil }
            
            var items : [Identifier] = []
            
            for item in array {
                if let dgItem = self.init(json: item) {
                    items.append(dgItem)
                }
            }
            
            return items
        }
    }
    
}
