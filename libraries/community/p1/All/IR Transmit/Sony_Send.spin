{{

      Sony_Send.spin
      Tom Doyle
      9 March 2007

      Use counter A to send a Sony remote keycode to an IR led.
      The counter is used in NCO mode and is turned on and off
      by changing ctra. 

      The Sony standard is used
      
         12 data bits
         25 mS gap between messages
         2.4 mS start bit
         1.2 mS data bit 1
         0.6 mS data bit 0
         0.6 mS gap between bits
     
}}
      

CON

  _CLKMODE = XTAL1 + PLL16X        ' 80 Mhz clock
  _XINFREQ = 5_000_000

  PNA4602M  =  38_000              ' IR Receiver Carrier Frequency


OBJ

  time      : "Timing"


PUB SendSonyCode(Pin, Code) | index

{{
   send Sony TV remote code
   Pin - pin connected to IR LED
   Code - decimal code for Sony tv remote
}}

  SynthFreq(Pin, PNA4602M) ' initialize counter A
  
  ' pause between messages
  ctra := 0
  time.pause1ms(25)

  ' start bit 2.4 mS
  ctra := %00100 << 26 | Pin
  time.pause10us(240)

  index := 0
  repeat
    if ((Code >> index) & 1)  == 1
      SendSonyBit(Pin, 1)
    else
      SendSonyBit(Pin, 0)
    index++
  while index < 12

  
PRI SendSonyBit(Pin, Bit) 

{{
   send a single bit to the IR led
   Pin - pin connected to IR led
   Bit - 1 or 0
}}

  ' gap between bits 0.6 mS
  ctra := 0
  time.pause10us(60)

  if Bit == 1                        ' 1.2 mS
    ctra := %00100 << 26 | Pin
    time.pause10us(120)
  else                               ' 0.6 mS
    ctra := %00100 << 26 | Pin
    time.pause10us(60)

  ctra := 0
        

PRI SynthFreq(Pin, Freq) | a, b, f

{{
   use counter A to generate a square wave
   Pin - pin connected to IR led
   Freq - frequency for counter (Freq < 500 kHz)
}}

  dira[Pin]~~                          ' output

  ctra := 0                            ' counter off till ready
   
  a := Freq <<= 1                      ' perform long division of a/b
  b := clkfreq
 
  repeat 32                            
    f <<= 1
    if a => b
      a -= b
      f++           
   a <<= 1
 
  ctra := %00100 << 26 | Pin            ' CTRA - NCO mode and PinA
  frqa := f                             'set FRQA                   
  dira[Pin]~~                           'make counter pin A output