//
//  DGDiscogsWantlist.swift
//  DGDiscogsHelper
//
//  Created by Daven Gomes on 15/12/2016.
//  Copyright © 2016 Daven Gomes. All rights reserved.
//

import Foundation

import SwiftyJSON
import Alamofire

extension DGDiscogsUser {
    
}

// MARK: Network Requests
extension DGDiscogsUser.Wantlist {
    
    /// Returns the list of releases in a user’s wantlist. Accepts Pagination parameters.
    /// Basic information about each release is provided, suitable for display in a list. For detailed information, call `getInfo()` for the corresponding release.
    /// If the wantlist has been made private by its owner, you must be authenticated as the owner to view it.
    /// The notes field will be visible if you are authenticated as the wantlist owner.
    ///
    /// - Parameters:
    ///   - pagination: The pagination information for the request.
    ///   - completion: Called once the request has been completed.
    public func getWants(
        for pagination: DGDiscogsUtils.Pagination = DGDiscogsUtils.Pagination.defaultPagination,
        completion: @escaping DGDiscogsCompletionHandlers.userWantlistCompletionHandler)
    {
        guard
            let url: URLConvertible = user.wantlistURL ?? dgResourceURL
            else { return }
        
        let params = pagination.dictionary
        
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
                
                let wants: [DGDiscogsUser.Wantlist.Want]? = DGDiscogsUser.Wantlist.Want.items(from: json["wants"].array)
                
                completion(.success(pagination: pagination,
                                    wants: wants))
        })
    }
    
    public func add(
        _ want: Want,
        completion: @escaping DGDiscogsCompletionHandlers.userWantlistAddCompletionHandler)
    {
        guard
            let url: URLConvertible = resourceURLConvertible(appending: String(want.basicRelease.discogsID))
            else { return }
        
        let params: [String : Any] = want.dictionary
        
        RequestHelper.sharedInstance.request(
            url: url,
            method: .put,
            parameters: params,
            
            completion: { (response, json, error) in
                
                if let error = error {
                    completion(.failure(error: error))
                }
                
                guard let json = json else {
                    completion(.failure(error: NSError(domain: "DGDiscogsClient", code: 500, userInfo: nil)))
                    return
                }

                
                if let want = DGDiscogsUser.Wantlist.Want(optionalJson: json) {
                    completion(.success(want: want))
                }
        })
    }
    
    public func remove(
        _ want: Want,
        completion: @escaping DGDiscogsCompletionHandlers.deleteCompletionHandler)
    {
        guard
            let url: URLConvertible = resourceURLConvertible(appending: String(want.basicRelease.discogsID))
            else { return }
        
        RequestHelper.sharedInstance.request(
            url: url,
            method: .delete,
            parameters: nil,
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
    
    public func getWant(
        forRelease release: DGDiscogsRelease,
        completion: @escaping DGDiscogsCompletionHandlers.deleteCompletionHandler)
    {
        guard
            let url: URLConvertible = resourceURLConvertible(appending: String(release.discogsID))
            else { return }
        
        RequestHelper.sharedInstance.request(
            url: url,
            method: .post,
            parameters: nil,
            expectingStatusCode: 200,
            completion: { (response, json, error) in
                
                if let error = error {
                    completion(.failure(error: error))
                }
                
                guard let json = json else {
                    completion(.failure(error: NSError(domain: "DGDiscogsClient", code: 500, userInfo: nil)))
                    return
                }

                
                if response.statusCode == 404 {
                    completion(.failure(error: NSError(domain: "DGDiscogsClient", code: 404, userInfo: nil)))
                } else {
                    completion(.success())
                }
        })
    }
}
