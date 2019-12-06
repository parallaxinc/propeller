symbol INPIN = pin3 ' digital in
symbol BATTPIN1 = 1 ' battery
symbol BATTPIN2 = 2 ' battery 
symbol PROPOUT = 0  ' so use sertxd. Alternative: just flip the line
symbol MUXOUT = 4   ' line to the mux that DOES get flipped either way

symbol SMIN = 250
symbol SMAX = 350


setfreq m8
low MUXOUT
wait 1
b12 = $30
b0 = 0
b11 = "R"

mainloop:

sertxd("$PW,",b11,",",#w1,",",#w2,"*",13,10)

' first read batteries, one at a time
if b0 = 1 then 
	readadc BATTPIN1, b13
	readadc BATTPIN1, b13
	readadc10 BATTPIN1, w1
	b0 = 0
else
	readadc BATTPIN2, b13
	readadc BATTPIN2, b13
	readadc10 BATTPIN2, w2
	b0 = 1
endif


pulsin 3,1,w3

if w3 = 0 then ' no signal from radio
  b11 = "X"
  high MUXOUT
elseif w3 < SMIN then  ' otherwise, see how good the signal is
  b11 = "H"
  low MUXOUT ' RC control
elseif w3 > SMAX then
  b11 = "L"
  low MUXOUT ' RC control
else
  b11 = "A"
  high MUXOUT ' AI control
endif

goto mainloop








