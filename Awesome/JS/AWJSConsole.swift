//
//  AWJSConsole.swift
//  Awesome
//
//  Created by Marshall Brekka on 4/21/15.
//  Copyright (c) 2015 Marshall Brekka. All rights reserved.
//

import Foundation

@objc protocol AWJSConsoleInterface {
    class func log(item: AnyObject)
}

@objc class AWJSConsole: NSObject, AWJSConsoleInterface {
    class func log(item: AnyObject) {
        println("JS Log: " + item.toString())
    }
}
