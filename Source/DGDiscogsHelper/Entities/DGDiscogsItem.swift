//
//  DGDiscogItem.swift
//  DGDiscogsHelper
//
//  Created by Daven Gomes on 11/11/2016.
//  Copyright © 2016 Daven Gomes. All rights reserved.
//

import Foundation

import SwiftyJSON
import Alamofire


/// An item represents an object in the Discogs database. These are represented by subclasses such as `DGDiscogsRelease`, `DGDiscogsArtist`, and `DGDiscogsRelease`.
public class DGDiscogsItem {
    
    /// The unique ID used to look-up the item in the Discogs database.
    public let discogsID : Int!
    
    /// The URL used to look-up the item on the Discogs database.
    public let resourceURL : URL?
    
    /// The URL used to visit the item's page on the Discogs website.
    public let uri : URL?
    
    /// A custom path to look-up the item on the Discogs database. It is recommended to override this field.
    var resourcePath : String? {
        get {
            return nil
        }
    }
    
    /// If a resource URL exists, this will be returned, else a custom path (the `dgPath`) will be returned.
    public var dgResourceURL : URLConvertible? {
        get{
            return resourceURL ?? resourcePath
        }
    }
    
    public init() {
        self.discogsID = nil
        self.resourceURL = nil
        self.uri = nil
    }
    
    required public init(json: JSON) {
        self.discogsID = json["id"].intValue
        self.resourceURL = URL(string: json["resource_url"].string)
        self.uri = URL(string: json["uri"].string)
    }
    
    public convenience init?(optionalJson: JSON?) {
        guard let json = optionalJson else { return nil }
        
        self.init(json: json)
    }
    
    
    /// Add a path to the current item's resource URL.
    ///
    /// - Parameter path: The path to add.
    /// - Returns: The final `URLConvertible` with the added `path`. This may be the full URL or simply the item's path.
    func resourceURLConvertible(appending path: String? = nil) -> URLConvertible? {
        guard let path = path else { return resourceURL }
        return resourceURL?.appendingPathComponent(path) ?? resourcePath?.appending("/" + path)
    }
    
    class func items(from array: [JSON]?) -> [DGDiscogsItem]? {
        
        guard let array = array else { return nil }
        
        var items : [DGDiscogsItem] = []
        
        for json in array {
            items.append(self.init(json: json))
        }
        
        return items
    }
    
    class func item(from json: JSON) -> DGDiscogsItem? {
        
        guard let type = json["type"].string else { return nil }
        
        return item(from: json, of: type)
    }
    
    class func item(from json: JSON, of type: String) -> DGDiscogsItem? {
        switch type {
        case "release":
            return DGDiscogsRelease(json: json)
        case "master":
            return DGDiscogsMasterRelease(json: json)
        case "artist":
            return DGDiscogsArtist(json: json)
        case "label":
            return DGDiscogsLabel(json: json)
        case "user":
            return DGDiscogsUser(json: json)
        default:
            return nil;
        }
    }
    
    var itemType : String {
        
        switch self {
            
        case is DGDiscogsArtist:
            return "artist";
        case is DGDiscogsMasterRelease:
            return "master"
        case is DGDiscogsRelease:
            return "release"
        case is DGDiscogsLabel:
            return "company"
        case is DGDiscogsUser:
            return "user"
        default:
            return "item"
        }
    }
    
    // This method is not in an extension as methods in extensions cannot be overridden yet in Swift 3 (using Xcode 8.1).
    public func getInfo(
        completion : @escaping DGDiscogsCompletionHandlers.infoCompletionHandler) {
        
        guard
            let path: URLConvertible = self.resourceURL ?? resourcePath
            else {
                completion(.failure(error: nil))
                return
        }
        
        RequestHelper.sharedInstance.request(
            url: path,
            method: .get,
            parameters: nil,
            
            completion: { (response, json, error) in
                
                if let error = error {
                    completion(.failure(error: error))
                    return
                }
                
                guard let json = json else {
                    completion(.failure(error: NSError(domain: "DGDiscogsClient", code: 500, userInfo: nil)))
                    return
                }
                
                if let item = DGDiscogsItem.item(from: json, of: self.itemType) {
                    completion(.success(item: item))
                }
        })
    }
    
    static func == (left: DGDiscogsItem, right: DGDiscogsItem) -> Bool {
        return left.discogsID == right.discogsID && left.itemType == right.itemType
    }
    
}
