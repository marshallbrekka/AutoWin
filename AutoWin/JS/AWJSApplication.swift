/*
** Application Level Events **
aw.application.launched
aw.application.terminated
aw.application.activated
aw.application.deactivated
aw.application.hidden
aw.application.unhidden
    
** Application functions **
                    
aw.application.applications()
aw.application.activate()
*/

import Foundation
import JavaScriptCore
import Cocoa

@objc protocol AWJSApplicationInterface : JSExport {
    func applications() -> [NSDictionary]
    func activate(_ pid:pid_t) -> Bool
}

/*
Class that provides the javascript interface for aw.application.
*/
@objc class AWJSApplication : NSObject, AWJSApplicationInterface, AWManagerAppEvent {
    let appEvents = [
        NSNotification.Name.NSWorkspaceDidLaunchApplication:"launched",
        NSNotification.Name.NSWorkspaceDidTerminateApplication:"terminated",
        NSNotification.Name.NSWorkspaceDidHideApplication:"hidden",
        NSNotification.Name.NSWorkspaceDidUnhideApplication:"unhidden",
        NSNotification.Name.NSWorkspaceDidActivateApplication:"activated",
        NSNotification.Name.NSWorkspaceDidDeactivateApplication:"deactivated"
    ]

    let manager:AWManager
    let events:AWJSEvent
    
    init(manager:AWManager, events: AWJSEvent) {
        self.manager = manager
        self.events = events
        super.init()
        self.manager.appEvent = self
    }
    
    deinit {
        NSLog("deinit AWJSApplication")
    }
    
    // JS application api
    func applications() -> [NSDictionary] {
        return manager.applications().map(AWJSApplication.applicationToDictionary)
    }
    
    func activate(_ pid:pid_t) -> Bool {
        if let app = manager.getApplication(pid) {
            return app.activate()
        } else {
            return false
        }
    }
    
    /*
    Triggers an event.
    Valid events are:
    launched, terminated, activated, deactivated, hidden, unhidden.
    */
    func appEventCallback(_ eventName: NSNotification.Name, app: AWApplication) {
        NSLog("triggering js app event: \(eventName.rawValue)")
        events.triggerEvent(
            "aw.application." + ((appEvents as NSDictionary)[eventName]! as! String),
            eventData: AWJSApplication.applicationToDictionary(app))
    }
    
    class func applicationToDictionary(_ app: AWApplication) -> NSDictionary {
        let pid: NSNumber = NSNumber(value: app.pid as Int32)
        return ["pid": pid]
    }
}
