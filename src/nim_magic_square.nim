# import std/math
import staticglfw
import opengl
import vmath
import pixie
import display


discard setMouseButtonCallback(window, proc(window: Window, button: cint, action: cint, modifiers: cint) {.cdecl.} =
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
)


const white = parseHex "ffffff"
const color1 = parseHex "ededed"
const color2 = parseHex "bfdbff"

var font = readFont("C:/Windows/Fonts/consola.ttf")
font.size = 30


proc drawTile(x, y: float) =
  drawRect x, y, 100.0, 100.0


main:
  ctx.fillStyle = white
  drawRect center.x, center.y, screenSize.w.float, screenSize.h.float

  ctx.fillStyle = color1
  drawTile center.x, center.y + 100
  drawTile center.x, center.y - 100
  drawTile center.x + 100, center.y
  drawTile center.x - 100, center.y

  ctx.fillStyle = color2
  drawTile center.x, center.y
  drawTile center.x - 100, center.y + 100
  drawTile center.x + 100, center.y + 100
  drawTile center.x - 100, center.y - 100
  drawTile center.x + 100, center.y - 100

  screen.fillText(font, "1", translate(center), vec2(0, 0), haCenter, vaMiddle)
