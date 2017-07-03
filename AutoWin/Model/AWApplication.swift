import Foundation
import Cocoa
import Carbon

class AWApplication {
    let app:NSRunningApplication
    let ref:AXUIElement
    let pid:pid_t
    
    init(app:NSRunningApplication) {
        self.app = app
        pid = app.processIdentifier
        ref = AXUIElementCreateApplication(pid)
    }
    
    deinit {
        print("deinit awapplication")
    }
    
    func activate() -> Bool {
        // TODO: use this instead https://stackoverflow.com/questions/2333078/how-to-launch-application-and-bring-it-to-front-using-cocoa-api/2334362#2334362
        return AWAccessibilityAPI.setAttribute(
            ref,
            property: NSAccessibilityFrontmostAttribute,
            value: true as AnyObject)
    }
    
    func title() -> String {
        if (app.localizedName == nil) {
            return ""
        } else {
            return app.localizedName!
        }
    }

    class func isSupportedApplication(_ app: AWApplication) -> Bool {
        print("getting application role", Date().timeIntervalSince1970, app.pid)
        let role = AWAccessibilityAPI.getAttribute(app.ref, property: NSAccessibilityRoleAttribute) as String?
        print("got application role", Date().timeIntervalSince1970, app.pid, role)
        if role != nil {
            return role! == NSAccessibilityApplicationRole
        } else {
            return false
        }
    }
}
