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
    func activate(pid:pid_t) -> Bool
}

/*
Class that provides the javascript interface for aw.application.
*/
@objc class AWJSApplication : NSObject, AWJSApplicationInterface, AWManagerAppEvent {
    let appEvents = [
        NSWorkspaceDidLaunchApplicationNotification:"launched",
        NSWorkspaceDidTerminateApplicationNotification:"terminated",
        NSWorkspaceDidHideApplicationNotification:"hidden",
        NSWorkspaceDidUnhideApplicationNotification:"unhidden",
        NSWorkspaceDidActivateApplicationNotification:"activated",
        NSWorkspaceDidDeactivateApplicationNotification:"deactivated"
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
        print("deinit awjsapp")
    }
    
    // JS application api
    func applications() -> [NSDictionary] {
        return manager.applications().map(AWJSApplication.applicationToDictionary)
    }
    
    func activate(pid:pid_t) -> Bool {
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
    func appEventCallback(eventName: String, app: AWApplication) {
        print("triggering js app event: " + eventName)
        events.triggerEvent(
            "aw.application." + appEvents[eventName]!,
            eventData: AWJSApplication.applicationToDictionary(app))
    }
    
    class func applicationToDictionary(app: AWApplication) -> NSDictionary {
        let pid: NSNumber = NSNumber(int: app.pid)
        return ["pid": pid]
    }
}