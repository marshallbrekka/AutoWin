/*
Javascript interface for exposing native internals to the JS/ClojureScript environment.

This should be thought of as the main class that sits between the native and js environments.
It is responsible for creating the js environment, listening for native events, and holding references
to all applications and windows for the lifetime of the progrea.

The initial API is documented below.

**** Events ****

** Application Level Events **
aw.application.launched
aw.application.terminated
aw.application.activated
aw.application.deactivated
aw.application.hidden
aw.application.unhidden


** Window Level Events **
aw.window.created
aw.window.destroyed
aw.window.focused
aw.window.mainWindow
aw.window.moved
aw.window.resized
aw.window.titleChanged
aw.window.minimized
aw.window.diminimized


** Mouse Events **
aw.mouse.moved


** Monitor Events **
aw.monitors.layoutChange


**** Functional API ****

** Application functions **
aw.application.applications()
aw.application.activate()

** Window Functions **
aw.window.windows()
aw.window.close()
aw.window.focusedWindow()
aw.window.becomeMain(window)
aw.window.setFrame(window,frame)
aw.window.setMinimized(window,boolean)

** Mouse functions **
aw.mouse.getPosition()
aw.mouse.setPosition(point)
*/

import Foundation









