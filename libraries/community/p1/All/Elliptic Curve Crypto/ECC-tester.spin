{{ ecc.spin }}
CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000
  propTX  = 30 'programming output
  propRX  = 31 'programming input
  baudrate = 115_200

  MAX_SIZE = 17


OBJ
  Clock : "Clock"
  debug: "SerialMirror"  '//debug port
  fmt:   "Format"  '//Format object

  p192 : "NIST-P192"
  p224 : "NIST-P224"
  p256 : "NIST-P256"
  p384 : "NIST-P384"
  p521 : "NIST-P521"
  ecc:    "ECC"


VAR
  BYTE buffer[180] 'buffer to assemble output strings

  long  dur

  long  args

  long  i

  long  kk
  long  vv
  long  rr

  long  cog

  long  before
  long  after

  long  Nwords
  long  Nbytes
  long  worksp

  long  leaddig

PUB Main
  Clock.init (5_000_000)
  Clock.setclock (XTAL1 + PLL16X) 'Set clock to really fast

  debug.start (propRX, propTX, 0, baudrate)
  sprinln (string("Starting..."),cnt)

  prin (string ("init:"))

  leaddig := 7

  args := ecc.start (p192.start)
  sprinln (string("P192 ECC cog = %i"), long[args][4])
  setup_sizes
  do_tests (192, @testv192, @testval192)
  ecc.stop
  p192.stop

  args := ecc.start (p224.start)
  sprinln (string("P224 ECC cog = %i"), long[args][4])
  setup_sizes
  do_tests (224, @testv224, @testval224)
  ecc.stop
  p224.stop

  args := ecc.start (p256.start)
  sprinln (string("P256 ECC cog = %i"), long[args][4])
  setup_sizes
  do_tests (256, @testv256, @testval256)
  ecc.stop
  p256.stop

  args := ecc.start (p384.start)
  sprinln (string("P384 ECC cog = %i"), long[args][4])
  setup_sizes
  do_tests (384, @testv384, @testval384)
  ecc.stop
  p384.stop

  leaddig := 3
  args := ecc.start (p521.start)
  sprinln (string("P521 ECC cog = %i"), long[args][4])
  setup_sizes
  do_tests (521, @testv521, @testval521)
  ecc.stop
  p521.stop

  debug.str (string("END"))
  debug.tx(10)
  repeat

PRI setup_sizes
  Nwords := ecc.size
  Nbytes := 4 * Nwords
  worksp := ecc.workspace
  sprinln (string("Nwords = %i"), Nwords)

PRI do_tests(pp, test1, test2)

  ecc.setinfinite
  ecc.addaff
  prinaffine(worksp)
  repeat i from 1 to 4
    sprinln (string ("k = 2^%i"), i)
    ecc.double
'    prinpoints (worksp)
    ecc.ensure
    prinaffine (worksp)

  ecc.setinfinite
  repeat i from 1 to 20
    sprinln (string ("k = %i"), i)
    ecc.addaff
    'prinpoints (worksp)
    ecc.ensure
    prinaffine (worksp)

  sprinln (string ("mult by W = 0x%x"), $018ebbb9)
  before := cnt
  ecc.setinfinite
  ecc.pointmul1 ($018ebbb9)
  after := cnt
  sprinln (string ("time %ims"), (after-before) / 80000)
  ecc.ensure
  prinaffine(worksp)
  sprinln (string (" and by W = 0x%x"), $5eed0e13)
  before := cnt
  ecc.pointmul1 ($5eed0e13)
  after := cnt
  sprinln (string ("time %ims"), (after-before) / 80000)
  ecc.ensure
  prinaffine(worksp)
  sprinln (string ("done tests"), 0)

  prinarr (test1, string ("k = "))
  before := cnt
  ecc.pointmul (test1)
  after := cnt
  sprinln (string ("total time %ims"), (after-before) / 80000)
  ecc.ensure
  prinaffine(worksp)

  prinarr (test2, string ("k = "))
  before := cnt
  ecc.pointmul (test2)
  after := cnt
  sprinln (string ("total time %ims"), (after-before) / 80000)
  ecc.ensure
  prinaffine(worksp)
  sprinln (string ("done P%i tests"), pp)

'PRI test_checks_sets
  sprinln (string("checkV(x) returns %i"), ecc.checkV(worksp+3*Nbytes))
  sprinln (string("checkV(y) returns %i"), ecc.checkV(worksp+4*Nbytes))
  sprinln (string("checkP returns %i"), ecc.checkP)
  prinpoints(worksp)
  sprinln (string("setP returns %i"), ecc.setP (@myx, @myy))
  sprinln (string("setP returns %i"), ecc.setP (@myy, @myx))
  sprinln (string("resetP returns %i"), ecc.resetP)



PRI sprin(fmtstr, fmtarg)
  fmt.sprintf (@buffer, fmtstr, fmtarg)
  debug.str (@buffer)

PRI sprinln(fmtstr, fmtarg)
  fmt.sprintf (@buffer, fmtstr, fmtarg)
  debug.str (@buffer)
  debug.tx (10)

