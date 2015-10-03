
Javascript interface for exposing native internals to the JS/ClojureScript environment.

This should be thought of as the main class that sits between the native and js environments.
It is responsible for creating the js environment, listening for native events, and holding references
to all applications and windows for the lifetime of the program.

The initial API is documented below.

# Events

## Application Level Events - DONE
- aw.application.launched
- aw.application.terminated
- aw.application.activated
- aw.application.deactivated
- aw.application.hidden
- aw.application.unhidden

## Window Level Events

- aw.window.created
- aw.window.destroyed
- aw.window.focused
- aw.window.mainWindow
- aw.window.moved
- aw.window.resized
- aw.window.titleChanged
- aw.window.minimized
- aw.window.unminimized

## Mouse Events - PUNT

- aw.mouse.moved


## Monitor Events - DONE

- aw.monitors.layoutChange


# Functional API

## Application functions -  DONE

- aw.application.applications()
- aw.application.activate()

## Window Functions

- aw.window.windows()
- aw.window.close()
- aw.window.focusedWindow()
- aw.window.becomeMain(window)
- aw.window.setFrame(window,frame)
- aw.window.setMinimized(window,boolean)

## Mouse functions

- aw.mouse.getPosition()
- aw.mouse.setPosition(point)


## Hot key functions - DONE

- aw.hotkey.add(key, modifiers, callback)
- aw.hotkey.remove(key, modifiers, callback)

## Monitor Functions - DONE

- aw.monitors.monitors()
