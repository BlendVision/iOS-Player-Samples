#  Making the Custom PlayerLayer View

## Overview
A view that provides the BV Player UI and default UI handling to an attached UniPlayer instance. This view needs a `UniPlayer` instance to work properly. This Player can be passed to the initializer.

If a custom UI is preferred, an `AVPlayerLayer`  can be registered via registerPlayerLayer See `UniPlayerView` for more details.

### Usage
```swift
// Create a subclass of UIView
class CustomView: UIView {
    init(player: UniPlayer, frame: CGRect) {
        super.init(frame: frame)

        // register the AVPlayerLayer of this view to the Player
        player.register(playerLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var playerLayer: AVPlayerLayer {
        layer as! AVPlayerLayer
    }

    override class var layerClass: AnyClass {
        AVPlayerLayer.self
    }
}
```
