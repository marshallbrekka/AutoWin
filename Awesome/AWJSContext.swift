//
//  AWJSContext.swift
//  Awesome
//
//  Created by Marshall Brekka on 4/20/15.
//  Copyright (c) 2015 Marshall Brekka. All rights reserved.
//

import Foundation
import JavaScriptCore



class AWJSContext {
    let context: JSContext = JSContext()
    let application: AWJSApplication;
    let api:NSDictionary

    init() {
        context.exceptionHandler = { context, exception in
            println("JS Error: \(exception)")
        }
        
        application =  AWJSApplication()
        // initialize api objects here
        api = [
            "application": application
        ]
        context.setObject(api, forKeyedSubscript: "aw")
        context.evaluateScript("document.createEvent('mousemove');")
    }

}