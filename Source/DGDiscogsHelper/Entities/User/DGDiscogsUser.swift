//
//  DGDiscogsUser.swift
//  DGDiscogsHelper
//
//  Created by Daven Gomes on 25/11/2016.
//  Copyright © 2016 Daven Gomes. All rights reserved.
//

import Foundation

import SwiftyJSON
import Alamofire

protocol DGDiscogsAuthenticatedProtocol {
    var authenticated: Bool { get }
}

/// Represents a user on Discogs. For an authenticated user, please refer to `DGDiscogsMasterUser`.
public class DGDiscogsUser: DGDiscogsItem, DGDiscogsAuthenticatedProtocol {
    
    /// Allows you to view and manage a user’s collection.
    public final class Collection: DGDiscogsAuthenticatedProtocol {
        
        public var folders: [Folder]?
        
        internal var fields: [Field]?
        
        public var uncategorizedFolder: Folder? {
            
            guard
                let index = folders?.index(where: { (folder) -> Bool in
                return folder.discogsID == 1
            })
                else { return nil }
            return folders?[index]
        }
        
        /// The monetary value of the collection.
        public struct Value {
            
            public let maximum: String?
            public let median: String?
            public let minimum: String?
            
            init(json: JSON) {
                self.maximum = json["maximum"].string
                self.median = json["median"].string
                self.minimum = json["minimum"].string
            }
        }
        
        /// The user which the collection belongs to.
        public let user: DGDiscogsUser
        
        public var authenticated: Bool {
            return user.discogsID == DGDiscogsManager.sharedInstance.user.discogsID
        }
        
        public var allFolder: Folder? {
            return folders?.filter({ (folder) -> Bool in
                return folder.discogsID == 0
            }).first
        }
        
        init(user: DGDiscogsUser) {
            self.user = user
            self.folders = nil
        }
        
        /// Represents an item in a user's collection folder.
        public final class Item: DGDiscogsItem, DGDiscogsAuthenticatedProtocol {
            
            public let instanceID: Int
            public let folderID: Int
            public let rating: Int
            public var basicRelease: DGDiscogsRelease
            public let notes: [Note]?
            public var folder: DGDiscogsUser.Collection.Folder?
            public let dateAdded: Date?
            public var authenticated: Bool {
                return folder?.collection?.user.discogsID == DGDiscogsManager.sharedInstance.user.discogsID
            }
            
            required public init(
                json: JSON,
                folder: DGDiscogsUser.Collection.Folder?)
            {
                self.instanceID = json["instance_id"].intValue
                let folderID = json["folder_id"].intValue
                self.folderID = folderID
                self.rating = json["rating"].intValue
                self.basicRelease = DGDiscogsRelease(json: json["basic_information"])
                basicRelease.set(userRating: self.rating)
                self.notes = Note.items(from: json["notes"].array)
                self.dateAdded = DGDiscogsUtils.date(from: json["date_added"].string)
                self.folder = folder ?? DGDiscogsManager.sharedInstance.user.collection.folders?.filter({ (folder) -> Bool in
                    return folder.discogsID == folderID
                }).first ?? DGDiscogsManager.sharedInstance.user.collection.uncategorizedFolder
                
                super.init(json: json)
            }
            
            init(
                json: JSON,
                folder: DGDiscogsUser.Collection.Folder? = DGDiscogsManager.sharedInstance.user.collection.uncategorizedFolder,
                release: DGDiscogsRelease)
            {
                
                self.instanceID = json["instance_id"].intValue
                self.folderID = json["folder_id"].intValue
                self.rating = json["rating"].intValue
                self.basicRelease = release
                basicRelease.set(userRating: self.rating)
                self.notes = Note.items(from: json["notes"].array)
                self.folder = folder ?? DGDiscogsManager.sharedInstance.user.collection.uncategorizedFolder
                self.dateAdded = Date()
                super.init(json: json)
            }
            
            required public convenience init(json: JSON) {
                self.init(json: json, folder: nil)
            }
            
            class func items(from array: [JSON]?) -> [Item]? {
                return super.items(from: array) as? [Item]
            }
            
            class func items(from array: [JSON]?, folder: DGDiscogsUser.Collection.Folder) -> [Item]? {
                guard let array = array else { return nil }
                
                var items : [Item] = []
                
                for json in array {
                    items.append(self.init(json: json, folder: folder))
                }
                
                return items
            }
            
            public override func getInfo(completion: @escaping DGDiscogsCompletionHandlers.infoCompletionHandler) {
                fatalError("Cannot call getInfo() on DGUser.Collection.Item.")
            }
        }
    }
    
    public final class Wantlist: DGDiscogsItem, DGDiscogsAuthenticatedProtocol {
        
