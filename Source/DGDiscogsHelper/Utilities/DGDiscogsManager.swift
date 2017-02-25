//
//  DGDiscogsManager.swift
//  DGDiscogsHelper
//
//  Created by Daven Gomes on 13/11/2016.
//  Copyright © 2016 Daven Gomes. All rights reserved.
//

import Foundation

import Alamofire
import SwiftyJSON

public class DGDiscogsManager {
    
    public static let sharedInstance = DGDiscogsManager()
    
    public var user: DGDiscogsUser! = nil
    
    public var adapter = SessionManager.default.adapter
    
    public func getAuthenticatedUser(
        setAsMainUser: Bool = false,
        completion : @escaping DGDiscogsCompletionHandlers.userAuthenticationCompletionHandler) {
        
        let url: URLConvertible = "oauth/identity"
        
        print("Must get auth user")
        
        RequestHelper.sharedInstance.request(
            url: url,
            method: .get,
            parameters: nil,
            
            completion: { (response, json, error) in
                
                if let error = error {
                    completion(.failure(error: error))
                }
                
                guard let json = json else {
                    completion(.failure(error: NSError(domain: "DGDiscogsClient", code: 500, userInfo: nil)))
                    return
                }
                
                let user = DGDiscogsUser(json: json)
                
                if setAsMainUser {
                    self.user = user
                }
                
                completion(.success(user: user, jsonString: json.rawString()))
        })
    }
    
}
