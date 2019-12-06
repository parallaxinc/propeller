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
   fHartley = Display#sFix + 20<<16 + 2<<8 + 10

   
VAR

  long H [NH]
  word Q [NQ]
  word s 


PUB Demo | i,j,t

  s:= i:= j:= t:= 0

  Display.Init                            'TTABCD
  Hartley.Init( @H+NH<<16, @Q+NQ<<16, @s, $1B0B12 )

  Display.LfStr(string("Brackwell S. 62 Tab. 4.2 DHT2"))
  Display.LfStr(string("[1024  873  495   72"))
  Display.LfStr(string(" -205 -242  -85  116"))
  Display.LfStr(string("  205  116  -85 -242"))
  Display.LfStr(string(" -205   72  495  873]"))

                                '     We
  q[ 0] :=  1024                ' 204.81
  q[ 1] :=   873                ' 204.89
  q[ 2] :=   495                ' 204.88
  q[ 3] :=    72                '  -0.13
  q[ 4] :=  -205                '  -0.06
  q[ 5] :=  -242                '  -0.03
  q[ 6] :=   -85                '  -0.00
  q[ 7] :=   116                '   0.01  
  q[ 8] :=   205                '   0.06
  q[ 9] :=   116                '   0.01
  q[10] :=   -85                '  -0.00  
  q[11] :=  -242                '  -0.03
  q[12] :=  -205                '  -0.06
  q[13] :=    72                '  -0.13
  q[14] :=   495                ' 204.88
  q[15] :=   873                ' 204.90

  
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
    Display.Pix(i*16,96 + ~~Q[i]~>6)                  'Meßwert
    Display.Pen(1)
    Display.Pix(i*16,48)
    Display.Lin(0,Hartley.We(i)~>23 )                 'Hartleywert
    Display.Pix(i*16+1,48)
    Display.Lin(0,Hartley.We(i)~>23 )

    