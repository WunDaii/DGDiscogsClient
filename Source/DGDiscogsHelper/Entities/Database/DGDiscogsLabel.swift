//
//  DGDiscogsLabel.swift
//  DGDiscogsHelper
//
//  Created by Daven Gomes on 12/11/2016.
//  Copyright © 2016 Daven Gomes. All rights reserved.
//

import Foundation

import SwiftyJSON
import Alamofire

/// A label represents a label, company, recording studio, location, or other entity involved with an artist or release (represented by `DGDiscogsArtist` and `DGDiscogsRelease` instances).
public final class DGDiscogsLabel : DGDiscogsItem {
    
    public var name : String!
    public var entityType : Int!
    public var entityTypeName : String!
    public var catNo : String?
    public var profile : String?
    public var releasesURL : URL?
    public var contactInfo : String?
    public var sublabels : [DGDiscogsLabel]?
    public var urls : [URL]?
    public var images : [DGDiscogsImage]?
    public var releases : [DGDiscogsRelease]?
    override var resourcePath : String? {
        get {
            return "labels/\(discogsID)"
        }
    }
    
    required public init(json: JSON) {

        super.init(json: json)
        
        self.name = json["name"].string ?? ""
        self.entityType = json["entity_type"].int ?? 0
        self.entityTypeName = json["entity_type_name"].string ?? ""
        self.catNo = json["catno"].string ?? ""
        self.profile = json["profile"].string
        self.releasesURL = URL(string:json["releases_url"].string ?? "")
        self.sublabels = DGDiscogsLabel.items(from: json["sublabels"].array)
        self.urls = URL.urls(from: json["urls"].arrayObject as? [String])
        self.images = DGDiscogsImage.items(from: json["images"].array)
    }

    class func items(from array: [JSON]?) -> [DGDiscogsLabel]? {
        return super.items(from: array) as? [DGDiscogsLabel]
    }
}

// MARK: Network requests
extension DGDiscogsLabel {
    
    /// Returns a list of `DGDiscogsReleases` associated with the label.
    ///
    /// - Parameters:
    ///   - pagination: The pagination information for the request.
    ///   - completion: Called once the request has been completed.
    public func getReleases(
        for pagination : DGDiscogsUtils.Pagination,
        completion : @escaping DGDiscogsCompletionHandlers.releasesCompletionHandler)
    {
        guard
            let path: URLConvertible = self.releasesURL ?? self.resourcePath?.appending("releases")
            else { return }

        let params = ["page" : pagination.page,
                  "per_page" : pagination.perPage]
        
        RequestHelper.sharedInstance.request(
            url: path,
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
                
            self.releases = DGDiscogsRelease.items(from: json["releases"].array)
            let pagination = DGDiscogsUtils.Pagination(json: json["pagination"])
            
            completion(.success(pagination: pagination, releases: self.releases))
        })
    }
}
