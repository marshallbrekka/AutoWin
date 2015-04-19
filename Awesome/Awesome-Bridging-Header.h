//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#include "AWObserver.h"

// expose private api to get the CGWindowID from an AXUIElementRef
extern AXError _AXUIElementGetWindow(AXUIElementRef, CGWindowID* out);