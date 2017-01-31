//
//  Extensions.swift
//  DGDiscogsHelper
//
//  Created by Daven Gomes on 11/11/2016.
//  Copyright © 2016 Daven Gomes. All rights reserved.
//

import Foundation

extension URL {
    
    init?(string: String?){
        guard let string = string else { return nil }
        self.init(string: string)
    }
    
    static func urls(from strings : [String]?) -> [URL]? {
        
        guard let strings = strings else { return nil }
        
        var urls = [URL]()
        
        for url in strings {
            if let dgURL = URL(string:url) {
                urls.append(dgURL)
            }
        }
        
        return urls
    }
}

func += <K, V> ( left: inout [K:V], right: [K:V]) {
    for (k, v) in right {
        left.updateValue(v, forKey: k)
    }
}
