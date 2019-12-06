{{ EmicDriverExtended.spin, v1.0
   Copyright (c) 2010 Austin Bowen
   *See end of file for terms of use*

   This is a driver for the Emic Text-to-Speech module.
     This program is completely self-contained, not requiring
     imported objects for communication. It also does not use
     an additional COG for operation. :) Check each subroutine
     below for the documentation on how to use it.

   This program assumes that both switches on the module are
     in the OFF position, for hexadecimal communication (faster)
     and no received echo on the Emic's TX pin. The system clock
     must be => 20MHz (If my calculations are correct.)


   The Emic is a +5V device, so proper protection for the Propeller
     is required:

     Direct connection for Sin:
     Sin <-- Prop

     10k resistor in series for Sout:
     Sout --> [10k] --> Prop

     10k resistor in series for Busy:
     Busy --> [10k] --> Prop

     Reset pulled high with 1k resistor,
     and connected to prop with diode:
              [1k] <-- +5V
               |
     Reset --> o --> [>Diode>] --> Prop


   For inclusion in a parent program:
   OBJ:
     EMIC : "EmicDriver"

   VAR
     BYTE EMIC_ABBR[50]         '(Optional)
     LONG EMIC_VER[4]           '(Optional)

   CON
     _CLKMODE   = XTAL1 + PLL16X
     _XINFREQ   = 5_000_000

     E_TX       = 0             '(Optional)
     E_RX       = 1
     E_BUSY     = 2
     E_RESET    = 3             '(Optional)

     VER_EH     = 0             'Stack number for Emic Hware (Optional)
     VER_ES     = 1             'Stack number for Emic Sware (Optional)
     VER_WH     = 2             'Stack number for WTS701 Hware (Optional)
     VER_WS     = 3             'Stack number for WTS701 Sware (Optional)

   PUB MAIN
     EMIC.START(E_TX, E_RX, E_BUSY, E_RESET)            'Start Emic
     EMIC.VERSION(@EMIC_VER)    '(Optional)             'Get versions

     EMIC.SAY(STRING("Hello, world!"), 2)               'Speak
     EMIC.STOP                                          'Done, stop Emic


   You'll probably use these subroutines the most:
     SAY
     SAY_VALUE
     VOLUME
     SPEED
     PITCH
}}

VAR
  LONG E_TX, E_RX, E_BUSY, E_RESET  'Pins
  LONG SET_V, SET_S, SET_P      'Volume/speed/pitch settings
  LONG SET_BACK[3]              'Settings backup stack
  LONG INITD                    'Initiation flag
  BYTE DATAIN[SIZE_DIN]         'RX'd data stack

CON
  'You can call any of these variables with the argument EMIC#XXX_X
  MAX_V     = 7                 'Max volume
  MAX_S     = 4                 'Max speed
  MAX_P     = 6                 'Max pitch

  DEF_V     = 4                 'Default volume
  DEF_S     = 2                 'Default speed
  DEF_P     = 1                 'Default pitch

  SIZE_DIN  = 101               'DATAIN stack sizes

PUB START (_E_TX, _E_RX, _E_BUSY, _E_RESET) | X
{{ Initiates the Emic driver. Returns TRUE if successful.

   The arguements represent the propeller pins connected to the
     respective Emic pins. If one is not used, give it a -1.

   Example:
     EMIC.START(0, 1, 2, -1)    'Not using the Emic's Reset pin
}}
  REPEAT X FROM 0 TO 3          'Make sure pins are in range!
    IF (_E_TX[X] < -1) OR (_E_TX[X] > 31)
      RETURN

  RESULT := INITD := TRUE       'About to be initiated
  LONGMOVE(@E_TX, @_E_TX, 4)    'Copy pins to local variables
  IF NOT RESET                  'Reset
    CLEAR
    SOFTRESET                   '^^
  SET_SAVE                      'Backup the current settings

