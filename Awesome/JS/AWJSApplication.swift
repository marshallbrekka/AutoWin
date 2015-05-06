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

/*
Class that provides the javascript interface for aw.application.
*/
@objc class AWJSApplication :  NSObject, AWJSApplicationInterface {
    let events: AWJSEvent
    let delegate: AWApplicationJSInterface? = nil
    
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
    
    /*
    Triggers an event.
    Valid events are:
    launched, terminated, activated, deactivated, hidden, unhidden.
    */
    func triggerEvent(eventName: String, app: AWApplication) {
        println("triggering js app event: " + eventName)
        events.triggerEvent(
            "aw.application." + eventName,
            eventData: AWJSApplication.applicationToDictionary(app))
        
    }
    
    class func applicationToDictionary(app: AWApplication) -> NSDictionary {
        var pid: NSNumber = NSNumber(int: app.pid)
        return ["pid": pid]
    }
}
