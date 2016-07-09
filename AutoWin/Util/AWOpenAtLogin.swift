import Foundation
import ServiceManagement
import Cocoa
import AppKit

class AWOpenAtLogin {
    class func setAppBundle() {
        let helperAppUrl = NSBundle.mainBundle().bundleURL.URLByAppendingPathComponent("Contents/Library/LoginItems/AutoWinHelper.app", isDirectory: true)
        
        let reverse = helperAppUrl.URLByDeletingLastPathComponent?.URLByDeletingLastPathComponent?.URLByDeletingLastPathComponent?.URLByDeletingLastPathComponent
        NSLog("reverse %@, %@", reverse!, helperAppUrl)
        let status = LSRegisterURL(helperAppUrl, true)
        if status != noErr {
            NSLog("Failed to LSRegisterURL '%@': %jd", helperAppUrl, status)
        }
    }
    
    class func setOpenAtLogin(enabled: Bool) {
        AWPreferences.setBool(AWPreferences.OpenAtLogin, value:enabled)
        if SMLoginItemSetEnabled("com.marshallbrekka.AutoWin.AutoWinHelper", enabled) {
            NSLog("SMLoginItemSetEnabled change to %i worked!", enabled)
        }
    }
}