//
//  DGDiscogsUserCollectionFolder.swift
//  DGDiscogsHelper
//
//  Created by Daven Gomes on 10/12/2016.
//  Copyright © 2016 Daven Gomes. All rights reserved.
//

import Foundation

import SwiftyJSON
import Alamofire

extension DGDiscogsUser.Collection {
    
    /// A folder within the user's collection.
    public final class Folder: DGDiscogsItem, DGDiscogsAuthenticatedProtocol {
        
        /// The number of items (represented by Item) in the folder.
        public let count: Int
        
        /// The name of the folder. Editable if authenticated as the folder's owner.
        public var name: String?
        
        /// The collection to which the folder belongs.
        public let collection: DGDiscogsUser.Collection?
        
        override var resourcePath : String? {
            get {
                return "users/\(collection?.user.username ?? "NEEDS USERNAME")/collection/folders/\(self.discogsID!)"
            }
        }
        
        public var authenticated: Bool {
            return collection?.user.discogsID == DGDiscogsManager.sharedInstance.user.discogsID
        }
        
        required public init(json: JSON, collection: DGDiscogsUser.Collection?) {
            
            self.count = json["count"].intValue
            self.name = json["name"].string
            self.collection = collection
            
            super.init(json: json)
        }
        
        required public convenience init(json: JSON) {
            self.init(json: json, collection: nil)
        }
        
        class func items(from array: [JSON]?, collection: DGDiscogsUser.Collection) -> [Folder]? {
            
            guard
                let array = array
                else { return nil }
            
            var items : [Folder] = []
            
            for json in array {
                items.append(self.init(json: json,
                                       collection: collection))
            }
            
            return items
        }
    }
}

// MARK: Network Requests
extension DGDiscogsUser.Collection.Folder {
    
    /// Returns the list of item in a folder in a user’s collection. Basic information about each release is provided. For detailed information, call `getInfo` on the release.
    /// If the folder is not 'All', or the collection has been made private by its owner, refer to `DGDiscogsMasterUser.MasterCollection.MasterFolder` for access. Else, only public notes fields will be visible.
    ///
    /// - Warning: Authentication as the folder's owner may be required.
    /// - Parameters:
    ///   - pagination: The pagination information for the request.
    ///   - sortOrder: Sort items by this field in a particular order.
    ///   - completion: Called once the request has been completed.
    public func getItems(
        pagination: DGDiscogsUtils.Pagination = DGDiscogsUtils.Pagination.defaultPagination,
        sortedBy sortOrder: DGDiscogsUtils.Sort? = nil,
        completion : @escaping DGDiscogsCompletionHandlers.userCollectionFolderItemsCompletionHandler) {
        
        guard
            let url: URLConvertible = resourceURLConvertible(appending: "releases")
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
                }
                
                guard let json = json else {
                    completion(.failure(error: NSError(domain: "DGDiscogsClient", code: 500, userInfo: nil)))
                    return
                }

            
            let pagination = DGDiscogsUtils.Pagination(json: json["pagination"])
            let items : [DGDiscogsUser.Collection.Item]? = DGDiscogsUser.Collection.Item.items(from: json["releases"].array, folder: self)
                
            completion(.success(pagination: pagination,
                                items: items))
        })
    }
    
    /// Add a release to this folder.
    ///
    /// - Precondition: Authentication as the folder owner is required.
    /// - Parameters:
    ///   - release: The release to add.
    ///   - completion: Called once the request has been completed.
    public func add(
        _ release: DGDiscogsRelease,
        completion : @escaping DGDiscogsCompletionHandlers.userCollectionAddItemCompletionHandler) {
        
        guard
            let releaseID = release.discogsID,
            let url: URLConvertible = resourceURLConvertible(appending: "releases/\(releaseID)")
            else { return }

        RequestHelper.sharedInstance.request(
            url: url,
            method: .post,
            parameters: nil,
            
            completion: { (response, json, error) in
                
                if let error = error {
                    completion(.failure(error: error))
                }
                
                guard let json = json else {
                    completion(.failure(error: NSError(domain: "DGDiscogsClient", code: 500, userInfo: nil)))
                    return
                }

                
                let item = DGDiscogsUser.Collection.Item(json: json, folder: self, release: release)
                
                completion(.success(item: item))
        })
    }
    
    /// Remove an instance of a release from a user’s collection folder.
    ///
    /// - Precondition: Authentication as the folder owner is required.
    /// - Parameters:
    ///   - item: The collection item to remove from the folder.
    ///   - completion: Called once the request has been completed.
    public func delete(
        item: DGDiscogsUser.Collection.Item,
        completion : @escaping DGDiscogsCompletionHandlers.deleteCompletionHandler) {
        
        guard
            let url: URLConvertible = resourceURLConvertible(appending: "releases/\(item.basicRelease.discogsID)/instances/\(item.instanceID)")
            else { return }
        
        RequestHelper.sharedInstance.request(
            url: url,
            method: .delete,
            parameters: nil,
            
            completion: { (response, json, error) in
                
                if let error = error {
                    completion(.failure(error: error))
                }
                
                guard let json = json else {
                    completion(.failure(error: NSError(domain: "DGDiscogsClient", code: 500, userInfo: nil)))
                    return
                }

                
                completion(.success())
        })
    }
}
