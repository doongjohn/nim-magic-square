import std/math
import std/random
import std/algorithm
import grids


proc newAscendingSeq(len: int): seq[int] =
  result = newSeq[int](len)
  for i, n in result.mpairs:
    n = i


template calcMagicSum*(size: SomeInteger): SomeInteger =
  (size * (size ^ 2 + 1)) div 2


proc gen3x3(seed: int): seq[seq[int]] =
  var arr = [1, 6, 7, 2, 9, 4, 3, 8]
  if (seed div 8) mod 2 == 1:
    arr.reverse()
    arr.rotateLeft(arr.len - 1)
  arr.rotateLeft(seed mod 4 * 2)
  @[
    @[arr[7], arr[0], arr[1]],
    @[arr[6], 5, arr[2]],
    @[arr[5], arr[4], arr[3]]
  ]


proc gen4x4(seed: int): seq[seq[int]] =
  const max = (4 * 4).int16
  const sum = calcMagicSum 4.int16
  var count = 0
  var n: array[16, int16]
  var used: set[int16]

  template use(num: typed) =
    used.incl num
    defer: used.excl num

  template isValid(num: int16): bool =
    num notin 1 .. max or num in used

  n[5] = 0
  while n[5] <= max:
    inc n[5]
    use n[5]

    n[6] = 0
    while n[6] <= max:
      inc n[6]
      if n[6] == n[5]: continue
      use n[6]

      n[9] = 0
      while n[9] <= max:
        inc n[9]
        if n[9] in used: continue
        use n[9]

        n[10] = sum - n[5] - n[6] - n[9]
        if isValid n[10]: continue
        use n[10]

        n[0] = 0
        while n[0] <= max:
          inc n[0]
          if n[0] in used: continue
          use n[0]

          n[15] = sum - n[0] - n[5] - n[10]
          if isValid n[15]: continue
          use n[15]

          n[12] = 0
          while n[12] <= max:
            inc n[12]
            if n[12] in used: continue
            use n[12]

            n[3] = sum - n[12] - n[9] - n[6]
            if isValid n[3]: continue
            use n[3]

            n[1] = 0
            while n[1] <= max:
              inc n[1]
              if n[1] in used: continue
              use n[1]

              n[2] = sum - n[0] - n[1] - n[3]
              if isValid n[2]: continue
              use n[2]

              n[14] = sum - n[2] - n[6] - n[10]
              if isValid n[14]: continue
              use n[14]

              n[13] = sum - n[12] - n[14] - n[15]
              if isValid n[13]: continue
              use n[13]

              n[4] = 0
              while n[4] <= max:
                inc n[4]
                if n[4] in used: continue
                use n[4]

                n[7] = sum - n[4] - n[5] - n[6]
                if isValid n[7]: continue
                use n[7]

                n[11] = sum - n[3] - n[7] - n[15]
                if isValid n[11]: continue
                use n[11]

                n[8] = sum - n[9] - n[10] - n[11]
                if isValid n[8]: continue

                # return result
                if seed mod 7040 == count:
                  result = newSeq[seq[int]](4)
                  for y, row in result.mpairs:
                    row = newSeq[int](4)
                    for x, i in row.mpairs:
                      i = n[y * 4  + x]
                  return

                inc count


proc genMagicSquare*(grid: Grid, seed: int): seq[seq[int]] =
  if grid.size == 3: return gen3x3 seed
  if grid.size == 4: return gen4x4 seed


proc genHint*(grid: Grid, hintCount: int): Grid =
  result = grid
  randomize()
  let magicSquare = grid.genMagicSquare rand(int.high)
  var hintSeq = newAscendingSeq(grid.size ^ 2)
  hintSeq.shuffle()
  for i in 0 ..< hintCount:
    let y = hintSeq[i] div grid.size
    let x = hintSeq[i] mod grid.size
    grid.tiles[y][x].num = magicSquare[y][x]
    grid.tiles[y][x].locked = true
