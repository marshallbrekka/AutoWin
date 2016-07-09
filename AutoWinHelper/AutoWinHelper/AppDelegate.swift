import Cocoa
import AppKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        NSLog("starting helper: %s", NSBundle.mainBundle().bundleURL.absoluteString)
        let parentUrl = NSBundle.mainBundle().bundleURL.URLByDeletingLastPathComponent?.URLByDeletingLastPathComponent?.URLByDeletingLastPathComponent?.URLByDeletingLastPathComponent
        let config:[String:AnyObject] = NSDictionary() as! [String : AnyObject]
        do {
            try NSWorkspace.sharedWorkspace().launchApplicationAtURL(parentUrl!, options: NSWorkspaceLaunchOptions.Default, configuration: config)
        } catch {
             NSLog("failed to launch", parentUrl!.absoluteString)
        }
        NSApplication.sharedApplication().terminate(self)
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
}