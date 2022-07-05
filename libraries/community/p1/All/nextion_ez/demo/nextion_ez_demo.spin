'' =================================================================================================
''
''   File....... nextion_ez_p1.spin
''   Purpose....
''   Author..... Charles Current

''   E-mail..... charles@charlescurrent.com
''   Started.... 17 JUN 2022
''   Updated.... 04 JUL 2022
''
'' =================================================================================================
{{
  A simple demonstration of how to use the nextion_ez_p1 object with the Nextion display

  This demo uses two serial connections.  One is for communicating with the Nextion (or simulator),
  the other to send debug data to a serial terminal.

  The Nextion demo project has 2 pages.
  The first page has 2 buttons, 1 number, 1 float and 1 text field
  The Run button is dual state and when depressed it will cause
  the Propeller To change the text field and increment the number and float fields.
  The Page1 button will cause the Propeller to request a change to page1

  The second page has 1 button, 1 slider, 1 gauge, 1 progress and 1 waveform
  The slider is located on the far right of the page
  Moving the slider will cause the Propeller to retrieve its position
  and use that value to update the progress bar, gauge and waveform.
  The Page0 button will cause the Propeller to request a change to page0

  NOTE: HMI files for Nextion Editor are also included in the demo folder.
}}


CON
        _clkmode = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq = 5_000_000

        NX_TX_PIN = 0
        NX_RX_PIN = 1
        NX_BAUD = 115_200

        DB_TX_PIN = 30
        DB_RX_PIN = 31
        DB_BAUD = 115_200

        CR = $0D

VAR
  long  nx_cmd
  long  nx_sub
  long  currentPage
  long  lastPage
  long  disp_value
  long  run_count
  byte  txt[256]

OBJ
  nextion       : "nextion_ez"
  serial         : "FullDuplexSerial"

PUB main
  waitcnt(clkfreq + cnt)
  serial.start(DB_RX_PIN, DB_TX_PIN, %0000, DB_BAUD)
  nextion.start(NX_RX_PIN, NX_TX_PIN, NX_BAUD)

  repeat
    waitcnt(clkfreq / 25 + cnt)

    if nextion.getCurrentPage <> currentPage            'has the Nextion page changed?
      lastPage := nextion.getLastPage
      currentPage := nextion.getCurrentPage

      'data to serial terminal to demonstrate what is returned
      serial.Str(STRING("currentPage = "))
      serial.hex(currentPage, 2)
      serial.Tx(CR)
      serial.Str(STRING("lastPage = "))
      serial.hex(lastPage, 2)
      serial.Tx(CR)
      serial.Str(STRING("dp = "))
      serial.hex(nextion.readNum(STRING("dp")), 2)
      serial.Tx(CR)

    nextion.listen                                      ' need to run this to check for incoming data from the Nextion
    if nextion.cmdAvail > 0                             ' has the nextion sent a command?         '
      nx_cmd := nextion.getCmd                          ' get the command byte

      'data to serial terminal to demonstrate what is returned
      serial.Str(STRING("nextion command = "))
      serial.hex(nx_cmd, 2)
      serial.Tx(CR)

      callCommand(nx_cmd)                               ' let's see what command we received

    if run_count == true
      disp_value++
      nextion.writeNum(STRING("x0.val"), disp_value)    ' update the nextion number
      nextion.writeNum(STRING("n0.val"), disp_value)    ' and float fields on page0

PRI callCommand(_cmd)           'parse the 1st command byte and decide how to proceed
  case _cmd
    "T" :                                               'standard Easy Nextion Library commands start with "T"
      nx_sub := nextion.readByte                       ' so we need the second byte to know what function to call

      'data to serial terminal to demonstrate what is returned
      serial.Str(STRING("nextion subcommand = "))
      serial.hex(nx_sub, 2)
      serial.Tx(CR)

      callTrigger(nx_sub)                               ' now we call the associated function

PRI callTrigger(_triggerId)    'use the 2nd command byte from nextion and call associated function
  case _triggerId
    $00 :
      trigger00                                         ' the orginal Arduino library uses numbered trigger functions
    $01 :
      trigger01
    $02 :
      runCount                                          ' but since we are parsing ourselves, we can call any method we want
    $03 :
      trigger03
    $04 :
      trigger04

PRI trigger00
  nextion.sendCmd(STRING("page 1"))                     ' nextion commands can have their arguments in the string we send

PRI trigger01
  nextion.pushCmdArg(0)                               ' or up to 16 arguments can pe passed via a stack
  nextion.sendCmd(STRING("page"))                       ' this allows the easy use of variables and constants

PRI runCount
  run_count := NOT run_count
  if run_count
    nextion.writeStr(STRING("t0.txt"), STRING("Running")) ' we can update nextion text attributes with writeStr
  else
    nextion.writeStr(STRING("t0.txt"), STRING("Stopped"))
  nextion.readStr(STRING("t0.txt"), @txt)                 ' and we can read text attributes with readStr

  'data to serial terminal to demonstrate what is returned
  serial.str(STRING("t0.txt = "))
  serial.str(@txt)
  serial.tx(CR)

PRI trigger03 | slidder, wave, guage
  slidder := nextion.readNum(STRING("h0.val"))            ' number attributes can be read with readNum
  guage := slidder * 36 / 10
  wave := slidder * 255 / 100

  nextion.writeNum(STRING("j0.val"), slidder)             ' and number attributes an be updated on the nextion with writeNum
  nextion.writeNum(STRING("z0.val"), guage)
  nextion.addWave(1, 0, wave)                             ' the addWave method makes it easy to add to a nextion waveform

  'data to serial terminal to demonstrate what is returned
  serial.str(STRING("h0.val = "))
  serial.hex(slidder, 2)
  serial.tx(CR)

PRI trigger04
  waitcnt(clkfreq / 25 + cnt)
  trigger03