        public let user: DGDiscogsUser!
        public var authenticated: Bool {
            return user.discogsID == DGDiscogsManager.sharedInstance.user.discogsID
        }
        override var resourcePath: String? {
            get {
                return "users/\(user.username ?? "NO_USERNAME_PROVIDED")/wants"
            }
        }
        
        public required init(json: JSON, user: DGDiscogsUser? = DGDiscogsManager.sharedInstance.user) {
            
            self.user = user
            
            super.init(json: json)
        }
        
        public init(user: DGDiscogsUser) {
            self.user = user
            super.init()
        }
        
        required public convenience init(json: JSON) {
            self.init(json: json, user: nil)
        }
        
        public convenience init?(optionalJson: JSON?) {
            guard let json = optionalJson else { return nil }
            self.init(json: json)
        }
    }
    
    public var username: String!
    public var location,
    profile,
    name,
    currencyAbbreviation: String?
    public let email: String?
    public var homepageURL : URL?
    public let inventoryURL,
    collectionFoldersURL,
    collectionFieldsURL,
    wantlistURL,
    avatarURL: URL?
    public let registered: Date?
    public let numberOfLists,
    numberForSale,
    numberInCollection,
    numberInWantlist,
    numberPending,
    releasesContributed,
    rank,
    releasesRated,
    sellerNumberOfRatings,
    buyerNumberOfRatings: Int?
    public let averageRating,
    buyerRating,
    sellerRating,
    buyerRatingStars,
    sellerRatingStars: Double?
    public var submissions: Submissions?
    public var contributions: Submissions?
    public var collection: DGDiscogsUser.Collection! = nil
    public var wantlist: Wantlist! = nil
    public var authenticated: Bool {
        return discogsID == DGDiscogsManager.sharedInstance.user.discogsID
    }
    
    override var resourcePath : String? {
        get {
            return "users/\(username!)/"
        }
    }
    
    required public init(json: JSON) {
        
        self.username = json["username"].stringValue
        self.profile = json["profile"].string
        self.wantlistURL = URL(string: json["wantlist_url"].string)
        self.homepageURL = URL(string: json["home_page"].string)
        self.location = json["location"].string
        self.name = json["name"].string
        self.email = json["email"].string
        self.currencyAbbreviation = json["curr_abbr"].string
        self.releasesContributed = json["releases_contributed"].int
        self.numberInCollection = json["num_collection"].int
        self.releasesRated = json["releases_rated"].int
        self.numberOfLists = json["num_lists"].int
        self.numberInWantlist = json["num_wantlist"].int
        self.sellerNumberOfRatings = json["seller_num_ratings"].int
        self.buyerNumberOfRatings = json["buyer_num_ratings"].int
        self.numberPending = json["num_pending"].int
        self.numberForSale = json["num_for_sale"].int
        self.rank = json["rank"].int
        self.averageRating = json["rating_avg"].double
        self.buyerRatingStars = json["buyer_rating_stars"].double
        self.buyerRating = json["buyer_rating"].double
        self.sellerRatingStars = json["seller_rating_stars"].double
        self.sellerRating = json["seller_rating"].double
        self.collectionFoldersURL = URL(string: json["collection_folders_url"].string)
        self.collectionFieldsURL = URL(string: json["collection_fields_url"].string)
        self.inventoryURL = URL(string: json["inventory_url"].string)
        self.avatarURL = URL(string: json["avatar_url"].string)
        self.registered = DGDiscogsUtils.date(from: json["registered"].string)
        
        super.init(json: json)
        
        self.collection = Collection(user: self)
        self.wantlist = Wantlist(user: self)
    }
    
    class func items(from array: [JSON]?) -> [DGDiscogsUser]? {
        return super.items(from: array) as? [DGDiscogsUser]
    }
}

// MARK: Network Requests
public extension DGDiscogsUser {
    
