# example: https://github.com/treeform/pixie/blob/master/examples/realtime_glfw.nim

import vmath
import staticglfw


proc getCursorPos*(window: Window): Vec2 =
  var x, y: cdouble
  window.getCursorPos(x.addr, y.addr)
  result.x = x
  result.y = y


template onMouseButton*(window: Window, body: untyped) =
  # https://forum.nim-lang.org/t/6378
  discard setMouseButtonCallback(window,
    proc(
      win: Window,
      button {.inject.}: cint,
      action {.inject.}: cint,
      modifiers {.inject.}: cint
    ) {.cdecl.} =
      body
  )


template onKeyboard*(window: Window, body: untyped) =
  discard setKeyCallback(window,
    proc (
      win: Window,
      key {.inject.}: cint,
      scancode {.inject.}: cint,
      action {.inject.}: cint,
      modifiers {.inject.}: cint
    ) {.cdecl.} =
      body
  )
