//
//  AWObserver.m
//  Awesome
//
//  Thing wrapper around the AXObserver functions. Done this way because doing
//  this from swift was really difficult to figure out, and this way "just works".
#import "AWObserver.h"

void watcher_observer_callback(AXObserverRef observer, AXUIElementRef element, CFStringRef notification, void* contextData) {
    AWObserver * ob = (__bridge AWObserver *) contextData;
    ob.callback(observer, element, notification);
}

@implementation AWObserver

- (id) init: (pid_t) pid callback:(Callback) fn  {
    if ( self = [super init] ) {
        AXObserverRef newObserver = NULL;
        // TODO: check err object, not sure what the right action should be if it failed.
        // Throw an exception?
        AXError err = AXObserverCreate(pid, watcher_observer_callback, &newObserver);
        self.callback = fn;
        self.observer = newObserver;
        
        // add the observer to the run loop, this may need to happen after we add notifications
        CFRunLoopSourceRef source = AXObserverGetRunLoopSource(newObserver);
        CFRunLoopAddSource(CFRunLoopGetCurrent(),
                           source,
                           kCFRunLoopDefaultMode);
    }
    return self;
}

- (void) addNotification:(AXUIElementRef) element notification:(CFStringRef) notifo {
    AXObserverAddNotification(self.observer, element, notifo, (__bridge void *) self);
}

-(void) removeNotification: (AXUIElementRef) element notification:(CFStringRef) notifo {
    AXObserverRemoveNotification(self.observer, element, notifo);
}

@end
