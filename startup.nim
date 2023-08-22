import ui

proc JoinGame() =
    echo "uwu"

proc main*() =
  var mainwin: Window

  mainwin = newWindow("libui Control Gallery", 640, 480, true)
  mainwin.margined = true
  mainwin.onClosing = (proc (): bool = return true)

  let box = newVerticalBox(true)
  mainwin.setChild(box)
  var group = newGroup("Basic Controls", true)
  box.add(group, false)

  var inner = newVerticalBox(true)
  group.child = inner
  inner.add newLabel("IP Address:")
  inner.add newEntry("127.0.0.1", proc() = discard)
  inner.add newLabel("IP Address:")
  inner.add newEntry("Test", proc() = discard)
  inner.add newButton("Join Game", proc() = msgBoxError(mainwin, "Error", "Rotec"))

  show(mainwin)
  mainLoop()

init()
main()