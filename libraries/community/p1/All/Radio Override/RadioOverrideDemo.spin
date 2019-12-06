{{
by mkb (spiritplumber@gmail.com) based on code by Rich Harman.
servo pulse reader to be used for mixing or overriding a radio in

requires an extra cog; replaces the multiplexer in navcom ai circuits.


}}
CON
  _clkmode = xtal1 + pll8x ' lowest rating 40mhz
  _xinfreq = 5_000_000

DAT
  pins    LONG 0, 1, 2, 3     ' radio is connected here
  outpins LONG 4, 5, 6, 7     ' servos are connected here
  pulsewidth LONG 1000,1000,1000,1000 ' doesn't actually need initialized to anything
  defaults LONG 1500,1500,1000,1500

OBJ
  com        : "FullDuplexSerial"
  'com2        : "FullDuplexSerial"
  radio            :"radio_override"
   
PUB Init | v,d

d:=10

' note that radio will fetch defaults, so just change them in your autonomous routine
radio.start(4, @pins,@pulsewidth,@outpins,@defaults,800,2200) ' the upper and lower limits are used with single-conversion radios to determine if the radio is on or off

com.start(31,30,0,9600)
'com2.start(9,8,0,9600)
radio.mode(radio#MIX) ' #radio #prog #override #mix
repeat

  ' this is just to have the servos do somehting in autonomous mode
  v~
  repeat 4
    defaults[v] += d
    if defaults[v] > 2100
       d := -10
    if defaults[v] < 900
       d := 10
    v++
  
  ' eh, talk to me
  com.dec(pulsewidth[0])
  com.tx(":")
  com.dec(pulsewidth[1])
  com.tx(":")
  com.dec(pulsewidth[2])
  com.tx(":")
  com.dec(pulsewidth[3])
  com.tx(":")
  com.dec(radio.valid)
    com.tx(13)

