//
//  DGDiscogsVideo.swift
//  DGDiscogsHelper
//
//  Created by Daven Gomes on 12/11/2016.
//  Copyright © 2016 Daven Gomes. All rights reserved.
//

import Foundation

import SwiftyJSON

public struct DGDiscogsVideo {
    
    public let duration : Int?
    public let description : String?
    public let embed : Int!
    public let title : String!
    public let uri : URL?
    
    init?(json: JSON?) {
        
        guard let json = json else { return nil }
        
        self.duration = json["duration"].int
        self.description = json["description"].string
        self.embed = json["embed"].int ?? 0
        self.title = json["title"].string
        self.uri = URL(string: json["uri"].string)
    }
    
    static func items(from array: [JSON]?) -> [DGDiscogsVideo]? {
        
        guard let array = array else { return nil }
        
        var items : [DGDiscogsVideo] = []
        
        for item in array {
            if let dgItem = self.init(json: item) {
                items.append(dgItem)
            }
        }
        return items
    }
}
