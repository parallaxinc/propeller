CON
  _xinfreq = 5_000_000
  _clkmode = xtal1 + pll16x 

OBJ
  pst  : "Parallax serial Terminal"

var
  byte initialized
  
pub init
    pst.Start(115_200)
  
pub print (lable, val)
   pst.Str(lable)
   pst.dec(val)
   pst.newline

pub print2(lable1, val1, lable2, val2)
   pst.Str(lable1)
   pst.dec(val1)
   pst.Str(string(" | "))
   pst.Str(lable2)
   pst.dec(val2)
   pst.newline
pub print3Dec(val1, val2, val3)
    pst.dec(val1)
    pst.Str(string(" | "))
    pst.dec(val2)
    pst.Str(string(" | "))
    pst.dec(val3)
    pst.newline    