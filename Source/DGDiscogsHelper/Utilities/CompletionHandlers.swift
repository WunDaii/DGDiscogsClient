//
//  CompletionHandlers.swift
//  DGDiscogsHelper
//
//  Created by Daven Gomes on 13/11/2016.
//  Copyright © 2016 Daven Gomes. All rights reserved.
//

import Foundation

public final class DGDiscogsCompletionHandlers {
    
    // MARK: Generic
    
    public enum InfoResultType {
        case success(item : DGDiscogsItem)
        case failure(error: Error?)
    }
    
    public enum EditResultType {
        case success()
        case failure(error : Error?)
    }
    
    public enum DeleteResultType {
        case success()
        case failure(error : Error?)
    }
    
    // MARK: Release
    
    /// Result from requesting releases of a `DGDiscogsArtist` or `DGDiscogsLabel`
    ///
    /// - success: the request was successful with an array of `DGDiscogsReleases`
    /// - failure: the request was unsuccessful with an optional error
    public enum ReleasesResultType {
        case success(pagination: DGDiscogsUtils.Pagination?, releases: [DGDiscogsRelease]?)
        case failure(error: Error?)
    }
    
    public enum UserReleaseRatingResultType {
        case success(rating: Int?)
        case failure(error: Error?)
    }
    
    public enum CommunityReleaseRatingResultType {
        case success(rating: Double?)
        case failure(error: Error?)
    }
    
    // MARK: MasterRelease
    
    public enum MasterReleaseResultType {
        case success(masterRelease: DGDiscogsMasterRelease)
        case failure(error: Error?)
    }
    
    public enum MasterVersionsResultType {
        case success(pagination: DGDiscogsUtils.Pagination?, versions: [DGDiscogsMasterRelease.Version]?)
        case failure(error: Error?)
    }
    
    // MARK: Search
    
    public enum SearchResultType {
        case success(pagination: DGDiscogsUtils.Pagination?, results: [DGDiscogsItem]?)
        case failure(error : Error?)
    }
    
    // MARK: User
    
    public enum UserAuthenticationResultType {
        case success(user: DGDiscogsUser, jsonString: String?)
        case failure(error : Error?)
    }
    
    public enum UserUpdateResultType {
        case success(user: DGDiscogsUser)
        case failure(error : Error?)
    }
    
    public enum UserSubmissionsResultType {
        case success(pagination: DGDiscogsUtils.Pagination?, submissions: DGDiscogsUser.Submissions)
        case failure(error : Error?)
    }
    
    public enum UserListingsResultType {
        case success(pagination: DGDiscogsUtils.Pagination?, listings: [DGDiscogsListing]?)
        case failure(error : Error?)
    }
    
    public enum UserOrdersResultType {
        case success(pagination: DGDiscogsUtils.Pagination?, orders: [DGDiscogsOrder]?)
        case failure(error : Error?)
    }
    
    // MARK: User Collection
    
    public enum UserCollectionFoldersResultType {
        case success(folders: [DGDiscogsUser.Collection.Folder]?)
        case failure(error : Error?)
    }
    
    public enum UserCollectionCreateFolderResultType {
        case success(folder: DGDiscogsUser.Collection.Folder)
        case failure(error : Error?)
    }
    
    public enum UserCollectionFolderItemsResultType {
        case success(pagination: DGDiscogsUtils.Pagination?, items: [DGDiscogsUser.Collection.Item]?)
        case failure(error : Error?)
    }
    
    public enum UserCollectionAddItemResultType {
        case success(item: DGDiscogsUser.Collection.Item)
        case failure(error : Error?)
    }
    
    public enum UserCollectionValueResultType {
        case success(collectionValue: DGDiscogsUser.Collection.Value)
        case failure(error : Error?)
    }
    
    public enum UserCollectionFieldsResultType {
        case success(fields: [DGDiscogsUser.Collection.Field]?)
        case failure(error : Error?)
    }
    
    public enum UserWantlistResultType {
        case success(pagination: DGDiscogsUtils.Pagination?, wants: [DGDiscogsUser.Wantlist.Want]?)
        case failure(error : Error?)
    }
    
    // MARK: Wantlist
    
    public enum UserWantlistAddResultType {
        case success(want: DGDiscogsUser.Wantlist.Want)
        case failure(error : Error?)
    }
    
    // MARK: Order
    
    public enum OrderUpdateResultType {
        case success(order: DGDiscogsOrder)
        case failure(error : Error?)
    }
    
    public enum OrderMessagesResultType {
        case success(pagination: DGDiscogsUtils.Pagination?, messages: [DGDiscogsOrder.Message]?)
        case failure(error : Error?)
    }
    
    public enum PriceSuggestionsResultType {
        case success(priceSuggestions: DGDiscogsPriceSuggestions)
        case failure(error : Error?)
    }
    
    // MARK: Completion Handlers
    
    public typealias infoCompletionHandler = (_ result: InfoResultType) -> Void
    public typealias editCompletionHandler = (_ result: EditResultType) -> Void
    public typealias deleteCompletionHandler = (_ result: DeleteResultType) -> Void
    
    public typealias releasesCompletionHandler = (_ result: ReleasesResultType) -> Void
    public typealias masterVersionsCompletionHandler = (_ result: MasterVersionsResultType) -> Void
    public typealias userReleaseRatingCompletionHandler = (_ result: UserReleaseRatingResultType) -> Void
    public typealias communityReleaseRatingCompletionHandler = (_ result: CommunityReleaseRatingResultType) -> Void
    public typealias masterReleaseCompletionHandler = (_ result: MasterReleaseResultType) -> Void
    
    public typealias searchCompletionHandler = (_ result: SearchResultType) -> Void
    
    public typealias userAuthenticationCompletionHandler = (_ result: UserAuthenticationResultType) -> Void
    public typealias userUpdateCompletionHandler = (_ result: UserUpdateResultType) -> Void
    public typealias userSubmissionsCompletionHandler = (_ result: UserSubmissionsResultType) -> Void
    public typealias userListingsCompletionHandler = (_ result: UserListingsResultType) -> Void
    public typealias userOrdersCompletionHandler = (_ result: UserOrdersResultType) -> Void
    
    public typealias userCollectionFoldersCompletionHandler = (_ result: UserCollectionFoldersResultType) -> Void
    public typealias userCollectionCreateFolderCompletionHandler = (_ result: UserCollectionCreateFolderResultType) -> Void
    public typealias userCollectionFolderItemsCompletionHandler = (_ result: UserCollectionFolderItemsResultType) -> Void
    public typealias userCollectionAddItemCompletionHandler = (_ result: UserCollectionAddItemResultType) -> Void
    public typealias userCollectionValueCompletionHandler = (_ result: UserCollectionValueResultType) -> Void
    public typealias userCollectionFieldsCompletionHandler = (_ result: UserCollectionFieldsResultType) -> Void
    public typealias userWantlistCompletionHandler = (_ result: UserWantlistResultType) -> Void
    
    public typealias userWantlistAddCompletionHandler = (_ result: UserWantlistAddResultType) -> Void
    
    public typealias orderUpdateCompletionHandler = (_ result: OrderUpdateResultType) -> Void
    public typealias orderMessagesCompletionHandler = (_ result: OrderMessagesResultType) -> Void
    public typealias priceSuggestionsCompletionHandler = (_ result: PriceSuggestionsResultType) -> Void
}
