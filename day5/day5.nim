import sequtils, strutils, parseutils

const input = """BFFFBBFRRR
FFFBBBFRRR
BBFFBBFRLL
"""

const Rows = 128

type
  Seat = object
    row, col: int
    pass: string
  Seats = array[Rows * 8, Seat]

proc seatId(s: Seat): int = s.row * 8 + s.col

proc binarySearch(s: string, max: int, charL, charU: static char): int =
  var
    l = 0
    h = max
  for i in 0 ..< s.len:
    case s[i]
    of charL: h = h - (h - l) div 2 - 1
    of charU: l = l + (h - l) div 2 + 1
    else: doAssert false
  doAssert l == h, " l " & $l & "  and h " & $h
  result = l

proc parseInput(input: string): seq[Seat] =
  let s = input.strip.splitLines
  for pass in s:
    var seat = Seat(pass: pass)
    seat.row = binarySearch(pass[0 ..< 7], Rows - 1, 'F', 'B')
    seat.col = binarySearch(pass[7 .. pass.high], 7, 'L', 'R')
    result.add seat

proc runTest =
  block Part1:
    let data = input.parseInput
    let exp = @[567, 119, 820]
    echo data.mapIt(it.seatId)
    doAssert data.mapIt(it.seatId) == exp

proc runDay5 =
  let data = readFile("day5.txt").parseInput
  block Part1:
    let res = data.mapIt(it.seatId)
    echo "Highest seat ID available ", res.max
  block Part2:
    var seats: Seats
    # map all seats to the Seats array
    for s in data:
      seats[s.seatId] = s
    # output the first seat after valid seats which is not set
    var firstSeat = false
    for i, s in seats:
      if not firstSeat and s.pass.len > 0:
        firstSeat = true
      if firstSeat and s.pass.len == 0:
        echo "Your seat id is ", i
        break

when isMainModule:
  runTest()

  runDay5()
