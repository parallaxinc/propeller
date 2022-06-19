'' =================================================================================================
''
''   File....... nextion_ez_p1.spin
''   Purpose....
''   Author..... Charles Current

''   E-mail..... charles@charlescurrent.com
''   Started.... 17 JUN 2022
''   Updated.... 18 JUN 2022
''
'' =================================================================================================
{{
  A simple demonstration of how to use the nextion_ez_p1 object with the Nextion display

  NOTE: HMI files for Nextion Editor are also included in the demo folder.
}}


CON
        _clkmode = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq = 5_000_000

        NX_TX_PIN = 0
        NX_RX_PIN = 1
        NX_BAUD = 9_600

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
  serial.start(DB_RX_PIN, DB_TX_PIN, %0000, 115_200)
  nextion.start(NX_RX_PIN, NX_TX_PIN, 9_600)

  repeat
    waitcnt(clkfreq / 25 + cnt)

    if nextion.getCurrentPage <> currentPage
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

    nextion.listen
    if nextion.cmdAvail > 0
      nx_cmd := nextion.getCmd

      'data to serial terminal to demonstrate what is returned
      serial.Str(STRING("nextion command = "))
      serial.hex(nx_cmd, 2)
      serial.Tx(CR)

      callCommand(nx_cmd)

    if run_count == true
      disp_value++
      nextion.writeNum(STRING("x0.val"), disp_value)
      nextion.writeNum(STRING("n0.val"), disp_value)

PRI callCommand(_cmd)           'parse the 1st command byte and decide how to proceed
  case _cmd
    "T" :                                               'standard Easy Nextion Library commands start with "T"
      nx_sub := nextion.getSubCmd                       ' so we need the second byte to know what function to call

      'data to serial terminal to demonstrate what is returned
      serial.Str(STRING("nextion subcommand = "))
      serial.hex(nx_sub, 2)
      serial.Tx(CR)

      callTrigger(nx_sub)

PRI callTrigger(_triggerId)    'use the 2nd command byte from nextion and call associated function

  if _triggerId < $40
    case _triggerId
      $00 :
        trigger00
      $01 :
        trigger01
      $02 :
        trigger02
      $03 :
        trigger03
      $04 :
        trigger04

PRI trigger00
  nextion.sendCmd(STRING("page 1"))

PRI trigger01
  nextion.sendCmd(STRING("page 0"))

PRI trigger02
  run_count := NOT run_count
  if run_count
    nextion.writeStr(STRING("t0.txt"), STRING("Running"))
  else
    nextion.writeStr(STRING("t0.txt"), STRING("Stopped"))
  nextion.readStr(STRING("t0.txt"), @txt)

  'data to serial terminal to demonstrate what is returned
  serial.str(STRING("t0.txt = "))
  serial.str(@txt)
  serial.tx(CR)

PRI trigger03 | slidder, wave, guage
  slidder := nextion.readNum(STRING("h0.val"))
  guage := slidder * 36 / 10
  wave := slidder * 2

  nextion.writeNum(STRING("j0.val"), slidder)
  nextion.writeNum(STRING("z0.val"), guage)
  nextion.addWave(1, 0, wave)

  'data to serial terminal to demonstrate what is returned
  serial.str(STRING("h0.val = "))
  serial.hex(slidder, 2)
  serial.tx(CR)

PRI trigger04
  waitcnt(clkfreq / 25 + cnt)
  trigger03