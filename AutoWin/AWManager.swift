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
import AXSwift

protocol AWManagerAppEvent:class {
    func appEventCallback(_ notifo:NSNotification.Name, app:AWApplication) -> Void
}

protocol AWManagerWindowEvent:class {
    func windowEventCallback(_ notifo:AXSwift.AXNotification, window:AWWindow) -> Void
}

class AWManager:AWNotificationTarget {
    
    class AppMeta {
        var app: AWApplication
        var windows: NSMutableDictionary
        var observer: Observer
        
        init(app: AWApplication,
            windows: NSMutableDictionary,
            observer: Observer) {
                self.app = app
                self.windows = windows
                self.observer = observer
        }

        deinit {
            NSLog("deinit AppMeta: \(self.app.pid)")
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
        NSLog("deinit AWManager")
    }
    
    func triggerWindowNotification(_ notifo: AXSwift.AXNotification, window: AWWindow) {
        NSLog("trigger window notification: \(notifo), \(window.id)")
        if windowEvent != nil {
            windowEvent!.windowEventCallback(notifo, window: window)
        }
    }
    
    func triggerAppNotification(_ notifo: NSNotification.Name, app: AWApplication) {
        NSLog("trigger app notifification: \(notifo), \(app.pid)")
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
                triggerWindowNotification(AXSwift.AXNotification.windowCreated, window: window)
            }
        }
    }
    
    func triggerAppPostTerminateEvents(_ meta: AppMeta) {
        let enumerator = meta.windows.objectEnumerator()
        while let window = enumerator.nextObject() as? AWWindow {
            triggerWindowNotification(AXSwift.AXNotification.uiElementDestroyed, window: window)
        }
        triggerAppNotification(NSNotification.Name.NSWorkspaceDidTerminateApplication, app: meta.app)
    }
    
    func receiveNotification(_ notification: Notification) {
        let app = notification.userInfo![NSWorkspaceApplicationKey] as! NSRunningApplication
        NSLog("app event - pid: \(app.processIdentifier), name: \(notification.name)")
        switch notification.name {
        case NSNotification.Name.NSWorkspaceDidTerminateApplication:
            if let meta = AWManagerInternal.removeApplication(apps, pid: app.processIdentifier) {
                triggerAppPostTerminateEvents(meta)
            }
            NSLog("removed app notifications")
        case NSNotification.Name.NSWorkspaceDidLaunchApplication:
            NSLog("tracking app")
            if initApp(app) {
               triggerAppPostLaunchEvents(app.processIdentifier)
            }
        default:
            if let awApp = AWManagerInternal.pidToApplication(apps, pid: app.processIdentifier) {
                triggerAppNotification(notification.name, app: awApp)
            }
        }
    }
    
    func observerHandler(_ observer: AXSwift.Observer, element: AXSwift.UIElement, notification: AXSwift.AXNotification) {
        NSLog("window event: \(notification) \(CFHash(element))")
        
        let appMeta = AWManagerInternal.elementRefToAppMeta(apps, ref: element)
        if appMeta != nil {
            // If the notification is one that can occur on window create,
            // and if the window doesn't yet exist, create the window and
            // trigger a window create event.
            let contains = AWManagerInternal.windowCreateNotifications.contains(notification)
            if contains {
                var window = AWManagerInternal.elementRefToWindow(apps, ref: element)
                if window == nil && AWWindow.isWindow(element) {
                    window = AWManagerInternal.createAndTrackWindow(apps, ref: element)
                    triggerWindowNotification(AXSwift.AXNotification.windowCreated, window: window!)
                }
            }
            if notification != AXSwift.AXNotification.windowCreated {
                switch notification {
                case AXSwift.AXNotification.uiElementDestroyed:
                    let window = AWManagerInternal.removeTrackedWindowByElement(apps, ref: element)
                    if window != nil {
                        triggerWindowNotification(notification, window: window!)
                    }

                default:
                    if let window = AWManagerInternal.elementRefToWindow(apps, ref: element) {
                        triggerWindowNotification(notification, window: window)
                    }
                }
            }
        }
    }

    func initApp(_ app: NSRunningApplication) -> Bool {
        NSLog("initing app - pid: \(app.processIdentifier)")
        let awApp = AWApplication(app: app)
        NSLog("created AWApplication - pid: \(app.processIdentifier)")
        if AWApplication.isSupportedApplication(awApp) {
            let observer = AWManagerInternal.createObserver(
                awApp.pid,
                appRef: awApp.ref,
                callback: {
                    [unowned self] (observer: AXSwift.Observer, element: AXSwift.UIElement, notification: AXSwift.AXNotification) -> Void in
                    NSLog("NOTIFICATION: \(notification)")
                    self.observerHandler(observer, element: element, notification: notification)
                })
            let meta = AppMeta(
                app: awApp,
                windows: AWManagerInternal.createWindowDictonary(awApp),
                observer: observer!)
            AWManagerInternal.trackApplication(self.apps, appMeta: meta)
            NSLog("done init app: \(app.processIdentifier)")
            return true
        } else {
            NSLog("not init app: \(app.processIdentifier)")
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
        do {
            let appElement: AXSwift.UIElement = try AXSwift.systemWideElement.attribute(.focusedApplication)!
            let app = try AXSwift.Application(forProcessID: appElement.pid())!
            let window:AXSwift.UIElement = try app.attribute(.focusedWindow)!
            return AWWindow(ref: window, pid: (try app.pid()))
        } catch {
            return nil
        }
    }
}