PUB SAY (TEXT, WAITMODE)
{{ Gives the Emic the text string and optionally waits for completions.
   Returns TRUE if successful.

   "WAITMODE" modes:
     0 - Don't wait to complete converting text or speaking
     1 - Wait to complete converting text
     2 - Wait to complete converting text AND speaking

   Note: If the Emic is busy or the text string is too long,
           the subroutine will return.

   Example:
     EMIC.SAY(STRING("Hello, world!"), 2)
}}
  IF INA[E_BUSY] OR NOT INITD   'Failsafe
    RETURN

  RESULT~~
  IF (STRSIZE(@TEXT) => 128)    'Make sure text size isn't > Emic's buffer
    TEXT := STRING("Text too long")
    RESULT~                     '^^

  TX($00)                       'Issue commands
  TX_STR(TEXT)
  TX($AA)                       '^^

  CASE WAITMODE                 'Execute proper wait mode
    1 : WAITNOTBUSY
    2 : WAITNOTBUSY
        WAITCNT(CLKFREQ/4+CNT)
        WAITNOTBUSY

PUB SAY_VALUE (VALUE, WAITMODE) | CNTR
{{ Converts the VALUE to text then gives the Emic the string.
     Optionally waits for completions. Returns TRUE if successful.

   "WAITMODE" modes:
     0 - Don't wait to complete converting text or speaking
     1 - Wait to complete converting text
     2 - Wait to complete converting text AND speaking

   Note: If the Emic is busy the subroutine will return.

   Example:
     EMIC.SAY_VALUE(1234, 2)
}}
  IF INA[E_BUSY] OR NOT INITD   'Failsafe
    RETURN                      '^^

  TX($00)                       'Issue commands

  CNTR := 1_000_000_000         '  Convert value to text
  IF (VALUE < 0)
    -VALUE
    TX("-")
  REPEAT 10
    IF (VALUE => CNTR)
      TX(VALUE/CNTR+"0")
      VALUE //= CNTR
      RESULT~~
    ELSEIF RESULT OR CNTR == 1
      TX("0")
    CNTR /= 10                  '  ^^

  TX($AA)                       '^^

  CASE WAITMODE                 'Execute proper wait mode
    1 : WAITNOTBUSY
    2 : WAITNOTBUSY
        WAITCNT(CLKFREQ/4+CNT)
        WAITNOTBUSY

  RETURN TRUE

