//
//  DGDiscogsItemNote.swift
//  DGDiscogsHelper
//
//  Created by Daven Gomes on 10/12/2016.
//  Copyright © 2016 Daven Gomes. All rights reserved.
//

import Foundation

import SwiftyJSON

extension DGDiscogsUser.Collection.Item {
    
    /// Represents a custom note that a user may have added to an item.
    public class Note {
        
        /// The ID of the field.
        public let fieldID: Int
        
        private var value_ : String?
        
        /// The note. Use `validate()` to set the note.
        public var value: String? {
            return value_
        }
        
        /// The field.
        private var field: DGDiscogsUser.Collection.Field? = nil
        
        required public init(json: JSON) {
            self.fieldID = json["field_id"].intValue
            self.value_ = json["value"].string ?? ""
        }
        
        static func items(from array: [JSON]?) -> [Note]? {
            
            guard let array = array else { return nil }
            
            var items : [Note] = []
            
            for json in array {
                items.append(self.init(json: json))
            }
            
            return items
        }
        
        var dictionary: [String : Any] {
            
            return ["field_id" : fieldID,
                    "value" : value ?? ""]
        }
        
        /// Attempts to set the value of the note.  This method will return true if:
        /// - the `field`'s `fieldType` is a `textArea`, or
        /// - the `value` matches any of the `options` of the `field`
        ///
        /// - Parameter value: The new value of the note.
        /// - Returns: Whether the `value` is valid and has been successfully set.
        public func validate(_ value: String?) -> Bool {

            guard let field = field else { return false }

            return field.isValid(value)
        }
        
        internal func set(value: String?) {
            value_ = value
        }
        
        public func getField(forUser user: DGDiscogsUser, _ completion: @escaping (_ field: DGDiscogsUser.Collection.Field?) -> Void) {
            
            if let field = field {
                completion(field)
                return
            }
            
            user.collection.getCustomFields(completion: { (result) in
                
                switch result {
                    
                case .success(fields: let fields):
                    
                    guard let fields = fields,
                        let index = fields.index(where: { (field) -> Bool in
                            return field.discogsID == self.fieldID
                        })
                        else { return }
                    
                    self.field = fields[index]
                    
                    completion(self.field)
                    
                    break
                    
                case .failure(error: _): break
                }
            })
        }
    }
}
