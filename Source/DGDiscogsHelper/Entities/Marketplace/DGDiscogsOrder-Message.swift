//
//  DGDiscogsOrderMessage.swift
//  DGDiscogsHelper
//
//  Created by Daven Gomes on 03/12/2016.
//  Copyright © 2016 Daven Gomes. All rights reserved.
//

import Foundation

import SwiftyJSON

extension DGDiscogsOrder {

public class Message: DGDiscogsItem {
    
    public enum MessageType: String {
        case status = "status"
        case shipping = "shipping"
        case message = "message"
        case refundReceived = "refund_received"
        case refundSent = "refund_sent"
    }
    
    public let statusID: Int?
    public var message: String?
    public let subject: String?
    public var type: MessageType!
    public var order: DGDiscogsOrder?
    public var timestamp: Date?
    
    required public init(json: JSON) {
        self.statusID = json["status_id"].int
        self.message = json["message"].string
        self.subject = json["subject"].string
        self.type = MessageType(rawValue: json["status"].string ?? "")
        self.order = DGDiscogsOrder(optionalJson: json["order"])
        self.timestamp = DGDiscogsUtils.date(from: json["timestamp"].string)
        
        super.init(json: json)
    }
    
    class func items(from array: [JSON]?) -> [Message]? {
        return super.items(from: array) as? [Message]
    }
    
}
}

extension DGDiscogsOrder.Message {
    
    public final class Message: DGDiscogsOrder.Message {
        
        public let from: DGDiscogsUser!
        
        required public init(json: JSON) {
            self.from = DGDiscogsUser(json: json["from"])
            
            super.init(json: json)
        }
    }
    
    public final class Status: DGDiscogsOrder.Message {
        
        public let actor: DGDiscogsUser!
        
        required public init(json: JSON) {
            self.actor = DGDiscogsUser(json: json["actor"])
            
            super.init(json: json)
        }
    }
    
    public final class Shipping: DGDiscogsOrder.Message {
        
        public let original,
        new: Double!
        
        required public init(json: JSON) {
            self.original = json["original"].doubleValue
            self.new = json["new"].doubleValue
            
            super.init(json: json)
        }
    }
    
    /// A message created when a refund is sent or received.
    public final class RefundMessage: DGDiscogsOrder.Message {
        
        public let refund: DGDiscogsOrder.Refund!
        
        required public init(json: JSON) {
            self.refund = DGDiscogsOrder.Refund(json: json["refund"])
            
            super.init(json: json)
        }
    }
}
