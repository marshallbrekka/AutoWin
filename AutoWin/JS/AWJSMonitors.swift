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
        self.notifier = AWNotification(center: NotificationCenter.default, target: self, notifications: [NSNotification.Name.NSApplicationDidChangeScreenParameters])
    }
    
    deinit {
        NSLog("deinit AWJSMonitorsEvent")
        notifier.stop()
    }
    
    func receiveNotification(_ notification: Notification) {
        NSLog("monitors changed")
        events.triggerEvent(
            "aw.monitors.layoutChange",
            eventData: nil)
    }
}

@objc class AWJSMonitors: NSObject, AWJSMonitorsInterface {
    deinit {
        NSLog("deinit AWJSMonitors")
    }
    
    /*
      each monitor includes the keys id and frame
      frame is an object with keys: width, height, x, y.
    */
    func monitors() -> [NSDictionary] {
        let monitors:[NSScreen] = (NSScreen.screens() as [NSScreen]?)!
        var monitorDictionarys:[NSDictionary] = []
        for monitor in monitors {
            monitorDictionarys.append(AWJSMonitors.monitorToDictionary(monitors[0], monitor: monitor))
        }
        return monitorDictionarys
    }
    
    class func monitorToDictionary(_ main: NSScreen, monitor:NSScreen) -> NSDictionary {
        let frame = monitor.visibleFrame
        let objFrame = ["width": frame.size.width,
                        "height": frame.size.height,
                        "x": frame.origin.x,
                        // screen frame is in cartisian coord system, flip it to match windows.
                        "y": main.frame.size.height - monitor.visibleFrame.size.height - frame.origin.y]
        let info:NSDictionary = monitor.deviceDescription as NSDictionary
        let result:NSDictionary = [
            "frame": objFrame,
            "id": info.object(forKey: "NSScreenNumber") as! NSNumber
        ]
        return result
    }
}
