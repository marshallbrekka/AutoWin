import Foundation
import ServiceManagement
import Cocoa
import AppKit

class AWOpenAtLogin {
    class func setAppBundle() {
        let helperAppUrl = Bundle.main.bundleURL.appendingPathComponent("Contents/Library/LoginItems/AutoWinHelper.app", isDirectory: true)
        
        let reverse = (((helperAppUrl as NSURL).deletingLastPathComponent as NSURL?)?.deletingLastPathComponent as NSURL?)?.deletingLastPathComponent?.deletingLastPathComponent()
        NSLog("reverse %@, %@", reverse!.absoluteString, helperAppUrl.absoluteString)
        let status = LSRegisterURL(helperAppUrl as CFURL, true)
        if status != noErr {
            NSLog("Failed to LSRegisterURL '%@': %jd", helperAppUrl.absoluteString, status)
        }
    }
    
    class func setOpenAtLogin(_ enabled: Bool) {
        AWPreferences.setBool(AWPreferences.OpenAtLogin, value:enabled)
        if SMLoginItemSetEnabled("com.marshallbrekka.AutoWin.AutoWinHelper" as CFString, enabled) {
            NSLog("SMLoginItemSetEnabled change to %s worked!", enabled.description)
        }
    }
}
