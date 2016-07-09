import Cocoa

NSUserDefaults.standardUserDefaults().setBool(true, forKey: "WebKitDeveloperExtras")
NSUserDefaults.standardUserDefaults().synchronize()
//[[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"WebKitDeveloperExtras"];
//[[NSUserDefaults standardUserDefaults] synchronize];
NSApplicationMain(Process.argc, Process.unsafeArgv)