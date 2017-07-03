import Foundation

class AWAccessibilityEnabled:NSObject {
    dynamic var enabled = false

    override init() {
        enabled = AWAccessibilityAPI.isProcessTrusted()
        super.init()
        DistributedNotificationCenter.default().addObserver(
            forName: NSNotification.Name("com.apple.accessibility.api"),
            object: nil, queue: nil, using: {(notifo:Notification) -> Void in
                let deadline = DispatchTime.now().uptimeNanoseconds + UInt64(UInt64(0.15 * Double(NSEC_PER_SEC)) / NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(
                    deadline: DispatchTime(uptimeNanoseconds: deadline),
                    qos: DispatchQoS.default,
                    flags: DispatchWorkItemFlags.noQoS,
                    execute: {
                        self.enabled = AWAccessibilityAPI.isProcessTrusted()
                    }

                )
        })
    }
}
