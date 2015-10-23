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
import Cocoa

@objc protocol AWJSWindowInterface : JSExport {
    func windows() -> [NSDictionary]
    func close(pid: pid_t, _ windowId: uint) -> Bool
    func focusedWindow() -> NSDictionary?
    func becomeMain(pid: pid_t, _ windowId: uint) -> Bool
    func setFrame(pid: pid_t, _ windowId: uint, _ frame: NSDictionary) -> Bool
    func setMinimized(pid: pid_t, _ windowId: uint, _ minimized: Bool) -> Bool
    func getFrame(pid: pid_t, _ windowId: uint) -> NSDictionary?
}

/*
Class that provides the javascript interface for aw.window.
*/
@objc class AWJSWindow : NSObject, AWJSWindowInterface {
    let manager:AWManager
    let events:AWJSEvent
    
    let windowEvents = [
        NSAccessibilityUIElementDestroyedNotification:"destroyed",
        NSAccessibilityWindowCreatedNotification:"created",
        NSAccessibilityWindowMovedNotification:"moved",
        NSAccessibilityWindowResizedNotification:"resized",
        NSAccessibilityFocusedWindowChangedNotification:"focused",
        NSAccessibilityMainWindowChangedNotification:"mainWindow"
    ]
    
    init(manager:AWManager, events:AWJSEvent) {
        self.manager = manager
        self.events = events
        super.init()
        manager.windowEventCallback = triggerEvent
    }
    
    // JS window api
    func windows() -> [NSDictionary] {
        return manager.windows().map(AWJSWindow.toDictionary)
    }
    
    func close(pid: pid_t, _ windowId: uint) -> Bool {
        print("calling close", pid, windowId)
        if let window = manager.getWindow(pid, windowId: windowId) {
            return window.close()
        } else {
            return false
        }
    }
    
    func focusedWindow() -> NSDictionary? {
        if let window = manager.focusedWindow() {
            return AWJSWindow.toDictionary(window)
        } else {
            return nil
        }
    }
    
    func becomeMain(pid: pid_t, _ windowId: uint) -> Bool {
        if let window = manager.getWindow(pid, windowId: windowId) {
            return window.becomeMain()
        } else {
            return false
        }
    }
    
    func setFrame(pid: pid_t, _ windowId: uint, _ frame: NSDictionary) -> Bool {
        print("frame", frame)
        if let window = manager.getWindow(pid, windowId: windowId) {
            return window.setFrame(frame)
        } else {
            return false
        }
    }
    
    func getFrame(pid: pid_t, _ windowId: uint) -> NSDictionary? {
        if let window = manager.getWindow(pid, windowId: windowId) {
            let frame = window.getFrame()
            print("frame!", frame)
            return frame
        } else {
            return nil
        }
    }
    
    func setMinimized(pid: pid_t, _ windowId: uint, _ minimized: Bool) -> Bool {
        if let window = manager.getWindow(pid, windowId: windowId) {
            // TODO defer
            //return window.setMinimized(minimized))
            return false
        } else {
            return false
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
            "aw.window." + windowEvents[eventName]!,
            eventData: AWJSWindow.toDictionary(window))
    }
    
    class func toDictionary(window: AWWindow) -> NSDictionary {
        let windowId: NSNumber = NSNumber(unsignedLong: window.id)
        return ["id": windowId, "pid": NSNumber(int: window.pid)]
    }
}
