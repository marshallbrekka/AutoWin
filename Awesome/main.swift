//
//  main.swift
//  Awesome
//
//  Created by Marshall Brekka on 11/30/15.
//  Copyright © 2015 Marshall Brekka. All rights reserved.
//

import Cocoa
NSUserDefaults.standardUserDefaults().setBool(true, forKey: "WebKitDeveloperExtras")
NSUserDefaults.standardUserDefaults().synchronize()
//[[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"WebKitDeveloperExtras"];
//[[NSUserDefaults standardUserDefaults] synchronize];
NSApplicationMain(Process.argc, Process.unsafeArgv)