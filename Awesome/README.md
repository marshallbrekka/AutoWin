## Starting Point

The app starts in AppDelegate, which instantiates the AWJSContext.

AWJSContext is the root class that maps the JS apis to the Swift counterparts.


## Application & Window Tracking

The applications and windows are tracked in the AWManager class.
It is responsible for keeping a list of all applications and windows, and listening for
events on each.