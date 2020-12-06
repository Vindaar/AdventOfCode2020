import sequtils, strutils, parseutils

const input = """
abc

a
b
c

ab
ac

a
a
a
a

b
"""
type
  Answers = set[char]
  Group = object
    people: seq[Answers]

proc parseInput(input: string): seq[Group] =
  let s = input.strip
  var i = 0
  var group: Group
  var answers: Answers
  var nCount = 0
  while i < s.len:
    case s[i]
    of 'a' .. 'z':
      answers.incl s[i]
      nCount = 0
    of '\n':
      if nCount > 0:
        result.add group
        group = Group()
      else:
        group.people.add answers
        answers = {}
      inc nCount
    else: doAssert false
    inc i
  group.people.add answers
  result.add group

proc countAll(g: Group): int =
  var s: Answers
  for a in g.people:
    s = s + a # union
  result = s.card

proc countCommon(g: Group): int =
  var s: Answers
  for i, a in g.people:
    if i == 0:
      s = a
    else:
      s = s * a # intersection
  result = s.card

proc runTest =
  block Part1:
    let data = input.parseInput
    var res = 0
    for g in data:
      res += g.countAll
    doAssert res == 11
  block Part2:
    let data = input.parseInput
    var res = 0
    for g in data:
      res += g.countCommon
    doAssert res == 6

proc runDay6 =
  let data = readFile("day6.txt").parseInput
  block Part1:
    var res = 0
    for g in data:
      res += g.countAll
    echo "Sum of group counts ", res
  block Part2:
    var res = 0
    for g in data:
      res += g.countCommon
    echo "Sum of common group counts ", res


when isMainModule:
  runTest()

  runDay6()
