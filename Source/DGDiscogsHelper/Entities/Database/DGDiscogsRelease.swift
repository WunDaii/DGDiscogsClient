//
//  DGDiscogsRelease.swift
//  DGDiscogsHelper
//
//  Created by Daven Gomes on 12/11/2016.
//  Copyright © 2016 Daven Gomes. All rights reserved.
//

import Foundation

import SwiftyJSON
import Alamofire

/// A release represents a particular physical or digital object released by one or more artists (represented by `DGDiscogsArtist` instances).
public class DGDiscogsRelease: DGDiscogsItem {
    
    private let artistName_: String?
    
    public let country: String?
    public let artists: [Artist]?
    public var artistNames: String? {
        return artists?.map({ (artist) -> String in
            return artist.artist.name
        }).joined(separator: ", ") ?? artistName_
    }
    public let extraArtists: [Artist]?
    public let title: String!
    public let tracklist: [Track]?
    public let notes: String?
    public let masterURL: URL?
    public let masterID: Int?
    public let lowestPrice: Double?
    public let numberForSale: Int!
    public let thumbURL: URL?
    public let images: [DGDiscogsImage]?
    public let videos: [DGDiscogsVideo]?
    public let genres: [String]?
    public let released: String?
    public let releaseFormatted: String?
    public let year: Int?
    public let estimatedWeight: Double?
    public let formats: [Format]?
    public let format: String?
    public let labels: [DGDiscogsLabel]?
    public let identifiers: [Identifier]?
    public let community: Community
    public var communityRating: Double?
    public var communityRatingCount: Int?
    private var userRating_: Int? = nil
    public var userRating: Int? {
        return userRating_
    }
    public var collectionItems: [DGDiscogsUser.Collection.Item]? = nil
    
    required public init(json: JSON) {
        
        self.artists = Artist.items(from: json["artists"].array)
        self.artistName_ = json["artist"].string
        self.country = json["country"].string
        self.extraArtists = Artist.items(from: json["extraartists"].array)
        self.community = Community(json: json["community"])
        self.title = json["title"].string!
        self.tracklist = Track.items(from: json["tracklist"].array)?
            .sorted {
                (s1, s2) -> Bool in
                return s1.position.localizedStandardCompare(s2.position) == .orderedAscending
        }
        self.notes = json["notes"].string
        self.masterID = json["master_id"].int
        self.masterURL = URL(string: json["master_url"].string)
        self.lowestPrice = json["lowest_price"].double
        self.thumbURL = URL(string: json["thumb"].string)
        self.images = DGDiscogsImage.items(from: json["images"].array)
        self.genres = (json["genres"].arrayObject ?? json["genre"].arrayObject) as? [String]
        self.numberForSale = json["num_for_sale"].int ?? 0
        self.year = json["year"].int
        self.released = json["released"].string
        self.releaseFormatted = json["released_formatted"].string
        self.videos = DGDiscogsVideo.items(from: json["videos"].array)
        self.estimatedWeight = json["estimated_weight"].double
        self.formats = Format.items(from: json["formats"].array)
        self.format = json["format"].string ?? (json["format"].arrayObject as? [String])?.joined(separator: ", ")
        self.labels = DGDiscogsLabel.items(from: json["labels"].array)
        self.identifiers = Identifier.items(from: json["identifiers"].array)
        self.userRating_ = json["rating"].int
        
        super.init(json: json)
    }
    
    class func items(from array: [JSON]?) -> [DGDiscogsRelease]? {
        return super.items(from: array) as? [DGDiscogsRelease]
    }
    
    internal func set(userRating: Int?) {
        self.userRating_ = userRating
    }
}

extension DGDiscogsRelease {
    
