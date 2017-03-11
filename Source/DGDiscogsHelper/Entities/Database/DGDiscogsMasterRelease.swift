//
//  DGDiscogsMasterRelease.swift
//  DGDiscogsHelper
//
//  Created by Daven Gomes on 12/11/2016.
//  Copyright © 2016 Daven Gomes. All rights reserved.
//

import Foundation

import SwiftyJSON
import Alamofire

/// A master release represents a set of similar releases (represented by `DGDiscogsRelease` instances). Masters (also known as “master releases”) have a “main release” which is often the chronologically earliest.
public final class DGDiscogsMasterRelease : DGDiscogsRelease {
    
    public struct Version {
        
        public let catNo : String?
        public let format : String?
        public let label : String?
        public let resourceURL : URL?
        public let majorFormats : [String]?
        public let basicRelease: DGDiscogsRelease
        public let released: Date?
        
        init?(json : JSON?) {
            
            guard let json = json else { return nil }
            
            self.catNo = json["catno"].string ?? json["catalog_number"].string
            self.format = json["format"].string
            self.label = json["label"].string
            self.resourceURL = URL(string: json["resource_url"].string)
            self.majorFormats = json["major_formats"].arrayObject as? [String]
            self.basicRelease = DGDiscogsRelease(json: json)
            self.released = DGDiscogsUtils.date(from: json["released"].string)
        }
        
        static func items(from array: [JSON]?) -> [Version]? {
            
            guard let array = array else { return nil }
            
            var items : [Version] = []
            
            for item in array {
                if let dgItem = self.init(json: item) {
                    items.append(dgItem)
                }
            }
            return items
        }
    }
    
    public let mainReleaseID : Int?
    public let mainReleaseURL : URL?
    public let styles : [String]?
    public let versionsURL : URL?
    public var versions : [Version]?
    
    required public init(json: JSON) {
        
        self.mainReleaseID = json["main_release"].int
        self.mainReleaseURL = URL(string:json["main_release_url"].string)
        self.styles = json["styles"].arrayObject as? [String]
        self.versionsURL = URL(string: json["versions_url"].string)
        
        super.init(json: json)
    }
    
    class func items(from array: [JSON]?) -> [DGDiscogsMasterRelease]? {
        return DGDiscogsItem.items(from: array) as? [DGDiscogsMasterRelease]
    }
}

// MARK: Network requests
extension DGDiscogsMasterRelease {
    
    /// Retrieves a list of all Releases that are versions of this master.
    ///
    /// - Parameters:
    ///   - pagination: The pagination information for the request.
    ///   - completion: Called when the request has been completed.
    public func getVersions(
        for pagination : DGDiscogsUtils.Pagination? = nil,
        completion : @escaping DGDiscogsCompletionHandlers.masterVersionsCompletionHandler)
    {
        let url : URLConvertible = self.versionsURL ?? "masters/\(self.discogsID)/versions"
        
        let params = pagination?.dictionary

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
                
            self.versions = DGDiscogsMasterRelease.Version.items(from: json["versions"].array)
            let pagination = DGDiscogsUtils.Pagination(json: json["pagination"])
            
            completion(.success(pagination: pagination, versions: self.versions))
        })
    }
}
