/**
Class for listening to notifications that come from an NSNotificationCenter object.
Currently this is used for application and window level events.
*/
import Foundation
import Cocoa

protocol AWNotificationTarget:class {
    func receiveNotification(_ notifo: Notification)
}

class AWNotification {
    let center:NotificationCenter
    var observers:[NSObjectProtocol] = []
    weak var target:AWNotificationTarget?
    
    init (center: NotificationCenter, target:AWNotificationTarget, notifications:[NSNotification.Name]) {
        self.target = target
        
        self.center = center
        for notification in notifications {
            let observer = center.addObserver(
                forName: notification,
                object: nil,
                queue: nil,
                using: receiver);
            observers.append(observer)
        }
    }
    
    func stop() {
        NSLog("calling stop")
        // Unregister the notifications
        for observer in observers {
            center.removeObserver(observer)
        }
        observers = []
    }
    
    deinit {
        NSLog("deinit AWNotification")
    }
    
    func receiver(_ notification:Notification!) {
        NSLog("AWNotification received: \(notification.name)")
        if target != nil {
            target!.receiveNotification(notification)
        }
    }
}
