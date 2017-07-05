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
import AXSwift

@objc protocol AWJSWindowInterface : JSExport {
    func windows() -> [NSDictionary]
    func close(_ pid: pid_t, _ windowId: uint) -> Bool
    func focusedWindow() -> NSDictionary?
    func becomeMain(_ pid: pid_t, _ windowId: uint) -> Bool
    func setFrame(_ pid: pid_t, _ windowId: uint, _ frame: NSDictionary) -> Bool
    func setMinimized(_ pid: pid_t, _ windowId: uint, _ minimized: Bool) -> Bool
    func getFrame(_ pid: pid_t, _ windowId: uint) -> NSDictionary?
}

/*
Class that provides the javascript interface for aw.window.
*/
@objc class AWJSWindow : NSObject, AWJSWindowInterface, AWManagerWindowEvent {
    let manager:AWManager
    let events:AWJSEvent
    
    let windowEvents = [
        AXSwift.AXNotification.uiElementDestroyed:"destroyed",
        AXSwift.AXNotification.windowCreated:"created",
        AXSwift.AXNotification.windowMoved:"moved",
        AXSwift.AXNotification.windowResized:"resized",
        AXSwift.AXNotification.focusedWindowChanged:"focused",
        AXSwift.AXNotification.mainWindowChanged:"mainWindow"
    ]
    
    init(manager:AWManager, events:AWJSEvent) {
        self.manager = manager
        self.events = events
        super.init()
        manager.windowEvent = self
    }
    
    deinit {
        NSLog("deinit AWJSWindow")
    }
    
    // JS window api
    func windows() -> [NSDictionary] {
        return manager.windows().map(AWJSWindow.toDictionary)
    }
    
    func close(_ pid: pid_t, _ windowId: uint) -> Bool {
        NSLog("calling close - pid: \(pid), windowId: \(windowId)")
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
    
    func becomeMain(_ pid: pid_t, _ windowId: uint) -> Bool {
        if let window = manager.getWindow(pid, windowId: windowId) {
            return window.becomeMain()
        } else {
            return false
        }
    }
    
    func setFrame(_ pid: pid_t, _ windowId: uint, _ frame: NSDictionary) -> Bool {
        NSLog("setting frame - pid: \(pid), windowId: \(windowId), frame: \(frame)")
        if let window = manager.getWindow(pid, windowId: windowId) {
            return window.setFrame(frame)
        } else {
            return false
        }
    }
    
    func getFrame(_ pid: pid_t, _ windowId: uint) -> NSDictionary? {
        if let window = manager.getWindow(pid, windowId: windowId) {
            let frame = window.getFrame()
            NSLog("got frame - pid: \(pid), windowId: \(windowId), frame: \(frame)")
            return frame
        } else {
            return nil
        }
    }
    
    func setMinimized(_ pid: pid_t, _ windowId: uint, _ minimized: Bool) -> Bool {
        if let window = manager.getWindow(pid, windowId: windowId) {
            // DEFER
            //return window.setMinimized(minimized)
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
    func windowEventCallback(_ eventName: AXSwift.AXNotification, window: AWWindow) {
        NSLog("triggering js window event: \(eventName)")
        events.triggerEvent(
            "aw.window." + windowEvents[eventName]!,
            eventData: AWJSWindow.toDictionary(window))
    }
    
    class func toDictionary(_ window: AWWindow) -> NSDictionary {
        let windowId: NSNumber = NSNumber(value: window.id as UInt)
        return ["id": windowId, "pid": NSNumber(value: window.pid as Int32)]
    }
}