    public func getMasterRelease(
        completion: @escaping DGDiscogsCompletionHandlers.masterReleaseCompletionHandler)
    {
        guard let url = masterURL else { return }
        
        RequestHelper.sharedInstance.request(
            url: url,
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
                
                let masterRelease = DGDiscogsMasterRelease(json: json)
                completion(.success(masterRelease: masterRelease))
        })
    }
    
    /// Retrieves the release’s rating for a given user.
    ///
    /// - Parameters:
    ///   - user: The user of the rating you are trying to request.
    ///   - completion: Called when the request has been completed.
    public func getRating(
        refresh: Bool = false,
        for user: DGDiscogsUser,
        completion: @escaping DGDiscogsCompletionHandlers.userReleaseRatingCompletionHandler)
    {
        if let userRating = userRating,
            !refresh {
            completion(.success(rating: userRating))
            return
        }
        
        let path = "releases/\(self.discogsID!)/rating/\(user.username!)"
        
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
                
                self.set(userRating: json["rating"].int)
                
                completion(.success(rating: self.userRating))
        })
    }
    
    /// Updates the release’s rating for a given user.
    ///
    /// - Precondition: Authentication as the user is required.
    /// - Parameters:
    ///   - rating: The new rating for a release between 1 and 5.
    ///   - user: The user of the rating you are trying to request.
    ///   - completion: Called when the request has been completed.
    public func addRating(
        rating: Int,
        for user: DGDiscogsUser,
        completion: @escaping DGDiscogsCompletionHandlers.userReleaseRatingCompletionHandler)
    {
        let path = "releases/\(self.discogsID!)/rating/\(user.username!)",
        params: [String : Any] = ["release_id" : self.discogsID,
                                  "username" : user.username,
                                  "rating" : rating]
        
        RequestHelper.sharedInstance.request(
            url: path,
            method: .put,
            parameters: params,
            encoding: JSONEncoding.default,
            completion: { (response, json, error) in
                
                if let error = error {
                    completion(.failure(error: error))
                    return
                }
                
                guard let json = json else {
                    completion(.failure(error: NSError(domain: "DGDiscogsClient", code: 500, userInfo: nil)))
                    return
                }
                
                guard
                    json["username"].string == user.username,
                    json["release_id"].int == self.discogsID
                    else { return }
                
                self.set(userRating: json["rating"].int)
                
                completion(.success(rating: rating))
        })
    }
    
    /// Deletes the release’s rating for a given user.
    ///
    /// - Precondition: Authentication as the user is required.
    /// - Parameters:
    ///   - user: The user of the rating you are trying to request.
    ///   - completion: Called when the request has been completed.
    public func removeRating(
        for user: DGDiscogsUser,
        completion: @escaping DGDiscogsCompletionHandlers.userReleaseRatingCompletionHandler) {
        
        let path = "releases/\(self.discogsID!)/rating/\(user.username!)",
        params: [String : Any] = ["release_id" : self.discogsID,
                                  "username" : user.username]
        
        RequestHelper.sharedInstance.request(
            url: path,
            method: .delete,
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
                
                self.set(userRating: nil)
                completion(.success(rating: nil))
        })
    }
    
    /// Retrieves the community release rating average and count.
    ///
    /// - Parameter completion: Called when the request has been completed.
    public func getCommunityRating(
        completion: @escaping DGDiscogsCompletionHandlers.communityReleaseRatingCompletionHandler)
    {
        let path = "releases/\(self.discogsID)/rating",
        params: [String : Any] = ["number" : self.discogsID]
        
        RequestHelper.sharedInstance.request(
            url: path,
            method: .delete,
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
                
                self.communityRating = json["rating"]["average"].double
                self.communityRatingCount = json["rating"]["count"].int
                
                completion(.success(rating: self.communityRating))
        })
    }
    
    public func addToCollection(
        folder: DGDiscogsUser.Collection.Folder? = nil,
        completion: @escaping DGDiscogsCompletionHandlers.userCollectionAddItemCompletionHandler)
    {
        
        if let folder = folder {
            
            folder.add(self, completion: { (result) in
                completion(result)
            })
            
        } else {
            
            DGDiscogsManager.sharedInstance.user.collection.getFolders(completion: { (result) in
                switch result {
                    
                case .success(folders: _):
                    
                    if let uncategorized = DGDiscogsManager.sharedInstance.user.collection.uncategorizedFolder {
                        self.addToCollection(folder: uncategorized, completion: { (result) in
                            completion(result)
                        })
                    }
                    
                    break
                case .failure(error: let error):
                    completion(.failure(error: error))
                    break
                }
            })
            
        }
    }
    
    public func getCollectionFolders(
        with pagination: DGDiscogsUtils.Pagination = DGDiscogsUtils.Pagination(page: 1, perPage: 50),
        completion : @escaping DGDiscogsCompletionHandlers.userCollectionFolderItemsCompletionHandler)
    {
        DGDiscogsManager.sharedInstance.user.collection.getCollectionFolders(for: self, with: pagination) { (result) in
            completion(result)
        }
    }
}
