import Foundation

class AWPreferences {
    static let JSFilePath = "AWPreferencesJSFilePath"
    static let OpenAtLogin = "AWPreferencesOpenAtLogin"

    class func getBool(_ key: String) -> Bool {
        return UserDefaults.standard.bool(forKey: key)
    }

    class func getString(_ key:String) -> String? {
        return UserDefaults.standard.string(forKey: key)
    }

    class func setBool(_ key: String, value: Bool) {
        UserDefaults.standard.set(value, forKey: key)
    }

    class func setString(_ key: String, value: String) {
        UserDefaults.standard.set(value, forKey: key)
    }
}
