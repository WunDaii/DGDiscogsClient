//
//  DGDiscogsImage.swift
//  DGDiscogsHelper
//
//  Created by Daven Gomes on 12/11/2016.
//  Copyright © 2016 Daven Gomes. All rights reserved.
//

import Foundation
import SwiftyJSON

public final class DGDiscogsImage: DGDiscogsItem {
    
    public enum ImageType: String {
        case primary = "primary"
        case secondary = "secondary"
    }
    
    public let height: Int?
    public let width: Int?
    public let type: DGDiscogsImage.ImageType?
    public let uri150: URL?
    
    required public init(json: JSON) {
        
        self.height = json["height"].int
        self.width = json["width"].int
        self.uri150 = URL(string: json["uri150"].string)
        self.type = ImageType.init(rawValue: json["type"].string ?? "")
        
        super.init(json: json)
    }

    class func items(from array: [JSON]?) -> [DGDiscogsImage]? {
        return super.items(from: array) as? [DGDiscogsImage]
    }
}
