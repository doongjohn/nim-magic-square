# Magic square game
# https://ko.wikipedia.org/wiki/마방진

import std/math
import vmath, chroma, pixie
import staticglfw, nimglfw, opengl
import app


const
  white = parseHex "ffffff"
  color1 = parseHex "bfdbff"
  color2 = parseHex "ededed"

# load font from the windows font directory
var font = readFont("C:/Windows/Fonts/consola.ttf")
font.size = 30


type Tile = object
  color: Color
  num: int

var grid = [
  [Tile(color: color1), Tile(color: color2), Tile(color: color1)],
  [Tile(color: color2), Tile(color: color1), Tile(color: color2)],
  [Tile(color: color1), Tile(color: color2), Tile(color: color1)],
]


proc isInGridBound(gridPos: IVec2): bool =
  gridPos.x >= 0 and
  gridPos.y >= 0 and
  gridPos.x < 3 and
  gridPos.y < 3


proc screenToGirdPos(screenPos: Vec2): IVec2 =
  result.x = ((center.x - 150 - screenPos.x) / -100).floor.int32
  result.y = ((center.y - 150 - screenPos.y) / -100).floor.int32


iterator gridItor: tuple[gpos: IVec2, spos: Vec2, tile: Tile] =
  # gpos => grid pos
  # spos => screen pos
  var s = vec2(center.x - 100, center.y - 100)
  for y, row in grid:
    for x, tile in row:
      yield (ivec2(x, y), vec2(s.x, s.y), tile)
      s.x += 100
    s.x = center.x - 100
    s.y += 100


discard setMouseButtonCallback(window,
  proc(window: Window, button: cint, action: cint, modifiers: cint) {.cdecl.} =
    if button == MOUSE_BUTTON_LEFT:
      case action
      of PRESS:
        let gridPos = screenToGirdPos(window.getCursorPos())
        echo gridPos
        if gridPos.isInGridBound:
          inc grid[gridPos.y][gridPos.x].num
      of RELEASE:
        discard
      else: discard
)


template clearScreen =
  ctx.fillStyle = white
  drawRect center.x, center.y, screenSize.w.float, screenSize.h.float


main:
  clearScreen()

  for (_, spos, tile) in gridItor():
    ctx.fillStyle = tile.color
    drawRect spos.x, spos.y, 100, 100
    if tile.num > 0:
      screen.fillText(font, $tile.num, translate(spos), vec2(0, 0), haCenter, vaMiddle)
