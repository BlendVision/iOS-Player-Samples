#  Player Analytics module

## Analytics Field Definition
`AnalyticsField.token`: The field is required, this appears to be a token or authentication key for analytics purposes.

`AnalyticsField.sessionId`: The field is optional, this represents a session identifier, likely used to track user sessions or interactions with the application.

`AnalyticsField.resourceId`: The field is optional, this could be an identifier for a specific resource or source within your application, used for tracking or categorization.

`AnalyticsField.resourceType`: The field is optional, this might indicate the type or category of the resource mentioned above.

`AnalyticsField.customData`: The field is optional, this seems to be a placeholder for custom data that you can include in your analytics events, allowing you to send additional information as needed.

## Important
In any case, you must obtain the `analytics license token` first in order to transmit player playback events to our data platform. 

## Usage
The sample code will show how to setup the analytics fields to the player, these additional information will be send to our data platform.
```swift
var moduleConfig: [String: String] {
    var config = [String: String]()
    config[AnalyticsField.token.rawValue] = "123456789" // replace "123456789" with your license
    config[AnalyticsField.sessionId.rawValue] = "session id"
    config[AnalyticsField.resourceId.rawValue] = "source id"
    config[AnalyticsField.resourceType.rawValue] = "resource type"
    config[AnalyticsField.customData.rawValue] = "custom data"
    return config
}

// Create player based on player config and module config
player = UniPlayerFactory.create(player: playerConfig, moduleConfig: moduleConfig)
```
