//
//  ApplicationNotification.swift
//  Awesome
//
//  Created by Marshall Brekka on 4/18/15.
//  Copyright (c) 2015 Marshall Brekka. All rights reserved.
//

import Foundation
import Cocoa

class ApplicationNotification {
    let center:NSNotificationCenter
    let observers:[NSObjectProtocol] = []
    
    init () {
        // All notifications to listen for
        let notifications = [
            NSWorkspaceDidLaunchApplicationNotification,
            NSWorkspaceDidTerminateApplicationNotification,
            NSWorkspaceDidHideApplicationNotification,
            NSWorkspaceDidUnhideApplicationNotification,
            NSWorkspaceDidActivateApplicationNotification,
            NSWorkspaceDidDeactivateApplicationNotification
        ]
        
        center = NSWorkspace.sharedWorkspace().notificationCenter
        for notification in notifications {
            var observer = center.addObserverForName(
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
        println(notification.name)
    }
}
