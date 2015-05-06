//
//  AWJSMonitors.swift
//  Awesome
//
//  Created by Marshall Brekka on 4/28/15.
//  Copyright (c) 2015 Marshall Brekka. All rights reserved.
//

import Foundation
import Cocoa
import JavaScriptCore

@objc protocol AWJSMonitorsInterface : JSExport {
    func monitors() -> [NSDictionary]
}

class AWJSMonitorsEvent: AWNotificationTarget {
    let events: AWJSEvent
    var notifier:AWNotification!
    
    init(events: AWJSEvent) {
        self.events = events
        self.notifier = AWNotification(center: NSNotificationCenter.defaultCenter(), target: self, notifications: [NSApplicationDidChangeScreenParametersNotification])
    }
    
    func recieveNotification(notification: NSNotification) {
        println("monitors changed")
        events.triggerEvent(
            "aw.monitors.layoutChange",
            eventData: nil)
    }
}

@objc class AWJSMonitors: NSObject, AWJSMonitorsInterface {
    let events: AWJSMonitorsEvent
    
    init(events:AWJSEvent) {
        self.events = AWJSMonitorsEvent(events: events);
    }
    
    /*
      each monitor includes the keys id and frame
      frame is an object with keys: width, height, x, y.
    */
    func monitors() -> [NSDictionary] {
        var monitors:[NSScreen] = NSScreen.screens() as! [NSScreen]
        var monitorDictionarys:[NSDictionary] = []
        for monitor in monitors {
            monitorDictionarys.append(AWJSMonitors.monitorToDictionary(monitor))
        }
        return monitorDictionarys
    }
    
    class func monitorToDictionary(monitor:NSScreen) -> NSDictionary {
        var frame = monitor.visibleFrame
        var objFrame = ["width": frame.size.width, "height": frame.size.height, "x": frame.origin.x, "y": frame.origin.y]
        var info:NSDictionary = monitor.deviceDescription as NSDictionary
        var result:NSDictionary = [
            "frame": objFrame,
            "id": info.objectForKey("NSScreenNumber") as! NSNumber
        ]
        return result
    }
    
}

