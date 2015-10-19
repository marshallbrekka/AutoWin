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
        NSAccessibilityMainWindowChangedNotification,
        NSAccessibilityFocusedWindowChangedNotification
    ]
    
    class func applications() -> [NSRunningApplication] {
        let workspace = NSWorkspace.sharedWorkspace()
        return workspace.runningApplications 
    }
    
    class func createAWObserver(
        pid:pid_t,
        appRef:AXUIElementRef,
        callback:(AXObserverRef!, AXUIElementRef!, CFStringRef!) -> Void) -> AWObserver {
        let observer = AWObserver(pid, callback: callback);
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
                    windowObjects.append(AWWindow(ref: $0))
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
    
    class func removeApplication(apps: NSMutableDictionary, pid: pid_t) -> AWManager.AppMeta? {
        let key = NSNumber(int: pid)
        let meta = apps.objectForKey(key) as? AWManager.AppMeta
        if (meta != nil) {
            apps.removeObjectForKey(key)
            for notification in windowNotifications {
                meta!.observer.removeNotification(meta!.app.ref, notification: notification)
            }
            return meta!
        } else {
            return nil
        }
    }
    
    class func elementRefToAppMeta(apps: NSMutableDictionary, ref:AXUIElementRef) -> AWManager.AppMeta? {
        let key = NSNumber(int: AWAccessibilityAPI.getPid(ref))
        return apps.objectForKey(key) as! AWManager.AppMeta?
    }
    
    class func createApplicationListener(callback: (NSNotification) -> Void) -> AWNotification {
        // All notifications to listen for
        return AWNotification(
            center: NSWorkspace.sharedWorkspace().notificationCenter,
            target: callback,
            notifications: appNotifications)
    }
    
    class func createAndTrackWindow(apps: NSMutableDictionary, ref: AXUIElementRef) -> AWWindow {
        let appMeta = AWManagerInternal.elementRefToAppMeta(apps, ref: ref)
        let window = AWWindow(ref: ref)
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