import Foundation
import Cocoa
import AXSwift

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
        AXSwift.AXNotification.uiElementDestroyed,
        AXSwift.AXNotification.windowCreated,
        AXSwift.AXNotification.windowMoved,
        AXSwift.AXNotification.windowResized,
        AXSwift.AXNotification.focusedWindowChanged,
        AXSwift.AXNotification.mainWindowChanged
    ]

    // Some or all of these events are fired when a window is created
    // and the order is not specified, so instead we will see if the
    // window already exists in our tracking for each of these events
    // and if it doesnt we will track it and trigger a window creation
    // event (if the original event was not a window creation event).
    static let windowCreateNotifications = [
        AXSwift.AXNotification.windowCreated,
        AXSwift.AXNotification.focusedWindowChanged,
        AXSwift.AXNotification.mainWindowChanged
    ]

    class func applications() -> [NSRunningApplication] {
        let workspace = NSWorkspace.shared()
        return workspace.runningApplications 
    }

    class func createObserver(
        _ pid:pid_t,
        appRef:AXSwift.UIElement,
        callback:@escaping AXSwift.Observer.Callback) -> AXSwift.Observer? {
        guard let observer = try? AXSwift.Observer(processID: pid, callback: callback) else {
            // TODO do something here to handle error case
            return nil
        }
            
        for notification in windowNotifications {
            try? observer.addNotification(notification, forElement: appRef)
        }
        return observer
    }

    class func applicationWindows(_ app: AWApplication) -> [AWWindow] {
        var windowObjects: [AWWindow] = []
        guard let windowRefs: [AXSwift.UIElement]? = try? app.ref.windows() else {
                return windowObjects
        }

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
            meta?.observer.stop()
            apps.removeObject(forKey: key)
            return meta!
        } else {
            return nil
        }
    }

    class func elementRefToAppMeta(_ apps: NSMutableDictionary, ref:AXSwift.UIElement) -> AWManager.AppMeta? {
        do {
            let key = NSNumber(value: (try ref.pid()) as Int32)
            return apps.object(forKey: key) as! AWManager.AppMeta?
        } catch {
            return nil
        }
    }

    class func createApplicationListener(_ target:AWNotificationTarget) -> AWNotification {
        // All notifications to listen for
        return AWNotification(
            center: NSWorkspace.shared().notificationCenter,
            target: target,
            notifications: appNotifications)
    }

    class func createAndTrackWindow(_ apps: NSMutableDictionary, ref: AXSwift.UIElement) -> AWWindow {
        let appMeta = AWManagerInternal.elementRefToAppMeta(apps, ref: ref)
        let window = AWWindow(ref: ref, pid: appMeta!.app.pid)
        if (appMeta != nil) {
            trackWindow(appMeta!.windows, window: window)
        }
        return window
    }

    class func elementRefToWindow(_ apps: NSMutableDictionary, ref: AXSwift.UIElement) -> AWWindow? {
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

    class func removeTrackedWindowByElement(_ apps: NSMutableDictionary, ref: AXSwift.UIElement) -> AWWindow? {
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
