//
//  AWOpenAtLogin.swift
//  Awesome
//
//  Created by Marshall Brekka on 10/24/15.
//  Copyright © 2015 Marshall Brekka. All rights reserved.
//

import Foundation

class AWOpenAtLogin {
    static func sharedFileList() -> LSSharedFileListRef {
        return LSSharedFileListCreate(nil, kLSSharedFileListSessionLoginItems.takeRetainedValue(), nil).takeRetainedValue()
    }
}
