//
//  AWStatusItem.swift
//  Awesome
//
//  Created by Marshall Brekka on 10/24/15.
//  Copyright © 2015 Marshall Brekka. All rights reserved.
//

import Foundation
import Cocoa

class AWStatusItem {
    let item:NSStatusItem
    let items = [["Preferences", "showPreferences:"],
                 ["Quit","quit:"]]
    
    init(target:AWStatusTarget) {
        item = NSStatusBar.systemStatusBar().statusItemWithLength(NSSquareStatusItemLength)
        let menu = NSMenu()
        for menuItem in items {
            let newItem = NSMenuItem(title:menuItem[0], action:Selector(menuItem[1]), keyEquivalent: "")
            newItem.target = target
            menu.addItem(newItem)
        }
        
//        item.button!.title = "AW"
        print("item widht", NSSquareStatusItemLength)

        item.button!.image = NSImage(named: "status")
        item.menu = menu
    }
}
