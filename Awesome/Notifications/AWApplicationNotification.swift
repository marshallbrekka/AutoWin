//
//  ApplicationNotification.swift
//  Awesome
//
//  Created by Marshall Brekka on 4/18/15.
//  Copyright (c) 2015 Marshall Brekka. All rights reserved.
//

import Foundation
import Cocoa

class AWApplicationNotification {
    let notificationMapping = [
        NSWorkspaceWillLaunchApplicationNotification:    "launched",
        NSWorkspaceDidTerminateApplicationNotification:  "terminated",
        NSWorkspaceDidHideApplicationNotification:       "hidden",
        NSWorkspaceDidUnhideApplicationNotification:     "unhidden",
        NSWorkspaceDidActivateApplicationNotification:   "activated",
        NSWorkspaceDidDeactivateApplicationNotification: "deactivated"
    ]
    let center:NSNotificationCenter
    var observers:[NSObjectProtocol] = []
    let manager:AWManager
    
    init (manager:AWManager) {
        self.manager = manager
        
        // All notifications to listen for
        let notifications = [
            NSWorkspaceWillLaunchApplicationNotification,
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
        println("got notification: " + notification.name)
        var name = notificationMapping[notification.name]
        var app = notification.userInfo![NSWorkspaceApplicationKey] as! NSRunningApplication
        manager.applicationEvent(name!, runningApp: app)
    }
}
