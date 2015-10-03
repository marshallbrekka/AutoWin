//
//  ApplicationNotification.swift
//  Awesome
//
//  Created by Marshall Brekka on 4/18/15.
//  Copyright (c) 2015 Marshall Brekka. All rights reserved.
//

import Foundation
import Cocoa

protocol AWNotificationTarget {
    func recieveNotification(notification:NSNotification)
}

class AWNotification {
    let center:NSNotificationCenter
    var observers:[NSObjectProtocol] = []
    let target:AWNotificationTarget
    
    init (center: NSNotificationCenter, target:AWNotificationTarget, notifications:[String]) {
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
        target.recieveNotification(notification)
    }
}
