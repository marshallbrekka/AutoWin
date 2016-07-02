//
//  AWObserver.swift
//  Awesome
//
//  Created by Marshall Brekka on 11/23/15.
//  Copyright © 2015 Marshall Brekka. All rights reserved.
//

import Foundation

typealias Callback = (ob:AXObserverRef, el:AXUIElementRef, notification:CFStringRef) -> Void

class AWObserver {
    let callback:Callback
    let observer:AXObserver
    var selfPointer:UnsafeMutablePointer<Void>?
    
    
    init(pid:pid_t, callback:Callback) {
        var observer:AXObserver? = nil
        let err = AXObserverCreate(pid, {(observer:AXObserverRef, element:AXUIElementRef, notification:CFStringRef, contextData:UnsafeMutablePointer<Void>) in
            
            let me = Unmanaged<AWObserver>.fromOpaque(COpaquePointer(contextData)).takeUnretainedValue()
            me.callback(ob: observer, el: element, notification: notification)
        }, &observer)

        self.callback = callback
        self.observer = observer!
        self.selfPointer = UnsafeMutablePointer(Unmanaged.passUnretained(self).toOpaque())
        let source = AXObserverGetRunLoopSource(observer!)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), source.takeUnretainedValue(), kCFRunLoopDefaultMode)
    }
    
    func addNotification(element:AXUIElementRef, notification:CFStringRef) {
        AXObserverAddNotification(self.observer, element, notification, selfPointer!)
    }
    
    deinit {
       let source = AXObserverGetRunLoopSource(observer)
        CFRunLoopRemoveSource(CFRunLoopGetCurrent(),
            source.takeUnretainedValue(),
            kCFRunLoopDefaultMode);
    }
}
