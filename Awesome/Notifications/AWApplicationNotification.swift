//
//  ApplicationNotification.swift
//  Awesome
//
//  Created by Marshall Brekka on 4/18/15.
//  Copyright (c) 2015 Marshall Brekka. All rights reserved.
//

import Foundation
import Cocoa

class AWApplicationNotification : AWNotificationTarget {
    let notificationMapping = [
        NSWorkspaceWillLaunchApplicationNotification:    "launched",
        NSWorkspaceDidTerminateApplicationNotification:  "terminated",
        NSWorkspaceDidHideApplicationNotification:       "hidden",
        NSWorkspaceDidUnhideApplicationNotification:     "unhidden",
        NSWorkspaceDidActivateApplicationNotification:   "activated",
        NSWorkspaceDidDeactivateApplicationNotification: "deactivated"
    ]
    let manager:AWManager
    var notifier:AWNotification!
    
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
        notifier = AWNotification(center: NSWorkspace.sharedWorkspace().notificationCenter, target: self, notifications: notifications)
    }
    
    func recieveNotification(notification: NSNotification) {
        var name = notificationMapping[notification.name]
        var app = notification.userInfo![NSWorkspaceApplicationKey] as! NSRunningApplication
        manager.applicationEvent(name!, runningApp: app)
    }
    
}
