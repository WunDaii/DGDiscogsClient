//
//  DGArtist.swift
//  DGDiscogsHelper
//
//  Created by Daven Gomes on 11/11/2016.
//  Copyright © 2016 Daven Gomes. All rights reserved.
//

import Foundation

import SwiftyJSON
import Alamofire

/// An artist represents a person in the Discogs database who contributed to a release (represented by a `DGDiscogsRelease` instance) in some capacity.
public final class DGDiscogsArtist: DGDiscogsItem {
    
    public let aliases: [DGDiscogsArtist]?
    public let name : String!
    public let realName : String?
    public let nameVariations : [String]?
    public let profile : String?
    public let images : DGDiscogsImages?
    public let urls : [URL]?
    public let releasesURL : URL?
    public let thumb: URL?
    public var releases : [DGDiscogsRelease]?
    public var members: [DGDiscogsArtist]?
    
    override var resourcePath : String? {
        get {
            return "artists/\(discogsID)"
        }
    }
    
    required public init(json: JSON) {
        
        self.aliases = DGDiscogsArtist.items(from: json["aliases"].array)
        self.name = json["name"].string ?? json["title"].string ?? ""
        self.realName = json["realName"].string
        self.nameVariations = json["namevariations"].arrayObject as? [String]
        self.profile = json["profile"].string
        self.urls = URL.urls(from: json["urls"].arrayObject as? [String])
        self.releasesURL = URL(string: json["releases_url"].string)
        self.thumb = json["thumb"].url
        self.members = DGDiscogsArtist.items(from: json["members"].array)
        self.images = DGDiscogsImages(json: json["images"].array)

        super.init(json: json)
    }
    
    class func items(from array: [JSON]?) -> [DGDiscogsArtist]? {
        return super.items(from: array) as? [DGDiscogsArtist]
    }
}

// MARK: Network requests
extension DGDiscogsArtist {
    
    /// Returns a list of `DGDiscogsReleases` and `DGDiscogsMasterReleases` associated with the artist.
    ///
    /// - Parameters:
    ///   - pagination: The pagination information for the request.
    ///   - completion: Called once the request has been completed.
    public func getReleases(
        for pagination : DGDiscogsUtils.Pagination = DGDiscogsUtils.Pagination(page: 1, perPage: 20),
        sortedBy sort: DGDiscogsUtils.Sort? = nil,
        completion : @escaping DGDiscogsCompletionHandlers.releasesCompletionHandler)
    {
        guard
            let url: URLConvertible = self.releasesURL ?? resourceURLConvertible(appending: "releases")
            else { return }
        
        var params = pagination.dictionary
        
        if let sort = sort {
            params += sort.dictionary
        }
        
        RequestHelper.sharedInstance.request(
            url: url,
            method: .get,
            parameters: params,
             completion: { (response, json, error) in
                
                if let error = error {
                    completion(.failure(error: error))
                    return
                }
                
                guard let json = json else {
                    completion(.failure(error: NSError(domain: "DGDiscogsClient", code: 500, userInfo: nil)))
                    return
                }

                
                if let releasesJSON = json["releases"].array {
                    
                    var releases: [DGDiscogsRelease] = []
                    
                    for json in releasesJSON {
                        if let type = json["type"].string,
                            type == "master" {
                            releases.append(DGDiscogsMasterRelease(json: json))
                        } else {
                            releases.append(DGDiscogsRelease(json: json))
                        }
                    }
                    
                    self.releases = releases
                    let pagination = DGDiscogsUtils.Pagination(json: json["pagination"])
                    
                    completion(.success(pagination: pagination, releases: self.releases))

                }
                
        })
    }
}
