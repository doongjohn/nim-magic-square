import std/algorithm
import pixie


type Tile* = ref object
  color*: Color
  locked*: bool
  num*: int


type Grid* = ref object
  pos*: Vec2
  size*: int
  tiles*: seq[seq[Tile]]
  cellSize*: float


proc initGrid*(pos: Vec2, size: int, cellSize: float): Grid =
  result = Grid(
    pos: pos,
    size: size,
    tiles: newSeq[seq[Tile]](size),
    cellSize: cellSize
  )
  for i in 0 ..< size:
    result.tiles[i] = newSeq[Tile](size)
    for tile in result.tiles[i].mitems:
      tile = Tile()


template at*(grid: Grid, x, y: int): Tile =
 grid.tiles[y][x]


template at*(grid: Grid, pos: IVec2): Tile =
  grid.tiles[pos.y][pos.x]


proc isInBound*(grid: Grid, gridPos: IVec2): bool =
  gridPos.x >= 0 and
  gridPos.y >= 0 and
  gridPos.x < grid.size and
  gridPos.y < grid.size


template calcTopLeftPos*(grid: Grid): Vec2 =
  vec2(
    grid.pos.x - grid.cellSize * grid.size.float / 2,
    grid.pos.y - grid.cellSize * grid.size.float / 2,
  )


proc screenToGirdPos*(grid: Grid, screenPos: Vec2): IVec2 =
  let topLeft = grid.calcTopLeftPos()
  result.x = ((screenPos.x - topLeft.x) / grid.cellSize).floor.int32
  result.y = ((screenPos.y - topLeft.y) / grid.cellSize).floor.int32


proc gridToScreenPos*(grid: Grid, gridPos: IVec2): Vec2 =
  let topLeft = grid.calcTopLeftPos()
  result.x = grid.cellSize * gridPos.x.float + topLeft.x + grid.cellSize / 2
  result.y = grid.cellSize * gridPos.y.float + topLeft.y + grid.cellSize / 2


iterator iterate*(grid: Grid): tuple[gpos: IVec2, spos: Vec2, tile: Tile] =
  # gpos => grid pos
  # spos => screen pos
  let topLeft = grid.calcTopLeftPos()
  var spos = topLeft + grid.cellSize / 2
  for y, row in grid.tiles:
    for x, tile in row:
      yield (ivec2(x.int32, y.int32), spos, tile)
      spos.x += grid.cellSize
    spos.x = topLeft.x + grid.cellSize / 2
    spos.y += grid.cellSize


iterator rows*(grid: Grid): seq[Tile] =
  for row in grid.tiles:
    yield row


iterator cols*(grid: Grid, container: var seq[Tile]): seq[Tile] =
  for x in 0 ..< grid.size:
    container.setLen 0
    for y in 0 ..< grid.size:
      container.add grid.tiles[y][x]
    yield container


iterator cols*(grid: Grid): seq[Tile] =
  var col = newSeq[Tile](grid.size)
  for _ in grid.cols(col):
    yield col


iterator lines*(grid: Grid): seq[Tile] =
  var line = newSeq[Tile](grid.size)

  # horizontal lines
  for row in grid.rows:
    yield row

  # vertical lines
  for col in grid.cols(line):
    yield col

  # diagonal lines
  for x in 0 ..< grid.size:
    for y in 0 ..< grid.size:
      line[x] = grid.tiles[y][x]
  yield line
  for x in 0 ..< grid.size:
    for y in  countdown(grid.size - 1, 0):
      line[x] = grid.tiles[y][x]
  yield line


proc sum*(line: openArray[Tile]): int =
  for i in line: result += i.num


proc findDuplicate*(grid: Grid, this: Tile, num: int): Tile =
  if num == 0: return nil
  for (gpos, _, tile) in grid.iterate():
    if tile.num == num and tile != this:
      return tile
