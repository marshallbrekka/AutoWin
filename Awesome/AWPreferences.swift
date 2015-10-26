//
//  AWPreferences.swift
//  Awesome
//
//  Created by Marshall Brekka on 10/24/15.
//  Copyright © 2015 Marshall Brekka. All rights reserved.
//

import Foundation

class AWPreferences {
    static let JSFilePath = "AWPreferencesJSFilePath"
    
    class func getBool(key: String) -> Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey(key)
    }
    
    class func getString(key:String) -> String? {
        return NSUserDefaults.standardUserDefaults().stringForKey(key)
    }
    
    class func setBool(key: String, value: Bool) {
        NSUserDefaults.standardUserDefaults().setBool(value, forKey: key)
    }
    
    class func setString(key: String, value: String) {
        NSUserDefaults.standardUserDefaults().setObject(value, forKey: key)
    }
}
