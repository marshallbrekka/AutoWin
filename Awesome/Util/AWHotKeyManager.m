//
//  AWHotKeyManager.m
//  Awesome
//
//  Created by Marshall Brekka on 4/22/15.
//  Copyright (c) 2015 Marshall Brekka. All rights reserved.
//

#import "AWHotKeyManager.h"
#import "Awesome-Swift.h"


/*
Class for holding the ref and callback and the keys it is watching.
*/
@interface AWHotKeyInstance : NSObject 
@property EventHotKeyRef ref;
@property (nonatomic,strong) AWHotKeyCallback callback;
@property NSString * key;
@property NSArray * modifiers;
- (id) initWithRef: (EventHotKeyRef) ref callback:(AWHotKeyCallback) callback key:(NSString*) key modifiers:(NSArray*) modifiers;
@end

@implementation AWHotKeyInstance

- (id) initWithRef: (EventHotKeyRef) ref callback:(AWHotKeyCallback) callback key:(NSString*) key modifiers:(NSArray*) modifiers {
    self.ref = ref;
    self.callback = callback;
    self.key = key;
    self.modifiers = modifiers;
    return self;
}
@end


@implementation AWHotKeyManager

- (id) init {
    self = [super init];
    self.eventId = 0;
    self.hotKeyIdToReference = [[NSMutableDictionary alloc] init];
    
    // Setup the event handlers
    EventTypeSpec eventType;
    EventTypeSpec eventReleasedType;
    eventType.eventClass = kEventClassKeyboard;
    eventType.eventKind = kEventHotKeyPressed;
    eventReleasedType.eventClass = kEventClassKeyboard;
    eventReleasedType.eventKind = kEventHotKeyReleased;
    
    InstallEventHandler(GetEventMonitorTarget(), &OnHotKeyDown, 1, &eventType, (__bridge void *)self, NULL);
    InstallEventHandler(GetEventMonitorTarget(), &OnHotKeyUp, 1, &eventReleasedType, (__bridge void *)self, NULL);
    
    return self;
}

/*
Registers a global hotkey for the provided callback. At the moment the callback 
will be called on both the key down and up events.

When registering a hotkey you must specify the key it is for, and any modifier keys.
The key can be any lowercase character or other symbol that doesn't require using shift
to create. The modifiers are passed in as an array of strings (if no modifiers then pass an empty array).
Possible modifier values are "cmd" "opt" "ctrl" and "shift".
*/
- (UInt32) addHotKey: (NSString*)key withModifiers:(NSArray*)modifiers forCallback:(AWHotKeyCallback)callback {
    // Store the hotkey here
    EventHotKeyRef hotKeyRef;
    // the int id of the hotkey
    UInt32 newId = self.eventId++;
    
    EventHotKeyID hotKeyID;
    hotKeyID.signature = *[[NSString stringWithFormat:@"awhk%d", newId] cStringUsingEncoding:NSASCIIStringEncoding];
    hotKeyID.id = newId;
    
    UInt32 keyCode = [AWKeyCodes charToKeyCode: key];
    UInt32 modifierCode = [AWKeyCodes modifiersToModCode:modifiers];
    RegisterEventHotKey(keyCode, modifierCode, hotKeyID, GetEventMonitorTarget(), 0, &hotKeyRef);
    
    AWHotKeyInstance *tracker = [[[AWHotKeyInstance alloc] init] initWithRef:hotKeyRef callback:callback key:key modifiers:modifiers];
    [self.hotKeyIdToReference setObject: tracker forKey: [NSNumber numberWithInt:newId]];
    return newId;
}

- (BOOL) removeHotKey: (UInt32) hotKeyId {
    NSNumber *key = [NSNumber numberWithInt:hotKeyId];
    AWHotKeyInstance *tracker = [self.hotKeyIdToReference objectForKey:key];
    UnregisterEventHotKey(tracker.ref);
    [self.hotKeyIdToReference removeObjectForKey:key];
    return true;
}

OSStatus hotKeyEvent(BOOL down, EventHandlerCallRef handler, EventRef event, void *managerPtr) {
    AWHotKeyManager *manager = (__bridge AWHotKeyManager *)managerPtr;
    EventHotKeyID hotKeyId;
    GetEventParameter(event, kEventParamDirectObject, typeEventHotKeyID, NULL, sizeof(hotKeyId), NULL, &hotKeyId);
    AWHotKeyInstance *tracker = [manager.hotKeyIdToReference objectForKey: [NSNumber numberWithInt: hotKeyId.id]];
    tracker.callback(down, tracker.key, tracker.modifiers);
    return noErr;
}

OSStatus OnHotKeyDown(EventHandlerCallRef handler, EventRef event, void *managerPtr) {
    return hotKeyEvent(true, handler, event, managerPtr);
}

OSStatus OnHotKeyUp(EventHandlerCallRef handler, EventRef event, void *managerPtr) {
    return hotKeyEvent(false, handler, event, managerPtr);
}

@end
