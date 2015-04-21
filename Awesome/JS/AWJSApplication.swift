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

protocol AWApplicationJSInterface {
    func applications() -> [AWApplication]
    func activate(pid: pid_t) -> Bool
}

@objc protocol AWJSApplicationInterface : JSExport {
    func applications() -> [NSDictionary]
    func activate(pid:pid_t) -> Bool
}


@objc class AWJSApplication :  NSObject, AWJSApplicationInterface {
    let events: AWJSEvent
    let delegate: AWApplicationJSInterface?
    
    init(events: AWJSEvent) {
        self.events = events
    }
    
    // JS application api
    func applications() -> [NSDictionary] {
        if delegate == nil {
            return []
        } else {
            return delegate!.applications()
                .map(AWJSApplication.applicationToDictionary)
        }
    }
    
    func activate(pid:pid_t) -> Bool {
        if delegate == nil {
            return false
        } else {
            return delegate!.activate(pid)
        }
    }
    
    // event handling api that impliments a protocol (soon)
    func launchedEvent(app:AWApplication) {
        triggerEvent("launched", app: app)
    }
    
    func terminatedEvent(app:AWApplication) {
        triggerEvent("terminated", app: app)
    }
    
    func activatedEvent(app:AWApplication) {
        triggerEvent("activated", app: app)
    }
    
    func deactivatedEvent(app:AWApplication) {
        triggerEvent("deactivated", app: app)
    }
    
    func hiddenEvent(app:AWApplication) {
        triggerEvent("hidden", app: app)
    }
    
    func unhiddenEvent(app:AWApplication) {
        triggerEvent("unhidden", app: app)
    }
    
    // generic fn for triggering an application event
    func triggerEvent(eventName: String, app: AWApplication) {
        events.triggerEvent(
            "aw.application." + eventName,
            eventData: AWJSApplication.applicationToDictionary(app))
        
    }
    
    class func applicationToDictionary(app: AWApplication) -> NSDictionary {
        var pid: NSNumber = NSNumber(int: app.pid)
        return ["pid": pid]
    }
}
