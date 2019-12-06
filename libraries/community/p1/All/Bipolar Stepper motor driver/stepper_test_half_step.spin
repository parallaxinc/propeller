CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000
  Delay = 300_000

PUB Toggle
  dira[0..3]~~
  repeat
    outa[0..3] := 1
    waitcnt(Delay + cnt)
    outa[0..3] := 3
    waitcnt(Delay + cnt)
    outa[0..3] := 2
    waitcnt(Delay + cnt)
    outa[0..3] := 6
    waitcnt(Delay + cnt)
    outa[0..3] := 4
    waitcnt(Delay + cnt)
    outa[0..3] := 12
    waitcnt(Delay + cnt)
    outa[0..3] := 8
    waitcnt(Delay + cnt)
    outa[0..3] := 9
    waitcnt(Delay + cnt)

