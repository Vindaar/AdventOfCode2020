import sequtils, strutils, parseutils, strscans, sets, seqmath, algorithm, sets, os, strformat
import ggplotnim, shell

const input = """
L.LL.LL.LL
LLLLLLL.LL
L.L.L..L..
LLLL.LL.LL
L.LL.LL.LL
L.LLLLL.LL
..L.L.....
LLLLLLLLLL
L.LLLLLL.L
L.LLLLL.LL
"""

type
  Grid = object
    data: string
    rows: int
    cols: int

proc parseGrid(s: string): Grid =
  let lines = s.strip.splitLines
  result.rows = lines.len
  result.cols = lines[0].len
  result.data = s.strip.replace("\n", "")

proc `==`(g1, g2: Grid): bool = g1.data == g2.data

func toIdx(g: Grid, col, row: int): int = row * g.cols + col

func `[]`(g: Grid, col, row: int): char =
  result = g.data[g.toIdx(col, row)]

func `[]=`(g: var Grid, col, row: int, val: char) =
  g.data[g.toIdx(col, row)] = val

proc `$`(g: Grid): string =
  for row in 0 ..< g.rows:
    for col in 0 ..< g.cols:
        result.add g[col, row]
    result.add '\n'

func isOccupied(g: Grid, col, row: int): bool =
  result = g[col, row] == '#'

func isOccupied(c: char): bool = c == '#'

func isFloor(g: Grid, col, row: int): bool =
  result = g[col, row] == '.'

func isFloor(c: char): bool = c == '.'

func isEmpty(g: Grid, col, row: int): bool =
  result = g[col, row] == 'L'

func isEmpty(c: char): bool = c == 'L'

func isSeat(c: char): bool = c in {'L', '#'}

proc numOccupiedAround(g: Grid, col, row: int): int =
  let combs = product([@[-1, 0, 1], @[-1, 0, 1]])
  for tup in combs:
    let
      (dr, dc) = (tup[0], tup[1])
      dCol = col + dc
      dRow = row + dr
    if dc == 0 and dr == 0:
      continue
    if dCol >= 0 and dCol < g.cols and dRow >= 0 and dRow < g.rows and
       g[dCol, dRow].isOccupied:
        inc result

proc numOccupiedVisible(g: Grid, col, row: int): int =
  let combs = product([@[-1, 0, 1], @[-1, 0, 1]])
  for tup in combs:
    # each direction walk as far until end of grid or seat found
    let
      (dr, dc) = (tup[0], tup[1])
    if dc == 0 and dr == 0:
      continue
    var
      dCol = col + dc
      dRow = row + dr
    while dCol >= 0 and dCol < g.cols and dRow >= 0 and
          dRow < g.rows and g[dCol, dRow].isFloor:
      dCol = dCol + dc
      dRow = dRow + dr
    if dCol >= 0 and dCol < g.cols and dRow >= 0 and dRow < g.rows and
       g[dCol, dRow].isOccupied:
        inc result

func occupied(g: Grid): int =
  result = g.data.countIt(it.isOccupied)

func occupy(g: var Grid, col, row: int) =
  g[col, row] = '#'

func empty(g: var Grid, col, row: int) =
  g[col, row] = 'L'

func constructFilename(g: Grid, step: int, suffix: string): string =
  result = &"out/grid_cols_{g.cols}_rows_{g.rows}_step_{step:03}_{suffix}.png"

proc plot(g: Grid, step: int, suffix = "") =
  ## create tilemap of plot
  let gridSize = g.cols * g.rows
  var
    cols = newSeq[int](gridSize)
    rows = newSeq[int](gridSize)
    vals = newSeq[string](gridSize)
  for col in 0 ..< g.cols:
    for row in 0 ..< g.rows:
      let idx = g.toIdx(col, row)
      cols[idx] = col
      rows[idx] = row
      vals[idx] = case g[col, row]
                  of '#': "Occupied"
                  of 'L': "Empty"
                  of '.': "Floor"
                  else: ""

  let df = seqsToDf(cols, rows, vals)
  createDir("out")
  let fname = constructFilename(g, step, suffix)
  ggplot(df, aes("cols", "rows", fill = "vals")) +
    geom_tile() +
    xlim(0, g.cols) + ylim(0, g.rows) +
    ggtitle(&"Grid size: {g.cols} columns x {g.rows} rows, evolution step {step}, {suffix}") +
    theme_opaque() +
    ggsave(fname)
  copyFile(fname, "/tmp/current_grid.png")

proc evolve(g: Grid, part2: static bool = false): Grid =
  result = g
  echo g
  for row in 0 ..< g.rows:
    for col in 0 ..< g.cols:
      let s = g[col, row]
      case s
      of '.': discard
      of 'L':
        when not part2:
          if numOccupiedAround(g, col, row) == 0:
            occupy result, col, row
        else:
          if numOccupiedVisible(g, col, row) == 0:
            occupy result, col, row
      of '#':
        when not part2:
          if numOccupiedAround(g, col, row) >= 4:
            empty result, col, row
        else:
          if numOccupiedVisible(g, col, row) >= 5:
            empty result, col, row
      else: doAssert false, "Invalid character in grid " & $s

proc evolveUntilSteady(g: Grid, part2: static bool = false): Grid =
  result = g
  var lastGrid: Grid
  var idx = 0
  when part2:
    let suffix = "part2"
  else:
    let suffix = "part1"
  plot(g, idx, suffix)
  while result != lastGrid:
    lastGrid = result
    result = result.evolve(part2 = part2)
    plot(result, idx, suffix)
    inc idx

proc animate(g: Grid, suffix: string) =
  ## call shell to animate
  let baseFilename = constructFilename(g, 0, suffix)
  let globInput = baseFilename.replace("step_000", "step_0??")
  let opts = "-delay 15 -quality 95 -set dispose background -layers OptimizePlus"
  let outname = &"grid_evolution_cols_{g.cols}_rows_{g.rows}_{suffix}.gif"
  shell:
    convert ($opts) ($globInput) ($outname)

proc runTest =
  let grid = input.parseGrid
  block Part1:
    doAssert grid.evolveUntilSteady.occupied == 37
    animate(grid, "part1")
  block Part2:
    doAssert grid.evolveUntilSteady(part2 = true).occupied == 26
    animate(grid, "part2")

proc runDay11 =
  let grid = readFile("day11.txt").parseGrid
  block Part1:
    echo "Number of occupied seats in steady state: ", grid.evolveUntilSteady.occupied
    animate(grid, "part1")
  block Part2:
    echo "Number of occupied seats in steady state in part2: ", grid.evolveUntilSteady(part2 = true).occupied
    animate(grid, "part2")

when isMainModule:
  runTest()
  runDay11()
