{{ 20.09.2013 

}}


OBJ
  Display: "Display"
  Hartley: "Hartley"
  

CON

  _CLKMODE = XTAL1 + PLL16x
  _XINFREQ = 6144000


CON

   NH = 16
   NQ = 16

   fTakt    = Display#uInt          + 2<<8
   fHartley = Display#sFix + 26<<16 + 3<<8 + 10

   
VAR

  long H [NH]
  word Q [NQ]
  word s 


PUB Demo | i,j,t

' Initialisierungen
 
  s:= i:= j:= t:= 0

  Display.Init
                                          'TTABCD
  Hartley.Init( @H+NH<<16, @Q+NQ<<16, @s, $1B0512 )

  Display.LfStr(string("Brackwell S. 59 Tab. 4.1"))
  Display.LfStr(string("[20 15  6  1  0  0  0  0"))
  Display.LfStr(string("  0  0  0  0  0  1  6 15]"))


  q[ 0] := 20                   '4.000
  q[ 1] := 15                   '3.560
  q[ 2] :=  6                   '2.487
  q[ 3] :=  1                   '1.322
  q[ 4] :=  0                   '0.500
  q[ 5] :=  0                   '0.118
  q[ 6] :=  0                   '0.013
  q[ 7] :=  0                   '0.000
  q[ 8] :=  0                   '0.000
  q[ 9] :=  0                   '0.000
  q[10] :=  0                   '0.013
  q[11] :=  0                   '0.118
  q[12] :=  0                   '0.500
  q[13] :=  1                   '1.322
  q[14] :=  6                   '2.487
  q[15] := 15                   '3.560


' Anzeige Prozessortakt und Rechenzeit

 
  Display.Lf
  Display.LfDec(clkfreq/100000,fTakt)
  Display.Str(string(" MHz: "))
  i:= cnt
  Hartley.Trig
  Hartley.Wait
  j:= cnt
  t:= (j-i)/(clkfreq/1000000)
  Display.Dec(t,Display#uInt)
  Display.Str(string(" µs"))
  Display.LfStr(string("80.0 MHz: "))
  t:= t*(clkfreq/10000)/8000
  Display.Dec(t,Display#uInt)
  Display.Str(string(" µs"))


' Anzeigen der Hartley-Transformierten


  Display.Wait(3)
  Display.Lf
  
  repeat i from 0 to 15
    Display.LfStr(string("Wert#"))
    Display.Dec(i,3)
    Display.Chr(":")
    Display.Dec(Hartley.We(i),fHartley)

  Display.Wait(3)
  Display.Ff
  
  repeat i from 0 to 255
    Display.Pen(3)
    Display.Pix(i*16,64 + ~~Q[i])                     'Meßwert
    Display.Pen(1)
    Display.Pix(i*16,32)
    Display.Lin(0,Hartley.We(i)~>23 )                 'Hartleywert
    Display.Pix(i*16+1,32)
    Display.Lin(0,Hartley.We(i)~>23 )

        