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

  s:= i:= j:= t:= 0

  Display.Init                            'TTABCD
  Hartley.Init( @H+NH<<16, @Q+NQ<<16, @s, $1B0112 )


  Display.LfStr(string("Brackwell S. 62 Tab. 4.2 f1"))
  Display.LfStr(string("[0000111100000000]"))


  q[ 0] :=  0                   ' 1.000 normiert auf 1                            
  q[ 1] :=  0                   ' 0.250
  q[ 2] :=  0                   '-0.854
  q[ 3] :=  0                   ' 0.374
  q[ 4] :=  1                   ' 0.000
  q[ 5] :=  1                   ' 0.250
  q[ 6] :=  1                   '-0.354
  q[ 7] :=  1                   ' 0.050
  q[ 8] :=  0                   ' 0.000
  q[ 9] :=  0                   ' 0.250
  q[10] :=  0                   '-0.146
  q[11] :=  0                   '-0.167
  q[12] :=  0                   ' 0.000
  q[13] :=  0                   ' 0.250
  q[14] :=  0                   '-0.354
  q[15] :=  0                   '-1.257


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
    Display.Dec(Hartley.We(i)/4,fHartley)


  Display.Wait(3)
  Display.Ff
  
  repeat i from 0 to 255
    Display.Pen(3)
    Display.Pix(i*16,96 + ~~Q[i]<<4)                  'Meßwert
    Display.Pen(1)
    Display.Pix(i*16,48)
    Display.Lin(0,Hartley.We(i)~>23 )                 'Hartleywert
    Display.Pix(i*16+1,48)
    Display.Lin(0,Hartley.We(i)~>23 )

    