{{ Nitendo Controller Object
  Version:  2.0
  Date: 25 Aug 2006
  Author: John Abshier
  Support:  Propeller forum http://forums.parallax.com
  Revision history:  Version 1.0 origingal NES only
                     Version 2.0 supports NES and SuperNES   }}
   
Con
   NES      = 1
   SuperNES = 2
   UP           = 65519
   DOWN         = 65503
   RIGHT        = 65407
   LEFT         = 65471
   SELECT       = 65531
   START        = 65527
   A            = 65279 
   B            = 65534
   X            = 65023         ' Super NES only
   Y            = 65533         ' Super NES only
   Lshoulder    = 64511         ' Super NES only
   Rshoulder    = 63487         ' Super NES only
OBJ

VAR
  long latch, data, clk, type, bits
PUB Init(l, d, c)   | tmp
{{  Initializes pin assignments and sets intial directions and pin values
    Arguments:
      l -- latch pin, orange wire
      d -- data pin, red wire
      c -- clock pin, yellow wire
    Return value:  false (0) if no controller is attached
                   otherwise the status of buttons            }}
  latch := l
  data := d
  clk := c
  type := 0                     ' type is unknown at present
  bits := 16                    ' get all bits for init
  dira[LATCH]~~                 ' LATCH to output
  dira[CLK]~~                   ' CLK to output
  dira[DATA]~                   ' Data to input                                                            
  outa[LATCH]~~                 ' high LATCH
  tmp := buttons
  if tmp == 0
    return false
  elseif tmp == 255
    type := NES
    bits := 8                   ' only need 8 bits for NES controller
    return type
  else
    type := SuperNES
    return type    

PUB buttons : btns | InBit
{{ Reads and returns the status of pressed buttons
   Arguments:  None
   Return value:  The status of the buttons.  If more than one button is pressed
                  the return value is the and of all buttons pressed
                  UP           = 239
                  DOWN         = 223
                  RIGHT        = 127
                  LEFT         = 191
                  SELECT       = 251
                  START        = 247
                  A            = 254
                  B            = 253
   shiftin courtesy Martin Hebel's BS2 Functions               }}
                  
    outa[LATCH]~                                         ' low LATCH  
    outa[CLK]~                                          ' Set clock low 
    btns:=0                                                                                   
      REPEAT bits                                         ' for number of bits                   
        InBit:= ina[DATA]                                ' get bit value                        
        btns := (btns >> 1) + (InBit << (bits-1))      ' Add to  value shifted by position    
        !outa[CLK]                                      ' cycle clock                          
        !outa[CLK]                                                                             
        waitcnt(500  + cnt)                 ' time delay
    outa[LATCH]~~               ' high LATCH
    if type == NES
      btns |= 65280
      if (btns | $FFFE) == $FFFE      ' A   last bit is 0 
         btns |= 1                ' set last bit to 1    
         btns &= 65279              ' set bit 9 to 0   
      if (btns | $FFFD) == $FFFD    ' B
        btns &= $fffe               ' set last bit 0
        btns |= 2                 ' set next to last to 1
PUB BtnPressed(WhichOne)
{{ Checks if a button or buttons are pressed.  Use the constants defined above.
   To check if more than one button is pressed simultaneously and the value.
   Example BtnPressed(NES#UP & NES#A)
   Arguments:  Buttons to check
   Return value:  true or false                                          }}
  if WhichOne == buttons
    return true
  else
    return false