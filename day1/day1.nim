import sequtils, strutils

const input = """
1721
979
366
299
675
1456
"""

proc sum2To2020(input: seq[int]): (int, int) =
  for x in input:
    for y in input:
      if x + y == 2020:
        return (x, y)
  doAssert false

proc sum3To2020(input: seq[int]): (int, int, int) =
  for x in input:
    for y in input:
      for z in input:
        if x + y + z == 2020:
          return (x, y, z)
  doAssert false

proc parseInput(s: string): seq[int] =
  result = s.strip.splitLines.mapIt(it.strip.parseInt)

proc runTest =
  let data = input.parseInput
  block Part1:
    let tup = data.sum2To2020
    doAssert tup[0] * tup[1] == 514579
  block Part2:
    let tup = data.sum3To2020
    doAssert tup[0] * tup[1] * tup[2] == 241861950

proc runDay1 =
  let data = readFile("day1.txt").parseInput
  block Part1:
    let tup = data.sum2To2020
    echo "Product part 1 is: ", tup[0] * tup[1]
  block Part2:
    let tup = data.sum3To2020
    echo "Product part 2 is: ", tup[0] * tup[1] * tup[2]

when isMainModule:
  runTest()

  runDay1()
