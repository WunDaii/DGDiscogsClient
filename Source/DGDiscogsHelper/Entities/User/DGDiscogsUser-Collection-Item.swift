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

extension DGDiscogsUser.Collection {
}

// MARK: Network Requests
extension DGDiscogsUser.Collection.Item {
    
    /// - Precondition: Authentication as the collection item owner is required.
    public func edit(
        note: Note,
        completion: @escaping DGDiscogsCompletionHandlers.editCompletionHandler) {
        
        guard
            let releaseID = basicRelease.discogsID,
            let url: URLConvertible = DGDiscogsManager.sharedInstance.user.resourcePath?.appending("collection/folders/\(self.folder?.discogsID ?? 1)/releases/\(releaseID)/instances/\(self.instanceID)/fields")
            else { return }
        
        let params = note.dictionary
        
        RequestHelper.sharedInstance.request(
            url: url,
            method: .post,
            parameters: params,
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
    
}
