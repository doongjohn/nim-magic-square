# import std/math
import staticglfw
import opengl
import pixie
import display


proc onMouseButton(window: Window, button: cint, action: cint, modifiers: cint) {.cdecl.} =
  if button == MOUSE_BUTTON_RIGHT:
    stdout.write "RMB "
    case action
    of PRESS: echo "down"
    of RELEASE: echo "up"
    else: discard
  if button == MOUSE_BUTTON_LEFT:
    stdout.write "LMB "
    case action
    of PRESS: echo "down"
    of RELEASE: echo "up"
    else: discard

discard setMouseButtonCallback(window, onMouseButton)


main:
  ctx.fillStyle = parseHex "db3327"
  drawRect center.x, center.y, 100.0, 100.0

  ctx.fillStyle = parseHex "278ddb"
  drawRect center.x, center.y + 100, 100.0, 100.0

  ctx.fillStyle = rgba(255, 100, 255, 255)
  drawRect center.x - 100, center.y + 100, 100.0, 100.0
  drawRect center.x + 100, center.y + 100, 100.0, 100.0
