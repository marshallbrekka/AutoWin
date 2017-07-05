import Foundation
import Carbon
import CoreServices

typealias AWHotKeyCallback = (_ down:Bool, _ key:String, _ modifiers:[String]) -> Void

class AWHotKeyManager {
    struct AWHotKeyInstance {
        let ref: EventHotKeyRef
        let key: String
        let modifiers: [String]
        var callbacks: NSMutableArray
    }
    
    struct AWHotKeyRef {
        let keyCode:UInt32
        let modCode:UInt32
        let handler: AWHotKeyCallbackWrapper
    }
    
    class AWHotKeySelfRef {
        let down:Bool
        let this:AWHotKeyManager
        init(down:Bool, this:AWHotKeyManager) {
            self.down = down
            self.this = this
        }
    }
    
    class AWHotKeyCallbackWrapper {
        var callback:AWHotKeyCallback
        init(callback:@escaping AWHotKeyCallback) {
            self.callback = callback
        }
    }

    var hotKeyInstances = [UInt64: AWHotKeyInstance]()
    var downRef:AWHotKeySelfRef?
    var upRef:  AWHotKeySelfRef?
    var downPointer:UnsafeMutableRawPointer?
    var upPointer:  UnsafeMutableRawPointer?
    
    init() {
        downRef     = AWHotKeySelfRef(down: true, this: self)
        upRef       = AWHotKeySelfRef(down: false, this: self)
        downPointer = Unmanaged.passUnretained(downRef!).toOpaque()
        upPointer   = Unmanaged.passUnretained(upRef!).toOpaque()

        installHandlerHelper(kEventHotKeyPressed, pointer: downPointer!) //downPointer!)
        installHandlerHelper(kEventHotKeyReleased, pointer: upPointer!) // !)
    }
    
    func addHotKey(_ key:String, modifiers:[String], callback:@escaping AWHotKeyCallback) -> AWHotKeyRef {
        let keyCode = AWKeyCodes.charToKeyCode(key)
        let modCode = AWKeyCodes.modifiersToModCode(modifiers)
        let code = AWHotKeyManager.combineKeyAndModCode(keyCode, modCode: modCode)
        let callbackWrapper = AWHotKeyCallbackWrapper(callback: callback)
        
        if let keyInstance = hotKeyInstances[code] {
            // we already have a listener, append the callback to the list
            keyInstance.callbacks.add(callbackWrapper)
        } else {
            // No listener, register one and start tracking callbacks
            var ref:EventHotKeyRef? = nil
            let hotKeyID = EventHotKeyID(signature: modCode, id: keyCode)
            RegisterEventHotKey(keyCode, modCode, hotKeyID, GetEventMonitorTarget(), 0,  &ref)
            let keyInstance = AWHotKeyInstance(
                ref: ref!,
                key: key,
                modifiers: modifiers,
                callbacks: [callbackWrapper])
            hotKeyInstances[code] = keyInstance
        }
        return AWHotKeyRef(keyCode: keyCode, modCode: modCode, handler: callbackWrapper)
    }
    
    func removeHotKey(_ ref: AWHotKeyRef) {
        let code = AWHotKeyManager.combineKeyAndModCode(ref.keyCode, modCode: ref.modCode)
        if let keyInstance = hotKeyInstances[code] {
            keyInstance.callbacks.remove(ref.handler)
            if (keyInstance.callbacks.count == 0) {
                UnregisterEventHotKey(keyInstance.ref)
                hotKeyInstances.removeValue(forKey: code)
            }
        }
    }
    
    fileprivate func installHandlerHelper(_ eventKind: Int, pointer:UnsafeMutableRawPointer) {
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: OSType(eventKind))
        let hotkey_callback: EventHandlerUPP = { (handler:EventHandlerCallRef?, event:EventRef?, ptr:UnsafeMutableRawPointer?) -> OSStatus in
            let pair = Unmanaged<AWHotKeySelfRef>.fromOpaque(ptr!).takeUnretainedValue()
            pair.this.eventHandler(pair.down, handler: handler!, event: event!)
            return noErr
        }
        InstallEventHandler(GetEventMonitorTarget(), hotkey_callback, 1, &eventType, pointer, nil)
    }
    
    fileprivate func eventHandler(_ down: Bool, handler: EventHandlerCallRef, event:EventRef) {
        var hotKeyId:EventHotKeyID = EventHotKeyID()
        GetEventParameter(event, OSType(kEventParamDirectObject), OSType(typeEventHotKeyID), nil, MemoryLayout<EventHotKeyID>.size, nil, &hotKeyId)
        let code = AWHotKeyManager.combineKeyAndModCode(hotKeyId.id, modCode: hotKeyId.signature)
        NSLog("event handler:: down: \(down), handler: \(handler), event: \(event), hotkeyId: \(hotKeyId.id), signature: \(hotKeyId.signature)")
        if let keyInstance = hotKeyInstances[code] {
            for callback:Any in keyInstance.callbacks {
                (callback as! AWHotKeyCallbackWrapper).callback(
                    down,
                    keyInstance.key,
                    keyInstance.modifiers)
            }
        }
    }
    
    static func combineKeyAndModCode(_ keyCode:UInt32, modCode: UInt32) -> UInt64 {
        let code = UInt64(keyCode)
        let modCodeInt = UInt64(modCode)
        return modCodeInt << 32 | code
    }
    
    static func keyAndModifiersToCode(_ key:String, modifiers:[String]) -> UInt64 {
        let keyCode = AWKeyCodes.charToKeyCode(key)
        let modCode = AWKeyCodes.modifiersToModCode(modifiers)
        return AWHotKeyManager.combineKeyAndModCode(keyCode, modCode: modCode)
    }
}