PRI prin(fmtstr)
  fmt.sprintf (@buffer, fmtstr, 0)
  debug.str (@buffer)

PRI prinln(fmtstr)
  fmt.sprintf (@buffer, fmtstr, 0)
  debug.str (@buffer)
  debug.tx (10)

PRI prinpoints(addr)
  prinarr (addr, string("X = "))
  prinarr (addr+Nbytes, string("Y = "))
  prinarr (addr+2*Nbytes, string("Z = "))

  prinarr (addr+3*Nbytes, string("xx= "))
  prinarr (addr+4*Nbytes, string("yy= "))
  prinarr (addr+5*Nbytes, string("zz= "))
  prinarr (addr+6*Nbytes, string ("t1= "))
  prinarr (addr+7*Nbytes, string ("t2= "))
  prinarr (addr+8*Nbytes, string ("t3= "))
  prinarr (addr+9*Nbytes, string ("t4= "))
  {
  prinarr (addr+10*Nbytes, string ("u = "))
  prinarr (addr+11*Nbytes, string ("v = "))
  prinarr (addr+12*Nbytes, string ("x1= "))
  prinarr (addr+13*Nbytes, string ("x2= "))
  }
  prinarr (addr+14*Nbytes, string ("b = "))
  prinarr (addr+15*Nbytes, string ("n = "))
  prinarr (addr+16*Nbytes, string ("Ox= "))
  prinarr (addr+17*Nbytes, string ("Oy= "))
  debug.tx(10)


PRI prinaffine(addr)
  prinarr (addr, string("x = "))
  prinarr (addr+Nbytes, string("y = "))
  debug.tx(10)


PRI prinarr (arr, name) | k
  debug.str (name)
  repeat k from Nwords-1 to 0
    prinwrd2 (k, long[arr][k])
  debug.tx (10)

PRI prinlzarr (arr, name) | k, l, lz
  debug.str (name)
  lz := true
  repeat k from Nwords-1 to 0
    l := long[arr][k]
    prinwrd (k, l, lz)
    if l <> 0
      lz := false
  debug.tx (10)

PRI prinfarr (arr, name) | k, l, lz
  debug.str (name)
  lz := true
  repeat k from Nwords-1 to 0
    l := long[arr][k]
    prinwrd (0, l, lz)
    if l <> 0
      lz := false
  debug.tx (10)


PRI prinwrd (ii, val, lz) | ct, k, l, m
  l := 0
  ct := 7
  repeat k from ct to 0
    m := (val >> (k << 2)) & $F
    if m <> 0
      lz := false
    if lz
      buffer [l++] := $20
    else
      buffer [l++] := hex[m]
  buffer[l] := 0
  debug.str (@buffer)


PRI prinwrd2 (ii, val) | ct, k, l
  l := 0
  ct := 7
  if ii == Nwords-1
    ct := leaddig
  repeat k from ct to 0
    buffer [l++] := hex[(val >> (k << 2)) & $F]
  buffer[l] := 0
  debug.str (@buffer)


DAT

{{ Data - test values (low order word first, note) }}

'myx           long $82FF1012, $F4FF0AFD, $43A18800, $7CBF20EB, $B03090F6, $188DA80E
'myy           long $1E794811, $73F977A1, $6B24CDD5, $631011ED, $FFC8DA78, $07192B95
myx           long $0628A2AA, $28094037, $4D22B652, $1844F716, $EB76324F, $1C995995
myy           long $1AAA9C04, $B34CB861, $00FA77BD, $029F5564, $37E9EB73, $EF1765CE


testval192      long    $03fff07f, $01fff000, $fe0007c0, $fc0003ff, $fffe01ff, $41ffc1ff
testv192        long    $5eed0e13, $018ebbb9, $00000000, $00000000, $00000000, $00000000

testval224	long    $fe0007c0, $03fff07f, $01fff000, $fe0007c0, $fc0003ff, $fffe01ff, $41ffc1ff
testv224	long    $5eed0e13, $018ebbb9, $00000000, $00000000, $00000000, $00000000, $00000000

testval256      long    $00000003, $fe0007c0, $03fff07f, $01fff000, $fe0007c0, $fc0003ff, $fffe01ff, $41ffc1ff
testv256        long    $5eed0e13, $018ebbb9, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000

testval384      long    $fffe0000, $fffff800, $7fff8007, $ffffff80, $00000003, $fe0007c0, $03fff07f, $01fff000
                long    $fe0007c0, $fc0003ff,$fffe01ff, $41ffc1ff
testv384        long    $5eed0e13, $018ebbb9, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000
                long    $00000000, $00000000, $00000000, $00000000
testval521      long    $ffcfffff, $3803ffff, $40000000, $001c0000, $fc000000, $fff001ff, $ff000fff, $ffff00ff
                long    $000007ff, $000f8000, $ffe0fffc, $ffe00007, $000f8003, $0007fffc, $fc03fff8, $ff83ffff
                long    $083
testv521        long    $5eed0e13, $018ebbb9, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000
                long    $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000
                long    $000

hex             byte    $30, $31, $32, $33, $34, $35, $36, $37, $38, $39, $41, $42, $43, $44, $45, $46

