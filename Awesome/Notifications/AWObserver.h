/**
Observer class for listening to accessibility notifications.
*/

#import <Foundation/Foundation.h>

typedef void (^Callback)(AXObserverRef ob, AXUIElementRef el, CFStringRef notification);
void watcher_observer_callback(AXObserverRef observer, AXUIElementRef element, CFStringRef notification, void* contextData);

AXObserverRef makeObserver(pid_t pid);

@interface AWObserver : NSObject {
}

@property (strong) Callback callback;
@property AXObserverRef observer;


- (id) init: (pid_t) pid callback:(Callback) fn;
- (void) addNotification: (AXUIElementRef)input notification:(CFStringRef) notifo;
- (void) stop;
@end

