//
//  AppDelegate.swift
//  Awesome
//
//  Created by Marshall Brekka on 3/27/15.
//  Copyright (c) 2015 Marshall Brekka. All rights reserved.
//

import Cocoa
import JavaScriptCore

let thing = JSContext()
let x = thing.evaluateScript("function x() {return {x: 1, y: 2}}; x()")



@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!


    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        println(x.toDictionary())
        println(kAXErrorFailure)
        println(kAXErrorIllegalArgument)
        println(kAXErrorInvalidUIElement)
        println(kAXErrorInvalidUIElementObserver)
        println(kAXErrorCannotComplete)
        println(kAXErrorAttributeUnsupported)
        println(kAXErrorActionUnsupported)
        println(kAXErrorNotImplemented)
        println(kAXErrorAPIDisabled)
        println(kAXErrorNoValue)
        println(kAXErrorParameterizedAttributeUnsupported)
        
        
        println("Are we trusted " + String(AXIsProcessTrusted()) + " "  + String(kAXErrorSuccess))
        var apps = Application.applications()
        for app in apps {
            println("App Name " + app.title())
            var windows = app.windows()
            for window in windows {
                println("  window name " + window.title()!)
            }
        }
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

