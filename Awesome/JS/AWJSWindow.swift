/*
** Window Level Events **
aw.window.created
aw.window.destroyed
aw.window.focused
aw.window.mainWindow
aw.window.moved
aw.window.resized
aw.window.titleChanged
aw.window.minimized
aw.window.unminimized

** Window functions **

aw.window.windows()
aw.window.close(window)
aw.window.focusedWindow()
aw.window.becomeMain(window)
aw.window.setFrame(window,frame)
aw.window.setMinimized(window,boolean)
*/

import Foundation
import JavaScriptCore

protocol AWWindowJSInterface {
    func windows() -> [AWWindow]
    func close(windowId: uint) -> Bool
    func focusedWindow() -> AWWindow
    func becomeMain(windowId: uint) -> Bool
    func setFrame(windowId: uint, frame: NSDictionary) -> Bool
    func setMinimized(windowId: Bool) -> Bool
    
}

@objc protocol AWJSWindowInterface : JSExport {
    func windows() -> [NSDictionary]
}

/*
Class that provides the javascript interface for aw.window.
*/
@objc class AWJSWindow : NSObject, AWJSWindowInterface {
    let events: AWJSEvent
    let delegate: AWWindowJSInterface? = nil
    
    init(events: AWJSEvent) {
        self.events = events
    }
    
    // JS window api
    func windows() -> [NSDictionary] {
        if delegate == nil {
            return []
        } else {
            return delegate!.windows()
                .map(AWJSWindow.toDictionary)
        }
    }
    
    /*
    Triggers an event.
    Valid events are:
    created, destroyed, focused, mainWindow, moved, resized, titleChanged,
    minimized, unminimized.
    */
    func triggerEvent(eventName: String, window: AWWindow) {
        print("triggering js window event: " + eventName)
        events.triggerEvent(
            "aw.window." + eventName,
            eventData: AWJSWindow.toDictionary(window))
        
    }
    
    class func toDictionary(window: AWWindow) -> NSDictionary {
        let windowId: NSNumber = NSNumber(unsignedInt: window.id)
        return ["id": windowId]
    }
}
