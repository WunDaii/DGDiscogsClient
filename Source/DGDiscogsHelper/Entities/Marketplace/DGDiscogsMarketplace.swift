//
//  DGDiscogsMarketplace.swift
//  DGDiscogsHelper
//
//  Created by Daven Gomes on 28/04/2017.
//
//

import Foundation

import Alamofire

public struct DGDiscogsMarketplace {
    
    static public func getPriceSuggestions(
        for release : DGDiscogsRelease,
        completion : @escaping DGDiscogsCompletionHandlers.priceSuggestionsCompletionHandler)
    {
        guard
            let discogsId = release.discogsID
            else { return }
        
        let url: URLConvertible = "marketplace/price_suggestions/\(discogsId)"

        RequestHelper.sharedInstance.request(
            url: url,
            method: .get,
            authentication: true,
            completion: { (response, json, error) in
                
                if let error = error {
                    completion(.failure(error: error))
                    return
                }
                
                guard let json = json else {
                    completion(.failure(error: NSError(domain: "DGDiscogsClient", code: 500, userInfo: nil)))
                    return
                }
                
                let priceSuggestions = DGDiscogsPriceSuggestions(json: json)
                
                completion(.success(priceSuggestions: priceSuggestions))
        })
    }
    
}
