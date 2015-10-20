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

class AWManager {
    
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
    var appEventCallback:((String, app:AWApplication) -> Void)?
    var windowEventCallback:((String, window:AWWindow) -> Void)?
    
    init() {
        // get all applications and watch for new ones.
        let apps = AWManagerInternal.applications()
        for app in apps {
            initApp(app)
        }
        notifier = AWManagerInternal.createApplicationListener(appNotificationHandler)
    }
    
    func triggerWindowNotification(notifo: String, window: AWWindow) {
        print("trigger notifo", notifo, window.id, AWAccessibilityAPI.getAttribute(window.ref, property: NSAccessibilitySubroleAttribute) as String?)
        if windowEventCallback != nil {
            windowEventCallback!(notifo, window: window)
        }
    }
    
    func triggerAppNotification(notifo: String, app: AWApplication) {
        print("trigger app notifo", notifo, app.pid)
        if appEventCallback != nil {
            appEventCallback!(notifo, app: app)
        }
    }
    
    func triggerAppPostLaunchEvents(pid: pid_t) {
        let app = apps.objectForKey(NSNumber(int: pid)) as? AppMeta
        if (app != nil) {
            triggerAppNotification(NSWorkspaceDidLaunchApplicationNotification, app: app!.app)
            let enumerator = app!.windows.objectEnumerator()
            while let window = enumerator.nextObject() as? AWWindow {
                triggerWindowNotification(NSAccessibilityWindowCreatedNotification, window: window)
            }
        }
    }
    
    func triggerAppPostTerminateEvents(meta: AppMeta) {
        let enumerator = meta.windows.objectEnumerator()
        while let window = enumerator.nextObject() as? AWWindow {
            triggerWindowNotification(NSAccessibilityUIElementDestroyedNotification, window: window)
        }
        triggerAppNotification(NSWorkspaceDidTerminateApplicationNotification, app: meta.app)
    }
    
    func appNotificationHandler(notification: NSNotification) {
        let app = notification.userInfo![NSWorkspaceApplicationKey] as! NSRunningApplication
        print("app event:", notification.name, app.processIdentifier)
        switch notification.name {
        case NSWorkspaceDidTerminateApplicationNotification:
            if let meta = AWManagerInternal.removeApplication(apps, pid: app.processIdentifier) {
                triggerAppPostTerminateEvents(meta)
            }
            print("removed app notifications")
        case NSWorkspaceDidLaunchApplicationNotification:
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
    
    func observerHandler(observer: AXObserverRef!, element: AXUIElementRef!, notification: CFString!) {
        
        print("window event:", notification, CFHash(element), kAXWindowCreatedNotification, NSAccessibilityWindowCreatedNotification)
        
        
        let appMeta = AWManagerInternal.elementRefToAppMeta(apps, ref: element)
        if appMeta != nil {
            let notifo = notification! as String
            // If the notification is one that can occur on window create,
            // and if the window doesn't yet exist, create the window and
            // trigger a window create event.
            if AWManagerInternal.windowCreateNotifications.contains(notifo) {
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

    func initApp(app: NSRunningApplication) -> Bool {
        print("initing app", app.processIdentifier, NSDate().timeIntervalSince1970)
        let awApp = AWApplication(app: app)
        print("created awApp", app.processIdentifier, NSDate().timeIntervalSince1970)
        if AWApplication.isSupportedApplication(awApp) {
            let observer = AWManagerInternal.createAWObserver(
                awApp.pid,
                appRef: awApp.ref,
                callback: observerHandler)
            let meta = AppMeta(
                app: awApp,
                windows: AWManagerInternal.createWindowDictonary(awApp),
                observer: observer)
            AWManagerInternal.trackApplication(self.apps, appMeta: meta)
            print("done init app", app.processIdentifier, NSDate().timeIntervalSince1970)
            return true
        } else {
            print("not init app", app.processIdentifier, NSDate().timeIntervalSince1970)
            return false
        }
        
    }
}
