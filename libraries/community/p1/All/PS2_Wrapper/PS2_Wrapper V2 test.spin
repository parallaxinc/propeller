{{ PS2_Wrapper test}}
CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000
OBJ
PS2 : "PS2_Wrapper"
PST: "Parallax Serial Terminal"
PUB start
 PS2.init(0,1000)
 PST.start(19200)
 repeat
        PST.Dec(PS2.X)
        PST.Dec(PS2.square)
        PST.Dec(PS2.circle)
        PST.Dec(PS2.triangle)
        PST.Char(" ")
        PST.Dec(PS2.R1)
        PST.Dec(PS2.L1)
        PST.Dec(PS2.R2)
        PST.Dec(PS2.L2)
        PST.Char(" ")
        PST.Dec(PS2.D_left)
        PST.Dec(PS2.D_down)
        PST.Dec(PS2.D_right)
        PST.Dec(PS2.D_up)
        PST.Char(" ")
        PST.Dec(PS2.start)
        PST.Dec(PS2.select)
        PST.Dec(PS2.L3)
        PST.Dec(PS2.R3)
        PST.Char(" ")
        PST.Hex(PS2.mode,2)
        PST.Char(" ")
        PST.Hex(PS2.id,2)
        PST.Char(" ")
        PST.Dec(PS2.LeftX)
        PST.Char(" ")
        PST.Dec(PS2.LeftY)
        PST.Char(" ")
        PST.Dec(PS2.RightX)
        PST.Char(" ")
        PST.Dec(PS2.RightY)
        PST.NewLine