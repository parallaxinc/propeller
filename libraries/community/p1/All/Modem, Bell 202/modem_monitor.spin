CON

  _clkmode      = xtal1 + pll8x     '<--------Change this line, as appropriate, for your Propeller setup.
  _xinfreq      = 10_000_000        '<--------Change this line, as appropriate, for your Propeller setup.

VAR

  byte  inpstr[5]

OBJ

  mdm   : "Bell202_modem"
  dbg   : "FullduplexSerial"        

PUB  Start | nstr, ch, param

  dbg.start(31, 30, 0, 38400)
  mdm.start_bp(0)                   '<--------Change this line, as appropriate, for your modem setup.
  mdm.receive
  nstr~
  waitcnt(cnt + clkfreq / 2)
  repeat
    if (mdm.inpchars)
      dbg.tx("?")
      dbg.tx(mdm.inp)
    dbg.tx("!")
    dbg.hex(mdm.signal, 8)
    dbg.tx(10)
    if ((ch := dbg.rxcheck) => 0)
      if (nstr and nstr < 5)
        inpstr[nstr++] := ch
        if (nstr == 5)
          mdm.set(inpstr[1], hex(inpstr[2]) << 28 | hex(inpstr[3]) << 24 | hex(inpstr[4]) << 20)
          nstr~
      elseif (ch == "!")
        nstr := 1

PRI hex(char)

  if ((char -= "0") > 9)
    char -= 7
  return char
    