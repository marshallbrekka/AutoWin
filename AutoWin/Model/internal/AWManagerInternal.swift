import Foundation
import Cocoa

class AWManagerInternal {
    static let appNotifications = [
        NSNotification.Name.NSWorkspaceDidLaunchApplication,
        NSNotification.Name.NSWorkspaceDidTerminateApplication,
        NSNotification.Name.NSWorkspaceDidHideApplication,
        NSNotification.Name.NSWorkspaceDidUnhideApplication,
        NSNotification.Name.NSWorkspaceDidActivateApplication,
        NSNotification.Name.NSWorkspaceDidDeactivateApplication
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
        let workspace = NSWorkspace.shared()
        return workspace.runningApplications 
    }

    class func createAWObserver(
        _ pid:pid_t,
        appRef:AXUIElement,
        callback:@escaping (AXObserver?, AXUIElement?, CFString?) -> Void) -> AWObserver {
        let observer = AWObserver(pid: pid, callback: callback);
            
        for notification in windowNotifications {
            observer.addNotification(appRef, notification: notification as CFString)
        }
        return observer
    }

    class func applicationWindows(_ app: AWApplication) -> [AWWindow] {
        var windowObjects: [AWWindow] = []
        let windowRefs: [AXUIElement]? = AWAccessibilityAPI.getAttributes(
            app.ref,
            property: NSAccessibilityWindowsAttribute) as [AXUIElement]?

        if windowRefs != nil {
            windowRefs?.map({
                if AWWindow.isWindow($0) {
                    windowObjects.append(AWWindow(ref: $0, pid: app.pid))
                }
            }) as [Void]!
        }
        return windowObjects
    }

    class func trackWindow(_ windows: NSMutableDictionary, window: AWWindow) {
        windows.setObject(window, forKey: window.id as NSCopying)
    }

    class func removeWindow(_ windows: NSMutableDictionary, window: AWWindow) {
        windows.removeObject(forKey: window.id)
    }

    class func createWindowDictonary(_ app: AWApplication) -> NSMutableDictionary {
        let windowDictionary = NSMutableDictionary()
        AWManagerInternal.applicationWindows(app).map({
            AWManagerInternal.trackWindow(windowDictionary, window: $0)
        }) as [Void]
        return windowDictionary
    }

    class func trackApplication(_ apps: NSMutableDictionary, appMeta: AWManager.AppMeta) {
        apps.setObject(appMeta, forKey: NSNumber(value: appMeta.app.pid as Int32))
    }

    class func pidToApplication(_ apps: NSMutableDictionary, pid: pid_t) -> AWApplication? {
        if let meta = apps.object(forKey: NSNumber(value: pid as Int32)) as? AWManager.AppMeta {
            return meta.app
        } else {
            return nil
        }
    }

    class func removeApplication(_ apps: NSMutableDictionary, pid: pid_t) -> AWManager.AppMeta? {
        let key = NSNumber(value: pid as Int32)
        let meta = apps.object(forKey: key) as? AWManager.AppMeta
        if (meta != nil) {
            apps.removeObject(forKey: key)
            return meta!
        } else {
            return nil
        }
    }

    class func elementRefToAppMeta(_ apps: NSMutableDictionary, ref:AXUIElement) -> AWManager.AppMeta? {
        let key = NSNumber(value: AWAccessibilityAPI.getPid(ref) as Int32)
        return apps.object(forKey: key) as! AWManager.AppMeta?
    }

    class func createApplicationListener(_ target:AWNotificationTarget) -> AWNotification {
        // All notifications to listen for
        return AWNotification(
            center: NSWorkspace.shared().notificationCenter,
            target: target,
            notifications: appNotifications)
    }

    class func createAndTrackWindow(_ apps: NSMutableDictionary, ref: AXUIElement) -> AWWindow {
        let appMeta = AWManagerInternal.elementRefToAppMeta(apps, ref: ref)
        let window = AWWindow(ref: ref, pid: appMeta!.app.pid)
        if (appMeta != nil) {
            trackWindow(appMeta!.windows, window: window)
        }
        return window
    }

    class func elementRefToWindow(_ apps: NSMutableDictionary, ref: AXUIElement) -> AWWindow? {
        let appMeta = AWManagerInternal.elementRefToAppMeta(apps, ref: ref)
        if (appMeta != nil) {
            let hash = CFHash(ref)
            let window = appMeta!.windows.object(forKey: hash)
            if (window != nil) {
                return window as? AWWindow
            }
        }
        return nil
    }

    class func removeTrackedWindowByElement(_ apps: NSMutableDictionary, ref: AXUIElement) -> AWWindow? {
        let appMeta = AWManagerInternal.elementRefToAppMeta(apps, ref: ref)
        if (appMeta != nil) {
            let window = appMeta!.windows.object(forKey: CFHash(ref))
            if (window != nil) {
                removeWindow(appMeta!.windows, window: window! as! AWWindow)
                return window as? AWWindow
            }
        }
        return nil
    }
}
