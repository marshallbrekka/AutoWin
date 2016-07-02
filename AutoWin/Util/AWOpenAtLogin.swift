//
//  AWOpenAtLogin.swift
//  Awesome
//
//  Created by Marshall Brekka on 10/24/15.
//  Copyright © 2015 Marshall Brekka. All rights reserved.
//

import Foundation
import ServiceManagement

class AWOpenAtLogin {
    class func setOpenAtLogin(enabled: Bool) {
        AWPreferences.setBool(AWPreferences.OpenAtLogin, value:enabled)
        let helperAppUrl = NSBundle.mainBundle().bundleURL.URLByAppendingPathComponent("Contents/Library/LoginItems/AutoWinHelper.app", isDirectory: true)
        
        let reverse = helperAppUrl.URLByDeletingLastPathComponent?.URLByDeletingLastPathComponent?.URLByDeletingLastPathComponent?.URLByDeletingLastPathComponent
        print("reverse",reverse, helperAppUrl)
        
        let status = LSRegisterURL(helperAppUrl, enabled)
        if status != noErr {
            NSLog("Failed to LSRegisterURL '%@': %jd", helperAppUrl, status)
        }
        
        if SMLoginItemSetEnabled("com.marshallbrekka.AutoWin.AutoWinHelper", enabled) {
            NSLog("SMLoginItemSetEnabled change to %i worked!", enabled)
        }
    }
}
