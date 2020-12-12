import sequtils, strutils, parseutils, strscans, sets, seqmath, algorithm, sets, os, strformat
import ggplotnim, shell

const input = """
F10
N3
F7
R90
F11
"""

type
  MoveKind = enum
    mkNorth = "N"
    mkEast = "E"
    mkSouth = "S"
    mkWest = "W"
    mkForward = "F"
    mkRight = "R"
    mkLeft = "L"
  Move = object
    kind: MoveKind
    val: int
  Point = object
    x: int
    y: int

proc distance(p1, p2: Point): int =
  result = abs(p2.x - p1.x) + abs(p2.y - p1.y)

proc parseCommands(s: string): seq[Move] =
  let lines = s.strip.splitLines
  result = lines.mapIt(Move(kind: parseEnum[MoveKind]($it[0]),
                            val: it[1 .. ^1].parseInt))

proc plotMovement(m: seq[Point], suffix: string) =
  var distances: seq[int]
  for i in 0 ..< m.len:
    distances.add distance(m[i], Point(x: 0, y: 0))
  var df = seqsToDf({ "x" : m.mapIt(it.x), "y" : m.mapIt(it.y),
                      "distance" : distances })

  createDir("out")
  ggplot(df, aes("x", "y", color = "distance")) +
    geom_line() +
    geom_point() +
    theme_opaque() +
    ggtitle(&"Movement of my ship! {suffix}") +
    ggsave(&"out/ship_movement_{suffix}.png")

proc moveHeading(pos: var Point, m: Move, heading: MoveKind) =
  case heading
  of mkNorth: inc pos.y, m.val
  of mkSouth: dec pos.y, m.val
  of mkEast: inc pos.x, m.val
  of mkWest: dec pos.x, m.val
  else: doAssert false, "Impossible branch"

proc followCommands(moves: seq[Move], suffix: string): int =
  var heading = mkEast
  var pos: Point
  var positions = @[Point(x:0, y:0)]
  for m in moves:
    case m.kind
    of mkNorth: inc pos.y, m.val
    of mkSouth: dec pos.y, m.val
    of mkEast: inc pos.x, m.val
    of mkWest: dec pos.x, m.val
    of mkForward: pos.moveHeading(m, heading)
    of mkRight: heading = MoveKind((heading.ord + m.val div 90) mod 4)
    of mkLeft: heading = MoveKind((heading.ord - m.val div 90) %% 4)
    positions.add pos
  result = distance(positions[0], pos)
  plotMovement(positions, suffix)

proc moveWaypoint(pos: var Point, waypoint: Point, m: Move) =
  for _ in 0 ..< m.val:
    inc pos.x, waypoint.x
    inc pos.y, waypoint.y

proc rotate(p: Point, angle: int, right: bool): Point =
  let c = cos(angle.float.degToRad).int
  var s = sin(angle.float.degToRad).int
  if right:
    s *= -1
  result = Point(x: p.x * c - p.y * s,
                 y: p.x * s + p.y * c)

proc followWaypoint(moves: seq[Move], suffix: string): int =
  var waypoint = Point(x: 10, y: 1)
  var pos: Point
  var positions = @[Point(x:0, y:0)]
  for m in moves:
    case m.kind
    of mkNorth: inc waypoint.y, m.val
    of mkSouth: dec waypoint.y, m.val
    of mkEast: inc waypoint.x, m.val
    of mkWest: dec waypoint.x, m.val
    of mkForward: pos.moveWaypoint(waypoint, m)
    of mkRight: waypoint = rotate(waypoint, m.val, true)
    of mkLeft: waypoint = rotate(waypoint, m.val, false)
    positions.add pos
  result = distance(positions[0], pos)
  plotMovement(positions, suffix)

proc runTest =
  let moves = input.parseCommands
  block Part1:
    doAssert moves.followCommands("test_part1") == 25
  block Part2:
    doAssert moves.followWaypoint("test_part2") == 286

proc runDay12 =
  let moves = readFile("day12.txt").parseCommands
  block Part1:
    echo "Manhatten distance of ship part 1: ", moves.followCommands("part1")
  block Part2:
    echo "Manhatten distance of ship part 2: ", moves.followWaypoint("part2")

when isMainModule:
  runTest()
  runDay12()
