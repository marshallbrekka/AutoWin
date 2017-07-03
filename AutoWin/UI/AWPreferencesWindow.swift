import Foundation
import Cocoa

class AWPreferencesWindow:NSWindowController {
    @IBOutlet weak var filePickerButton:NSButton?
    @IBOutlet weak var jsFilePathLabel:NSTextField?
    @IBOutlet weak var reloadJSButton:NSButton?
    @IBOutlet weak var openAtLoginButton:NSButton?
    @IBOutlet weak var enableAccessibilityButton:NSButton?
    @IBOutlet weak var accessibilityStatus:NSTextField?
    fileprivate var context = 0
    fileprivate var accessibilityEnabled:AWAccessibilityEnabled?
    fileprivate var reloadJS:(() -> Void)?
    
    override init(window:NSWindow!) {
        super.init(window: window)
    }
    
    required init(coder:NSCoder) {
        super.init(coder: coder)!
    }
    
    convenience init (accessibility:AWAccessibilityEnabled, reloadJS: @escaping () -> Void) {
        self.init(window: nil)
        Bundle.main.loadNibNamed("AWPreferences", owner: self, topLevelObjects: nil)
        accessibilityEnabled = accessibility
        self.reloadJS = reloadJS
        accessibility.addObserver(self, forKeyPath: "enabled", options: .new, context: &context)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
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
        enableAccessibilityButton?.isEnabled = !accessibilityEnabled!.enabled
    }
    
    @IBAction override func showWindow(_ sender: Any?) {
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
    
    @IBAction func showFilePicker(_ sender:NSButton) {
        let openPanel = NSOpenPanel()
        openPanel.allowedFileTypes = ["js"]
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canCreateDirectories = false
        openPanel.canChooseFiles = true
        openPanel.beginSheetModal(for: window!, completionHandler: { (result) -> Void in
            if result == NSFileHandlingPanelOKButton {
                print(openPanel.url?.path)
                AWPreferences.setString(AWPreferences.JSFilePath, value: openPanel.url!.path)
                self.jsFilePathLabel!.stringValue = openPanel.url!.path
                //Do what you will
                //If there's only one URL, surely 'openPanel.URL'
                //but otherwise a for loop works
            }
        })
    }
    
    @IBAction func setOpenAtLogin(_ sender:NSButton) {
        print("set open at login")
        AWOpenAtLogin.setOpenAtLogin(sender.state == NSOnState)
    }
    
    @IBAction func enableAccessibility(_ sender:NSButton) {
        print("enable accessibility")
        AWAccessibilityAPI.promptToTrustProcess()
    }
    
    @IBAction func reloadJS(_ sender:NSButton) {
        print("reloading js")
        reloadJS!()
    }
}
