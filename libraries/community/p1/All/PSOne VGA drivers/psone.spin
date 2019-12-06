{{ PSOne test
}}
CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

OBJ 
                                                        '2 Cog here 
  kbm           : "kbm"                                 '1 COG for mouse and keyboard
  
  vga           : "VGA_512x128_Bitmap_PSOne"            '1 COG
  
  uarts         : "pcFullDuplexSerial4FC"               '1 COG for 4 serial ports

  config        : "config"                              'no COG required

VAR
  word Color[64]
  long Pixels[2048],Sync

Pub Start | check, char, SendServo,mx,my,bm,oldbm
  config.Init(@pininfo,0)                               'initialize config setup

  kbm.start(config.GetPin(CONFIG#MOUSE1_DATA),config.GetPin(CONFIG#MOUSE1_CLK), {
}   config.GetPin(CONFIG#KEYBOARD1_DATA),config.GetPin(CONFIG#KEYBOARD1_CLK))

  wordfill(@color,%%0020_3300,192)
  longfill(@pixels,0,2048)
  longfill(@pixels+32,$ffffffff,64)
  longfill(@pixels+512,$ffffffff,64)
  longfill(@pixels+1024,$ffffffff,64)
  longfill(@pixels+1536,$ffffffff,64)
  
  waitcnt(clkfreq*3 + cnt)                              'delay for debugging
  
  uarts.Init
  uarts.AddPort(0,config.GetPin(CONFIG#DEBUG_RX),config.GetPin(CONFIG#DEBUG_TX),{
}   UARTS#PINNOTUSED,UARTS#PINNOTUSED,UARTS#DEFAULTTHRESHOLD, {
}   UARTS#NOMODE,UARTS#BAUD115200)                      'Add debug port
  uarts.Start                                           'Start the ports
  
  uarts.str(0,string("RB UI V1.0",13))
  
  if kbm.keyboardpresent <> 0
    uarts.str(0,string("Keyboard present",13))
  if kbm.mousepresent <> 0
    uarts.str(0,string("Mouse present",13))

  waitcnt(clkfreq/2 + cnt)                              'delay for debugging

  vga.start(config.GetPin(CONFIG#VGA1), @Color, @Pixels, @Sync)
  
  'Handle keyboard
  repeat
    mx := kbm.delta_x
    my := kbm.delta_y
    if mx <> 0 OR my <> 0
      PrintMouse(mx,my)
    if (bm := kbm.buttons) <> oldbm
      oldbm := bm
      PrintButtons(bm)
    if char := kbm.key
      PrintKey(char)

PUB ChangeColor(c)
  
PRI SetX(x)
  
PRI SetY(y)

PUB PrintMouse(mx,my)

PUB PrintButtons(bm)
    
PUB PrintKey(char)

DAT
'pin configuration table for this project
pininfo       word CONFIG#IPR_TX                'pin 0
              word CONFIG#IPR_RX                'pin 1
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
              word CONFIG#VGA1                  'pin 16
              word CONFIG#VGA1                  'pin 17
              word CONFIG#VGA1                  'pin 18
              word CONFIG#VGA1                  'pin 19
              word CONFIG#VGA1                  'pin 20
              word CONFIG#VGA1                  'pin 21
              word CONFIG#VGA1                  'pin 22
              word CONFIG#VGA1                  'pin 23
              word CONFIG#MOUSE1_DATA           'pin 24
              word CONFIG#MOUSE1_CLK            'pin 25
              word CONFIG#KEYBOARD1_DATA        'pin 26
              word CONFIG#KEYBOARD1_CLK         'pin 27
              word CONFIG#I2C_SCL1              'pin 28
              word CONFIG#I2C_SDA1              'pin 29
              word CONFIG#DEBUG_TX              'pin 30
              word CONFIG#DEBUG_RX              'pin 31