//
//  AppDelegate.swift
//  Awesome
//
//  Created by Marshall Brekka on 3/27/15.
//  Copyright (c) 2015 Marshall Brekka. All rights reserved.
//

import Cocoa
import JavaScriptCore


/*
let thing = JSContext()
//let x = thing.evaluateScript("var x = function (arg) {return 'hello'; return typeof arg}")
var other = thing.evaluateScript("var triple = function(value) { return value * 3 }")
//var fn = thing.objectForKeyedSubscript("x")
//var point = JSValue(point: , inContext: thing)
//var result = fn.callWithArguments([["x":1]])

let tripleFunction = thing.objectForKeyedSubscript("triple")
let result2 = tripleFunction.callWithArguments([5])
*/





@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!


    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        let context = JSContext()
        context.exceptionHandler = { context, exception in
            println("JS Error: \(exception)")
        }
        var s = CGSize(width: 20, height: 10)
        var sValue = JSValue(size: s, inContext: context)
        
        context.evaluateScript("var num = 5 + 5")
        context.evaluateScript("var names = ['Grace', 'Ada', 'Margaret']")
        context.evaluateScript("var triple = function(value) { return value * 3 }")
        let tripleNum: JSValue = context.evaluateScript("triple(num)")
        
        context.evaluateScript("var x = function (arg) {return {width: arg.width, height: arg.height}}")
        let hifn = context.objectForKeyedSubscript("x")
        let hire = hifn.callWithArguments([sValue])
        println("hi fn \(hire.toSize())")
        println("Tripled: \(tripleNum.toInt32())")
        let names = context.objectForKeyedSubscript("names")
        let initialName = names.objectAtIndexedSubscript(0)
        println("The first name: \(initialName.toString())")
        let tripleFunction = context.objectForKeyedSubscript("triple")
        let result = tripleFunction.callWithArguments([5])
        println("Five tripled: \(result.toInt32())")

        
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
                var p = window.position()
                var s = window.size()
                println("  window name \(window.title()!): x=\(p.x), y=\(p.y), w=\(s.width), h=\(s.height)")
            }
        }
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

