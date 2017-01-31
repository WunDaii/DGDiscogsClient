//
//  DGDiscogsRelease-Community.swift
//  DGDiscogsHelper
//
//  Created by Daven Gomes on 11/12/2016.
//  Copyright © 2016 Daven Gomes. All rights reserved.
//

import Foundation

import SwiftyJSON

extension DGDiscogsRelease {
    
    public struct Community {
        public let contributors: [DGDiscogsUser]?
        //TODO: add data_quality
        public let have,
        want: Int
        public let status: String?
        public let submitter: DGDiscogsUser!
        public let rating: Rating
        
        init(json: JSON) {
            self.contributors = DGDiscogsUser.items(from: json["contributors"].array)
            self.have = json["have"].int ?? 0
            self.want = json["want"].int ?? 0
            self.status = json["status"].string
            self.submitter = DGDiscogsUser(json: json["submitter"])
            self.rating = Rating(json: json["rating"])
        }
    }
}
