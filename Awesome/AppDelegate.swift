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
    
    var iapps:[AWApplication]?
    var context: AWJSContext?
    var hkm: AWHotKeyManager?
    var id1:UInt32?
    //var notifo:ApplicationNotification?


    func applicationDidFinishLaunching(aNotification: NSNotification) {
        context = AWJSContext()
        /*hkm = AWHotKeyManager()
        id1 = hkm!.addHotKey("e", withModifiers: ["cmd", "opt", "ctrl", "shift"], forCallback: {(down:Bool, key:String!, modifiers:[AnyObject]!) in
            println("got hotkey event callback")
            if (!down) {
                self.hkm!.removeHotKey(self.id1!);
            }
        })*/
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
        print("terminating")
        
    }


}

