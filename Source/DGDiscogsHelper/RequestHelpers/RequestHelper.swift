//
//  RequestHelper.swift
//  DGDiscogsHelper
//
//  Created by Daven Gomes on 12/11/2016.
//  Copyright © 2016 Daven Gomes. All rights reserved.
//

import Foundation

import Alamofire
import SwiftyJSON

public struct DGDiscogsAuthInfo {
    let token : String? = "wjNkTiNwOuZVcayyjFnDRNymvFmvtgktQektNNBV"
    let key = "QTTIIjwWZekVUQPCCUYI"
    let secret = "PSZaRdEaozndcMgLMsgFLEMhMStwDoLq"
}

class RequestHelper {
    
    static let sharedInstance = RequestHelper()
    static let baseURL = URL(string: "https://api.discogs.com/")!
    
    typealias completionHandler = (_ response : HTTPURLResponse, _ json : JSON?, _ error: NSError?) -> Void
    
    var discogsAuthInfo : DGDiscogsAuthInfo = DGDiscogsAuthInfo()
    
    func getStatusCode(forMethod method: HTTPMethod) -> Int {
        
        switch method {
        case .put:
            return 201
        case .delete:
            return 204
        default:
            return 200
        }
    }
    
    func request(
        url : URLConvertible,
        method : HTTPMethod = HTTPMethod.get,
        parameters: Parameters? = nil,
        headers: HTTPHeaders? = nil,
        authentication: Bool = false,
        encoding: ParameterEncoding = URLEncoding.default,
        expectingStatusCode: Int? = nil,
        completion : @escaping completionHandler)
    {
        var url = url
        if let urlString = url as? String, !urlString.contains(RequestHelper.baseURL.absoluteString) {
            url = RequestHelper.baseURL.appendingPathComponent(urlString)
        }
        
        let expectingStatusCode_ = expectingStatusCode ?? getStatusCode(forMethod: method)
        
        if let parameters = parameters {
            print("Parameters > \(parameters)")
        }

        SessionManager.default.request(url, method: method, parameters: parameters, encoding: encoding, headers: headers).responseJSON { response in
            
            guard let httpResponse = response.response else { return }
            
            print("*** GOT RESULT ***")
            print("*** Request > \(response.request)")  // original URL request
            print("*** Response > \(response.response)") // HTTP URL response
            print("*** Status Code > \(response.response?.statusCode)")  // original URL request
            print("*** Data > \(response.data)")     // server data
            print("*** Result > \(response.result)")   // result of response serialization
            
            
            
//            guard let statusCode = response.response?.statusCode,
//            statusCode == expectingStatusCode_
//                else {
//                print("Request failed > Expecting status code does not match.")
//                return
//            }
            
            switch response.result {
                
            case .success(let data):
                
                let json = JSON(data)
                print("- JSON < \(json)")
                completion(httpResponse, json, nil)
                
            case .failure(let error):
                print("Request failed with error: \(error)")
                print("Response headers: \(response.response?.allHeaderFields)")
                
                completion(httpResponse, nil, NSError(domain: "DGDiscogsClient", code: 500, userInfo: nil))

                return
            }
        }
    }
}
