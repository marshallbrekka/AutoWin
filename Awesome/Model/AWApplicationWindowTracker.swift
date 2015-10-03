/**
Tracks applications and their windows. Emitting application
and window specific events.
*/
import Foundation

class AWApplicationWindowTracker {
    var apps:[AWApplication]
    var windows: [AWWindow]
    
    init() {
        apps = AWApplication.applications();
        // do something here to listen for new app launch events
        windows = []
        for app in apps {
            let appWindows = app.windows()
            windows.appendContentsOf(appWindows)
        }
        
    }
    
    func watchApp(app: AWApplication) {
        // this function should watch the app for window events,
        // and for application level events.
    }
}
