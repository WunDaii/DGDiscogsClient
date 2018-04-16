//
//  DGDiscogsUtils.swift
//  DGDiscogsHelper
//
//  Created by Daven Gomes on 26/11/2016.
//  Copyright © 2016 Daven Gomes. All rights reserved.
//

import Foundation

import SwiftyJSON

public enum DGDiscogsError: Error {
    public enum Folder: Error {
        case deleteNotEmpty
    }
}

public struct DGDiscogsUtils {
    
    public struct Price {
        
        public let currency : String
        public let value : Double
        
        init?(json : JSON?) {
            guard let
                json = json,
                let currency = json["currency"].string,
                let value = json["value"].double
                else { return nil }
            
            self.currency = currency
            self.value = value
        }
    }
    
    public struct Sort {
        
        public enum SortBy: String {
            case label = "label"
            case artist = "artist"
            case title = "title"
            case catno = "catno"
            case format = "format"
            case rating = "rating"
            case year = "year"
            case added = "added"
        }
        
        public enum SortOrder: String {
            case ascending = "asc"
            case descending = "desc"
        }
        
        public init(sortBy: SortBy, sortOrder: SortOrder) {
            self.sortBy = sortBy
            self.sortOrder = sortOrder
        }
        
        public init?(sortBy: String, sortOrder: String) {
            
            guard
            let sortBy = SortBy(rawValue: sortBy),
                let sortOrder = SortOrder(rawValue: sortOrder)
                else { return nil }

            self.sortBy = sortBy
            self.sortOrder = sortOrder
        }
        
        public var sortBy : SortBy
        public var sortOrder : SortOrder
        
        var dictionary: [String : String] {
            return ["sort" : sortBy.rawValue,
                    "sort_order" : sortOrder.rawValue]
        }
    }
    
    public struct Pagination {
        
        public struct URLs {
            
            public let next: URL?
            public let previous: URL?
            public let first: URL?
            public let last: URL?
            
            init(json: JSON?) {
                next = json?["next"].url
                previous = json?["next"].url
                first = json?["first"].url
                last = json?["last"].url
            }
        }
        
        public let perPage : Int!
        public let items : Int!
        public let page: Int!
        public let urls : URLs
        public let pages : Int!
        
        init?(json: JSON?) {
            
            guard let json = json else { return nil }
            
            self.perPage = json["per_page"].int ?? 0
            self.items = json["items"].int ?? 0
            self.page = json["page"].int ?? 1
            self.urls = URLs(json: json["urls"])
            self.pages = json["pages"].int ?? 1
        }
        
        public init(page: Int, perPage: Int) {
            self.page = page
            self.perPage = perPage
            self.items = 0
            self.pages = 0
            self.urls = URLs(json: nil)
        }
        
        var dictionary: [String : Any] {
            return ["page" : page,
                    "per_page" : perPage]
        }
        
        static public var defaultPagination: Pagination {
            return Pagination(page: 1, perPage: 50)
        }
    }
    
    static func removeNilAndUnwrap(in dict: [String : Any?] ) -> [String : Any] {
        
        var newDict : [String : Any] = [:]
        
        for (key, value) in dict {
            if let value = value {
                newDict[key] = value
            }
        }
        
        return newDict
    }
    
    static func date(from dateString: String?) -> Date? {
        
        guard
            let dateString = dateString
            else { return nil }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        if let date = dateFormatter.date(from: dateString) {
            return date
        }
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.date(from: dateString)
    }
}
