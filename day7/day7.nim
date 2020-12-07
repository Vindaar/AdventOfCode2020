import sequtils, strutils, parseutils, strscans, sets

const input = """
light red bags contain 1 bright white bag, 2 muted yellow bags.
dark orange bags contain 3 bright white bags, 4 muted yellow bags.
bright white bags contain 1 shiny gold bag.
muted yellow bags contain 2 shiny gold bags, 9 faded blue bags.
shiny gold bags contain 1 dark olive bag, 2 vibrant plum bags.
dark olive bags contain 3 faded blue bags, 4 dotted black bags.
vibrant plum bags contain 5 faded blue bags, 6 dotted black bags.
faded blue bags contain no other bags.
dotted black bags contain no other bags.
"""
type
  Bag = ref BagObj
  BagObj = object
    color: string
    contain: seq[(int, Bag)]

proc pretty(b: Bag, indent = 0): string =
  if b.isNil:
    return "nil"
  result.add "Bag(color: " & $b.color
  if b.contain.len > 0:
    result.add ", contains: ["
  for i, c in b.contain:
    result.add("(num: " & $c[0] & ", " & pretty(c[1], indent = indent + 2) & ")")
    if i < b.contain.high:
      result.add ", "
    else:
      result.add "]"
  result.add ")"
proc `$`(b: Bag): string = b.pretty()

proc parseInput(input: string): seq[Bag] =
  let lines = input.strip.splitLines
  var line: string
  proc parseContent(s: string): (int, Bag) =
    if s.startsWith("no"):
      return
    var color: string
    if s.scanf("$i $* bag", result[0], color):
      result[1] = Bag(color: color)
    else: doAssert false, " ** " & $s
  proc parseBag(s: string): Bag =
    new(result)
    let idx = s.parseUntil(result.color, " bag")
    doAssert idx > 0

  var bag: Bag
  var bagBuf: string
  var i = 0
  while i < lines.len:
    var idx = 0
    bag = Bag()
    let line = lines[i]
    idx += line.parseUntil(bagBuf, "contain", 0)
    inc idx, "contain".len + 1
    bag = parseBag(bagBuf)
    while idx < line.len:
      idx += line.parseUntil(bagBuf, {',', '.'}, start = idx)
      inc idx, 2
      let (num, cont) = parseContent(bagBuf)
      if num > 0:
        bag.contain.add((num, cont))
    result.add bag
    inc i

proc findBag(bags: seq[Bag], color: string): int =
  for i, b in bags:
    if b.color == color:
      return i
  doAssert false, "Should always find it!"

proc walkForShiny(b: Bag, bags: seq[Bag]): HashSet[string] =
  for (num, c) in b.contain:
    if c.color == "shiny gold":
      result.incl b.color
    else:
      let idx = findBag(bags, c.color)
      let set = walkForShiny(bags[idx], bags)
      if set.card > 0:
        result = result.union(set)
        result.incl b.color

proc walkForShiny(bags: seq[Bag]): HashSet[string] =
  for b in bags:
    result = result.union(walkForShiny(b, bags))

proc countContainedBags(bags: seq[Bag], color: string): int =
  let idx = findBag(bags, color)
  for (num, c) in bags[idx].contain:
    result += num
    result += (num * countContainedBags(bags, c.color))

proc runTest =
  let data = input.parseInput
  block Part1:
    doAssert walkForShiny(data).card == 4
  block Part2:
    echo data.countContainedBags("shiny gold")

proc runDay7 =
  let data = readFile("day7.txt").parseInput
  block Part1:
    let res = data.walkForShiny
    echo res
    echo "Number of bags can hold 'shiny gold': ", res.card
  block Part2:
    echo "Number of bags contained in 'shiny gold': ", data.countContainedBags("shiny gold")


when isMainModule:
  runTest()
  runDay7()
