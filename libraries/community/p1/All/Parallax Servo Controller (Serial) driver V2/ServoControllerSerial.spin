{{ ServoControllerSerial.spin, v2.0
   Copyright (c) 2009 Austin Bowen
   *See end of file for terms of use*

   Allows the control of up to 2 Parallax Servo Controllers (serial)
   See the subroutines below for info on how to use them.
   
   It's easy to include the object:

   OBJ
     PSC : "ServoControllerSerial"
   
   CON
     _CLKMODE = XTAL1 + PLL16X
     _XINFREQ = 5_000_000
    
     COMPIN   = 0               'Pin used for communication with the PSC
     PSC_BAUD = 0               'Baud rate (0 - 2400, 1 - 38400)
                
   PUB MAIN
     PSC.START(COMPIN, PSC_BAUD)
}}

VAR
  BYTE DATAIN[4]                'Data input buffer
  LONG COMPIN, BAUD             'Communication pin

CON                   
  US      = 1_000_000
  CNT_MIN = 396

PUB START (_COMPIN, _BAUD)
{{ Saves the Communication Pin and sets the baud rate
    *NOTE* The RX subroutine can only receive at 2400 baud. Subroutines that receive
      information from the PSC (GETPOS and GETVER) will temporarilly switch to 2400 baud
      if the PSC is set to 38400, and switch back when it's done. Since this process is slow,
      I would only recommend 38400 baud if you plan on setting positions rapidly.
}}
  IF (CLKFREQ <> 80_000_000)
    RETURN
  COMPIN := _COMPIN #> 0 <# 31
  _BAUD := _BAUD #> 0 <# 1  
  IF (SETBAUD(-1) <> _BAUD)
    SETBAUD(_BAUD)       
  RETURN GETVER(0)
  
PUB SETPOS (CHANNEL, RAMP, POSITION)
{{ Set the ramp rate and position of a servo channel }}
  TX_STR(STRING("!SC"))
  TX(CHANNEL)
  TX(RAMP)
  TX(POSITION.BYTE[0])       
  TX(POSITION.BYTE[1])
  TX(13)

PUB GETPOS (CHANNEL) | _BAUD
{{ Returns the positional value of the specified servo channel in decimal form }}  
  IF (_BAUD := BAUD)
    SETBAUD(0)
  TX_STR(STRING("!SCRSP"))
  TX(CHANNEL)
  TX(13)
  RX_STR(0)                            
  IF (BAUD <> _BAUD)
    SETBAUD(_BAUD)
  RETURN (DATAIN[1] << 8) + DATAIN[2]  
  
PUB SETBAUD (_BAUD)
{{ Sets the baud rate to either 2400 or 38400, or returns the current baud rate
   _BAUD: 1 sets baud to 38400, 0 sets baud to 2400, -1 returns the current baud rate
   *NOTE* The RX subroutine can only receive at 2400 baud. Subroutines that receive
     information from the PSC (GETPOS and GETVER) will temporarilly switch to 2400 baud
     if it's already set to 38400, and switch back when it's done. I would only recommend
     38400 baud if you plan on setting positions rapidly.
}}          
  IF (_BAUD == -1)
    RESULT := BAUD~
    TX_STR(STRING("!SCVER?", 13))
    _BAUD := RX
    IF (_BAUD < "0") OR (_BAUD > "9")  
      RESULT := BAUD := 1
  ELSE
    TX_STR(STRING("!SCSBR"))
    TX(_BAUD)
    TX(13)
    BAUD := _BAUD           
  WAITCNT(CLKFREQ/15+CNT)
  
PUB GETVER (STRPTR) | _BAUD
{{ Returns the current firmware version number of the PSC as a 3-byte string,
   and if given, saves the version number in your own string, ex: GETVER(@MYSTR) }}  
  IF (_BAUD := BAUD)
    SETBAUD(0)
  TX_STR(STRING("!SCVER?", 13))         
  RESULT := RX_STR(STRPTR)          
  IF (BAUD <> _BAUD)
    SETBAUD(_BAUD)               

PUB TX (CHAR) | BR, BITS
{{ Transmit a single byte to the PSC }}
  BR := CLKFREQ/2400-1700 #> CNT_MIN    
  IF BAUD
    BR := CLKFREQ/38400-1700 #> CNT_MIN    
  CHAR := ((1 << 8)+CHAR) << 2                          'Set up string with start & stop bit
  DIRA[COMPIN]~~                                        'Set as output         
  REPEAT 10                                             'Send each bit based on baud rate 
    WAITCNT(BR+CNT)   
    OUTA[COMPIN] := (CHAR >>= 1)                                              

PUB TX_STR (STRINGPTR)
{{ Transmit a string of characters to the PSC }}
  REPEAT STRSIZE(STRINGPTR)
    TX(BYTE[STRINGPTR++])                               'Send each character in string     

PUB RX | X, TIMER
{{ Receives a single byte from the PSC, does not lock up }}                                            
  DIRA[COMPIN]~                                         'Set as input    
  TIMER := CNT                                          
  REPEAT UNTIL INA[COMPIN] OR ((CNT-TIMER)/(CLKFREQ/10) => 1) 'Wait for idle  
  TIMER := CNT
  REPEAT UNTIL NOT INA[COMPIN] OR ((CNT-TIMER)/(CLKFREQ/10) => 1) 'Wait for start bit  
  WAITCNT(CLKFREQ/US*417*100/90+CNT)                    'Pause to be centered in 1st bit time
  RESULT := INA[COMPIN]                                 'Read LSB 
  REPEAT X FROM 1 TO 7                                  
    WAITCNT(CLKFREQ/US*347+CNT)                         'Wait until center of next bit
    RESULT := RESULT | (INA[COMPIN] << X)               'Read next bit, shift and store  
   
PUB RX_STR (STRPTR) | X
{{ Receives a string of characters from the PSC and returns the address of the buffer used in this object
    PSC.RX_STR(@DATAIN)
    PRINT_STR(@DATAIN)
      -or-
    PRINT_STR(PSC.RX_STR(0))
}}                                      
  BYTEFILL((RESULT := @DATAIN), 0, 4)                   'Fill string memory with 0's (null)
  REPEAT X FROM 0 TO 2                                  'Receive all 3 bytes
    DATAIN[X] := RX                                                                     
  IF STRPTR                                             'Move to STRPTR if given
    BYTEMOVE(STRPTR, @DATAIN, 3)  

    
{{Permission is hereby granted, free of charge, to any person obtaining a copy of this software
  and associated documentation files (the "Software"), to deal in the Software without restriction,
  including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
  and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,
  subject to the following conditions: 
   
  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. 
   
  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
  PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
  FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
  ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
}}