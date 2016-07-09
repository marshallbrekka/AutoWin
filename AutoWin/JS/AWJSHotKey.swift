import Foundation
import JavaScriptCore

@objc protocol AWJSHotKeyInterface :JSExport {
    // Use hacky param names so that we get addHotkeyListener as the js method
    func add(key:String, _ modifiers:[String], _ callback: JSValue)
    // Use hacky param names so that we get removeHotkey as the js method
    func remove(key:String, _ modifiers:[String])
}

@objc class AWJSHotKey : NSObject, AWJSHotKeyInterface {
    struct AWJSHotKeyInstance {
        let ref:AWHotKeyManager.AWHotKeyRef
        var callback:JSManagedValue
    }
    
    let manager:AWHotKeyManager
    var listeners = [UInt64:AWJSHotKeyInstance]()
    var receiver:AWHotKeyCallback?
    
    init(manager:AWHotKeyManager) {
        self.manager = manager;
        super.init()
        receiver = {[unowned self] (down:Bool, key:String, modifiers:[String]) in
            if down {
                let code = AWHotKeyManager.keyAndModifiersToCode(key, modifiers: modifiers)
                if let instance = self.listeners[code] {
                    instance.callback.value.callWithArguments([key, modifiers])
                }
            }
        }
    }
    
    deinit {
        print("deinit awjshotkey")
        unregisterAll()
    }
    
    func unregisterAll() {
        print("deinnitting js hotkey")
        for (_, instance) in listeners {
            if let virtualMachine = instance.callback.value?.context?.virtualMachine {
                virtualMachine.removeManagedReference(instance.callback, withOwner: self)
            }
            manager.removeHotKey(instance.ref)
        }
    }
    
    func add(key: String, _ modifiers: [String], _ callback: JSValue) {
        let code = AWHotKeyManager.keyAndModifiersToCode(key, modifiers: modifiers)
        let wrapped = JSManagedValue(value: callback)
        callback.context.virtualMachine.addManagedReference(wrapped, withOwner: self)
        if var instance = listeners[code] {
            let virtualMachine = instance.callback.value.context.virtualMachine
            virtualMachine.removeManagedReference(instance.callback, withOwner: self)
            instance.callback = wrapped
        } else {
            let ref = manager.addHotKey(key, modifiers: modifiers, callback: receiver!)
            listeners[code] = AWJSHotKeyInstance(ref: ref, callback: wrapped)
        }
    }
    
    func remove(key: String, _ modifiers: [String]) {
        let code = AWHotKeyManager.keyAndModifiersToCode(key, modifiers: modifiers)
        if let instance = listeners[code] {
            let virtualMachine = instance.callback.value.context.virtualMachine
            virtualMachine.removeManagedReference(instance.callback, withOwner: self)
            manager.removeHotKey(instance.ref)
        }
    }
}