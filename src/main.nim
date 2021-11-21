# Magic square game
# https://ko.wikipedia.org/wiki/마방진

import std/math
import std/algorithm
import vmath, chroma, pixie
import staticglfw, nimglfw, opengl
import app


const
  color1 = parseHex "bfdbff"
  color2 = parseHex "ededed"


type Tile = ref object
  color: Color
  locked: bool
  num: int

type Grid = array[3, array[3, Tile]]


var selected: Tile = nil

var grid = [
  [Tile(), Tile(), Tile()],
  [Tile(), Tile(), Tile()],
  [Tile(), Tile(), Tile()],
]


template at(grid: Grid, x, y: int): Tile {.used.} = grid[y][x]
template at(grid: Grid, pos: IVec2): Tile {.used.} = grid[pos.y][pos.x]


proc isInGridBound(gridPos: IVec2): bool =
  gridPos.x >= 0 and
  gridPos.y >= 0 and
  gridPos.x < 3 and
  gridPos.y < 3


proc screenToGirdPos(screenPos: Vec2): IVec2 =
  result.x = ((center.x - 150 - screenPos.x) / -100).floor.int32
  result.y = ((center.y - 150 - screenPos.y) / -100).floor.int32


iterator iterate(grid: Grid): tuple[gpos: IVec2, spos: Vec2, tile: Tile] =
  # gpos => grid pos
  # spos => screen pos
  var s = vec2(center.x - 100, center.y - 100)
  for y, row in grid:
    for x, tile in row:
      yield (ivec2(x, y), vec2(s.x, s.y), tile)
      s.x += 100
    s.x = center.x - 100
    s.y += 100


iterator allLines(grid: Grid): array[3, Tile] =
  var line: array[3, Tile]
  # vertical lines
  for x in 0 .. grid.high:
    for y in 0 .. grid.high: line[x] = grid[y][x]
  yield line
  # horizontal lines
  for y in 0 .. grid.high:
    for x in 0 .. grid.high: line[y] = grid[y][x]
  yield line
  # diagonal lines
  for x, y in [0, 1, 2]: line[x] = grid[y][x]
  for x, y in [0, 1, 2].reversed: line[x] = grid[y][x]


proc addLine(line: array[3, Tile]): int =
  for i in line: result += i.num


proc evalMagicSquare: bool =
  result = true
  for line in grid.allLines:
    if line.addLine != 15: return false


window.onMouseButton:
  if button == MOUSE_BUTTON_LEFT:
    case action
    of PRESS:
      let pos = window.getCursorPos.screenToGirdPos
      if pos.isInGridBound and not grid.at(pos).locked:
        selected = grid.at(pos)
      else:
        selected = nil
    of RELEASE:
      discard
    else: discard


window.onKeyboard:
  if selected == nil: return
  if action == PRESS:
    case key
    of KEY_KP_0: selected.num = 0
    of KEY_KP_1: selected.num = 1
    of KEY_KP_2: selected.num = 2
    of KEY_KP_3: selected.num = 3
    of KEY_KP_4: selected.num = 4
    of KEY_KP_5: selected.num = 5
    of KEY_KP_6: selected.num = 6
    of KEY_KP_7: selected.num = 7
    of KEY_KP_8: selected.num = 8
    of KEY_KP_9: selected.num = 9
    else: discard

    if evalMagicSquare():
      echo "magic square has been completed!"
    else:
      echo "magic square is not yet complete..."


ctx.font = "C:/Windows/Fonts/consola.ttf"
ctx.fontSize = 30
ctx.textAlign = haCenter


main:
  clearScreen()

  for (_, spos, tile) in grid.iterate:
    tile.color = if tile.locked:
      color1
    else:
      color2

    ctx.fillStyle = if tile == selected:
      tile.color.darken 0.1
    else:
      tile.color

    drawRect spos.x, spos.y, 90, 90

    if tile.num > 0:
      ctx.fillStyle = static: parseHex "000000"
      ctx.fillText($tile.num, vec2(spos.x, spos.y + 5))
