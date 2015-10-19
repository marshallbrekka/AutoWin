/**
Class for listening to notifications that come from an NSNotificationCenter object.
Currently this is used for application and window level events.
*/

import Foundation
import Cocoa

protocol AWNotificationProto {
    
}

class AWNotificationStub : AWNotificationProto {

}

class AWNotification : AWNotificationProto {
    let center:NSNotificationCenter
    var observers:[NSObjectProtocol] = []
    let target:(NSNotification) -> Void
    
    init (center: NSNotificationCenter, target:(NSNotification) -> Void, notifications:[String]) {
        self.target = target
        
        self.center = center
        for notification in notifications {
            let observer = center.addObserverForName(
                notification,
                object: nil,
                queue: nil,
                usingBlock: reciever);
            observers.append(observer)
        }
    }
    
    deinit {
        // Unregister the notifications
        for observer in observers {
            center.removeObserver(observer)
        }
    }
    
    func reciever(notification:NSNotification!) {
        print("got notification: " + notification.name)
        target(notification)
    }
}
