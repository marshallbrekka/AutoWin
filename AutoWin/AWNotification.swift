/**
Class for listening to notifications that come from an NSNotificationCenter object.
Currently this is used for application and window level events.
*/
import Foundation
import Cocoa

protocol AWNotificationTarget:class {
    func receiveNotification(notifo: NSNotification)
}

class AWNotification {
    let center:NSNotificationCenter
    var observers:[NSObjectProtocol] = []
    weak var target:AWNotificationTarget?
    
    init (center: NSNotificationCenter, target:AWNotificationTarget, notifications:[String]) {
        self.target = target
        
        self.center = center
        for notification in notifications {
            let observer = center.addObserverForName(
                notification,
                object: nil,
                queue: nil,
                usingBlock: receiver);
            observers.append(observer)
        }
    }
    
    func stop() {
        print("calling stop")
        // Unregister the notifications
        for observer in observers {
            center.removeObserver(observer)
        }
        observers = []
    }
    
    deinit {
        print("killing notifier")
    }
    
    func receiver(notification:NSNotification!) {
        print("got notification: " + notification.name)
        if target != nil {
            target!.receiveNotification(notification)
        }
    }
}