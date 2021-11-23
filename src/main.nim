# Magic square game
# https://ko.wikipedia.org/wiki/마방진

# TODO:
# - [ ] press enter to confirm
# - [ ] auto generate hint


import std/math
import std/algorithm
import std/sequtils
import vmath, chroma, pixie
import staticglfw, nimglfw, opengl
import app


const
  color1 = parseHex "bfdbff"
  color2 = parseHex "ededed"
  color3 = parseHex "ff9494"


type Tile = ref object
  color: Color
  locked: bool
  num: int


type Grid = ref object
  size: int
  tiles: seq[seq[Tile]]


# let grid = Grid(size: 3, tiles: @[
#   @[Tile(), Tile(), Tile()],
#   @[Tile(), Tile(), Tile()],
#   @[Tile(), Tile(), Tile()],
# ])

let grid = Grid(size: 4, tiles: @[
  @[Tile(), Tile(), Tile(), Tile()],
  @[Tile(), Tile(), Tile(), Tile()],
  @[Tile(), Tile(), Tile(), Tile()],
  @[Tile(), Tile(), Tile(), Tile()],
])

# let grid = Grid(size: 5, tiles: @[
#   @[Tile(), Tile(), Tile(), Tile(), Tile()],
#   @[Tile(), Tile(), Tile(), Tile(), Tile()],
#   @[Tile(), Tile(), Tile(), Tile(), Tile()],
#   @[Tile(), Tile(), Tile(), Tile(), Tile()],
#   @[Tile(), Tile(), Tile(), Tile(), Tile()],
# ])


const cellSize = 100.0
const tileSize = 90.0
var selected: tuple[tile: Tile, pos: IVec2] = (nil, ivec2())
var duplicate: Tile = nil
var typedNum = 0


proc newSeqAscending[T](len: int): seq[T] =
  var i = -1
  newSeq[int](grid.size).map(
    proc(x: int): int =
      inc i
      i
  )


template at(grid: Grid, x, y: int): Tile {.used.} = grid.tiles[y][x]
template at(grid: Grid, pos: IVec2): Tile {.used.} = grid.tiles[pos.y][pos.x]


proc isInGridBound(gridPos: IVec2): bool =
  gridPos.x >= 0 and
  gridPos.y >= 0 and
  gridPos.x < grid.size and
  gridPos.y < grid.size


proc screenToGirdPos(screenPos: Vec2): IVec2 =
  result.x = ((center.x - screenPos.x - cellSize * floor(grid.size / 2) - cellSize / 2 * (grid.size mod 2).float) / -cellSize).floor.int32
  result.y = ((center.y - screenPos.y - cellSize * floor(grid.size / 2) - cellSize / 2 * (grid.size mod 2).float) / -cellSize).floor.int32


iterator iterate(grid: Grid): tuple[gpos: IVec2, spos: Vec2, tile: Tile] =
  # gpos => grid pos
  # spos => screen pos
  let offset = -cellSize / 2 * (grid.size mod 2 - 1).float - cellSize * floor(grid.size / 2)
  var spos = vec2(center.x + offset, center.y + offset)
  for y, row in grid.tiles:
    for x, tile in row:
      yield (ivec2(x.int32, y.int32), spos, tile)
      spos.x += cellSize
    spos.x = center.x + offset
    spos.y += cellSize


iterator lines(grid: Grid): seq[Tile] =
  let asc = newSeqAscending[int](grid.size)
  var line = newSeq[Tile](grid.size)

  # vertical lines
  for x in asc:
    for y in asc:
      line[y] = grid.tiles[y][x]
    yield line

  # horizontal lines
  for y in asc:
    for x in asc:
      line[x] = grid.tiles[y][x]
    yield line

  # diagonal lines
  for x, y in asc: line[x] = grid.tiles[y][x]
  yield line

  # diagonal lines
  for x, y in asc.reversed: line[x] = grid.tiles[y][x]
  yield line


proc findDuplicate(grid: Grid, this: Tile, num: int): Tile =
  result = nil
  if num != 0:
    for (gpos, _, tile) in grid.iterate():
      if tile.num == num and tile != this:
        return tile


proc sum(line: openArray[Tile]): int =
  for i in line: result += i.num


proc evalMagicSquare: bool =
  result = true
  for line in grid.lines:
    if line.sum != (grid.size * (grid.size ^ 2 + 1)) div 2:
      return false


proc gameCompelete =
  selected.tile = nil
  for (_, _, tile) in grid.iterate:
    tile.locked = true


proc confirmTypedNum =
  defer: duplicate = nil
  if duplicate == nil:
    selected.tile.num = typedNum
    if evalMagicSquare():
      gameCompelete()
  else:
    selected.tile.num = 0
    typedNum = 0


window.onMouseButton:
  if button == MOUSE_BUTTON_LEFT:
    case action
    of PRESS:
      let pos = window.getCursorPos.screenToGirdPos
      if pos.isInGridBound and not grid.at(pos).locked:
        if selected.tile != nil:
          confirmTypedNum()
        selected.tile = grid.at(pos)
        selected.pos = pos
        typedNum = selected.tile.num
      elif selected.tile != nil:
        confirmTypedNum()
        selected.tile = nil
    of RELEASE:
      discard
    else: discard


window.onKeyboard:
  if action != PRESS:
    return

  if key in KEY_RIGHT .. KEY_UP and selected.tile == nil:
    selected.tile = grid.at(0, 0)
    selected.pos = ivec2(0, 0)
    typedNum = selected.tile.num
    return

  if selected.tile == nil:
    return

  if key == KEY_ESCAPE:
    confirmTypedNum()
    selected.tile = nil

  # arrow movement
  if key in KEY_RIGHT .. KEY_UP:
    var newPos = ivec2(-1, -1)
    case key
    of KEY_UP:
      newPos = ivec2(selected.pos.x, selected.pos.y - 1)
    of KEY_DOWN:
      newPos = ivec2(selected.pos.x, selected.pos.y + 1)
    of KEY_RIGHT:
      newPos = ivec2(selected.pos.x + 1, selected.pos.y)
    of KEY_LEFT:
      newPos = ivec2(selected.pos.x - 1, selected.pos.y)
    else: discard
    if newPos.isInGridBound:
      confirmTypedNum()
      selected.tile = grid.at(newPos)
      selected.pos = newPos
      typedNum = selected.tile.num

  # erase number
  if key == KEY_BACKSPACE:
    typedNum = typedNum div 10
    duplicate = grid.findDuplicate(selected.tile, typedNum)

  # write number
  if key in KEY_KP_0 .. KEY_KP_9:
    let newNum = typedNum * 10 + (key - KEY_KP_0).int
    if newNum <= grid.size * grid.size:
      typedNum = newNum
      duplicate = grid.findDuplicate(selected.tile, typedNum)

  # confirm number
  if key == KEY_ENTER:
    confirmTypedNum()


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

    ctx.fillStyle =
      if tile == selected.tile:
        tile.color.darken 0.05
      elif tile == duplicate:
        color3
      else:
        tile.color

    drawRect spos.x, spos.y, tileSize, tileSize

    ctx.fillStyle = static: parseHex "000000"
    if tile == selected.tile:
      if typedNum > 0:
        ctx.fillText($typedNum, vec2(spos.x, spos.y + 5))
    elif tile.num > 0:
      ctx.fillText($tile.num, vec2(spos.x, spos.y + 5))
