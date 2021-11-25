import std/sequtils


proc newSeqAscending*[T](len: int): seq[T] =
  var i = -1
  newSeq[int](len).map(
    proc(x: int): int =
      inc i
      i
  )
