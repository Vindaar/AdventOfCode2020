import sequtils, strutils, parseutils, strscans, sets, seqmath, algorithm, sets

const input = """
28
33
18
42
31
14
46
20
48
47
24
23
49
45
19
38
39
11
1
32
25
35
8
17
7
9
4
2
34
10
3
"""

proc parseAdapters(s: string): seq[int] =
  result = s.strip.splitLines.mapIt(it.parseInt).sorted

proc countJoltDiffs(s: seq[int], diff: int): int =
  for i in 0 ..< s.high:
    if s[i + 1] - s[i] == diff:
      inc result
  inc result # because outlet to 1st adapter counts as well

proc find3Jolts(s: openArray[int]): seq[int] =
  for i in 0 ..< s.high:
    if s[i + 1] - s[i] == 3:
      result.add i
  result.add s.high

proc countValidArrangements(s: openArray[int], seen: var HashSet[seq[int]],
                            idx: int) =
  template theBody(newIdx: untyped): untyped {.dirty.} =
    var mseen = seen
    for ms in seen:
      var res = ms
      if res[^1] >= s[newIdx] or abs(res[^1] - s[newIdx]) > 3:
        continue
      mseen.excl ms
      res.add s[newIdx]
      mseen.incl res
      countValidArrangements(s, mseen, newIdx)
    seen = mseen.union(seen)

  var i = idx
  while i < s.len:
    if i+1 <= s.high and s[i+1] - s[i] <= 3:
      theBody(i+1)
    if i+2 <= s.high and s[i+2] - s[i] <= 3:
      theBody(i+2)
    if i+3 <= s.high and s[i+3] - s[i] <= 3:
      theBody(i+3)
    inc i
  var mseen = seen
  for ms in seen:
    var res = ms
    if res[^1] == s[^1]:
      continue
    mseen.excl ms
    if abs(res[^1] - s[^1]) <= 3: # sanity...
      res.add s[^1]
    if res[^1] == s[^1]:
      mseen.incl res
  seen = mseen

proc countValidWrapper(s: openArray[int]): int =
  let threeJoltArgs = s.find3Jolts()
  echo threeJoltArgs
  var last = 0
  result = 1
  for i in threeJoltArgs:
    var seen: HashSet[seq[int]]
    seen.incl @[s[last]]
    countValidArrangements(s[last .. i], seen, 0)
    result *= seen.card
    last = i + 1

proc runTest =
  let data = input.parseAdapters
  block Part1:
    doAssert data.countJoltDiffs(1) * data.countJoltDiffs(3) == 22 * 10
  block Part2:
    doAssert concat(@[0], data, @[data.max + 3]).countValidWrapper() == 19208

proc runDay10 =
  let data = readFile("day10.txt").parseAdapters
  block Part1:
    echo "Product of 1 jolt * 3 jolt diffs: ", data.countJoltDiffs(1) * data.countJoltDiffs(3)
  block Part2:
    let res = concat(@[0], data, @[data.max + 3]).countValidWrapper()
    echo "Number of possible arrangements ", res


when isMainModule:
  runTest()
  runDay10()
