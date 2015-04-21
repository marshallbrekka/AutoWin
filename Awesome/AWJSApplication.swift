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


@objc protocol AWJSApplicationInterface : JSExport {
    func applications() -> [NSDictionary]
    func activate(pid:pid_t) -> Bool
}


@objc class AWJSApplication :  NSObject, AWJSApplicationInterface {
    let events: AWJSEvent
    
    init(events: AWJSEvent) {
        self.events = events
    }
    
    // JS application api
    func applications() -> [NSDictionary] {
        return [["thing": 2]]
    }
    
    func activate(pid:pid_t) -> Bool {
        return true
    }
    
    // event handling api that impliments a protocol (soon)
    func launchedEvent(app:Application) {
        triggerEvent("launched", app: app)
    }
    
    func terminatedEvent(app:Application) {
        triggerEvent("terminated", app: app)
    }
    
    func activatedEvent(app:Application) {
        triggerEvent("activated", app: app)
    }
    
    func deactivatedEvent(app:Application) {
        triggerEvent("deactivated", app: app)
    }
    
    func hiddenEvent(app:Application) {
        triggerEvent("hidden", app: app)
    }
    
    func unhiddenEvent(app:Application) {
        triggerEvent("unhidden", app: app)
    }
    
    // generic fn for triggering an application event
    func triggerEvent(eventName: String, app: Application) {
        var pid: NSNumber = NSNumber(int: app.pid)
        events.triggerEvent(
            "aw.application." + eventName,
            eventData: ["pid": pid])
        
    }
}
