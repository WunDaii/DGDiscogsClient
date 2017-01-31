//
//  DGDiscogsUser-Submissions.swift
//  DGDiscogsHelper
//
//  Created by Daven Gomes on 17/12/2016.
//  Copyright © 2016 Daven Gomes. All rights reserved.
//

import Foundation

import SwiftyJSON

extension DGDiscogsUser {

    public struct Submissions {
        
        public var artists: [DGDiscogsArtist]
        public var labels: [DGDiscogsLabel]
        public var releases: [DGDiscogsRelease]
        
        init(json: JSON) {
            self.artists = DGDiscogsArtist.items(from: json["artists"].array) ?? []
            self.labels = DGDiscogsLabel.items(from: json["labels"].array) ?? []
            self.releases = DGDiscogsRelease.items(from: json["releases"].array) ?? []
        }
        
        mutating func add(json : JSON) {
            artists += DGDiscogsArtist.items(from: json["artists"].array) ?? []
            labels += DGDiscogsLabel.items(from: json["labels"].array) ?? []
            releases += DGDiscogsRelease.items(from: json["releases"].array) ?? []
        }
    }
}
