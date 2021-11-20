# import std/math
import staticglfw
import opengl
import vmath
import chroma
import pixie
import display


const white = parseHex "ffffff"
const color1 = parseHex "bfdbff"
const color2 = parseHex "ededed"

var font = readFont("C:/Windows/Fonts/consola.ttf")
font.size = 30


type Tile = object
  color: Color
  data: string

const grid = [
  [Tile(color: color1), Tile(color: color2), Tile(color: color1)],
  [Tile(color: color2), Tile(color: color1), Tile(color: color2)],
  [Tile(color: color1), Tile(color: color2), Tile(color: color1)],
]


proc getCursorPos: Vec2 =
  var x, y: cdouble
  window.getCursorPos(x.addr, y.addr)
  result.x = x
  result.y = y


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
    of PRESS:
      echo "down"
      let mousePos = getCursorPos()
      echo mousePos
    of RELEASE: echo "up"
    else: discard
)


proc drawTile(x, y: float) =
  drawRect x, y, 100.0, 100.0


main:
  ctx.fillStyle = white
  drawRect center.x, center.y, screenSize.w.float, screenSize.h.float

  var pos = vec2(center.x - 100, center.y - 100)

  for row in grid:
    for tile in row:
      ctx.fillStyle = tile.color
      drawTile pos.x, pos.y
      if tile.data != "":
        screen.fillText(font, tile.data, translate(pos), vec2(0, 0), haCenter, vaMiddle)
      pos.x += 100
    pos.x = center.x - 100
    pos.y += 100
