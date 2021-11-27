import std/random
import std/algorithm
import grids


proc newAscendingSeq(len: int): seq[int] =
  result = newSeq[int](len)
  for i, n in result.mpairs:
    n = i


proc gen3(seed: int): seq[seq[int]] =
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
    return gen3 seed
  # TODO
  if grid.size mod 1 == 0:
    discard
  if grid.size mod 4 == 0:
    discard
  if grid.size mod 2 == 0:
    discard


proc genHint*(grid: Grid): Grid =
  result = grid
  randomize()
  var hintCount = 2
  let ms = grid.genMagicSquare rand(int.high)
  var hintList = newAscendingSeq grid.size
  hintList.shuffle()
  for i in 0 ..< hintCount:
    let y = hintList[i] div grid.size
    let x = hintList[i] mod (grid.size + 1)
    grid.tiles[y][x].num = ms[y][x]
    grid.tiles[y][x].locked = true
