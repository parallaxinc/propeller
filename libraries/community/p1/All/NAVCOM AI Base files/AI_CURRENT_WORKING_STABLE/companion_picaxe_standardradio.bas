symbol INPIN = pin3 ' digital in
symbol BATTPIN1 = 1 ' battery
symbol BATTPIN2 = 2 ' battery 
symbol PROPOUT = 0  ' so use sertxd. Alternative: just flip the line
symbol MUXOUT = 4   ' line to the mux that DOES get flipped either way

symbol CENTER = 300 ' of a servo pulse (150*2)
symbol SWING = 120  ' of a servo pulse (50*2 plus a bit of leeway)
symbol SMIN = CENTER - SWING
symbol SMAX = CENTER + SWING

symbol SIGQUAL = 4 ' quality needed to flip from AI to RC

#define USEPULSIN = 1  ' bypass pulsin and run bitbang instead


setfreq m8
low MUXOUT
wait 1
b12 = $30
b0 = 0
b11 = "R"


mainloop:

sertxd("$PW,",b11,",",#w1,",",#w2,",",#b1,"*",13,10)

' first read batteries, one at a time
if b0 = 1 then 
	readadc BATTPIN2, b13
	readadc BATTPIN2, b13
	readadc10 BATTPIN2, w1
	b0 = 0
else
	readadc BATTPIN1, b13
	readadc BATTPIN1, b13
	readadc10 BATTPIN2, w2
	b0 = 1
endif


readpulse:
b12 = 0 ' ascii zero, less overhead for printout above
for b13 = 0 to 5 ' signal qual is generally expressed in fifths anyway

  #ifdef USEPULSIN
  ' method 1: pulsin (more precise)
  pulsin 3,1,w3
  
  #else
  ' method 2: bitbang it (faster), no for loop because this is more deterministic
  ' we are at 4000 ips and this is 2 statements per line, so 40 lines should cover 20msecs.
  b1 = pin3
  b1 = b1 + pin3
  b1 = b1 + pin3
  b1 = b1 + pin3
  b1 = b1 + pin3
  b1 = b1 + pin3
  b1 = b1 + pin3
  b1 = b1 + pin3
  b1 = b1 + pin3
  b1 = b1 + pin3
  b1 = b1 + pin3
  b1 = b1 + pin3
  b1 = b1 + pin3
  b1 = b1 + pin3
  b1 = b1 + pin3
  b1 = b1 + pin3
  b1 = b1 + pin3
  b1 = b1 + pin3
  b1 = b1 + pin3
  b1 = b1 + pin3
  b1 = b1 + pin3
  b1 = b1 + pin3
  b1 = b1 + pin3
  b1 = b1 + pin3
  b1 = b1 + pin3
  b1 = b1 + pin3
  b1 = b1 + pin3
  b1 = b1 + pin3
  b1 = b1 + pin3
  b1 = b1 + pin3
  b1 = b1 + pin3
  b1 = b1 + pin3
  b1 = b1 + pin3
  b1 = b1 + pin3
  b1 = b1 + pin3
  b1 = b1 + pin3
  b1 = b1 + pin3
  b1 = b1 + pin3
  b1 = b1 + pin3
  b1 = b1 + pin3
  w3 = b1 * 180 ' to keep the math consistent: this will probably need changing!
  #endif
  
  if w3 = 0 then goto nosignal ' just quit if we're not getting anything at all
  if w3 > SMIN and w3 < SMAX then  ' otherwise, see how good the signal is
     inc b12
  endif
next b13


if b12 = 0 then goto crappysignal
if b12 => SIGQUAL then goto signal

crappysignal:
b11 = "L"    ' tells the AI that we may be getting a rc xmit, but it's weak
high MUXOUT ' AI control
goto mainloop

signal:
b11 = "R"
low MUXOUT  ' RC control
goto mainloop

nosignal:
b11 = "A"
high MUXOUT ' AI control
goto mainloop





