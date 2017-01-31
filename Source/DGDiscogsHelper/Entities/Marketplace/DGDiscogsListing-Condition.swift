//
//  DGDiscogsListing-Condition.swift
//  DGDiscogsHelper
//
//  Created by Daven Gomes on 11/12/2016.
//  Copyright © 2016 Daven Gomes. All rights reserved.
//

import Foundation

extension DGDiscogsListing {
    
    public enum Condition : String{
        
        case mint = "Mint (M)"
        case nearMint = "Near Mint (NM or M-)"
        case veryGoodPlus = "Very Good Plus (VG+)"
        case veryGood = "Very Good (VG)"
        case goodPlus = "Good Plus (G+)"
        case good = "Good (G)"
        case fair = "Fair (F)"
        case poor = "Poor (P)"
        
        // Sleeve-specific conditions
        case generic = "Generic"
        case notGraded = "Not Graded"
        case noCover = "No Cover"
    }
}
