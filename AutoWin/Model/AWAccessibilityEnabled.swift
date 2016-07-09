import Foundation

class AWAccessibilityEnabled:NSObject {
    dynamic var enabled = false

    override init() {
        enabled = AWAccessibilityAPI.isProcessTrusted()
        super.init()
        NSDistributedNotificationCenter.defaultCenter().addObserverForName(
            "com.apple.accessibility.api",
            object: nil, queue: nil, usingBlock: {(notifo:NSNotification) -> Void in
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.15 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
                    self.enabled = AWAccessibilityAPI.isProcessTrusted()
                })
        })
    }
}