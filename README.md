# DGDiscogsClient
Swift client for the Discogs API.

**_This library is still in development._**

## Installation

### CocoaPods (iOS 8+, OS X 10.9+) (Recommended)

You can install DGDiscogsClient via CocoaPods by adding to your Podfile:

```
    pod 'OAuthSwiftAlamofire'
    pod 'DGDiscogsClient', '0.0.1'
```

### Swift Package Manager 

You can install `DGDiscogsClient` via the [Swift Package Manager](https://swift.org/package-manager/) by adding to your `Package.swift` file:

```
import PackageDescription

let package = Package(
    name: "YOUR_PROJECT_NAME",
    targets: [],
    dependencies: [
        .Package(url: "https://github.com/WunDaii/DGDiscogsClient.git", version: “0.0.1”,
    ]
)
```

## Usage

### Authorization

You must authorise the user with Discogs by using the auth flow provided by [OAuthSwiftAlamofire](https://github.com/OAuthSwift/OAuthSwiftAlamofire).

1. Create an `OAuth1Swift` object with your credentials:

```
oauthSwift = OAuth1Swift(
            consumerKey:    "YOUR_CONSUMER_KEY”,
            consumerSecret: “YOUR_CONSUMER_SECRET”,
            requestTokenUrl: "https://api.discogs.com/oauth/request_token",
            authorizeUrl:    "https://discogs.com/oauth/authorize",
            accessTokenUrl:  "https://api.discogs.com/oauth/access_token"
        )
```

2. Add the `RequestAdapter` to `DGDiscogsManager`:
        
```
        DGDiscogsManager.sharedInstance.adapter = oauthSwift.requestAdapter
        let sessionManager = SessionManager.default
        sessionManager.adapter = oauthSwift.requestAdapter
```
        
3. Authorize with `OAuthSwift`:

```
            let _ = oauthSwift.authorize(
                withCallbackURL: URL(string: "recordshelf://oauth-callback/discogs")!,
                success: { credential, response, parameters in
                    print(credential.oauthToken)
                    print(credential.oauthTokenSecret)
                    
                    UserDefaults.standard.set(credential.oauthToken, forKey: "oauth_token")
                    UserDefaults.standard.set(credential.oauthTokenSecret, forKey: "oauth_token_secret")
                    
                    self.load()
            },
                failure: { error in
                    print(error.localizedDescription)
            })
        }
```
### Accessing the Discogs API

#### Overview

Each request on a `DGDiscogs` object returns an `enum` called 'result', that has two possible values: `success` and `failure`.  The `success` value will pass the expected values from the request, whilst the `failure` value typically returns an `NSError`.

##### Examples

```
        DGDiscogsManager.sharedInstance.getAuthenticatedUser { (result) in
            
            switch result {
                
            case .success():
                print("Successful")
                break
                
            case .failure(error: let error):
                print("There was an error: \(error?.localizedDescription)")
                break
                
            default:
                break
            }
        }
```
```
        let user = DGDiscogsManager.sharedInstance.user

        DGDiscogsManager.sharedInstance.user.getOrders { (result) in
            
            switch result {
                
            case .success(pagination: _, orders: let orders):
                
                guard
                    let orders = orders
                    else { return }
                
                print("The user has made \(orders.count) orders.")
                break
                
            case .failure(error: let error):
                print("There was an error: \(error?.localizedDescription)")
                break
                
            default:
                break
            }
            
        }
```

### Notes

* You may compare `DGDiscogsItems` using the `==` operator, as this will compare each `item`'s `discogsID` and `itemType` values.
* In requests where pagination is possible, you may omit the `pagination:` parameter when calling the method. This will default to a `DGDiscogsUtils.Pagination` with 20 items per page for page 1.

