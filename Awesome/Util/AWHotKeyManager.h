/*
Class for registering global hotkeys and tracking them.
*/

#import <Foundation/Foundation.h>
#import <Carbon/Carbon.h>


typedef void (^AWHotKeyCallback)(BOOL isDown, NSString* key, NSArray* modifiers);

@interface AWHotKeyManager : NSObject

@property NSMutableDictionary *hotKeyIdToReference;
@property UInt32 eventId;

/*
 Registers a global hotkey for the provided callback. At the moment the callback
 will be called on both the key down and up events.
 
 When registering a hotkey you must specify the key it is for, and any modifier keys.
 The key can be any lowercase character or other symbol that doesn't require using shift
 to create. The modifiers are passed in as an array of strings (if no modifiers then pass an empty array).
 Possible modifier values are "cmd" "opt" "ctrl" and "shift".
 
 Returns an int id for the hotkey listener, which can be used to remove the listener with removeHotKey.
 */
- (UInt32) addHotKey: (NSString*)key withModifiers:(NSArray*)modifiers forCallback:(AWHotKeyCallback)callback;

/*
Given a hotkey listener id removes the listener. Returns a boolean
indicating the success or failure of the operation.
*/
- (BOOL) removeHotKey: (UInt32) hotKeyId;

OSStatus OnHotKeyEvent(EventHandlerCallRef nextHandler, EventRef theEvent, void *userData);
OSStatus OnHotKeyReleasedEvent(EventHandlerCallRef nextHandler, EventRef theEvent, void *userData);

@end
