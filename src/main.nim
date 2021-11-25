# Magic square game
# https://ko.wikipedia.org/wiki/마방진

# TODO:
# - [ ] auto generate hint


import std/math
import staticglfw, nimglfw
import opengl
import pixie
import grids
import app


const
  color1 = parseHex "bfdbff"
  color2 = parseHex "ededed"
  color3 = parseHex "ff9494"
  tileSize = 90.0


var gameEnded = false
let grid = initGrid(center, 4, 100)


type Selected = object
  input: int
  pos: IVec2
  tile: Tile
  dup: Tile

var selected = Selected(
  input: 0,
  pos: ivec2(-1, -1),
  tile: nil,
  dup: nil
)


proc gameCompelete =
  gameEnded = true
  selected.tile = nil
  selected.dup = nil
  for (_, _, tile) in grid.iterate:
    tile.locked = true


template calcMagicSquareSum(size: int): int =
  (size * (size ^ 2 + 1)) div 2


let magicSquareSum = calcMagicSquareSum grid.size


proc evalMagicSquare: bool =
  result = true
  for line in grid.lines:
    if line.sum != magicSquareSum:
      return false


proc evalInput =
  defer: selected.dup = nil
  if selected.dup == nil:
    selected.tile.num = selected.input
    if evalMagicSquare():
      gameCompelete()
  else:
    selected.tile.num = 0
    selected.input = 0


# mouse input logic
window.onMouseButton:
  if gameEnded:
    return

  if button == MOUSE_BUTTON_LEFT:
    case action
    of PRESS:
      let pos = grid.screenToGirdPos window.getCursorPos
      if grid.isInBound(pos) and not grid.at(pos).locked:
        if selected.tile != nil:
          evalInput()
        selected.tile = grid.at(pos)
        selected.pos = pos
        selected.input = selected.tile.num
      elif selected.tile != nil:
        evalInput()
        selected.tile = nil
    of RELEASE:
      discard
    else: discard


# keyboard input logic
window.onKeyboard:
  if gameEnded:
    return

  if action != PRESS:
    return

  if key in KEY_RIGHT .. KEY_UP and selected.tile == nil:
    selected.tile = grid.at(0, 0)
    selected.pos = ivec2(0, 0)
    selected.input = selected.tile.num
    return

  if selected.tile == nil:
    return

  if key == KEY_ESCAPE:
    evalInput()
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
    if grid.isInBound(newPos):
      evalInput()
      selected.tile = grid.at(newPos)
      selected.pos = newPos
      selected.input = selected.tile.num

  # erase number
  if key == KEY_BACKSPACE:
    selected.input = selected.input div 10
    selected.dup = grid.findDuplicate(selected.tile, selected.input)

  # write number
  if key in KEY_KP_0 .. KEY_KP_9:
    let newNum = selected.input * 10 + (key - KEY_KP_0).int
    if newNum <= grid.size * grid.size:
      selected.input = newNum
      selected.dup = grid.findDuplicate(selected.tile, selected.input)

  # confirm number
  if key == KEY_ENTER:
    evalInput()


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
      elif tile == selected.dup:
        color3
      else:
        tile.color

    drawRect spos.x, spos.y, tileSize, tileSize

    ctx.fillStyle = static: parseHex "000000"
    if tile == selected.tile:
      if selected.input > 0:
        ctx.fillText($selected.input, vec2(spos.x, spos.y + 5))
    elif tile.num > 0:
      ctx.fillText($tile.num, vec2(spos.x, spos.y + 5))
