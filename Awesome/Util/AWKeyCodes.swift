//
//  KeyCodes.swift
//  Awesome
//
//  Created by Marshall Brekka on 4/22/15.
//  Copyright (c) 2015 Marshall Brekka. All rights reserved.
//

import Foundation
import Carbon
import Cocoa


let AWCharToModCode:NSDictionary = [
    "cmd"  : cmdKey,
    "ctrl" : controlKey,
    "opt"  : optionKey,
    "shift": shiftKey
]

let AWCharToKeyCode:NSDictionary = [
    "a":kVK_ANSI_A,
    "b":kVK_ANSI_B,
    "c":kVK_ANSI_C,
    "d":kVK_ANSI_D,
    "e":kVK_ANSI_E,
    "f":kVK_ANSI_F,
    "g":kVK_ANSI_G,
    "h":kVK_ANSI_H,
    "i":kVK_ANSI_I,
    "j":kVK_ANSI_J,
    "k":kVK_ANSI_K,
    "l":kVK_ANSI_L,
    "m":kVK_ANSI_M,
    "n":kVK_ANSI_N,
    "o":kVK_ANSI_O,
    "p":kVK_ANSI_P,
    "q":kVK_ANSI_Q,
    "r":kVK_ANSI_R,
    "s":kVK_ANSI_S,
    "t":kVK_ANSI_T,
    "u":kVK_ANSI_U,
    "v":kVK_ANSI_V,
    "w":kVK_ANSI_W,
    "x":kVK_ANSI_X,
    "y":kVK_ANSI_Y,
    "z":kVK_ANSI_Z,
    "0":kVK_ANSI_0,
    "1":kVK_ANSI_1,
    "2":kVK_ANSI_2,
    "3":kVK_ANSI_3,
    "4":kVK_ANSI_4,
    "5":kVK_ANSI_5,
    "6":kVK_ANSI_6,
    "7":kVK_ANSI_7,
    "8":kVK_ANSI_8,
    "9":kVK_ANSI_9,
    "`":kVK_ANSI_Grave,
    "=":kVK_ANSI_Equal,
    "-":kVK_ANSI_Minus,
    "]":kVK_ANSI_RightBracket,
    "[":kVK_ANSI_LeftBracket,
    "\"":kVK_ANSI_Quote,
    ";":kVK_ANSI_Semicolon,
    "\\":kVK_ANSI_Backslash,
    ",":kVK_ANSI_Comma,
    "/":kVK_ANSI_Slash,
    ".":kVK_ANSI_Period,
    "§":kVK_ISO_Section
    ]

@objc class AWKeyCodes:NSObject {
    class func charToKeyCode(key:String) -> UInt32 {
        let code = AWCharToKeyCode.objectForKey(key) as! Int
        return UInt32(code)
        
    }
    
    class func modifiersToModCode(modifiers:[String]) -> UInt32 {
        var code = 0 as UInt32
        for mod in modifiers {
            let modCode:UInt32 = UInt32(AWCharToModCode.objectForKey(mod) as! Int)
            code |= modCode
        }
        return code
    }
}
