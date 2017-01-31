//
//  DGDiscogsImages.swift
//  DGDiscogsHelper
//
//  Created by Daven Gomes on 08/01/2017.
//
//

import Foundation

import SwiftyJSON

public struct DGDiscogsImages {
    
    public let rawArray: [DGDiscogsImage]?
    
    public init?(json: [JSON]?) {
        
        guard let json = json,
            json.count > 0
            else { return  nil }
        
        self.rawArray = DGDiscogsImage.items(from: json)
    }
    
    public subscript(index: Int) -> DGDiscogsImage? {
        get {
            return rawArray?[index]
        }
    }
    
    public var count: Int {
        get {
            return rawArray?.count ?? 0
        }
    }
    
    public var primaryImage: DGDiscogsImage? {
        return rawArray?.first
    }

}

extension DGDiscogsImages: Sequence, IteratorProtocol {
    
    mutating public func next() -> Int? {
        
        var count = 0
        
        if let images = rawArray,
            count != images.count{
            defer { count += 1 }
            return count
        }
        
        return nil
    }
}
