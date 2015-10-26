//
//  AWPreferencesWindow.swift
//  Awesome
//
//  Created by Marshall Brekka on 10/24/15.
//  Copyright © 2015 Marshall Brekka. All rights reserved.
//

import Foundation
import Cocoa

class AWPreferencesWindow:NSWindowController {
    @IBOutlet weak var filePickerButton:NSButton?
    @IBOutlet weak var jsFilePathLabel:NSTextField?
    @IBOutlet weak var openAtLoginButton:NSButton?
    @IBOutlet weak var enableAccessibilityButton:NSButton?
    @IBOutlet weak var accessibilityStatus:NSTextField?
    
    override func windowDidLoad() {
        print("window did load")
        NSDistributedNotificationCenter.defaultCenter().addObserverForName(
            "com.apple.accessibility.api",
            object: nil, queue: nil, usingBlock: {(notifo:NSNotification) -> Void in
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.15 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
                    self.updateAccessibilityEnabled()
                })
            })
        jsFilePathLabel?.stringValue = "Really Long Label"
    }
    
    func updateAccessibilityEnabled() {
        let enabled = AWAccessibilityAPI.isProcessTrusted()
        accessibilityStatus?.stringValue = enabled ? "Enabled" : "Disabled"
        enableAccessibilityButton?.enabled = !enabled
    }
    
    @IBAction override func showWindow(sender: AnyObject?) {
        print("show window", window, jsFilePathLabel)
        let filePath = AWPreferences.getString(AWPreferences.JSFilePath)
        if (filePath != nil) {
            jsFilePathLabel?.stringValue = filePath!
        } else {
            jsFilePathLabel?.stringValue = "No File Specified"
        }
        
        updateAccessibilityEnabled()
        super.showWindow(sender)
    }

    
    @IBAction func showFilePicker(sender:NSButton) {
        let openPanel = NSOpenPanel()
        openPanel.allowedFileTypes = ["js"]
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canCreateDirectories = false
        openPanel.canChooseFiles = true
        openPanel.beginSheetModalForWindow(window!, completionHandler: { (result) -> Void in
            if result == NSFileHandlingPanelOKButton {
                print(openPanel.URL?.path)
                AWPreferences.setString(AWPreferences.JSFilePath, value: openPanel.URL!.path!)
                self.jsFilePathLabel!.stringValue = openPanel.URL!.path!
                //Do what you will
                //If there's only one URL, surely 'openPanel.URL'
                //but otherwise a for loop works
            }
        })
    }
    
    @IBAction func setOpenAtLogin(sender:NSButton) {
        print("set open at login")
    }
    
    @IBAction func enableAccessibility(sender:NSButton) {
        print("enable accessibility")
        AWAccessibilityAPI.promptToTrustProcess()
    }
    
}
