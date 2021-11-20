# example: https://github.com/treeform/pixie/blob/master/examples/realtime_glfw.nim

import vmath
import staticglfw


proc getCursorPos*(window: Window): Vec2 =
  var x, y: cdouble
  window.getCursorPos(x.addr, y.addr)
  result.x = x
  result.y = y
