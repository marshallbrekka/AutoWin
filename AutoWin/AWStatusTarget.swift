import Foundation
import Cocoa

class AWStatusTarget:NSObject {
    var prefWindow:AWPreferencesWindow
    var controller:NSWindowController?
    var reloadJS: () -> Void
    
    init(accessibility:AWAccessibilityEnabled, reloadJS:@escaping () -> Void) {
        self.reloadJS = reloadJS;
        prefWindow = AWPreferencesWindow(accessibility: accessibility, reloadJS: reloadJS)
    }
    
    func showPreferences(_ sender: AnyObject) {
        print("showing preferences")
        NSApplication.shared().activate(ignoringOtherApps: true)
        prefWindow.showWindow(nil)
    }
    
    func reload(_ sender: AnyObject) {
        print("reloading js")
        reloadJS()
    }
    
    func quit(_ sender: AnyObject) {
        print("quiting")
        NSApplication.shared().terminate(sender)
    }
}
