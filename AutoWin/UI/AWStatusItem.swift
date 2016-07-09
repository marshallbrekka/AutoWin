import Foundation
import Cocoa

class AWStatusItem {
    let item:NSStatusItem
    let items = [["Preferences", "showPreferences:"],
                 ["Reload JS", "reload:"],
                 ["Quit","quit:"]]
    
    init(target:AWStatusTarget) {
        item = NSStatusBar.systemStatusBar().statusItemWithLength(NSSquareStatusItemLength)
        let menu = NSMenu()
        for menuItem in items {
            let newItem = NSMenuItem(title:menuItem[0], action:Selector(menuItem[1]), keyEquivalent: "")
            newItem.target = target
            menu.addItem(newItem)
        }
        
        item.button!.image = NSImage(named: "status")
        item.menu = menu
    }
}