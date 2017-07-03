import Cocoa
import AppKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NSLog("starting helper: %s", Bundle.main.bundleURL.absoluteString)
        let parentUrl = (((Bundle.main.bundleURL as NSURL).deletingLastPathComponent as NSURL?)?.deletingLastPathComponent as NSURL?)?.deletingLastPathComponent?.deletingLastPathComponent()
        let config:[String:AnyObject] = NSDictionary() as! [String : AnyObject]
        do {
            try NSWorkspace.shared().launchApplication(at: parentUrl!, options: NSWorkspaceLaunchOptions.default, configuration: config)
        } catch {
             NSLog("failed to launch", parentUrl!.absoluteString)
        }
        NSApplication.shared().terminate(self)
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}
