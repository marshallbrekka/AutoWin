function currentMonitor(w) {
  var monitors = aw.monitors.monitors()
  return monitors[0];
}

function fullscreen() {
  var focused = aw.window.focusedWindow()
  var monitor = currentMonitor(focused);
  aw.window.setFrame(focused.pid, focused.id, monitor.frame)
}

aw.hotkey.addHotkeyListener("f", ["cmd", "opt", "ctrl"], fullscreen);
