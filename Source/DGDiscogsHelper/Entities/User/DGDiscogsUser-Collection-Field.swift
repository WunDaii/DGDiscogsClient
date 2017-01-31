//
//  DGDiscogsCollectionField.swift
//  DGDiscogsHelper
//
//  Created by Daven Gomes on 10/12/2016.
//  Copyright © 2016 Daven Gomes. All rights reserved.
//

import Foundation

import SwiftyJSON
import Alamofire

extension DGDiscogsUser.Collection {
    
    public struct Field {
        
        public enum FieldType: String {
            case dropdown = "dropdown"
            case textArea = "textarea"
        }
        
        public let name: String
        public let options: [String]?
        public let position: Int
        public let discogsID: Int
        public let fieldType: FieldType
        public let publicAvailable: Bool
        
        init(json: JSON) {
            self.name = json["name"].stringValue
            self.options = json["options"].arrayObject as? [String]
            self.position = json["position"].intValue
            self.discogsID = json["id"].intValue
            self.fieldType = FieldType(rawValue: json["type"].stringValue) ?? .dropdown
            self.publicAvailable = json["public"].bool ?? false
        }
        
        static func items(
            from array: [JSON]?)
            -> [Field]?
        {
            guard let array = array else { return nil }
            
            var items : [Field] = []
            
            for json in array {
                items.append(self.init(json: json))
            }
            
            return items
        }
        
        public func isValid(
            _ value: String?)
            -> Bool
        {
            if fieldType == .textArea {
                return true
            }
            
            if let options = options,
                let value = value,
                options.contains(value) {
                return true
            }
            
            return false
        }
    }
}
