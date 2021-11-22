# Magic square game
# https://ko.wikipedia.org/wiki/마방진

# TODO:
# - [ ] generic grid api
# - [ ] arrow key selection
# - [ ] auto generate hint


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


type Grid = ref object
  size: int
  tiles: seq[seq[Tile]]


let grid = Grid(size: 4, tiles: @[
  @[Tile(), Tile(), Tile(), Tile()],
  @[Tile(), Tile(), Tile(), Tile()],
  @[Tile(), Tile(), Tile(), Tile()],
  @[Tile(), Tile(), Tile(), Tile()],
])


const cellSize = 100.0
const tileSize = 90.0
let offset = cellSize * floor(grid.size / 2) + cellSize / 2
var selected: Tile = nil


template at(grid: Grid, x, y: int): Tile {.used.} = grid.tiles[y][x]
template at(grid: Grid, pos: IVec2): Tile {.used.} = grid.tiles[pos.y][pos.x]


proc isInGridBound(gridPos: IVec2): bool =
  gridPos.x >= 0 and
  gridPos.y >= 0 and
  gridPos.x < grid.size and
  gridPos.y < grid.size


proc screenToGirdPos(screenPos: Vec2): IVec2 =
  result.x = ((center.x - offset - cellSize / 2 - screenPos.x) / -cellSize).floor.int32
  result.y = ((center.y - offset - cellSize / 2 - screenPos.y) / -cellSize).floor.int32


iterator iterate(grid: Grid): tuple[gpos: IVec2, spos: Vec2, tile: Tile] =
  # gpos => grid pos
  # spos => screen pos
  var spos = vec2(center.x - offset, center.y - offset)
  for y, row in grid.tiles:
    for x, tile in row:
      yield (ivec2(x, y), spos, tile)
      spos.x += cellSize
    spos.x = center.x - offset
    spos.y += cellSize


iterator lines(grid: Grid): array[4, Tile] =
  const arr = [0, 1, 2, 3]
  var line: array[4, Tile]

  # vertical lines
  for x in arr:
    for y in arr:
      line[y] = grid[y][x]
    yield line

  # horizontal lines
  for y in arr:
    for x in arr:
      line[x] = grid[y][x]
    yield line

  # diagonal lines
  for x, y in arr: line[x] = grid[y][x]
  yield line

  # diagonal lines
  for x, y in arr.reversed: line[x] = grid[y][x]
  yield line


proc sum(line: openArray[Tile]): int =
  for i in line: result += i.num


proc evalMagicSquare: bool =
  result = true
  for line in grid.lines:
    if line.sum != 34:
      return false


proc gameOver =
  selected = nil
  for (_, _, tile) in grid.iterate:
    tile.locked = true


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
    if key == KEY_BACKSPACE:
      selected.num = selected.num div 10
      if evalMagicSquare(): gameOver()
    if key in KEY_KP_0 .. KEY_KP_9:
      let newNum = selected.num * 10 + (key - KEY_KP_0).int
      if newNum <= grid.len * grid.len:
        selected.num = newNum
        if evalMagicSquare(): gameOver()


# font settings
ctx.font = "C:/Windows/Fonts/consola.ttf"
ctx.fontSize = 30
ctx.textAlign = haCenter


# main loop
main:
  clearScreen()

  for (_, spos, tile) in grid.iterate:
    tile.color = if tile.locked:
      color1
    else:
      color2

    ctx.fillStyle = if tile == selected:
      tile.color.darken 0.05
    else:
      tile.color

    drawRect spos.x, spos.y, tileSize, tileSize

    if tile.num > 0:
      ctx.fillStyle = static: parseHex "000000"
      ctx.fillText($tile.num, vec2(spos.x, spos.y + 5))