PUB VOLUME (SETTING)
{{ Adjusts the Emic's volume level.

   "SETTING" possibilities:
     0 through 7, EMIC#DEF_V, EMIC#MAX_V
     -1 returns the current volume level

   Note: If the Emic is busy, it will return without communicating
         and return the current volume level.

   Example:
     EMIC.VOLUME(5)             'Set volume to 5
     EMIC.VOLUME(EMIC#MAX_V)    'Set volume to maximum (7)
     EMIC.VOLUME(EMIC#DEF_V)    'Set volume back to default (4)
     X := EMIC.VOLUME(-1)       'Grab the current volume level
}}
  SETTING := SETTING <# MAX_V #> -1                     'Failsafe
  IF (SETTING == -1) OR INA[E_BUSY] OR NOT INITD
    RETURN SET_V                                        '^^

  TX($01)                       'Issue commands
  TX(SETTING+"0")
  TX($AA)                       '^^

  WAITNOTBUSY
  RETURN SET_V := SETTING

PUB SPEED (SETTING)
{{ Adjusts the Emic's speech speed level.

   "SETTING" possibilities:
     0 through 4, EMIC#DEF_, EMIC#MAX_
     -1 returns the current speed level

   Example:
     EMIC.SPEED(1)              'Set speed to 1
     EMIC.SPEED(EMIC#MAX_S)     'Set speed to maximum (4)
     EMIC.SPEED(EMIC#DEF_S)     'Set speed back to default (2)
     X := EMIC.SPEED(-1)        'Grab the current speed
}}
  SETTING := SETTING <# MAX_S #> -1                     'Failsafe
  IF (SETTING == -1) OR INA[E_BUSY] OR NOT INITD
    RETURN SET_S                                        '^^

  TX($02)                       'Issue commands
  TX(SETTING+"0")
  TX($AA)                       '^^

  WAITNOTBUSY
  RETURN SET_S := SETTING

PUB PITCH (SETTING)
{{ Adjusts the Emic's speech pitch level.

   "SETTING" possibilities:
     0 through 6, EMIC#DEF_P, EMIC#MAX_P
     -1 returns the current volume level

   Example:
     EMIC.PITCH(4)              'Set pitch to 4
     EMIC.PITCH(EMIC#MAX_P)     'Set pitch to maximum (6)
     EMIC.PITCH(EMIC#DEF_P)     'Set pitch back to default (1)
     X := EMIC.PITCH(-1)        'Grab the current pitch level
}}
  SETTING := SETTING <# MAX_P #> -1                     'Failsafe
  IF (SETTING == -1) OR INA[E_BUSY] OR NOT INITD
    RETURN SET_P                                        '^^

  TX($03)                       'Issue commands
  TX(SETTING+"0")
  TX($AA)                       '^^

  WAITNOTBUSY
  RETURN SET_P := SETTING

PUB ADDABBR (ABBR, TEXT)
{{ Adds an abbreviation to the Emic's abbreviation table.

   "ABBR": The abbreviation string.
   "TEXT": The string of text to be abbreviated. (Cannot contain numerals)

   Example:
     EMIC.ADDABBR(STRING("BS2"), STRING("Basic stamp two"))
     EMIC.SAY(STRING("The BS2 is cool!"), 2)  'The Emic says "The Basic
                                              '  stamp two is cool!"
}}
  IF INA[E_BUSY] OR NOT INITD   'Failsafe
    RETURN                      '^^

  SET_SAVE                      'Backup settings because Emic softresets
  TX($04)                       'Issue commands
  TX_STR(ABBR)
  TX(",")
  TX_STR(TEXT)
  TX($AA)                       '^^

  WAITCNT(CLKFREQ/5+CNT)
  WAITNOTBUSY
  SET_LOAD                      'Restore backed up settings
  WAITCNT(CLKFREQ/2+CNT)

PUB DELABBR (ABBR)
{{ Removes an abbreviation from the Emic's abbreviation table.

   "ABBR": The string of the abbreviation to be removed.

   Example:
     EMIC.DELABBR(STRING("BS2"))
     EMIC.SAY(STRING("The BS2 is cool!"), 2)  'The Emic says
                                              '  "The BS2 is cool!"
}}
  IF INA[E_BUSY] OR NOT INITD   'Failsafe
    RETURN                      '^^

  SET_SAVE                      'Backup settings because Emic softresets
  TX($05)                       'Issue commands
  TX_STR(ABBR)
  TX($AA)                       '^^

  WAITCNT(CLKFREQ/5+CNT)
  WAITNOTBUSY
  SET_LOAD                      'Restore backed up settings
  WAITCNT(CLKFREQ/2+CNT)

PUB LISTABBR (STKPTR, SIZE, SEP) | X
{{ Grabs a list of the abbreviations in the Emic's table.

   "STRPTR": The address of a string of bytes (stack) for the list to be
               copied into. This is optional, in that case put a 0.
   "SIZE"  : The size of the specified string of bytes. Just in case.
               If a stack isn't used then this doesn't matter.
   "SEP"   : The separation character between table entries. ie 13, or ","

   This subroutine returns the address of the DATAIN stack used to
     grab the abbreviation list. If not using your own stack, you
     can just use the address to this one. But only until
     the next RX_STR is called, because it clears the DATAIN stack.
     Table entries will be separated by a "."

   Example:
     BYTE LIST[51]              'Establish a byte stack for the abbr list

     X := EMIC.LISTABBR(@LIST, 51)  'Give the address and size of LIST

     '(Assuming you have a method for serial communication with a terminal)
     PRINT_STR(@LIST)
       'Or...
     PRINT_STR(X)
}}
  IF INA[E_BUSY] OR (E_TX == -1) OR NOT INITD           'Failsafe
    RETURN                                              '^^

  TX($06)                       'Issue commands
  TX($AA)                       '^^
  RX_STR                        'Begin recieving the table
  REPEAT X FROM 0 TO SIZE_DIN-1 'Convert hex end-of-lines to ASCII
    IF (DATAIN[X] == $0A)
      DATAIN[X] := SEP          '^^
  IF (STKPTR > 0)                                       'Copy to STRPTR?
    BYTEMOVE(STKPTR, @DATAIN, SIZE-1 <# SIZE_DIN-1)     '^^

  WAITNOTBUSY
  RETURN @DATAIN                'Return with DATAIN's address

PUB VERSION (STKPTR) | X
{{ Grabs a small list of the Emic hardware/software versions,
     and the speech processor's hardware/software versions.

   "VERSTKPTR": The pointer to a long stack for the version numbers.

   This subroutine returns the address of the DATAIN stack used to
     grab the version list. If not using your own stack, you can just
     use the address to this one. But only until the next RX_STR is called.

   Example:
     LONG EMIC_VER[4]           'One for each version

     (Constants)
     VER_EH = 0                 'Stack variable number for Emic Hware
     VER_ES = 1                 'Stack variable number for Emic Sware
     VER_WH = 2                 'Stack variable number for WTS701 Hware
     VER_WS = 3                 'Stack variable number for WTS701 Sware

     EMIC.VERSION(@EMIC_VER)    'Save the list in the EMIC_VER stack
     EMIC.SAY_VALUE(EMIC_VER[VER_EH], 2)  'Say the Emic Hardware version
}}
  IF INA[E_BUSY] OR (E_TX == -1) OR NOT INITD           'Failsafe
    RETURN                                              '^^

  TX($07)                       'Issue commands
  TX($AA)                       '^^
  REPEAT X FROM 0 TO 3          'Begin recieving list and
    LONG[STKPTR][X] := RX       '  saving to stack
  WAITNOTBUSY
  RETURN TRUE

PUB SOFTRESET
{{ Issues the soft reset command, which clears the volume, speed,
     and pitch settings to their default values. It leaves everything
     else (such as the abbreviation table) in tact.
}}
  IF INA[E_BUSY] OR NOT INITD   'Failsafe
    RETURN                      '^^

  TX($08)                       'Issue commands
  TX($AA)                       '^^

  'Store Emic default settings
  SET_V := DEF_V                'Set VOLUME to default (4)
  SET_S := DEF_S                'Set SPEED to default  (2)
  SET_P := DEF_P                'Set PITCH to default  (1)

  WAITNOTBUSY
  RETURN TRUE

PUB RESET
{{ Issues a hard reset by pulling the reset pin low, which
     completely restarts the Emic and reinitializes the firmware.
}}
  IF NOT INITD OR (E_RESET == -1)  'Failsafe
    RETURN                         '^^

  DIRA[E_RESET]~~               'Reset
  OUTA[E_RESET]~
  WAITCNT(CLKFREQ/5+CNT)
  OUTA[E_RESET]~~
  DIRA[E_RESET]~                '^^

  'Store Emic default settings
  SET_V := DEF_V                'Set VOLUME to default (4)
  SET_S := DEF_S                'Set SPEED to default  (2)
  SET_P := DEF_P                'Set PITCH to default  (1)

  WAITCNT(CLKFREQ/2+CNT)        'Wait for it to wake up
  WAITNOTBUSY
  CLEAR
  RETURN TRUE

PUB AIN (THRU)
{{ This is only available on the SIP version. This enables the analog
     audio signal on the AIN pin to to be fed through the Emic to the
     AOUT and SP+/SP- pins. The Emic is considered busy when doing this.

   "THRU": Given TRUE, it lets the signal through.
           Given FALSE, it doesn't.

   Example:
     EMIC.AIN(TRUE)             'Let the signal on AIN through
     WAITCNT(CLKFREQ+CNT)       'Wait one second...
     EMIC.AIN(FALSE)            'Close the signal
}}
  IF NOT INITD                  'Failsafe
    RETURN                      '^^

  IF THRU                       'Issue commands
    TX($09)
    TX($AA)
    RETURN TRUE
  ELSEIF INA[E_BUSY]
    TX($AA)
    WAITNOTBUSY
    RETURN TRUE                 '^^


'----- Extra Commands -----

PUB SET_SAVE
{{ Backs up the current volume/speed/pitch settings in extra variables. }}
  LONGMOVE(@SET_BACK, @SET_V, 3)

PUB SET_LOAD
{{ Restores the backed up volume/speed/pitch settings. }}
  LONGMOVE(@SET_V, @SET_BACK, 3)
  VOLUME(SET_V)
  SPEED(SET_S)
  PITCH(SET_P)

PUB BUSY_RESET
{{ Resets and restores the Emic module if Busy pin is high.
     If you find that the Emic has become unresponsive because it's
     stuck in a busy state, you can use this to reset the Emic
     and restore your previously set vol/speed/pitch settings.
}}
  IF INA[E_BUSY]                'If the Emic is busy...
    SET_SAVE                    '  Backup settings
    RESET                       '  Reset
    SET_LOAD                    '  Restore settings
    RETURN TRUE

PUB IS_INITD
{{ Returns the state of initiation. }}
  RETURN INITD

PUB STOP
{{ Clears the Propeller's Emic pin directions and states,
     and calls for a reset. Returns TRUE if successful.
}}
  IF INITD                      'If initiated..
    IF NOT RESET                '  Reset Emic module
      WAITNOTBUSY
      SOFTRESET                 '  ^^
    DIRA[E_RX]~                 '  Set all Emic pins to input
    IF E_TX+1
      DIRA[E_TX]~
    DIRA[E_BUSY]~
    IF E_RESET+1
      DIRA[E_RESET]~            '  ^^
    OUTA[E_RX]~                 '  Set all Emic pins low
    IF E_TX+1
      OUTA[E_TX]~
    IF E_RESET+1
      OUTA[E_BUSY]~
    OUTA[E_RESET]~              '  ^^
    INITD~                      '  No longer initialized
    RETURN TRUE                 '  Termination successful


'----- Communication Commands -----

PUB WAITNOTBUSY
{{ Waits until the busy pin goes low. Be careful not to use this
     if the Emic has been told to let the AIN signal through, because
     the Emic is then in a constant state of busy, and you're stuck
     until the system clock counter resets...

   Example:
     EMIC.SAY(STRING("Hello!"), 0)  'Give the Emic text without waiting
     EMIC.WAITNOTBUSY               'Using this to wait for Emic to finish
}}
  WAITPEQ(0, |<E_BUSY, 0)

PUB TX (CHAR) | BR
  BR := CLKFREQ/2400-1700 #> 381                        'Calculate baud rate
  CHAR := ((1 << 8)+CHAR) << 2                          'Set up character with start & stop bit
  DIRA[E_RX]~~
  REPEAT 10                                             'Send each bit based on baud rate
    OUTA[E_RX] := CHAR >>= 1
    WAITCNT(BR+CNT)
  WAITCNT(CLKFREQ/950+CNT)

PUB TX_STR (STRPTR)
  REPEAT STRSIZE(STRPTR)
    TX(BYTE[STRPTR++])                                  'Send each character in string

PUB RX | BR, X
  BR := 1_000_000/2400                                     'Calculate bit rate
  DIRA[E_TX]~                                               'Set as input
  WAITPEQ(1 << E_TX, |<E_TX, 0)                           'Wait for idle
  WAITPNE(1 << E_TX, |<E_TX, 0)                           'Wait for Start bit
  WAITCNT(CLKFREQ/1_000_000*BR*100/90+CNT)                        'Pause to be centered in 1st bit time
  REPEAT X FROM 0 TO 7                                'Number of bits - 1
    RESULT := RESULT | (INA[E_TX] << X)                       'Read next bit, shift and store
    WAITCNT(CLKFREQ/1_000_000*(BR-70)+CNT)                          'Wait until center of next bit

PUB RX_STR | PTR
  BYTEFILL(@DATAIN, 0, SIZE_DIN)                     'Fill string memory with 0's (null)
  PTR~
  REPEAT
    DATAIN[PTR] := RX      'Get character
    IF (DATAIN[PTR] == $55) OR (PTR => SIZE_DIN)                          'String end
      DATAIN[PTR]~
      RETURN @DATAIN
    PTR++

PRI CLEAR
{{ Required on startup for some reason I don't yet know.
   Buffer clear maybe?
}}
  REPEAT 2
    TX($AA)
    WAITNOTBUSY


DAT
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
