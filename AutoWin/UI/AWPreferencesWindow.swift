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
    @IBOutlet weak var reloadJSButton:NSButton?
    @IBOutlet weak var openAtLoginButton:NSButton?
    @IBOutlet weak var enableAccessibilityButton:NSButton?
    @IBOutlet weak var accessibilityStatus:NSTextField?
    private var context = 0
    private var accessibilityEnabled:AWAccessibilityEnabled?
    private var reloadJS:(() -> Void)?
    
    override init(window:NSWindow!) {
        super.init(window: window)
    }
    
    required init(coder:NSCoder) {
        super.init(coder: coder)!
    }
    
    convenience init (accessibility:AWAccessibilityEnabled, reloadJS: () -> Void) {
        self.init(window: nil)
        NSBundle.mainBundle().loadNibNamed("AWPreferences", owner: self, topLevelObjects: nil)
        accessibilityEnabled = accessibility
        self.reloadJS = reloadJS
        accessibility.addObserver(self, forKeyPath: "enabled", options: .New, context: &context)
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if context == &self.context {
            updateAccessibilityEnabled()
        }
    }

    override func windowDidLoad() {
        print("window did load")
        jsFilePathLabel?.stringValue = "Really Long Label"
    }
    
    func updateAccessibilityEnabled() {
        accessibilityStatus?.stringValue = accessibilityEnabled!.enabled ? "Enabled" : "Disabled"
        enableAccessibilityButton?.enabled = !accessibilityEnabled!.enabled
    }
    
    @IBAction override func showWindow(sender: AnyObject?) {
        print("show window", window, jsFilePathLabel)
        let filePath = AWPreferences.getString(AWPreferences.JSFilePath)
        if (filePath != nil) {
            jsFilePathLabel?.stringValue = filePath!
        } else {
            jsFilePathLabel?.stringValue = "No File Specified"
        }
        
        openAtLoginButton!.state = AWPreferences.getBool(AWPreferences.OpenAtLogin) ? NSOnState : NSOffState
        
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
        AWOpenAtLogin.setOpenAtLogin(sender.state == NSOnState)
    }
    
    @IBAction func enableAccessibility(sender:NSButton) {
        print("enable accessibility")
        AWAccessibilityAPI.promptToTrustProcess()
    }
    
    @IBAction func reloadJS(sender:NSButton) {
        print("reloading js")
        reloadJS!()
    }
    
}
