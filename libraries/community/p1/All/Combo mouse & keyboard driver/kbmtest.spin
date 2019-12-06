{{
  KBM driver test
        Tim Moore July 08
}}
CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

OBJ 
                                                        '1 Cog here 
  kbm           : "kbm"                                 '1 COG for mouse and keyboard
  
  uarts         : "pcFullDuplexSerial4FC"               '1 COG for 4 serial ports

  config        : "config"                              'no COG required

Pub Start | char, mx, my
  config.Init(@pininfo,0)                               'initialize config setup

  kbm.start(config.GetPin(CONFIG#MOUSE1_DATA),config.GetPin(CONFIG#MOUSE1_CLK), {
}   config.GetPin(CONFIG#KEYBOARD1_DATA),config.GetPin(CONFIG#KEYBOARD1_CLK))

  waitcnt(clkfreq*3 + cnt)                              'delay for debugging
  
  uarts.Init
  uarts.AddPort(0,config.GetPin(CONFIG#DEBUG_RX),config.GetPin(CONFIG#DEBUG_TX),{
}   UARTS#PINNOTUSED,UARTS#PINNOTUSED,UARTS#DEFAULTTHRESHOLD, {
}   UARTS#NOMODE,UARTS#BAUD115200)                      'Add debug port
  uarts.Start                                           'Start the ports
  
  uarts.str(0,string("KBMTest",13))
  
  if kbm.keyboardpresent <> 0
    uarts.str(0,string("Keyboard present",13))
  if kbm.mousepresent <> 0
    uarts.str(0,string("Mouse present",13))

  repeat
    mx := kbm.delta_x
    my := kbm.delta_y
    if mx <> 0 OR my <> 0
      uarts.str(0,string("Mouse "))
      uarts.dec(0,mx)
      uarts.tx(0," ")
      uarts.dec(0, my)
      uarts.tx(0,13)
    if char := kbm.key
      uarts.hex(0,char,4)
      uarts.tx(0," ")
         
DAT
'pin configuration table for this project
pininfo       word CONFIG#NOT_USED              'pin 0
              word CONFIG#NOT_USED              'pin 1
              word CONFIG#NOT_USED              'pin 2
              word CONFIG#NOT_USED              'pin 3
              word CONFIG#NOT_USED              'pin 4
              word CONFIG#NOT_USED              'pin 5
              word CONFIG#NOT_USED              'pin 6
              word CONFIG#NOT_USED              'pin 7
              word CONFIG#NOT_USED              'pin 8
              word CONFIG#NOT_USED              'pin 9
              word CONFIG#NOT_USED              'pin 10
              word CONFIG#NOT_USED              'pin 11
              word CONFIG#NOT_USED              'pin 12
              word CONFIG#NOT_USED              'pin 13
              word CONFIG#NOT_USED              'pin 14
              word CONFIG#NOT_USED              'pin 15
              word CONFIG#NOT_USED              'pin 16
              word CONFIG#NOT_USED              'pin 17
              word CONFIG#NOT_USED              'pin 18
              word CONFIG#NOT_USED              'pin 19
              word CONFIG#NOT_USED              'pin 20
              word CONFIG#NOT_USED              'pin 21
              word CONFIG#NOT_USED              'pin 22
              word CONFIG#NOT_USED              'pin 23
              word CONFIG#MOUSE1_DATA           'pin 24
              word CONFIG#MOUSE1_CLK            'pin 25
              word CONFIG#KEYBOARD1_DATA        'pin 26
              word CONFIG#KEYBOARD1_CLK         'pin 27
              word CONFIG#NOT_USED              'pin 28
              word CONFIG#NOT_USED              'pin 29
              word CONFIG#DEBUG_TX              'pin 30
              word CONFIG#DEBUG_RX              'pin 31