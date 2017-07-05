import Foundation
import Cocoa
import AXSwift

class AWWindow {
    let ref:AXSwift.UIElement
    let id: UInt
    let pid: pid_t

    init(ref:AXSwift.UIElement, pid: pid_t) {
        self.ref = ref
        id = CFHash(ref.element)
        self.pid = pid
    }

    deinit {
        NSLog("deinit AWWindow")
    }

    func title() -> String? {
        guard let title:String = try! ref.attribute(.title) else {
            return nil
        }
        return title
    }

    func getSize() -> CGSize {
        return try! ref.attribute(.size)!
    }

    func getPosition() -> CGPoint {
        return try! ref.attribute(.position)!
    }

    func getFrame() -> NSDictionary {
        let size = getSize()
        let position = getPosition()
        return ["x": position.x,
                "y": position.y,
                "width": size.width,
                "height": size.height]
    }

    func becomeMain() -> Bool {
        do {
            try ref.setAttribute(.main, value: true)
            return true
        } catch {
            return false
        }
    }

    func setFrame(_ frame: NSDictionary) -> Bool {
        NSLog("setting frame on window: \(frame)")
        let x = frame.object(forKey: "x") as? Int
        let y = frame.object(forKey: "y") as? Int
        let width = frame.object(forKey: "width") as? Int
        let height = frame.object(forKey: "height") as? Int
        if (x == nil || y == nil || width == nil || height == nil) {
            return false
        } else {
            let size = CGSize(width: width!, height: height!)
            let position = CGPoint(x: x!, y: y!)
            do {
                try ref.setAttribute(.size, value: size)
                NSLog("set size of window")
                try ref.setAttribute(.position, value: position)
                NSLog("set position of window")
                try ref.setAttribute(.size, value: size)
                NSLog("set size of window")
                 return true
            } catch {
                return false
            }
        }
    }

    func close() -> Bool {
        do {
            let closeButton:AXSwift.UIElement = try ref.attribute(.closeButton)!
            try closeButton.performAction(.press)
            return true
        } catch {
            return false
        }
    }

    class func isWindow(_ ref:AXSwift.UIElement) -> Bool {
        do {
            let role:AXSwift.Role? = try ref.role()
            NSLog("window role \(role)")
        
            // The role attribute on a window can potentially be something
            // other than kAXWindowRole (e.g. Emacs does not claim kAXWindowRole)
            // so we will do the simple test first, but then also attempt to duck-type
            // the object, to see if it has a property that any window should have
            if role == nil {
                return false
            } else if role! == AXSwift.Role.window {
                let subrole:AXSwift.Subrole? = try ref.subrole()
                return (subrole == nil ||
                        subrole! == AXSwift.Subrole.standardWindow)
            } else {
                let minimizedAttr:AnyObject? = try ref.attribute(.minimizeButton)
                NSLog("window doesn't have standard role, \(minimizedAttr)")
                return minimizedAttr != nil
            }
        } catch {
            return false
        }
    }
}
