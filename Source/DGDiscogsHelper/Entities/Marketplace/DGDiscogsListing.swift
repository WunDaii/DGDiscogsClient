//
//  DGDiscogsListing.swift
//  DGDiscogsHelper
//
//  Created by Daven Gomes on 24/11/2016.
//  Copyright © 2016 Daven Gomes. All rights reserved.
//

import Foundation

import SwiftyJSON
import Alamofire

/// Represents an item for sale in the Discogs Marketplace.
public final class DGDiscogsListing : DGDiscogsItem, DGDiscogsAuthenticatedProtocol {
    
    /// The status of a `DGDiscogsListing`.
    ///
    /// - forSale: the listing is ready to be shown on the Marketplace
    /// - draft: the listing is not ready for public display
    /// - expired: the listing has expired.
    /// - sold: the listing has been sold.
    public enum Status: String {
        case forSale = "For Sale"
        case draft = "Draft"
        case expired = "Expired"
        case sold = "Sold"
    }
    
    /// The status of the listing. Defaults to `forSale`.
    public var status: Status? = .forSale
    
    /// The price of the item (in the seller’s currency).
    public var price: DGDiscogsUtils.Price?
    
    /// The condition of the release.
    public var condition: Condition?
    
    /// The condition of the sleeve of the item you are posting.
    public var sleeveCondition: Condition?
    
    /// Whether or not to allow buyers to make offers on the item. Defaults to `false`.
    public var allowOffers: Bool
    public let shipsFrom: String?
    
    /// Any remarks about the item that will be displayed to buyers.
    public var comments: String?
    public let releaseVersion: DGDiscogsMasterRelease.Version!
    public let audio: Bool
    public var seller: DGDiscogsUser!
    
    /// A freeform field that can be used for the seller’s own reference. Information stored here will not be displayed to anyone other than the seller. This field is called “Private Comments” on the Discogs website.
    public var externalID: String?
    
    /// A freeform field that is intended to help identify an item’s physical storage location. Information stored here will not be displayed to anyone other than the seller. This field will be visible on the inventory management page and will be available in inventory exports via the website.
    public var location: String?
    
    /// The weight, in grams, of this listing, for the purpose of calculating shipping. Set this field to auto to have the weight automatically estimated for you when creating or editing a listing.
    public var weight: Double?
    
    /// The number of items this listing counts as, for the purpose of calculating shipping. This field is called “Counts As” on the Discogs website. Set this field to auto to have the quantity automatically estimated for you when creating or editing a listing.
    public var formatQuantity: Int?
    
    public var authenticated: Bool {
        return seller.discogsID == DGDiscogsManager.sharedInstance.user.discogsID
    }
    
    override var resourcePath : String? {
        get {
            return "marketplace/listings/\(discogsID)"
        }
    }
    
    required public init(json: JSON) {
        
        self.status = Status(rawValue: json["status"].string ?? "")
        self.price = DGDiscogsUtils.Price(json: json["price"])
        self.condition = Condition(rawValue: json["condition"].string ?? "")
        self.sleeveCondition = Condition(rawValue: json["sleeve_condition"].string ?? "")
        self.allowOffers = json["allow_offers"].bool ?? false
        self.shipsFrom = json["ships_from"].string
        self.comments = json["comments"].string
        self.releaseVersion = DGDiscogsMasterRelease.Version(json: json["release"])!
        self.audio = json["audio"].bool ?? false
        self.externalID = json["external_id"].string
        self.location = json["location"].string
        self.weight = json["weight"].doubleValue
        self.formatQuantity = json["format_quantity"].intValue
        self.seller = DGDiscogsUser(json: json["seller"])
        
        super.init(json: json)
    }
    
    class func items(
        from array: [JSON]?)
        -> [DGDiscogsListing]?
    {
        return super.items(from: array) as? [DGDiscogsListing]
    }
    
    var dictionary : [String : Any] {
        let params_ : [String : Any?] = ["listing_id" : discogsID,
                                         "release_id" : releaseVersion.basicRelease.discogsID,
                                         "condition" : condition?.rawValue ,
                                         "sleeve_condition" : sleeveCondition?.rawValue,
                                         "price" : price,
                                         "comments" : comments,
                                         "allow_offers" : allowOffers,
                                         "status" : status,
                                         "external_id" : externalID,
                                         "location" : location,
                                         "weight" : weight,
                                         "format_quantity" : formatQuantity]
        
        return DGDiscogsUtils.removeNilAndUnwrap(in: params_)
    }
    
    /// View the data associated with a listing.
    /// If the authorized user is the listing owner, the listing will include the weight, format quantity, external ID, and location values.
    ///
    /// - Parameter completion: Called once the request has been completed.
    override public func getInfo(
        completion: @escaping DGDiscogsCompletionHandlers.infoCompletionHandler)
    {
        super.getInfo(completion: completion)
    }
}

// MARK: Network Requests
extension DGDiscogsListing {
    
    public func add(
        completion : @escaping DGDiscogsCompletionHandlers.infoCompletionHandler)
    {
        let url : URLConvertible = "marketplace/listings"
        let params = self.dictionary
        
        RequestHelper.sharedInstance.request(
            url: url,
            method: .post,
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

            
            completion(.success(item: self))
        })
    }
    
    /// Edit the data associated with a listing.
    /// If the listing’s `status` is not `forSale`, `draft`, or `expired`, it cannot be modified – only deleted. To re-list a `sold` listing, a new listing must be created.
    ///
    /// - Parameter completion: Called once the request has been completed.
    public func update(
        completion : @escaping DGDiscogsCompletionHandlers.infoCompletionHandler)
    {
        guard
            let url : URLConvertible = dgResourceURL
            else { return }
        
        let params = self.dictionary
        
        RequestHelper.sharedInstance.request(
            url: url,
            method: .post,
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

            
            completion(.success(item: self))
        })
    }
    
    public func delete(
        completion : @escaping DGDiscogsCompletionHandlers.deleteCompletionHandler)
    {
        guard
            let url : URLConvertible = dgResourceURL
            else { return }
        
        RequestHelper.sharedInstance.request(
            url: url,
            method: .delete,
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

            
            completion(.success())
        })
    }
}
