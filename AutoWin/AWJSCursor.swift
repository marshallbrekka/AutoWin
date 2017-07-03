/*
 ** Application Level Events **
 aw.application.launched
 aw.application.terminated
 aw.application.activated
 aw.application.deactivated
 aw.application.hidden
 aw.application.unhidden
 
 ** mouse functions **
 
 aw.mouse.applications()
 aw.application.activate()
 */

import Foundation
import JavaScriptCore
import Cocoa

@objc protocol AWJSCursorInterface : JSExport {
    func setPosition(_ position:NSDictionary) -> Bool
    func getPosition() -> NSDictionary?
    func click(_ position:NSDictionary) -> Bool
    
}

/*
 Class that provides the javascript interface for aw.cursor.
 */
@objc class AWJSCursor : NSObject, AWJSCursorInterface {
    
    override init () {
    }
    
    deinit {
        print("deinit awjsmouse")
    }
    
    // JS application api
    func getPosition() -> NSDictionary? {
        let position = AWCursor.getPosition()
        return [
            "x": position.x,
            "y": position.y
        ]
    }
    
    func setPosition(_ position:NSDictionary) -> Bool {
        let point = dictToPoint(position)
        if point != nil {
            AWCursor.setPosition(point!)
            return true
        }
        return false
    }
    
    func click(_ position:NSDictionary) -> Bool {
        let point = dictToPoint(position)
        if point != nil {
            AWCursor.click(point!)
            return true
        }
        return false
    }
    
    func dictToPoint(_ position:NSDictionary) -> CGPoint? {
        let x = position.object(forKey: "x") as? Int
        let y = position.object(forKey: "y") as? Int
        if x != nil && y != nil {
            return CGPoint(x: x!, y: y!)
        }
        return nil
    }
}
