# AutoWin - alpha

A platform for building window managers on OSX using JavaScript.

## Usage

AutoWin provides a JavaScript API for getting and manipulating the layout of windows, and monitoring the state of windows and monitors using event listeners.
By design, it does not provide any built in window management features, only the tools to build a window manager on top of it.

By default it comes with a minimal [demo script](AutoWin/demo.js) which binds the hotkey `cmd` + `opt` + `ctrl` + `f` to a function that fullscreens the currently focused window on the "main" monitor. You can replace this script with your own through the preferences window, accessible through the status bar icon.

This is Alpha software, so expect to encounter bugs and the occasional crash.

## Installing

Download the latest release - [AutoWin-1.2.zip](https://marshallbrekka.github.io/AutoWin/releases/AutoWin-1.2.zip)

## JavaScript API

### Events

The callback functions for events are always called with the first argument as the event name.
Depending on the event, some callbacks will receive an object of data as a second argument.

#### aw.events.addEvent(eventName, callback)
**Params**
- eventName `string` - The event to listen for
- callback `function` - Function that is called when the event occurs.

#### aw.events.removeEvent(eventName, callback)
**Params**
- eventName `string` - The event to remove a listener for
- callback `function` - Function that was previously registered as an event listener.

#### Window Events
All window events provide a window object as the second argument to the event listener
- aw.window.created
- aw.window.destroyed
- aw.window.focused
- aw.window.mainWindow
- aw.window.moved
- aw.window.resized

#### Application Events
All application events provide an application object as the second argument to the event listener.
- aw.application.launched
- aw.application.terminated
- aw.application.activated
- aw.application.deactivated
- aw.application.hidden
- aw.application.unhidden

#### Monitor Events
All monitor events provide a list of monitor objects as the second argument to the event listener.
- aw.monitors.layoutChange


### Windows

A window is defined as an object with two keys, `pid`, and `id`, where `pid` is the process that owns the window, and `id` is the window id. When interacting with a specific window you will need to provide both the `pid` and the `id`.

#### aw.window.windows()
**Returns**
A list of window objects

#### aw.window.focused()
**Returns**
The window object of the window that currently has focus, or null if no window has focus.

#### aw.window.close(pid, id)
Closes the window specified by the proccess id and window id.

**Params**
- pid `int` - The process ID of the window to close.
- id  `int` - The window id to close.

**Returns**
A boolean indicating the success or failure of the operation.


#### aw.window.becomeMain(pid, id)
Makes the window the "main" window for the application it belongs to. If the application is already the frontmost application, this is the same as focusing the window. If the application is not, it brings the window forward in the window "stack".

To focus a window in the traditional sense, you would tell it to become main, and then tell its application to become "active".

**Params**
- pid `int` - The process ID of the window to become main.
- id  `int` - The window id to become main.

**Returns**
A boolean indicating the success or failure of the operation.


#### aw.window.getFrame(pid, id)
Returns the frame of the window as an object with keys `x`, `y`, `width`, and `height`, whose values are ints.

The `x` and `y` coordinates are relative to the *main* monitor, which is the one specified by the white bar at the top when viewing the monitor layout in System Preferences.

**Params**
- pid `int` - The process ID of the window to get the frame for.
- id  `int` - The window id to get the frame for.

**Returns**
The window frame as an object.

#### aw.window.setFrame(pid, id, frame)
Sets the frame of the specified window.
It does not make any guarantees that the resulting size and position of the window will match the specified frame, as the application that owns the window may have specified visual constraints that do not match the desired frame.

**Params**
- pid `int` - The process ID of the window to set the frame for.
- id  `int` - The window id to set the frame for.
- frame `object`
  - x `int` - x coordinate relative to the top left of the main monitor
  - y `int` - y coordinate relative to the top left of the main monitor
  - width `int` - desired width of the window
  - height `int` - desired height of the window

**Returns**
Boolean indicating the success of the operation.

### Applications

#### aw.applications.applications()
**Returns**
A list of applications objects, which have a single key `pid`.

#### aw.applications.activate(pid)
Makes the application the active application.

**Params**
- pid `int` - The process id of the application to activate.

### Monitors

Monitors are represented by an object with keys `id` and frame `frame` (the same structure as a window frame).

#### aw.monitors.get()
**Returns**
Returns a list of monitor objects.

### Hotkeys

- Hotkey Modifiers - `cmd`, `ctrl`, `opt`, `shift`

#### aw.hotkeys.add(key, modifiers, callback)
Adds a function as a callback for a combination of modifer keys and a single key.
The callback fn should accept three arguments:
- down `boolean` - True if triggered on keydown, false otherwise. For now this is always true.
- key `string` - The key the hotkey was registered with.
- modifiers `array<string>` - The array of modifiers the hotkey was registered with.

**Params**
- key `string` - The key to add the hotkey for.
- modifiers `array<string>` - An array of hotkey modifiers.
- callback `function(down, key, modifiers)` - The function that is called when the hotkey is triggered.

#### aw.hotkeys.remove(key, modifiers, callback)
Removes a previously registered hotkey

**Params**
- key `string` - The key to the hotkey was added for.
- modifiers `array<string>` - The array of modifiers the hotkey was added with.
- callback `function(down, key, modifiers)` - The function the hotkey was added with.