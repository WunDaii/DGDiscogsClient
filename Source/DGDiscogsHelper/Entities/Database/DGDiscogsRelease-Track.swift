//
//  DGDiscogsTrack.swift
//  DGDiscogsHelper
//
//  Created by Daven Gomes on 12/11/2016.
//  Copyright © 2016 Daven Gomes. All rights reserved.
//

import Foundation

import SwiftyJSON

extension DGDiscogsRelease {

public final class Track : DGDiscogsItem {
    
    public let title : String!
    public let position : String!
    public let type : String?
    public let duration : String?
    public let extraArtists : [Artist]?
    
    required public init(json: JSON) {
        
        self.title = json["title"].string!
        self.duration = json["duration"].string
        self.extraArtists = Artist.items(from: json["extraartists"].array)
        self.type = json["type_"].string
        self.position = json["position"].string
        
        super.init(json: json)
    }
    
    class func items(from array: [JSON]?) -> [Track]? {
        return super.items(from: array) as? [Track]
    }
    }
}
