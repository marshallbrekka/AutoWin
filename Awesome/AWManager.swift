//
//  AWManager.swift
//  Awesome
//
//  Created by Marshall Brekka on 4/21/15.
//  Copyright (c) 2015 Marshall Brekka. All rights reserved.
//

import Foundation

class AWManager: AWApplicationJSInterface {
    
    // A map of pid (NSNumber) to application (AWApplication)
    let apps:NSMutableDictionary = NSMutableDictionary()
    
    func applications() -> [AWApplication] {
        var keys:[NSNumber] = apps.allKeys as [NSNumber]
        return keys.map({(pid:NSNumber) -> AWApplication in
            return self.apps.objectForKey(pid) as AWApplication
        });
    }
    
    func activate(pid: pid_t) -> Bool {
        var key = NSNumber(int: pid)
        var app:AWApplication? = apps.objectForKey(key) as AWApplication?
        if app != nil {
            return app.activate()
        } else {
            println("application wasn't found for pid")
            return false
        }
    }
    
}