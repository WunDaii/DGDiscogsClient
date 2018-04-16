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
    
    typealias completionHandler = (_ response : HTTPURLResponse?, _ json : JSON?, _ error: Error?) -> Void
    
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
                
        if let parameters = parameters {
            print("Parameters > \(parameters)")
        }
        
        SessionManager.default.request(url, method: method, parameters: parameters, encoding: encoding, headers: headers).responseJSON { response in
            
            guard
                let httpResponse = response.response
                else {
                    
                    completion(response.response, nil, response.result.error)
                    //                    self.responseError(response)
                    
                    return }
            
            print("*** GOT RESULT ***")
            print("*** Request > \(String(describing: response.request))")  // original URL request
            print("*** Response > \(String(describing: response.response))") // HTTP URL response
            print("*** Status Code > \(String(describing: response.response?.statusCode))")  // original URL request
            print("*** Data > \(String(describing: response.data))")     // server data
            print("*** Result > \(response.result)")   // result of response serialization
            
            switch response.result {
                
            case .success(let data):
                
                let json = JSON(data)
                print("- JSON < \(json)")
                completion(httpResponse, json, nil)
                break
                
            case .failure(let error):
                print("Request failed with error: \(error)")
                print("Response headers: \(String(describing: response.response?.allHeaderFields))")
                
                completion(httpResponse, nil, error)
                
                return
            }
        }
    }
    
    func responseError(_ response: DataResponse<Any>) {
        if let error = response.result.error as? AFError {
            switch error {
            case .invalidURL(let url):
                print("Invalid URL: \(url) - \(error.localizedDescription)")
            case .parameterEncodingFailed(let reason):
                print("Parameter encoding failed: \(error.localizedDescription)")
                print("Failure Reason: \(reason)")
            case .multipartEncodingFailed(let reason):
                print("Multipart encoding failed: \(error.localizedDescription)")
                print("Failure Reason: \(reason)")
            case .responseValidationFailed(let reason):
                print("Response validation failed: \(error.localizedDescription)")
                print("Failure Reason: \(reason)")
                
                switch reason {
                case .dataFileNil, .dataFileReadFailed:
                    print("Downloaded file could not be read")
                case .missingContentType(let acceptableContentTypes):
                    print("Content Type Missing: \(acceptableContentTypes)")
                case .unacceptableContentType(let acceptableContentTypes, let responseContentType):
                    print("Response content type: \(responseContentType) was unacceptable: \(acceptableContentTypes)")
                case .unacceptableStatusCode(let code):
                    print("Response status code was unacceptable: \(code)")
                }
            case .responseSerializationFailed(let reason):
                print("Response serialization failed: \(error.localizedDescription)")
                print("Failure Reason: \(reason)")
                // statusCode = 3840 ???? maybe..
            }
            
            print("Underlying error: \(String(describing: error.underlyingError))")
        } else if let error = response.result.error as? URLError {
            print("URLError occurred: \(error)")
        } else {
            print("Unknown error: \(String(describing: response.result.error))")
        }
    }
}
