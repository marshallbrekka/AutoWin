/**
High level goal, does not reflect the existing code below yet.

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
    
    init() {
        // get all applications and watch for new ones.
        let apps = AWManagerInternal.applications()
        for app in apps {
            initApp(app)
        }
        notifier = AWManagerInternal.createApplicationListener(appNotificationHandler)
    }
    
    func triggerWindowNotification(notifo: String, window: AWWindow) {
        print("trigger notifo", notifo, window.id)
    }
    
    func appNotificationHandler(notification: NSNotification) {
        let app = notification.userInfo![NSWorkspaceApplicationKey] as! NSRunningApplication
        print("app event:", notification.name, app.processIdentifier)
        switch notification.name {
        case NSWorkspaceDidTerminateApplicationNotification:
            AWManagerInternal.removeApplication(apps, pid: app.processIdentifier)
            print("removed app notifications")
        case NSWorkspaceDidLaunchApplicationNotification:
            print("tracking app")
            initApp(app)
        default:
            print("other notifo")
        }

    }
    
    func observerHandler(observer: AXObserverRef!, element: AXUIElementRef!, notification: CFString!) {
        
        print("window event:", notification, CFHash(element), kAXWindowCreatedNotification, NSAccessibilityWindowCreatedNotification)
        let appMeta = AWManagerInternal.elementRefToAppMeta(apps, ref: element)
        if appMeta != nil {
            let notifo = notification! as String
            switch notifo {
            case NSAccessibilityWindowCreatedNotification:
                let window = AWManagerInternal.createAndTrackWindow(apps, ref: element!)
                triggerWindowNotification(notifo, window: window)
            case NSAccessibilityUIElementDestroyedNotification:
                let window = AWManagerInternal.removeTrackedWindowByElement(apps, ref: element)
                if (window != nil) {
                    triggerWindowNotification(notifo, window: window!)
                }
            default:
                let window = AWManagerInternal.elementRefToWindow(apps, ref: element!)
                if (window != nil) {
                    triggerWindowNotification(notifo, window: window!)
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
