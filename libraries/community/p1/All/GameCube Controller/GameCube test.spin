CON

  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000


OBJ

  text : "tv_text"
  gc    : "GameCube_v1.2"
  
var
  long addr
PUB start | i
  gc.start(0)
  'start term
  text.start(12)
  
  
  repeat
    text.str(string($A,1,$B,1))
    text.str(string("A B X Y Z L R Start Up Down Left Right"))
    text.str(string($A,1,$B,2))
    text.bin(gc.A, 1)
    text.out(" ")
    text.bin(gc.B, 1)
    text.out(" ")
    text.bin(gc.X, 1)
    text.out(" ")
    text.bin(gc.Y, 1)
    text.out(" ")
    text.bin(gc.Z, 1)
    text.out(" ")
    text.bin(gc.L, 1)
    text.out(" ")
    text.bin(gc.R, 1)

    text.str(string(" "))
    text.bin(gc.ST, 1)

    text.str(string("     "))
    text.bin(gc.Up, 1)

    text.str(string("  "))
    text.bin(gc.Down, 1)

    text.str(string("    "))
    text.bin(gc.Left, 1)

    text.str(string("    "))
    text.bin(gc.Right, 1)

    text.str(string($A,1,$B,4))
    text.str(string("JoyX JoyY CX CY Ltrig Rtrig"))
    text.str(string($A,1,$B,5))

    text.out(" ")
    text.hex(gc.JoyX, 2)

    text.str(string("   "))
    text.hex(gc.JoyY, 2)

    text.str(string("  "))
    text.hex(gc.CX, 2)

    text.out(" ")
    text.hex(gc.CY, 2)

    text.str(string("  "))
    text.hex(gc.LAnalog, 2)

    text.str(string("    "))
    text.hex(gc.RAnalog, 2) 