//
//  DGDiscogsWantlist-Want.swift
//  DGDiscogsHelper
//
//  Created by Daven Gomes on 15/12/2016.
//  Copyright © 2016 Daven Gomes. All rights reserved.
//

import Foundation

import SwiftyJSON
import Alamofire

extension DGDiscogsUser.Wantlist {
    
    public final class Want: DGDiscogsItem {
        
        public var wantlist: DGDiscogsUser.Wantlist?
        public var rating: Int?
        public let basicRelease: DGDiscogsRelease
        public let dateAdded: Date?
        public let notes: String?
        
        public required init(json: JSON, wantlist: DGDiscogsUser.Wantlist?) {
            
            self.basicRelease = DGDiscogsRelease(json: json["basic_information"])
            self.rating = json["rating"].intValue
            self.dateAdded = DGDiscogsUtils.date(from: json["date_added"].string)
            self.notes = json["notes"].string
            self.wantlist = wantlist
            
            super.init(json: json)
        }
        
        public init(release: DGDiscogsRelease, rating: Int?, notes: String?) {
            self.basicRelease = release
            self.notes = notes
            self.wantlist = DGDiscogsManager.sharedInstance.user.wantlist
            self.dateAdded = nil
            super.init()
        }
        
        class func items(from array: [JSON]?) -> [DGDiscogsUser.Wantlist.Want]? {
            return super.items(from: array) as? [DGDiscogsUser.Wantlist.Want]
        }
        
        required public convenience init(json: JSON) {
            self.init(json: json, wantlist: nil)
        }
        
        public convenience init?(optionalJson: JSON?) {
            guard let json = optionalJson else { return nil }
            self.init(json: json)
        }
        
        var dictionary: [String : Any] {
            let dictionary: [String : Any] = ["username" : wantlist?.user?.username ?? DGDiscogsManager.sharedInstance.user.username!,
                    "release_id" : basicRelease.discogsID,
                    "notes" : notes ?? "",
                    "rating" : rating ?? 0]
            return DGDiscogsUtils.removeNilAndUnwrap(in: dictionary)
        }
    }
}

// MARK: Network Requests
extension DGDiscogsUser.Wantlist.Want {
    
    public func update(
        completion: @escaping DGDiscogsCompletionHandlers.userWantlistAddCompletionHandler)
    {
        guard
            let url: URLConvertible = resourceURLConvertible(appending: String(basicRelease.discogsID))
            else { return }
        
        let params: [String : Any] = dictionary
        
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

                
                if let want = DGDiscogsUser.Wantlist.Want(optionalJson: json) {
                    completion(.success(want: want))
                }
        })
    }
}
