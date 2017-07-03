import Foundation

typealias Callback = (_ ob:AXObserver, _ el:AXUIElement, _ notification:CFString) -> Void

class AWObserver {
    let callback:Callback
    let observer:AXObserver!
    let foo:String
    var selfPointer:UnsafeMutableRawPointer?
    
    
    init(pid:pid_t, callback:@escaping Callback) {
        var observer:AXObserver? = nil
        
        let handler = {(observer:AXObserver, element:AXUIElement, notification:CFString, contextData:UnsafeMutableRawPointer?) in
            NSLog("got notification " + ((notification as NSString) as String));
            if contextData != nil {
                let me2 = Unmanaged<AWObserver>.fromOpaque(contextData!)
                let me = me2.takeRetainedValue()
                print(me.foo)
                me.callback(observer, element, notification)
            } else {
                NSLog("skipping notification " + ((notification as NSString) as String));
            }
        } as AXObserverCallback
        let err = AXObserverCreate(pid, handler, &observer)
        self.foo = "hello"
        self.callback = callback
        self.observer = observer!
        //var selfVar = self
        self.selfPointer = UnsafeMutableRawPointer(Unmanaged<AWObserver>.passUnretained(self).toOpaque())
//        let source = AXObserverGetRunLoopSource(observer!)
        CFRunLoopAddSource(
          RunLoop.current.getCFRunLoop(),
          AXObserverGetRunLoopSource(self.observer),
          CFRunLoopMode.defaultMode)
    }
    
    func addNotification(_ element:AXUIElement, notification:CFString) {
        NSLog("adding notification " + ((notification as NSString) as String));
        AXObserverAddNotification(self.observer, element, notification, selfPointer!)
    }
    
    deinit {
       let source = AXObserverGetRunLoopSource(observer)
        CFRunLoopRemoveSource(CFRunLoopGetCurrent(),
            source,
            CFRunLoopMode.defaultMode);
    }
}
