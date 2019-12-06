''PID Demo
''Displays Current Point, Set Point, and PID Output in BS2 Debug terminal set for 38400 baud, 8 bit, No parity
''Set the Set point via changing the variable in the code and using the Debug Input.  Enter the new Set Point and press Enter.
''9-25-07
''crgwbr
VAR

long CP     'PID Current Point
long SP     'PID Set Point
long Gain   'PID Gain
long IT     'PID Integral Time
long output 'PID Output
long mode   'PID Mode
long stack[20]

long pot1
long pot2

CON

_clkmode = xtal1 + pll16x
_xinfreq = 5_000_000

OBJ

PID    : "PID"
Serial : "Extended_FDSerial"

PUB Main | count

Serial.start(31, 30, %0000, 38400) 'Display Data in Basic Stamp Debug Terminal

Serial.Str(string("***********************"))
Serial.tx(13)
Serial.Str(string("Prop PID Demo"))
Serial.tx(13)
Serial.Str(string("***********************"))
repeat 2
  Serial.tx(13)

waitcnt(80_000_000 + cnt)


CP := 50
SP := 50
Gain := 10
IT := 1

PID.Start(@CP, @SP, Gain, IT, @output)

serial.tx(0)

cognew(Get_Set_Point, @stack)

repeat

  count := count + 1
  Serial.tx(0)
  Serial.str(string("Loop Number: "))
  Serial.DEC(count)
  Serial.tx(13)
  
  Serial.str(string("Current Point: "))
  Serial.DEC(CP)
  Serial.tx(13)

  Serial.str(string("Set Point: "))
  Serial.DEC(SP)
  Serial.tx(13)

  Serial.str(string("PID Output: "))
  Serial.DEC(output)

  waitcnt(20_000_000 + cnt)

PUB Get_Set_Point

repeat
  SP := Serial.rxDec
  