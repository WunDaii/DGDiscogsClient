# DGDiscogsClient
Swift client for the Discogs API.

## Installation

### CocoaPods (iOS 8+, OS X 10.9+) (Recommended)

You can install DGDiscogsClient via CocoaPods by adding to your Podfile:

```
    pod 'OAuthSwiftAlamofire'
    pod 'DGDiscogsClient', '0.0.1'
```

### Swift Package Manager 

You can install DGDiscogsClient via the Swift Package Manager by adding to your Package.swift file:

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

You must authorise the user with Discogs by using the auth flow provided by OAuthSwiftAlamofire.

1. Create an OAuth1Swift object with your credentials:

```
oauthSwift = OAuth1Swift(
            consumerKey:    "YOUR_CONSUMER_KEY”,
            consumerSecret: “YOUR_CONSUMER_SECRET”,
            requestTokenUrl: "https://api.discogs.com/oauth/request_token",
            authorizeUrl:    "https://discogs.com/oauth/authorize",
            accessTokenUrl:  "https://api.discogs.com/oauth/access_token"
        )
```

2. Add the RequestAdapter to DGDiscogsManager:
        
```
        DGDiscogsManager.sharedInstance.adapter = oauthSwift.requestAdapter
        let sessionManager = SessionManager.default
        sessionManager.adapter = oauthSwift.requestAdapter
```
        
3. Authorize with OAuthSwift:

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


