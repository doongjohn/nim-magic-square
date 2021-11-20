import staticglfw
import vmath


proc getCursorPos*(window: Window): Vec2 =
  var x, y: cdouble
  window.getCursorPos(x.addr, y.addr)
  result.x = x
  result.y = y
