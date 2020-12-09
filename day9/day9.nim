import sequtils, strutils, parseutils, strscans, sets, seqmath

const input = """
35
20
15
25
47
40
62
55
65
95
102
117
150
182
127
219
299
277
309
576
"""

proc parseData(s: string): seq[int] =
  result = s.strip.splitLines.mapIt(it.parseInt)

proc isValid(val: int, s: seq[int]): bool =
  for i in 0 ..< s.len:
    for j in i ..< s.len:
      if s[i] + s[j] == val:
        return true

proc findFirstInvalid(s: seq[int], preambleLen: int): int =
  var preamble = s[0 ..< preambleLen]
  for i in preambleLen ..< s.len:
    if not s[i].isValid(preamble):
      return s[i]
    preamble.delete(0)
    preamble.add s[i]

proc findContiguousSet(val: int, s: seq[int]): seq[int] =
  var i = 0
  while i < s.len:
    if result.sum > val:
      while result.sum > val:
        result.delete(0)
    if result.sum == val: # not elif, cause removal in above might give us result
      return
    if s[i] < val:
      result.add(s[i])
    inc i

proc runTest =
  let data = input.parseData
  let firstInvalid = data.findFirstInvalid(5)
  block Part1:
    doAssert firstInvalid == 127
  block Part2:
    let res = firstInvalid.findContiguousSet(data)
    doAssert res.min + res.max == 62

proc runDay9 =
  let data = readFile("day9.txt").parseData
  let firstInvalid = data.findFirstInvalid(25)
  block Part1:
    echo "First number not summing to any of previous 25: ", firstInvalid
  block Part2:
    let res = firstInvalid.findContiguousSet(data)
    echo "Min + max of contiguous set: ", res.min + res.max


when isMainModule:
  runTest()
  runDay9()
