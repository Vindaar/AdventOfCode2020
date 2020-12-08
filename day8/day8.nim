import sequtils, strutils, parseutils, strscans, sets

const input = """
nop +0
acc +1
jmp +4
acc +3
jmp -3
acc -99
acc +1
jmp -4
acc +6
"""

type
  OpCode = enum
    opNop = "nop"
    opAcc = "acc"
    opJmp = "jmp"

  Instruction = tuple[opCode: OpCode, num: int]

proc parseOp(s: string): (OpCode, int) =
  result[0] = parseEnum[OpCode](s[0 .. 2])
  result[1] = parseInt s[4 .. s.high]

proc parseInstructions(input: string): seq[Instruction] =
  let operations = input.strip.splitLines
  for op in operations:
    result.add parseOp(op)

proc checkAccumulater(instructions: seq[Instruction]): tuple[acc: int, looped: bool] =
  var seenInstructions: set[uint16]
  var idx = 0
  while idx < instructions.len:
    let (opCode, num) = instructions[idx]
    if idx.uint16 in seenInstructions:
      result.looped = true
      break
    seenInstructions.incl idx.uint16
    case opCode
    of opNop: inc idx
    of opAcc:
      inc result.acc, num # result may be negative!
      inc idx
    of opJmp: inc idx, num # num may be negative!
  if idx >= instructions.len:

proc fixBrokenInstruction(instructions: seq[Instruction]): int =
  for i, op in instructions:
    var mdata = instructions
    case op[0]
    of opNop:
      mdata[i] = (opCode: opJmp, num: op[1])
    of opJmp:
      mdata[i] = (opCode: opNop, num: op[1])
    else: continue
    let (num, looped) = mdata.checkAccumulater()
    if not looped:
      return num
  doAssert false, "no fix found!"

proc runTest =
  let data = input.parseInstructions
  block Part1:
    doAssert data.checkAccumulater[0] == 5
  block Part2:
    doAssert data.fixBrokenInstruction == 8

proc runDay8 =
  let data = readFile("day8.txt").parseInstructions
  block Part1:
    let res = checkAccumulater(data)
    echo "State of accumulater before endless loop: ", res
  block Part2:
    echo "State of accumulater after fixing endless loop: ", data.fixBrokenInstruction()


when isMainModule:
  runTest()
  runDay8()
