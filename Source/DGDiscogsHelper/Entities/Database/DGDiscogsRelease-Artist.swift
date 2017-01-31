//
//  DGDiscogsReleaseArtist.swift
//  DGDiscogsHelper
//
//  Created by Daven Gomes on 12/11/2016.
//  Copyright © 2016 Daven Gomes. All rights reserved.
//

import Foundation
import SwiftyJSON

extension DGDiscogsRelease {
    
    public final class Artist : DGDiscogsItem {
        
        public let role : String?
        public let tracks : String?
        public let artist : DGDiscogsArtist!
        
        required public init(json: JSON) {
            
            self.role = json["role"].string
            self.artist = DGDiscogsArtist(json: json)
            self.tracks = json["tracks"].string
            
            super.init(json: json)
        }
        
        class func items(from array: [JSON]?) -> [Artist]? {
            return super.items(from: array) as? [Artist]
        }
    }
}
