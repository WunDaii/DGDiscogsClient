//
//  DGDiscogsOrder.swift
//  DGDiscogsHelper
//
//  Created by Daven Gomes on 26/11/2016.
//  Copyright © 2016 Daven Gomes. All rights reserved.
//

import Foundation

import SwiftyJSON
import Alamofire

/// Allows you to manage a seller’s Marketplace orders.
public final class DGDiscogsOrder: DGDiscogsItem, DGDiscogsAuthenticatedProtocol {
    
    /// Represents the shipping information required for an order (represented by `DGDiscogsOrder`).
    public struct Shipping {
        
        /// The currency of which the `value` is given.
        public let currency: String?
        
        /// The method of shipping.
        public let method: String?
        
        /// The cost of shipping the order.
        public let value: Double?
        
        init(json: JSON) {
            self.currency = json["currency"].string
            self.method = json["method"].string
            self.value = json["value"].double
        }
    }
    
    public struct Refund {
        public let amount: Double!
        public let order: DGDiscogsOrder!
        
        init(json: JSON) {
            self.amount = json["amount"].doubleValue
            self.order = DGDiscogsOrder(json: json["order"])
        }
    }
    
    public enum Status: String {
        case all =  "All"
        case newOrder = "New Order"
        case buyerContacted = "Buyer Contacted"
        case invoiceSent = "Invoice Sent"
        case paymentPending = "Payment Pending"
        case paymentReceived = "Payment Received"
        case shipped = "Shipped"
        case merged = "Merged"
        case orderChanged = "Order Changed"
        case refundSent = "Refund Sent"
        case cancelled = "Cancelled"
        case cancelledNonPayingBuyer = "Cancelled (Non-Paying Buyer)"
        case cancelledItemUnavailable = "Cancelled (Item Unavailable)"
        case cancelledBuyersRequest = "Cancelled (Per Buyer's Request)"
        case cancelledRefundReceived = "Cancelled (Refund Received)"
        
        var dictionary : [String : String] {
            return ["status" : rawValue]
        }
    }
    
    public let messagesURL: URL?
    public let status: Status?
    public let nextStatus: [String]?
    public let fee: DGDiscogsUtils.Price?
    public let shipping: Shipping?
    public let items: [DGDiscogsListing]?
    public let shippingAddress: String?
    public let additionalInstructions: String?
    public let seller: DGDiscogsUser?
    public let buyer: DGDiscogsUser?
    public let total: DGDiscogsUtils.Price?
    
    public var authenticated: Bool {
        return seller?.discogsID == DGDiscogsManager.sharedInstance.user.discogsID
    }
    
    override var resourcePath : String? {
        get {
            return "marketplace/orders/\(discogsID)"
        }
    }
    
    required public init(json: JSON) {
        
        self.messagesURL = json["messages_url"].url
        self.status = Status(rawValue: json["status"].string ?? "")
        self.nextStatus = json["next_status"].arrayObject as? [String]
        self.fee = DGDiscogsUtils.Price(json: json["fee"])
        self.items = DGDiscogsListing.items(from: json["items"].array)
        self.shipping = Shipping(json: json["shipping"])
        self.shippingAddress = json["shipping_address"].string
        self.additionalInstructions = json["additional_instructions"].string
        self.seller = DGDiscogsUser(json: json["seller"])
        self.buyer = DGDiscogsUser(json: json["buyer"])
        self.total = DGDiscogsUtils.Price(json: json["total"])
        
        super.init(json: json)
    }
    
    convenience init?(optionalJson: JSON?) {
        guard let json = optionalJson else { return nil }
        self.init(json: json)
    }
    
    class func items(from array: [JSON]?) -> [DGDiscogsOrder]? {
        return super.items(from: array) as? [DGDiscogsOrder]
    }
}

// MARK: Network requests
extension DGDiscogsOrder {
    
    /// Edit the data associated with an order.
    ///
    /// - Parameter completion: Called once a response has been received.
    /// - Precondition: Authentication as the seller is required.
    public func update(
        completion : @escaping DGDiscogsCompletionHandlers.orderUpdateCompletionHandler)
    {
        guard
            let url: URLConvertible = dgResourceURL
            else { return }
        
        let params_: [String : Any?] = ["status" : status,
                                         "shipping" : shipping?.value]
        let params = DGDiscogsUtils.removeNilAndUnwrap(in: params_)
        
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
            
            let order = DGDiscogsOrder(json: json)
            completion(.success(order: order))
        })
    }
    
    
    /// Returns a list of the order’s messages with the most recent first.
    ///
    /// - Parameters:
    ///   - pagination: The pagination information for the request.
    ///   - completion: Called when the request has been completed.
    /// - Precondition: Authentication as the seller is required.
    public func getMessages(
        for pagination : DGDiscogsUtils.Pagination,
        completion : @escaping DGDiscogsCompletionHandlers.orderMessagesCompletionHandler)
    {
        guard
            let url: URLConvertible = messagesURL ?? resourceURLConvertible(appending: "messages")
            else { return }
        
        var params: [String : Any?] = ["order_id" : self.discogsID]
        params += pagination.dictionary
        
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
                
            let pagination = DGDiscogsUtils.Pagination(json: json["pagination"])
            let messages: [Message]? = Message.items(from: json["messages"].array)
            
            completion(.success(pagination: pagination, messages: messages))
        })
    }
}
