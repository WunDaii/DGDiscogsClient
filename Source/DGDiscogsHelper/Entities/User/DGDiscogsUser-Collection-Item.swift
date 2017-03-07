//
//  DGDiscogsCollectionRelease.swift
//  DGDiscogsHelper
//
//  Created by Daven Gomes on 10/12/2016.
//  Copyright © 2016 Daven Gomes. All rights reserved.
//

import Foundation

import SwiftyJSON
import Alamofire

// MARK: Network Requests
extension DGDiscogsUser.Collection.Item {
    
    /// - Precondition: Authentication as the collection item owner is required.
    public func edit(
        field: DGDiscogsUser.Collection.Field,
        value: String? = nil,
        completion: @escaping DGDiscogsCompletionHandlers.editCompletionHandler) {
        
        guard
            let releaseID = basicRelease.discogsID,
            let url: URLConvertible = DGDiscogsManager.sharedInstance.user.resourcePath?.appending("collection/folders/\(self.folder?.discogsID ?? 1)/releases/\(releaseID)/instances/\(self.instanceID)/fields/\(field.discogsID)")
            else { return }
        
        let params = ["value" : value]
        
        RequestHelper.sharedInstance.request(
            url: url,
            method: .post,
            parameters: params,
            encoding: JSONEncoding.default,
            expectingStatusCode: 204,
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
    
    public func getFolder(
        for user: DGDiscogsUser,
        _ completion: @escaping (_ folder: DGDiscogsUser.Collection.Folder?) -> Void)
    {
        user.collection.getFolders { (result) in
            
            switch result {
            case .success(folders: let folders):
                
                guard
                    let folders = folders,
                    let index = folders.index(where: { (folder) -> Bool in
                        return folder.discogsID == self.folderID
                    })
                    else {
                        completion(user.collection.uncategorizedFolder)
                        return
                }
                
                completion(folders[index])
                
                break
                
            case .failure(error: _):
                completion(user.collection.uncategorizedFolder)
                break
            }
            
        }
    }
    
    /// - Precondition: Authentication as the collection item owner is required.
    public func moveFolder(
        to folder: DGDiscogsUser.Collection.Folder,
        completion: @escaping DGDiscogsCompletionHandlers.editCompletionHandler) {
        
        guard
            let releaseID = basicRelease.discogsID,
            let url: URLConvertible = DGDiscogsManager.sharedInstance.user.resourcePath?.appending("collection/folders/\(self.folder?.discogsID ?? 1)/releases/\(releaseID)/instances/\(self.instanceID)")
            else { return }
        
        let params = ["folder_id" : folder.discogsID]
        
        RequestHelper.sharedInstance.request(
            url: url,
            method: .post,
            parameters: params,
            encoding: JSONEncoding.default,
            expectingStatusCode: 204,
            completion: { (response, json, error) in
                
                if let error = error {
                    completion(.failure(error: error))
                }
                
                guard let json = json else {
                    completion(.failure(error: NSError(domain: "DGDiscogsClient", code: 500, userInfo: nil)))
                    return
                }
                
                self.folder = folder
                
                completion(.success())
        })
    }}
