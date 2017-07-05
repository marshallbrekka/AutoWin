import Foundation
import Cocoa
import Carbon
import AXSwift

class AWApplication {
    let app:NSRunningApplication
    let ref:AXSwift.Application
    let pid:pid_t
    
    init(app:NSRunningApplication) {
        self.app = app
        pid = app.processIdentifier
        ref = AXSwift.Application(app)!
    }
    
    deinit {
        NSLog("deinit AWApplication: \(pid)")
    }
    
    func activate() -> Bool {
        return app.activate(options: [NSApplicationActivationOptions.activateIgnoringOtherApps])
    }
    
    func title() -> String {
        if (app.localizedName == nil) {
            return ""
        } else {
            return app.localizedName!
        }
    }

    class func isSupportedApplication(_ app: AWApplication) -> Bool {
        NSLog("getting application role \(app.pid)")
        do {
        if let role: AXSwift.Role = try app.ref.role() {
            NSLog("got application role: \(app.pid), \(role)")
            return role == AXSwift.Role.application
        } else {
            return false
            }
        } catch {
            return false
        }
    }
}
