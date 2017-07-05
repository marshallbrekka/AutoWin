import Foundation
import JavaScriptCore

@objc protocol AWJSEventInterface: JSExport {
    func addEvent(_ eventName:String, _ listener:JSValue)
    func removeEvent(_ eventName:String, _ listener:JSValue)
}

@objc class AWJSEvent: NSObject, AWJSEventInterface {
    let eventListeners: NSMutableDictionary;

    override init() {
        self.eventListeners = NSMutableDictionary()
    }
    
    deinit {
        NSLog("deinit AWJSEvent")
    }

    func addEvent(_ eventName: String, _ listener:JSValue) {
        NSLog("adding event listener: \(eventName)")
        let wrapped = JSManagedValue(value: listener)
        listener.context.virtualMachine.addManagedReference(wrapped, withOwner: self)
        var listeners:[JSManagedValue]? = eventListeners.object(forKey: eventName) as! [JSManagedValue]?
        if (listeners == nil) {
            listeners = [wrapped!];
        } else {
            // Exit early if the listener is already present
            for existingListener in listeners! {
                if (wrapped?.isEqual(existingListener))! {
                    return;
                }
            }
            listeners!.append(wrapped!)
        }
        eventListeners.setObject(listeners!, forKey: eventName as NSCopying)
    }
    
    func removeEvent(_ eventName: String, _ listener:JSValue) {
        NSLog("removing event listener: \(eventName)")
        var listeners:[JSManagedValue]? = eventListeners.object(forKey: eventName) as! [JSManagedValue]?
        if (listeners != nil) {
            listeners = listeners!.filter( {(existingListener: JSManagedValue) -> Bool in
                if (listener.isNotEqual(to: existingListener.value)) {
                    return true
                } else {
                    existingListener.value.context.virtualMachine.removeManagedReference(existingListener, withOwner: self)
                    return false
                }
            })
            eventListeners.setObject(listeners!, forKey: eventName as NSCopying)
        }
    }
    
    func triggerEvent(_ eventName: String, eventData: NSDictionary?) {
        let listeners: [JSManagedValue]? = eventListeners.object(forKey: eventName) as! [JSManagedValue]?
        if (listeners != nil) {
            NSLog("triggering listeners for: \(eventName)")
            for listener in listeners! {
                if eventData == nil {
                    listener.value.call(withArguments: [eventName])
                } else {
                    listener.value.call(withArguments: [eventName, eventData!])
                }
            }
        } else {
            NSLog("no listeners for: \(eventName)")
        }
    }
}
