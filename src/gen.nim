import std/math
import std/random
import std/algorithm
import grids


proc newAscendingSeq(len: int): seq[int] =
  result = newSeq[int](len)
  for i, n in result.mpairs:
    n = i


proc gen3x3(seed: int): seq[seq[int]] =
  var arr = @[1, 6, 7, 2, 9, 4, 3, 8]
  if (seed div 8) mod 2 == 1:
    arr.reverse()
    arr.rotateLeft(arr.len - 1)
  arr.rotateLeft(seed mod 4 * 2)
  @[
    @[arr[7], arr[0], arr[1]],
    @[arr[6], 5, arr[2]],
    @[arr[5], arr[4], arr[3]]
  ]


proc genMagicSquare*(grid: Grid, seed: int): seq[seq[int]] =
  if grid.size == 3:
    return gen3x3 seed
  # TODO
  if grid.size mod 1 == 0:
    discard
  if grid.size mod 4 == 0:
    discard
  if grid.size mod 2 == 0:
    discard


proc genHint*(grid: Grid): Grid =
  result = grid
  let magicSquare = grid.genMagicSquare rand(int.high)
  var hintCount = 2
  var hintSeq = newAscendingSeq(grid.size ^ 2)
  randomize()
  hintSeq.shuffle()
  for i in 0 ..< hintCount:
    let y = hintSeq[i] div grid.size
    let x = hintSeq[i] mod grid.size
    grid.tiles[y][x].num = magicSquare[y][x]
    grid.tiles[y][x].locked = true
