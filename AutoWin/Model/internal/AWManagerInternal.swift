import Foundation
import Cocoa

class AWManagerInternal {
    static let appNotifications = [
        NSWorkspaceDidLaunchApplicationNotification,
        NSWorkspaceDidTerminateApplicationNotification,
        NSWorkspaceDidHideApplicationNotification,
        NSWorkspaceDidUnhideApplicationNotification,
        NSWorkspaceDidActivateApplicationNotification,
        NSWorkspaceDidDeactivateApplicationNotification
    ]

    static let windowNotifications = [
        NSAccessibilityUIElementDestroyedNotification,
        NSAccessibilityWindowCreatedNotification,
        NSAccessibilityWindowMovedNotification,
        NSAccessibilityWindowResizedNotification,
        NSAccessibilityFocusedWindowChangedNotification,
        NSAccessibilityMainWindowChangedNotification
    ]

    // Some or all of these events are fired when a window is created
    // and the order is not specified, so instead we will see if the
    // window already exists in our tracking for each of these events
    // and if it doesnt we will track it and trigger a window creation
    // event (if the original event was not a window creation event).
    static let windowCreateNotifications = [
        NSAccessibilityWindowCreatedNotification,
        NSAccessibilityFocusedWindowChangedNotification,
        NSAccessibilityMainWindowChangedNotification
    ]

    class func applications() -> [NSRunningApplication] {
        let workspace = NSWorkspace.sharedWorkspace()
        return workspace.runningApplications 
    }

    class func createAWObserver(
        pid:pid_t,
        appRef:AXUIElementRef,
        callback:(AXObserverRef!, AXUIElementRef!, CFStringRef!) -> Void) -> AWObserver {
        let observer = AWObserver(pid: pid, callback: callback);
            
        for notification in windowNotifications {
            observer.addNotification(appRef, notification: notification)
        }
        return observer
    }

    class func applicationWindows(app: AWApplication) -> [AWWindow] {
        var windowObjects: [AWWindow] = []
        let windowRefs: [AXUIElementRef]? = AWAccessibilityAPI.getAttributes(
            app.ref,
            property: NSAccessibilityWindowsAttribute) as [AXUIElementRef]?

        if windowRefs != nil {
            windowRefs?.map({
                if AWWindow.isWindow($0) {
                    windowObjects.append(AWWindow(ref: $0, pid: app.pid))
                }
            }) as [Void]!
        }
        return windowObjects
    }

    class func trackWindow(windows: NSMutableDictionary, window: AWWindow) {
        windows.setObject(window, forKey: window.id)
    }

    class func removeWindow(windows: NSMutableDictionary, window: AWWindow) {
        windows.removeObjectForKey(window.id)
    }

    class func createWindowDictonary(app: AWApplication) -> NSMutableDictionary {
        let windowDictionary = NSMutableDictionary()
        AWManagerInternal.applicationWindows(app).map({
            AWManagerInternal.trackWindow(windowDictionary, window: $0)
        }) as [Void]
        return windowDictionary
    }

    class func trackApplication(apps: NSMutableDictionary, appMeta: AWManager.AppMeta) {
        apps.setObject(appMeta, forKey: NSNumber(int: appMeta.app.pid))
    }

    class func pidToApplication(apps: NSMutableDictionary, pid: pid_t) -> AWApplication? {
        if let meta = apps.objectForKey(NSNumber(int: pid)) as? AWManager.AppMeta {
            return meta.app
        } else {
            return nil
        }
    }

    class func removeApplication(apps: NSMutableDictionary, pid: pid_t) -> AWManager.AppMeta? {
        let key = NSNumber(int: pid)
        let meta = apps.objectForKey(key) as? AWManager.AppMeta
        if (meta != nil) {
            apps.removeObjectForKey(key)
            return meta!
        } else {
            return nil
        }
    }

    class func elementRefToAppMeta(apps: NSMutableDictionary, ref:AXUIElementRef) -> AWManager.AppMeta? {
        let key = NSNumber(int: AWAccessibilityAPI.getPid(ref))
        return apps.objectForKey(key) as! AWManager.AppMeta?
    }

    class func createApplicationListener(target:AWNotificationTarget) -> AWNotification {
        // All notifications to listen for
        return AWNotification(
            center: NSWorkspace.sharedWorkspace().notificationCenter,
            target: target,
            notifications: appNotifications)
    }

    class func createAndTrackWindow(apps: NSMutableDictionary, ref: AXUIElementRef) -> AWWindow {
        let appMeta = AWManagerInternal.elementRefToAppMeta(apps, ref: ref)
        let window = AWWindow(ref: ref, pid: appMeta!.app.pid)
        if (appMeta != nil) {
            trackWindow(appMeta!.windows, window: window)
        }
        return window
    }

    class func elementRefToWindow(apps: NSMutableDictionary, ref: AXUIElementRef) -> AWWindow? {
        let appMeta = AWManagerInternal.elementRefToAppMeta(apps, ref: ref)
        if (appMeta != nil) {
            let hash = CFHash(ref)
            let window = appMeta!.windows.objectForKey(hash)
            if (window != nil) {
                return window as? AWWindow
            }
        }
        return nil
    }

    class func removeTrackedWindowByElement(apps: NSMutableDictionary, ref: AXUIElementRef) -> AWWindow? {
        let appMeta = AWManagerInternal.elementRefToAppMeta(apps, ref: ref)
        if (appMeta != nil) {
            let window = appMeta!.windows.objectForKey(CFHash(ref))
            if (window != nil) {
                removeWindow(appMeta!.windows, window: window! as! AWWindow)
                return window as? AWWindow
            }
        }
        return nil
    }
}