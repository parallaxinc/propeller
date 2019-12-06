CON

  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000


OBJ

  text : "tv_text"
  N64    : "N64_v1.2"
  
var
  long addr
PUB start 
  N64.start(0)
  text.start(12)
  
  
  repeat
    text.str(string($A,1,$B,1))
    text.str(string("A B L R Z Start Up Down Left Right"))
    text.str(string($A,1,$B,2))
    text.bin(N64.A, 1)
    text.out(" ")
    text.bin(N64.B, 1)
    text.out(" ")
    text.bin(N64.L, 1)
    text.out(" ")
    text.bin(N64.R, 1)
    text.out(" ")
    text.bin(N64.Z, 1)
    text.str(string("   "))
    text.bin(N64.ST, 1)
    text.str(string("   "))
    text.bin(N64.DU, 1)
    text.str(string("  "))
    text.bin(N64.DD, 1)
    text.str(string("    "))
    text.bin(N64.DL, 1)
    text.str(string("    "))
    text.bin(N64.DR, 1)

    text.str(string($A,1,$B,4))
    text.str(string("JoyX JoyXu JoyY JoyYu CU CD CL CR"))
    text.str(string($A,2,$B,5))
    text.hex(N64.JoyX, 2)
    text.str(string("   "))
    text.hex(N64.JoyXu, 2)
    text.str(string("    "))
    text.hex(N64.JoyY, 2)
    text.str(string("   "))
    text.hex(N64.JoyYu, 2)
    text.str(string("   "))
    text.bin(N64.CU, 1)
    text.str(string("  "))
    text.bin(N64.CD, 1)
    text.str(string("  "))
    text.bin(N64.CL, 1)
    text.str(string("  "))
    text.bin(N64.CR, 1)