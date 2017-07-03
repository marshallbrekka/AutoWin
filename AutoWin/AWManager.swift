/**
High level goal

On Application "get" (either on initial launch, or via event),
create an application object, get all its windows, and start
listening for app events.

In a dict keyed by PID, store a map with keys
app: AWApplication Object
windows: dict of windows
observer: the application observer instance

The windows dict is keyed by the hash of the AXUIElementRef, and maps
to an instance of a AWWindow.
*/
import Foundation
import Cocoa


protocol AWManagerAppEvent:class {
    func appEventCallback(_ notifo:NSNotification.Name, app:AWApplication) -> Void
}

protocol AWManagerWindowEvent:class {
    func windowEventCallback(_ notifo:String, window:AWWindow) -> Void
}

class AWManager:AWNotificationTarget {
    
    class AppMeta {
        var app: AWApplication
        var windows: NSMutableDictionary
        var observer: AWObserver
        
        init(app: AWApplication,
            windows: NSMutableDictionary,
            observer: AWObserver) {
                self.app = app
                self.windows = windows
                self.observer = observer
        }
    }
    
    // A map of pid (NSNumber) to application (AWApplication)
    let apps:NSMutableDictionary = NSMutableDictionary()
    var notifier:AWNotification? = nil
    weak var appEvent:AWManagerAppEvent?
    weak var windowEvent:AWManagerWindowEvent?
    
    init() {
        // get all applications and watch for new ones.
        let apps = AWManagerInternal.applications()
        for app in apps {
            initApp(app)
        }
        notifier = AWManagerInternal.createApplicationListener(self)
    }
    
    deinit {
        print("killing manager")
    }
    
    func triggerWindowNotification(_ notifo: String, window: AWWindow) {
        print("trigger notifo", notifo, window.id, AWAccessibilityAPI.getAttribute(window.ref, property: NSAccessibilitySubroleAttribute) as String?)
        if windowEvent != nil {
            windowEvent!.windowEventCallback(notifo, window: window)
        }
    }
    
    func triggerAppNotification(_ notifo: NSNotification.Name, app: AWApplication) {
        print("trigger app notifo", notifo, app.pid)
        if appEvent != nil {
            appEvent!.appEventCallback(notifo, app: app)
        }
    }
    
    func triggerAppPostLaunchEvents(_ pid: pid_t) {
        let app = apps.object(forKey: NSNumber(value: pid as Int32)) as? AppMeta
        if (app != nil) {
            triggerAppNotification(NSNotification.Name.NSWorkspaceDidLaunchApplication, app: app!.app)
            let enumerator = app!.windows.objectEnumerator()
            while let window = enumerator.nextObject() as? AWWindow {
                triggerWindowNotification(NSAccessibilityWindowCreatedNotification, window: window)
            }
        }
    }
    
    func triggerAppPostTerminateEvents(_ meta: AppMeta) {
        let enumerator = meta.windows.objectEnumerator()
        while let window = enumerator.nextObject() as? AWWindow {
            triggerWindowNotification(NSAccessibilityUIElementDestroyedNotification, window: window)
        }
        triggerAppNotification(NSNotification.Name.NSWorkspaceDidTerminateApplication, app: meta.app)
    }
    
    func receiveNotification(_ notification: Notification) {
        let app = notification.userInfo![NSWorkspaceApplicationKey] as! NSRunningApplication
        print("app event:", notification.name, app.processIdentifier)
        switch notification.name {
        case NSNotification.Name.NSWorkspaceDidTerminateApplication:
            if let meta = AWManagerInternal.removeApplication(apps, pid: app.processIdentifier) {
                triggerAppPostTerminateEvents(meta)
            }
            print("removed app notifications")
        case NSNotification.Name.NSWorkspaceDidLaunchApplication:
            print("tracking app")
            if initApp(app) {
               triggerAppPostLaunchEvents(app.processIdentifier)
            }
        default:
            if let awApp = AWManagerInternal.pidToApplication(apps, pid: app.processIdentifier) {
                triggerAppNotification(notification.name, app: awApp)
            }
        }
    }
    
