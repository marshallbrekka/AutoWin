//  http://stackoverflow.com/questions/31891002/how-do-you-use-cgeventtapcreate-in-swift
import Foundation
import CoreGraphics

func callback(_ proxy:CGEventTapProxy, type:CGEventType, event:CGEvent, refcon: UnsafeMutableRawPointer) -> Unmanaged<CGEvent>? {
    print("mouse moved")
    return Unmanaged.passRetained(event)
}

class AWCursor {
    class func getPosition() -> CGPoint {
        let event = CGEvent(source: nil)
        let location = event?.location
        return location!;
    }

    class func setPosition(_ point:CGPoint) {
        CGWarpMouseCursorPosition(point)
    }
    
    
    class func click(_ point: CGPoint) {
        let theEvent = CGEvent(mouseEventSource: nil,
                               mouseType: CGEventType.leftMouseDown,
                               mouseCursorPosition: point,
                               mouseButton: CGMouseButton.left);
        theEvent!.post(tap: CGEventTapLocation.cghidEventTap);
        theEvent!.type = CGEventType.leftMouseUp;
        theEvent!.post(tap: CGEventTapLocation.cghidEventTap);
    }

    let etap:CFMachPort?

    init() {
        print("creating mask!")
        let mask = (1 << CGEventType.mouseMoved.rawValue)
        etap = CGEvent.tapCreate(tap: CGEventTapLocation.cgSessionEventTap,
            place: CGEventTapPlacement.headInsertEventTap,
            options: CGEventTapOptions.listenOnly,
            eventsOfInterest: CGEventMask(mask),
            callback: callback as! CGEventTapCallBack,
            userInfo: nil);

        let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, etap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, CFRunLoopMode.commonModes)
        CGEvent.tapEnable(tap: etap!, enable: true)
        CFRunLoopRun()
    }
}
