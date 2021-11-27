# Magic square game
# ref: https://ko.wikipedia.org/wiki/마방진
# ref: http://www.mathematische-basteleien.de/magsquare.htm
# ref: https://blogs.mathworks.com/cleve/2012/11/05/magic-squares-part-2-algorithms/
# ref: https://mindyourdecisions.com/blog/2015/11/08/how-many-3x3-magic-squares-are-there-sunday-puzzle/
# source: https://github.com/CalebDepatie/MagicSquares
# source: https://github.com/Coac/MagicSquare/blob/master/src/MagicSquare.java

# TODO:
# - [x] create square of any size
# - [x] display duplicate error
# - [x] evaluate magic square
# - [ ] auto generate hint
# - [ ] display sum
# - [ ] display help


import std/math
import staticglfw, nimglfw
import opengl
import pixie
import grids
import app
import draw
import gen


const
  color1 = parseHex "bfdbff"
  color2 = parseHex "ededed"
  color3 = parseHex "ff9494"
  tileSize = 90.0


template calcMagicSum(size: int): int =
  (size * (size ^ 2 + 1)) div 2


var
  gameEnded = false
  grid = initGrid(center, 3, 100).genHint()
  magicSquareSum = calcMagicSum grid.size
  selected: tuple[pos: IVec2, input: int, tile, dup: Tile] =
    (ivec2(-1, -1), 0, nil, nil)


proc gameRestart =
  gameEnded = false
  grid = initGrid(center, 3, 100).genHint()
  magicSquareSum = calcMagicSum grid.size
  selected = (ivec2(-1, -1), 0, nil, nil)


proc gameCompelete =
  gameEnded = true
  selected.tile = nil
  selected.dup = nil
  for (_, _, tile) in grid.iterate:
    tile.locked = true


proc evalMagicSquare: bool =
  result = true
  for line in grid.lines:
    if line.sum != magicSquareSum:
      return false


proc evalInput =
  selected.tile.num = selected.input
  if evalMagicSquare():
    gameCompelete()


proc updateInput =
  if selected.dup == nil:
    evalInput()
  else:
    selected.input = 0
    selected.tile.num = 0
    selected.dup = nil


# mouse input logic
window.onMouseButton:
  if gameEnded:
    return

  if button == MOUSE_BUTTON_LEFT:
    case action
    of PRESS:
      let pos = grid.screenToGirdPos window.getCursorPos
      if grid.isInBound(pos):
        if selected.tile != nil:
          updateInput()
        let tile = grid.at(pos)
        selected.pos = pos
        selected.input = tile.num
        selected.tile = tile
      elif selected.tile != nil:
        updateInput()
        selected.tile = nil
    of RELEASE:
      discard
    else: discard


# keyboard input logic
window.onKeyboard:
  if action != PRESS:
    return

  # restart game
  if key == KEY_R:
    gameRestart()

  if gameEnded:
    return

  if key in KEY_RIGHT .. KEY_UP and selected.tile == nil:
    selected.pos = ivec2(0, 0)
    selected.input = selected.tile.num
    selected.tile = grid.at(0, 0)
    return

  if selected.tile == nil:
    return

  if key == KEY_ESCAPE:
    updateInput()
    selected.tile = nil

  # arrow movement
  if key in KEY_RIGHT .. KEY_UP:
    var newPos = case key
    of KEY_UP:
      ivec2(selected.pos.x, selected.pos.y - 1)
    of KEY_DOWN:
      ivec2(selected.pos.x, selected.pos.y + 1)
    of KEY_RIGHT:
      ivec2(selected.pos.x + 1, selected.pos.y)
    of KEY_LEFT:
      ivec2(selected.pos.x - 1, selected.pos.y)
    else:
      ivec2(-1, -1)
    if grid.isInBound(newPos):
      updateInput()
      let tile = grid.at(newPos)
      selected.pos = newPos
      selected.input = tile.num
      selected.tile = tile

  if selected.tile.locked:
    return

  # erase number
  if key == KEY_BACKSPACE:
    selected.input = selected.input div 10
    selected.dup = grid.findDuplicate(selected.tile, selected.input)
    if selected.dup == nil:
      evalInput()

  # write number
  if key in KEY_KP_0 .. KEY_KP_9:
    let newNum = selected.input * 10 + (key - KEY_KP_0).int
    if newNum <= grid.size ^ 2:
      selected.input = newNum
      selected.dup = grid.findDuplicate(selected.tile, selected.input)
      if selected.dup == nil:
        evalInput()

  # confirm number
  if key == KEY_ENTER:
    updateInput()


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

    # draw tile
    drawRect spos.x, spos.y, tileSize, tileSize

    # draw number
    ctx.fillStyle = static: parseHex "000000"
    if tile == selected.tile:
      if selected.input > 0:
        ctx.fillText($selected.input, vec2(spos.x, spos.y + 5))
    elif tile.num > 0:
      ctx.fillText($tile.num, vec2(spos.x, spos.y + 5))
