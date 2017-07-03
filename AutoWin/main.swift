import Cocoa
import AXSwift

UserDefaults.standard.set(true, forKey: "WebKitDeveloperExtras")
UserDefaults.standard.synchronize()
//[[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"WebKitDeveloperExtras"];
//[[NSUserDefaults standardUserDefaults] synchronize];
NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
