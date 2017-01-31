//
//  Package.swift
//  DGDiscogsHelper
//
//  Created by Daven Gomes on 18/12/2016.
//  Copyright © 2016 Daven Gomes. All rights reserved.
//

import PackageDescription

let package = Package(
    name: "DGDiscogsHelper",
    targets: [],
    dependencies: [
        .Package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", versions: Version(1,0,0)..<Version(3, .max, .max)),
        .Package(url: "https://github.com/Alamofire/Alamofire.git", majorVersion: 4)
        ]
)
