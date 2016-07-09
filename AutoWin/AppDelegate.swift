import Cocoa
import Carbon
import JavaScriptCore

class AppDelegate: NSObject, NSApplicationDelegate {
    var context: AWJSContext?
    var manager: AWManager?
    var menuItem:AWStatusItem?
    var menuTarget:AWStatusTarget?
    var hk:AWHotKeyManager?
    var ms:AWMouse?
    var accessibilityEnabled:AWAccessibilityEnabled?
    var ref:EventHotKeyRef = nil
    private var observerContext = 0
    var cc:JSContext?

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        AWOpenAtLogin.setAppBundle()
        cc = JSContext()
        AWAccessibilityAPI.promptToTrustProcess()
        accessibilityEnabled = AWAccessibilityEnabled()
        menuTarget = AWStatusTarget(accessibility: accessibilityEnabled!, reloadJS: reloadJS)
        menuItem = AWStatusItem(target:menuTarget!)
        hk = AWHotKeyManager()
        if accessibilityEnabled!.enabled {
            startApp()
        }
        
        hk!.addHotKey("r", modifiers: ["ctrl", "opt", "cmd"], callback: {(down: Bool, key:String, modifiers:[String]) in
            if !down {
                self.reloadJS()
            }
        })
        accessibilityEnabled?.addObserver(self, forKeyPath: "enabled", options: .New, context: &context)
    }
    
    func startApp() {
        NSLog("staring app")
        manager = AWManager()
        loadJSEnvironment()
    }
    
    func stopApp() {
        NSLog("stopping app")
        manager = nil
        context = nil
    }
    
    func reloadJS() {
        NSLog("reloading js")
        if (manager != nil) {
            context = nil
            loadJSEnvironment()
        }
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if context == &self.context {
            if accessibilityEnabled!.enabled {
                startApp()
            } else {
                stopApp()
                AWAccessibilityAPI.promptToTrustProcess()
            }
        }
    }
    
    func loadJSEnvironment() {
        var savedFilePath = AWPreferences.getString(AWPreferences.JSFilePath)
        if savedFilePath == nil {
            savedFilePath = NSBundle.mainBundle().pathForResource("demo", ofType: "js")
        }
  
        do {
            let contents = try String(contentsOfFile: savedFilePath!, encoding:NSUTF8StringEncoding)
            context = AWJSContext(manager: manager!, hotKeys: hk!, customContent: contents)
                
        } catch _ {
            print("ERROR", savedFilePath)
        }
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
        print("terminating")
    }
}