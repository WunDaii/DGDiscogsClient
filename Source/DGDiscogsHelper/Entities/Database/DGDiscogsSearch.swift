//
//  DGDiscogsSearch.swift
//  DGDiscogsHelper
//
//  Created by Daven Gomes on 19/11/2016.
//  Copyright © 2016 Daven Gomes. All rights reserved.
//

import Foundation

import SwiftyJSON
import Alamofire

// TODO: Documentation
public final class DGDiscogsSearch {
    
    public final class Parameters {
        
        public var query,
        type,
        title,
        releaseTitle,
        credit,
        artist,
        anv,
        label,
        genre,
        style,
        country,
        year,
        format,
        catNo,
        barcode,
        track,
        submitter,
        contributor: String?
        
        var dictionary: [String : Any] {
            
            let dict: [String : String?] = ["query" : query,
                                          "type" : type,
                                          "title" : title,
                                          "release_title" : releaseTitle,
                                          "credit" : credit,
                                          "artist" : artist,
                                          "anv" : anv,
                                          "label" : label,
                                          "genre" : genre,
                                          "style" : style,
                                          "country" : country,
                                          "year" : year,
                                          "format" : format,
                                          "catno" : catNo,
                                          "barcode" : barcode,
                                          "track" : track,
                                          "submitter" : submitter,
                                          "contributor" : contributor]
            
//            let dict : [String : Any?] = ["query" : query,
//                                          "type" : type ?? "all",
//                                          "title" : title,
//                                          "release_title" : releaseTitle,
//                                          "credit" : credit,
//                                          "artist" : artist,
//                                          "anv" : anv,
//                                          "label" : label,
//                                          "genre" : genre,
//                                          "style" : style,
//                                          "country" : country,
//                                          "year" : year,
//                                          "format" : format,
//                                          "catno" : catNo,
//                                          "barcode" : barcode,
//                                          "track" : track,
//                                          "submitter" : submitter,
//                                          "contributor" : contributor]
            
            return DGDiscogsUtils.removeNilAndUnwrap(in: dict)
        }
        
        public init() {
            
        }
    }
    
    public var parameters: Parameters
    
    public init(parameters: Parameters = Parameters()) {
        self.parameters = parameters
    }
}

// MARK: Network requests
extension DGDiscogsSearch {
    
    public func search(
        for pagination : DGDiscogsUtils.Pagination? = nil,
        completion : @escaping DGDiscogsCompletionHandlers.searchCompletionHandler)
    {
        let url : URLConvertible = "database/search"
        var params = parameters.dictionary
        
        if let pagination = pagination {
            params += pagination.dictionary
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

            
            // TODO: Error handle
            
            guard let results = json["results"].array else { return }
            
            var items : [DGDiscogsItem] = []
            
            for result in results {
                if let item = DGDiscogsItem.item(from: result) {
                    items.append(item)
                }
            }
            
            let pagination = DGDiscogsUtils.Pagination(json: json["pagination"])
            
            completion(.success(pagination: pagination,
                                results: items))
        })
        
    }
}
