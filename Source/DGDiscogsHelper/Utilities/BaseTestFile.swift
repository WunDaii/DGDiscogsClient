//
//  BaseTestFile.swift
//  DGDiscogsHelper
//
//  Created by Daven Gomes on 11/11/2016.
//  Copyright © 2016 Daven Gomes. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class BaseTestFile {
    
    let token = "wjNkTiNwOuZVcayyjFnDRNymvFmvtgktQektNNBV"
    let key = "QTTIIjwWZekVUQPCCUYI"
    let secret = "PSZaRdEaozndcMgLMsgFLEMhMStwDoLq"
    let baseURL = "https://api.discogs.com/"
    
    func run(completion: @escaping () -> Void?) {
        
        print("Run()")
        let url = "artists/2839269/releases"
//         url = "https://api.discogs.com/oauth/identity"
        
        RequestHelper.sharedInstance.request(url: url, method: .get, parameters: nil, completion: { (response, json, error) in
            
//            if let error = error {
//                completion(.failure(error: error))
//            }
//            
//            guard let json = json else {
//                completion(.failure(error: NSError(domain: "DGDiscogsClient", code: 500, userInfo: nil)))
//            }
            
            completion()
        })
    }
}
