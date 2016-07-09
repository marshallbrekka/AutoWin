//  http://stackoverflow.com/questions/31891002/how-do-you-use-cgeventtapcreate-in-swift
import Foundation
import CoreGraphics

func callback(proxy:CGEventTapProxy, type:CGEventType, event:CGEventRef, refcon: UnsafeMutablePointer<Void>) -> Unmanaged<CGEvent>? {
    print("mouse moved")
    return Unmanaged.passRetained(event)
}

class AWMouse {
    class func getPosition() -> CGPoint {
        let event = CGEventCreate(nil)
        let location = CGEventGetLocation(event)
        return location;
    }

    class func setPosition(point:CGPoint) {
        CGWarpMouseCursorPosition(point)
    }

    let etap:CFMachPort?

    init() {
        print("creating mask!")
        let mask = (1 << CGEventType.MouseMoved.rawValue)
        etap = CGEventTapCreate(CGEventTapLocation.CGSessionEventTap,
            CGEventTapPlacement.HeadInsertEventTap,
            CGEventTapOptions.ListenOnly,
            CGEventMask(mask),
            callback,
            nil);

        let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, etap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, kCFRunLoopCommonModes)
        CGEventTapEnable(etap!, true)
        CFRunLoopRun()
    }
}