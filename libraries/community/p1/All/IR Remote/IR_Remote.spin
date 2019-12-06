{{
      IR_Remote_NewCog.spin
      Tom Doyle
      2 March 2007

      Panasonic IR Receiver - Parallax #350-00014

      Receive and display codes sent from a Sony TV remote control.
      See "Infrared Decoding and Detection appnote" and "IR Remote for the Boe-Bot Book v1.1"
      on Parallax website for additional info on TV remotes.

      The procedure uses counter A to measure the pulse width of the signals received
      by the Panasonic IR Receiver. The procedure waits for a start pulse and then decodes the
      next 12 bits. The entire 12 bit result is returned. The lower 7 bits contain the actual
      key code. The upper 5 bits contain the device information (TV, VCR etc.) and are masked off
      for the display.

      Most TV Remotes send the code over and over again as long as the key is pressed.
      This allows auto repeat for TV operations like increasing volume. The volume continues to
      increase as long as you hold the 'volume up' key down. Even if the key is pressed for a
      very short time there is often more than one code sent. The best way to eliminate the
      auto key repeat is to look for an idle gap in the IR receiver output. There is a period of
      idle time (20-30 ms) between packets. The getSonyCode procedure will wait for an idle period
      controlled by the gapMin constant. This value can be adjusted to eliminate auto repeat
      while maintaining a fast response to a new keypress. If auto repeat is desired the indicated
      section of code at the start of the getSonyCode procedure can be commented out.

      The procedure sets a tolerance for the width of the start bit and the logic level 1 bit to
      allow for variation in the pulse widths sent out by different remotes. It is assumed that a
      bit is 0 if it is not a 1.

      The procedure to read the keycode ( getSonyCode ) is run in a separate cog. This allows
      the main program loop to continue without waiting for a key to be pressed. The getSonyCode
      procedure writes the NoNewCode value (255) into the keycode variable in main memory to
      indicate that no new keycode is available. When a keycode is received it writes the keycode
      into the main memory variable and terminates. With only 8 cogs available it seems to be a
      good idea to free up cogs rather than let them run forever. The main program can fire off
      the procedure if and when it is interested in a new keycode.
        
}}


CON

  _CLKMODE = XTAL1 + PLL16X        ' 80 Mhz clock
  _XINFREQ = 5_000_000

  NoNewCode    =  255               ' indicates no new keycode received

  gapMin       =   2000             ' minimum idle gap - adjust to eliminate auto repeat
  startBitMin  =   2000             ' minimum length of start bit in us (2400 us reference)
  startBitMax  =   2800             ' maximum length of start bit in us (2400 us reference)
  oneBitMin    =   1000             ' minimum length of 1 (1200 us reference)
  oneBitMax    =   1400             ' maximum length of 1 (1200 us reference)

  ' Sony TV remote key codes
  ' these work for the remotes I tested however your mileage may vary
  
  one   =  0
  two   =  1
  three =  2
  four  =  3
  five  =  4
  six   =  5
  seven =  6
  eight =  7
  nine  =  8
  zero  =  9

  chUp  = 16
  chDn  = 17
  volUp = 18
  volDn = 19
  mute  = 20
  power = 21
  last  = 59


VAR

  byte  cog
  long  Stack[20]  


PUB Start(Pin, addrMainCode) : result
{{
   Pin - propeller pin connected to IR receiver
   addrMainCode - address of keycode variable in main memory
}}

    stop
    byte[addrMainCode] := NoNewCode
    cog := cognew(getSonycode(Pin, addrMainCode), @Stack) + 1
    result := cog


PUB Stop
{{
   stop cog if in use
}}

    if cog
      cogstop(cog~ -1)

    
PUB getSonyCode(pin, addrMainCode) | irCode, index, pulseWidth, lockID

{{
   Decode the Sony TV Remote key code from pulses received by the IR receiver
}}

   ' wait for idle period (ir receiver output = 1 for gapMin)
   ' comment out "auto repeat" code if auto key repeat is desired
   
   ' start of "auto repeat" code section
   dira[pin]~
   index := 0
   repeat
     if ina[Pin] == 1
       index++
     else
       index := 0
   while index < gapMin
   ' end of "auto repeat" code section

   frqa := 1
   ctra := 0
   dira[pin]~
   
   ' wait for a start pulse ( width > startBitMin and < startBitMax  )
   repeat      
      ctra := (%10101 << 26 ) | (PIN)                      ' accumulate while A = 0  
      waitpne(0 << pin, |< Pin, 0)                         
      phsa:=0                                              ' zero width
      waitpeq(0 << pin, |< Pin, 0)                         ' start counting
      waitpne(0 << pin, |< Pin, 0)                         ' stop counting                                               
      pulseWidth := phsa  / (clkfreq / 1_000_000) + 1    
   while ((pulseWidth < startBitMin) OR (pulseWidth > startBitMax))

   ' read in next 12 bits
   index := 0
   irCode := 0
   repeat
      ctra := (%10101 << 26 ) | (PIN)                      ' accumulate while A = 0  
      waitpne(0 << pin, |< Pin, 0)                         
      phsa:=0                                              ' zero width
      waitpeq(0 << pin, |< Pin, 0)                         ' start counting
      waitpne(0 << pin, |< Pin, 0)                         ' stop counting                                               
      pulseWidth := phsa  / (clkfreq / 1_000_000) + 1
      
    if (pulseWidth > oneBitMin) AND (pulseWidth < oneBitMax)
       irCode := irCode + (1 << index)
    index++
   while index < 11

   irCode := irCode & $7f                                   ' mask off upper 5 bits

   byte[addrMainCode] := irCode