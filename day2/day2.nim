import sequtils, strutils, times, strscans

const input = """
1-3 a: abcde
1-3 b: cdefg
2-9 c: ccccccccc
"""

proc countValidPasswordsPart1(input: seq[string]): int =
  for p in input:
    var
      frm: int
      to: int
      letter: string
      count = 0
      sub: string
    if scanf(p, "$i-$i $w: $w", frm, to, letter, sub):
      for c in sub:
        if c == letter[0]:
          inc count
        if count > to: break
      result = if count >= frm and count <= to: result + 1 else: result

proc countValidPasswordsPart2(input: seq[string]): int =
  for p in input:
    var
      idx1: int
      idx2: int
      letter: string
      count = 0
      sub: string
    if scanf(p, "$i-$i $w: $w", idx1, idx2, letter, sub):
      if sub[idx1 - 1] == letter[0] xor sub[idx2 - 1] == letter[0]:
        result += 1

proc parseInput(s: string): seq[string] =
  result = s.strip.splitLines

proc runTest =
  let data = input.parseInput
  block Part1:
    doAssert data.countValidPasswordsPart1 == 2
  block Part2:
    doAssert data.countValidPasswordsPart2 == 1

proc runDay2 =
  let data = readFile("day2.txt").parseInput
  block Part1:
    let res = data.countValidPasswordsPart1
    echo "Valid passwords part 1 is: ", res
  block Part2:
    let res = data.countValidPasswordsPart2
    echo "Valid passwords part 2 is: ", res


when isMainModule:
  runTest()

  runDay2()
