import sequtils, strutils, times

const testInput = """
..##.......
#...#...#..
.#....#..#.
..#.#...#.#
.#...##..#.
..#.##.....
.#.#.#....#
.#........#
#.##...#...
#...##....#
.#..#...#.#
"""

proc countTrees(s: seq[string], incC, incR: int): int =
  var
    r, c = 0
  while r < s.len:
    case s[r][c]
    of '#': inc result
    else: discard
    c = (c + incC) mod s[r].len
    r = min(s.len, r + incR)

proc countTreesPart2(s: seq[string]): int =
  let slopes = {1 : 1, 3 : 1, 5 : 1, 7 : 1, 1 : 2}
  result = 1
  for (c, r) in slopes:
    result *= s.countTrees(c, r)

proc parseInput(s: string): seq[string] =
  result = s.strip.splitLines

proc runTest =
  let data = testInput.parseInput
  block Part1:
    doAssert data.countTrees(3, 1) == 7
  block Part2:
    doAssert data.countTreesPart2() == 336

proc runDay3 =
  let data = readFile("day3.txt").parseInput
  block Part1:
    let res = data.countTrees(3, 1)
    echo "Number of trees part 1 is: ", res
  block Part2:
    let res = data.countTreesPart2()
    echo "Number of trees part 2 is: ", res


when isMainModule:
  runTest()

  runDay3()
