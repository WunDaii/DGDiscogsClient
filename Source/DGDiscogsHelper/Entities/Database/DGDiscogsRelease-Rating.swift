//
//  DGDiscogsRelease-Rating.swift
//  DGDiscogsHelper
//
//  Created by Daven Gomes on 11/12/2016.
//  Copyright © 2016 Daven Gomes. All rights reserved.
//

import Foundation

import SwiftyJSON

extension DGDiscogsRelease {
    public struct Rating {
        public let average: Double?
        public let count: Int?
        
        init(json: JSON) {
            self.average = json["average"].double
            self.count = json["count"].int
        }
    }
}
