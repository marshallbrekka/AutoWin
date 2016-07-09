import Foundation
import Cocoa

class AWStatusTarget:NSObject {
    var prefWindow:AWPreferencesWindow
    var controller:NSWindowController?
    var reloadJS: () -> Void
    
    init(accessibility:AWAccessibilityEnabled, reloadJS:() -> Void) {
        self.reloadJS = reloadJS;
        prefWindow = AWPreferencesWindow(accessibility: accessibility, reloadJS: reloadJS)
    }
    
    func showPreferences(sender: AnyObject) {
        print("showing preferences")
        NSApplication.sharedApplication().activateIgnoringOtherApps(true)
        prefWindow.showWindow(nil)
    }
    
    func reload(sender: AnyObject) {
        print("reloading js")
        reloadJS()
    }
    
    func quit(sender: AnyObject) {
        print("quiting")
        NSApplication.sharedApplication().terminate(sender)
    }
}