import sequtils, strutils, times, strscans, parseutils, tables

const testInput = """
ecl:gry pid:860033327 eyr:2020 hcl:#fffffd
byr:1937 iyr:2017 cid:147 hgt:183cm

iyr:2013 ecl:amb cid:350 eyr:2023 pid:028048884
hcl:#cfa07d byr:1929

hcl:#ae17e1 iyr:2013
eyr:2024
ecl:brn pid:760753108 byr:1931
hgt:179cm

hcl:#cfa07d eyr:2025 pid:166559648
iyr:2011 ecl:brn hgt:59in
"""

const testInputPart2 = """
eyr:1972 cid:100
hcl:#18171d ecl:amb hgt:170 pid:186cm iyr:2018 byr:1926

iyr:2019
hcl:#602927 eyr:1967 hgt:170cm
ecl:grn pid:012533040 byr:1946

hcl:dab227 iyr:2012
ecl:brn hgt:182cm pid:021572410 eyr:2020 byr:1992 cid:277

hgt:59cm ecl:zzz
eyr:2038 hcl:74454a iyr:2023
pid:3556412378 byr:2007

pid:087499704 hgt:74in ecl:grn iyr:2012 eyr:2030 byr:1980
hcl:#623a2f

eyr:2029 ecl:blu cid:129 byr:1989
iyr:2014 pid:896056539 hcl:#a97842 hgt:165cm

hcl:#888785
hgt:164cm byr:2001 iyr:2015 cid:88
pid:545766238 ecl:hzl
eyr:2022

iyr:2010 hgt:158cm hcl:#b6652a ecl:blu byr:1944 eyr:2021 pid:093154719
"""

type
  PassportField = enum
    pfByr = "byr" # (Birth Year)
    pfIyr = "iyr" # (Issue Year)
    pfEyr = "eyr" # (Expiration Year)
    pfHgt = "hgt" # (Height)
    pfHcl = "hcl" # (Hair Color)
    pfEcl = "ecl" # (Eye Color)
    pfPid = "pid" # (Passport ID)
    pfCid = "cid" # (Country ID)
  Passport = object
    fields: set[PassportField]
    data: Table[PassportField, string]

proc validatePassports(ps: seq[Passport]): int =
  for pId in ps:
    if pId.fields.card == 8 or
       (pId.fields.card == 7 and pfCid notin pId.fields):
      inc result

proc verifyYear(s: string, range: Slice[int]): bool =
  result = s.len == 4 and s.parseInt in range

proc verifyHeight(s: string): bool =
  var
    h: int
    unit: string
  if scanf(s, "$i$w", h, unit):
    case unit
    of "cm": result = h in 150 .. 193
    of "in": result = h in 59 .. 76
    else: discard

proc verifyColor(s: string): bool =
  result = s[0] == '#' and s.len == 7 and s[1 .. ^1].allCharsInSet({'0' .. '9', 'a' .. 'f'})

proc validatePassportsPart2(ps: seq[Passport]): int =
  for pId in ps:
    if pId.fields.card == 8 or
       (pId.fields.card == 7 and pfCid notin pId.fields):
      # perform validation of fields
      var valid = true
      for key, val in pId.data:
        case key
        of pfByr: valid = verifyYear(val, 1920 .. 2002)
        of pfIyr: valid = verifyYear(val, 2010 .. 2020)
        of pfEyr: valid = verifyYear(val, 2020 .. 2030)
        of pfHgt: valid = verifyHeight(val)
        of pfHcl: valid = verifyColor(val)
        of pfEcl: valid = val in ["amb", "blu", "brn", "gry", "grn", "hzl", "oth"]
        of pfPid: valid = val.len == 9 and val.allCharsInSet({'0' .. '9'})
        of pfCid: discard
        if not valid: break
      if valid:
        inc result

proc parseInput(input: string): seq[Passport] =
  let s = input.strip
  var
    buf, key, val: string
    idx = 0
    next = false
    pId: Passport
  while idx < input.len:
    case s[idx]
    of ' ':
      key = ""
      val = ""
    of '\n':
      result.add pId
      pId.fields = {}
      pId.data = initTable[PassportField, string]()
    else:
      idx += s.parseUntil(buf, {' ', '\n'}, start = idx)
      if buf.scanf("$w:$*", key, val):
        let kEnum = parseEnum[PassportField](key)
        pId.fields.incl kEnum
        pId.data[kEnum] = val
    inc idx
  result.add pId

proc runTest =
  block Part1:
    let data = testInput.parseInput
    doAssert data.validatePassports == 2
  block Part2:
    let data = testInputPart2.parseInput
    doAssert data.validatePassportsPart2 == 4

proc runDay4 =
  let data = readFile("day4.txt").parseInput
  block Part1:
    let res = data.validatePassports
    echo "Number of valid passports part 1 is: ", res
  block Part2:
    let res = data.validatePassportsPart2
    echo "Number of valid passports part 2 is: ", res


when isMainModule:
  runTest()

  runDay4()
