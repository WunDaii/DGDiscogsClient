//
//  DGDiscogsUserCollection.swift
//  DGDiscogsHelper
//
//  Created by Daven Gomes on 10/12/2016.
//  Copyright © 2016 Daven Gomes. All rights reserved.
//

import Foundation

import SwiftyJSON
import Alamofire

public extension DGDiscogsUser {
}

// MARK: Network Requests
extension DGDiscogsUser.Collection {
    
    /// Retrieve a list of folders in a user’s collection. If the collection has been made private by its owner, authentication as the collection owner is required. If you are not authenticated as the collection owner, only the 'All' folder (with `discogsID` 0) will be visible (if the requested user’s collection is public).
    ///
    /// - Parameter completion: Called when the request has been completed.
    public func getFolders(
        refresh: Bool = false,
        completion: @escaping DGDiscogsCompletionHandlers.userCollectionFoldersCompletionHandler)
    {
        
        if let folders = folders,
            !refresh {
            completion(.success(folders: folders))
            return
        }
        
        guard
            let url: URLConvertible = self.user.resourceURLConvertible(appending: "collection/folders")
            else { return }
        
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
                
                self.folders = Folder.items(from: json["folders"].array, collection: self)
                completion(.success(folders: self.folders))
        })
    }
    
    /// Returns the minimum, median, and maximum value of the user’s collection.
    ///
    /// - Precondition: Authentication as the collection owner is required.
    /// - Parameter completion: Called when the request has been completed.
    public func getValue(
        completion: @escaping DGDiscogsCompletionHandlers.userCollectionValueCompletionHandler)
    {
        
        guard
            let url: URLConvertible = self.user.resourceURLConvertible(appending: "collection/value")
            else { return }
        
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
                
                
                let collectionValue = Value(json: json)
                completion(.success(collectionValue: collectionValue))
        })
    }
    
    /// Retrieve a list of user-defined collection notes fields. These fields are available on every release in the collection.
    /// If the collection has been made private by its owner, authentication as the collection owner is required.
    /// If you are not authenticated as the collection owner, only fields with `publicAvailable` set to `true` will be visible.
    ///
    /// - Precondition: Authentication as the collection owner is required.
    /// - Parameters:
    ///   - completion: Called once the request has been completed.
    public func getCustomFields(
        refresh: Bool = false,
        completion : @escaping DGDiscogsCompletionHandlers.userCollectionFieldsCompletionHandler)
    {
        
        if let fields = fields,
            !refresh {
            completion(.success(fields: fields))
            return
        }
        
        guard
            let url: URLConvertible = self.user.resourceURLConvertible(appending: "collection/fields")
            else { return }
        
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
                
                
                self.fields = Field.items(from: json["fields"].array)
                completion(.success(fields: self.fields))
        })
    }
    
    
    /// View the user’s collection folders which contain a specified release. This will also show information about each release instance.
    ///
    /// - Precondition: Authentication as the collection owner is required.
    /// - Parameters:
    ///   - release: The `DGDiscogsRelease` to look up in the user's collection.
    ///   - pagination: Pagination information for the request.
    ///   - completion: Called once the request has been completed.
    public func getCollectionFolders(
        for release: DGDiscogsRelease,
        with pagination: DGDiscogsUtils.Pagination = DGDiscogsUtils.Pagination(page: 1, perPage: 50),
        completion : @escaping DGDiscogsCompletionHandlers.userCollectionFolderItemsCompletionHandler)
    {
        
        guard
            let url: URLConvertible = self.user.resourceURLConvertible(appending: "collection/releases/\(release.discogsID ?? 0)")
            else { return }
        
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
                
                
                let pagination = DGDiscogsUtils.Pagination(json: json["pagination"])
                let items: [Item]? = Item.items(from: json["releases"].array)
                
                release.collectionItems = items
                
                completion(.success(pagination: pagination, items: items))
        })
    }
    
    /// Create a new folder in the user’s collection.
    ///
    /// - Parameters:
    ///   - name: The name of the folder.
    ///   - completion: Called once the request has been completed.
    public func createNewFolder(
        called name: String,
        completion : @escaping DGDiscogsCompletionHandlers.userCollectionCreateFolderCompletionHandler)
    {
        guard
            let url: URLConvertible = self.user.resourceURLConvertible(appending: "collection/folders")
            else { return }
        
        let params = ["name" : name]
        
        RequestHelper.sharedInstance.request(
            url: url,
            method: .post,
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
                
                
                if response?.statusCode == 201 {
                    let folder = Folder(json: json)
                    completion(.success(folder: folder))
                }
        })
    }
}