    func observerHandler(_ observer: AXObserver!, element: AXUIElement!, notification: CFString!) {
        print("window event:", notification, CFHash(element), kAXWindowCreatedNotification, NSAccessibilityWindowCreatedNotification)
        
        let appMeta = AWManagerInternal.elementRefToAppMeta(apps, ref: element)
        if appMeta != nil {
            let notifo = notification! as String
            // If the notification is one that can occur on window create,
            // and if the window doesn't yet exist, create the window and
            // trigger a window create event.
            let contains = AWManagerInternal.windowCreateNotifications.contains(notifo)
            if contains {
                var window = AWManagerInternal.elementRefToWindow(apps, ref: element)
                if window == nil && AWWindow.isWindow(element) {
                    window = AWManagerInternal.createAndTrackWindow(apps, ref: element)
                    triggerWindowNotification(NSAccessibilityWindowCreatedNotification, window: window!)
                }
            }
            if notifo != NSAccessibilityWindowCreatedNotification {
                switch notifo {
                case NSAccessibilityUIElementDestroyedNotification:
                    let window = AWManagerInternal.removeTrackedWindowByElement(apps, ref: element)
                    if window != nil {
                        triggerWindowNotification(notifo, window: window!)
                    }

                default:
                    if let window = AWManagerInternal.elementRefToWindow(apps, ref: element!) {
                        triggerWindowNotification(notifo, window: window)
                    }
                }
            }
        }
    }

    func initApp(_ app: NSRunningApplication) -> Bool {
        print("initing app", app.processIdentifier, Date().timeIntervalSince1970)
        let awApp = AWApplication(app: app)
        print("created awApp", app.processIdentifier, Date().timeIntervalSince1970)
        if AWApplication.isSupportedApplication(awApp) {
            let observer = AWManagerInternal.createAWObserver(
                awApp.pid,
                appRef: awApp.ref,
                callback: {
                    [unowned self] (observer: AXObserver?, element: AXUIElement?, notification: CFString?) -> Void in
                    print("NOTIFICATION:", notification ?? "no notification")
                    self.observerHandler(observer, element: element, notification: notification)
                })
            let meta = AppMeta(
                app: awApp,
                windows: AWManagerInternal.createWindowDictonary(awApp),
                observer: observer)
            AWManagerInternal.trackApplication(self.apps, appMeta: meta)
            print("done init app", app.processIdentifier, Date().timeIntervalSince1970)
            return true
        } else {
            print("not init app", app.processIdentifier, Date().timeIntervalSince1970)
            return false
        }
        
    }
    
    func getApplication(_ pid: pid_t) -> AWApplication? {
        return AWManagerInternal.pidToApplication(apps, pid: pid)
    }
    
    func applications() -> [AWApplication] {
        var appObjects: [AWApplication] = []
        let enumerator = apps.objectEnumerator()
        while let appMeta = enumerator.nextObject() as? AppMeta {
            appObjects.append(appMeta.app);
        }
        return appObjects
    }
    
    func getWindow(_ pid: pid_t, windowId: uint) -> AWWindow? {
        if let appMeta = apps.object(forKey: NSNumber(value: pid as Int32)) as? AppMeta {
            return appMeta.windows.object(forKey: NSNumber(value: windowId as UInt32)) as? AWWindow
        } else {
            return nil
        }
    }
    
    func windows() -> [AWWindow] {
        var windowObjects: [AWWindow] = []
        let enumerator = apps.objectEnumerator()
        while let appMeta = enumerator.nextObject() as? AppMeta {
            let windowEnumerator = appMeta.windows.objectEnumerator()
            while let window = windowEnumerator.nextObject() as? AWWindow {
                windowObjects.append(window)
            }
        }
        return windowObjects
    }
    
    func focusedWindow() -> AWWindow? {
        let system = AXUIElementCreateSystemWide()
        let app = AWAccessibilityAPI.getAttribute(system, property: kAXFocusedApplicationAttribute) as AXUIElement?
        if app != nil {
            if let window:AXUIElement = AWAccessibilityAPI.getAttribute(app!, property: NSAccessibilityFocusedWindowAttribute) as AXUIElement? {
                return AWWindow(ref: window, pid: AWAccessibilityAPI.getPid(app!))
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
}
