//
//  AWObserver.h
//  Awesome
//
//  Created by Marshall Brekka on 4/16/15.
//  Copyright (c) 2015 Marshall Brekka. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^Callback)(AXObserverRef ob, AXUIElementRef el, CFStringRef notification);
void watcher_observer_callback(AXObserverRef observer, AXUIElementRef element, CFStringRef notification, void* contextData);

AXObserverRef makeObserver(pid_t pid);

@interface AWObserver : NSObject {
}

@property (retain) Callback callback;
@property AXObserverRef observer;


- (id) init: (pid_t) pid callback:(Callback) fn;
- (void) addNotification: (AXUIElementRef)input notification:(CFStringRef) notifo;
- (void) removeNotification: (AXUIElementRef)input notification:(CFStringRef) notifo;
@end