    /// Retrieve a user’s submissions by username.
    ///
    /// The Submissions resource represents all edits that a user makes to releases, labels, and artist.
    /// - Parameters:
    ///   - pagination: The pagination information for the request.
    ///   - completion: Called when the request has been completed.
    public func getSubmissions(
        for pagination: DGDiscogsUtils.Pagination = DGDiscogsUtils.Pagination.defaultPagination,
        completion: @escaping DGDiscogsCompletionHandlers.userSubmissionsCompletionHandler) {
        
        guard
            let url: URLConvertible = resourceURLConvertible(appending: "submissions")
            else { return }
        
        let params = pagination.dictionary
        
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

                
                let pagination = DGDiscogsUtils.Pagination(json: json["pagination"])
                
                if var submissions = self.submissions {
                    submissions.add(json: json)
                } else {
                    self.submissions = Submissions(json: json)
                }
                
                completion(.success(pagination: pagination,
                                    submissions: self.submissions!))
        })
    }
    
    /// Retrieve a user’s contribution.
    ///
    /// The contributions resource represents releases, labels, and artists submitted by a user.
    /// - Parameters:
    ///   - pagination: The pagination information for the request.
    ///   - sortOrder: Sort items by this field in a particular order.
    ///   - completion: Called when the request has been completed.
    public func getContributions(
        for pagination: DGDiscogsUtils.Pagination = DGDiscogsUtils.Pagination.defaultPagination,
        sortedBy sortOrder: DGDiscogsUtils.Sort? = nil,
        completion: @escaping DGDiscogsCompletionHandlers.userSubmissionsCompletionHandler)
    {
        
        guard
            let url: URLConvertible = resourceURLConvertible(appending: "contributions")
            else { return }
        
        var params: [String : Any] = pagination.dictionary
        
        if let sortOrder = sortOrder {
            params += sortOrder.dictionary
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

                
                let pagination = DGDiscogsUtils.Pagination(json: json["pagination"])
                
                if var contributions = self.contributions {
                    contributions.add(json: json)
                } else {
                    self.contributions = Submissions(json: json)
                }
                
                completion(.success(pagination: pagination,
                                    submissions: self.submissions!))
        })
    }
    
    // TODO: Add status:
    
    /// Returns the list of listings in a user’s inventory.
    /// Basic information about each listing and the corresponding release is provided, suitable for display in a list. For detailed information about the release, make another call to fetch the corresponding DGDiscogsRelease.
    ///
    /// If you are not authenticated as the inventory owner, only items that have a status of `forSale` will be visible.
    ///
    /// If you are authenticated as the inventory owner you will get additional `weight`, `formatQuantity`, `externalID`, and `location` data.
    /// - Parameters:
    ///   - pagination: The pagination information for the request.
    ///   - sortOrder: Sort items by this field in a particular order.
    ///   - completion: Called when the request has been completed.
    public func getListings(
        for pagination: DGDiscogsUtils.Pagination = DGDiscogsUtils.Pagination.defaultPagination,
        sortedBy sortOrder: DGDiscogsUtils.Sort? = nil,
        completion: @escaping DGDiscogsCompletionHandlers.userListingsCompletionHandler)
    {
        
        guard
            let url: URLConvertible = resourceURLConvertible(appending: "inventory")
            else { return }
        
        var params: [String : Any] = pagination.dictionary
        
        if let sortOrder = sortOrder {
            params += sortOrder.dictionary
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

                
                let pagination = DGDiscogsUtils.Pagination(json: json["pagination"])
                let listings : [DGDiscogsListing]? = DGDiscogsListing.items(from: json["listings"].array)
                
                completion(.success(pagination: pagination,
                                    listings: listings))
        })
    }
    
    /// Edit a user’s profile data.
    ///
    /// - Precondition: Authentication as the user is required.
    /// - Parameter completion: Called when the request has been completed
    public func update(
        completion: @escaping DGDiscogsCompletionHandlers.userUpdateCompletionHandler)
    {
        
        guard
            let url: URLConvertible = self.dgResourceURL
            else { return }
        
        let params = ["username" : username,
                      "name" : name,
                      "homepage" : homepageURL?.absoluteString,
                      "location" : location,
                      "profile" : profile,
                      "curr_abbr" : currencyAbbreviation]
        
        RequestHelper.sharedInstance.request(
            url: url,
            method: .post,
            parameters: params,
            completion: { (response, json, error) in
                
                if let error = error {
                    completion(.failure(error: error))
                    return
                }
                
                guard json != nil else {
                    completion(.failure(error: NSError(domain: "DGDiscogsClient", code: 500, userInfo: nil)))
                    return
                }

                completion(.success(user: self))
        })
    }
    
    /// Returns a list of the user’s orders.
    ///
    /// - Precondition: Authentication as the user is required.
    /// - Parameters:
    ///   - pagination: The pagination information for the request.
    ///   - status: Only show orders with this status.
    ///   - sortedBy: Sort items by this field and order.
    ///   - completion: Called when the request has been completed.
    public func getOrders(
        for pagination: DGDiscogsUtils.Pagination = DGDiscogsUtils.Pagination.defaultPagination,
        status: DGDiscogsOrder.Status? = nil,
        sortedBy: DGDiscogsUtils.Sort? = nil,
        completion: @escaping DGDiscogsCompletionHandlers.userOrdersCompletionHandler)
    {
        let url: URLConvertible = "marketplace/orders"
        
        var params: [String : Any] = pagination.dictionary
        
        if let sortedBy = sortedBy {
            params += sortedBy.dictionary
        }
        
        if let status = status {
            params += status.dictionary
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

                
                let pagination = DGDiscogsUtils.Pagination(json: json["pagination"])
                let orders : [DGDiscogsOrder]? = DGDiscogsOrder.items(from: json["orders"].array)
                
                completion(.success(pagination: pagination,
                                    orders: orders))
        })
    }
}
