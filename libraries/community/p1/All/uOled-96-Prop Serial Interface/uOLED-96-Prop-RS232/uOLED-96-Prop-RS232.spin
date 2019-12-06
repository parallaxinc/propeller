'RS232 interface for uOLED-96-Prop
'Copyright (C) 2008 Raymond Allen.  See end of file for terms of use.

'Notes:
' Interface designed to mimic uOLED-128-GMD1 (with some additions, especially the extended commands)
' This is the top-level object for using the uOLED-96-Prop as a serial controlled device.
' The OLED driver has been partially converted to assembly, mostly to improve image drawing speed
' Several commands have been added to the underlying OLED driver
' A Windows application is provided to test this interface.  This app also can create preformatted image/animation data.
' Serial data is sent/received with pins 31/30 by default for convienence
' Functions utilizing the SD card require the SD card to be formatted with FAT file system
' You must allow ~100ms for the OLED to initialize before sending commands on power-up
' An auto-baud detector (like that of the uOLED-128-GMD1) waits for 5 seconds for "U"=$55 character
' Auto-baud detector works up to 57600 baud
' After 5 seconds, baud rate defaults to 115200 and a logo is show to indicate ready state
' Baud settings are adjustable by values in the CON section
' 2 new fonts are added based on the ROM font
' Support for "transparent" character display added
' Can display all Windows Bitmap files (but works best with 24-bit Bitmaps)
' Can also display preformatted images from data files in 8 or 16 bits/pixel mode
' Preformatted images can also be embedded and shown here (as the splash screen demonstrates)
' Also, slideshows/animations compiled into a preformatted data file can be displayed
' Any byte must be sent to stop slideshows/animations in progress
' The color value of a pixel can be read
' The current screen can be saved as a bitmap
' The screen can be rotated 180 degrees for usage upside down.  This doesn't currently support images, but could do so.
' A Ymodem terminal session can be established to transfer files to/from SD over the serial connection
' Data can be read/written to SD card files
' Binary programs stored on the SD card (such as Femtobasic) can be run
'
' A full list of supported commands is given below:


'General Commands:
' A     'Add User Bitmapped Character
' B     'Set Background Color
' b     'Place Text button
' C     'Draw Circle
' c     'Block copy and Paste (bitmap copy)
' D     'Display user bitmapped character
' E     'Erase screen
' F     'Font size
' G     'Draw Triangle
' g     'Draw Polygon
' I     'Display Image
' L     'Draw Line
' O     'Select Opaque or Transparent text
' P     'Put a pixel
' p     'Set pen size
' R     'Read a pixel
' r     'Draw rectangle
' S     'Place unformatted string of ASCII text
' s     'Place formatted string of ASCII text
' T     'Place formatted text character
' t     'Place unformatted text character
' V     'Version/Device Info Request
' Y     'OLED Display control functions

'Display Specific Commands
' $W    'Write OLED Command
' $S    'Display Scroll Control
' $D    'Dim Screen Area
' $F    'Flip display 180 degrees   (works for most commands, except images)

'Extended SD Commands
' @R    'Open File on SD card for reading             
' @W    'Open File on SD card for writing               
' @r    'Read bytes from SD card                        
' @w    'Write bytes to SD card                       
' @C    'Close File on SD card
' @E    'Erase file on SD card                      
' @S    'Save screen as BMP to SD card
' @B    'Display BMP image from SD card
' @I    'Display image from raw data from SD card
' @s    'Show Slideshow from prepared data file on SD card                   
' @L    'Load and run binary program from SD card
' @F    'Run FemtoBasic from SD card (file fbasic.bin must be present on SD card)
' @D    'View SD Card Directory
' @Y    'Begin YModem file transfer terminal session



CON
  _CLKMODE      = XTAL1 + PLL8X        'only running in 8X to avoid trouble with multiple cogs                
  _XINFREQ      = 8_000_000

'Settings for RS232 host communications:
  RxPin = 31      'Pins 31&30 are also used for programming so they are easiest to use
  TxPin = 30      'But, you could also use pins 18, 19, 20 or 21 by changing these values.
  RsMode = 0      'Mode for comms (normally 0).  See FullDuplexSerial.SPIN for other options 
  AutoBaudTimeout=5  'seconds of autodetection before falling back to default baud                                                                                        
  defaultBaud = 115200  'If Auto-Baud Detection fails, device will fall back to this baud
  ACK = $06       'send when command acknowledged
  NAK = $15      'send when command not understood

  dSlow         = 50
  dFast         = 20

  HardwareVersion=1      '(AFAIK)
  FirmwareVersion=1      'So says I

  

OBJ
  OLED  : "uOLED-96-Prop_V4RayAsm"  'Assembly aided version of modified Oled driver
  ser : "uOLED-FullDuplexSerial"
  'DELAY : "Clock"
  num: "numbers"
  SD: "fsrwFemto"                 ' FAT File System Read/Write from Mike Green used in "kiosk" demo with slight mods   

VAR

  'Baud detection varaibles
  long BaudRate
  long stack[100]   'stack space for launching SPIN code in a new cog
  long bBaudAutoDetected  'flag set when baud auto-detected

  'Oled control variables
  word BackgroundColor
  long bTransparentText  'flag to say whether or not text will be transparent
  long bWireFrame 'AKA Pensize:  0=solid, non-zero=wireframe
  long nFont  'stores the current font selection:  0=5x7, 1=8x8, 2=8x12, 3=16x32

  'buffers
  byte lineBuffer[96*3]' buffer for line of an image
  byte StringBuffer[257]  'storage for incoming ASCII strings
  byte tbuf[20] 'temp storage for filenames

  'Screen scrolling variables
  byte ScrollHorizontalStep
  byte ScrollStartRow
  byte ScrollingRows
  byte ScrollVerticalStep
  byte ScrollSpeed

  'SD card control variables
  long bMountFailure



PUB Main |i,j,k,x,y,c,nx,ny,w,z,x0,y0
  'Set some default values
  bWireFrame:=false  'start off in solid mode
  nFont:=0           'start with the  5x7 font
  bTransparentText:=true    'can see through text by default
  'set scrolling defaults
  ScrollHorizontalStep:=0  'no horizontal scroll by default
  ScrollStartRow:=0 'start at first row
  ScrollingRows:=64 'and scroll the whole screen by default
  ScrollVerticalStep:=1 'scroll 1 row at a time by default
  ScrollSpeed:=1 'fast speed by default (0=fastest, 2=slowest)

  'initialize number to string object
  num.init
  
  'Next, initialize the OLED display (takes ~100ms or so)
  OLED.InitOLED
  oled.Set_Contrast_RGB(150,150,150) 'overide default contrast settings with these ones that darken the screen a bit (better for pictures and screen)
  OLED.CLS  'clear OLED screen
  
  'Next, try to autodetect baud rate from serial line
  if AutoBaudDetect==false  'Baud rate set if AutoDetect works.
    BaudRate:=defaultBaud   'Otherwise, fall back to default

 'Start serial comms before initializing display (because that takes a while... This way we can take instructions to process after oled initialization)                         
  ser.start(RxPin,TxPin,RsMode,BaudRate)  

  'send acknoledge of baud rate if autodetected
  if bBaudAutoDetected==true
    ser.tx(Ack)    'This looks like a spade card suit character in Hyperterminal
  else
    'will default to defaultBaud and wait for input
    Splash  'Show splash screen so people know we're online and awaiting input at default baud


  'Try mounting SD card and record result
  SD.start 
  bMountFailure:=\SD.mountSD

  'Now, start command receive&process cycle
  repeat
    i:=ser.rx
    case i
      "E":  'erase screen with background color
          Oled.ClsA(BackgroundColor)
          ser.tx(ACK)

      "P":  'put a pixel
          Oled.PutPixelA(ser.rx,ser.rx,ser.rx<<8+ser.rx)
          ser.tx(ACK)

      "R":  'read a pixel
          x:=ser.rx
          y:=ser.rx
          'Have to do a dummy read first
          c:=Oled.GetPixelA(x,y)  'retrieve 16-bit color given x,y coordinates
          'real read...
          c:=Oled.GetPixelA(x,y)  'retrieve 16-bit color given x,y coordinates          
          'transmit color
          ser.tx(c.byte[1])
          ser.tx(c.byte[0])
          'Note:  No ACK!
          
      "L":  'draw a line
          Oled.LineA(ser.rx,ser.rx,ser.rx,ser.rx,ser.rx<<8+ser.rx)
          ser.tx(ACK)
          
      "r":  'draw a rectangle
          Oled.RectangleA(ser.rx,ser.rx,ser.rx,ser.rx,bWireFrame,ser.rx<<8+ser.rx) 
          ser.tx(ACK)
          
      "g":  'draw polygon
          i:=ser.rx '# vertices
          k:=0
          repeat j from 1 to i     'buffer vertex points
            StringBuffer[k++]:=ser.rx
            StringBuffer[k++]:=ser.rx
          c:=c:=ser.rx<<8+ser.rx  'line color
          x0:=StringBuffer[0]
          y0:=StringBuffer[1]
          k:=2
          repeat j from 1 to i-1 'draw lines
            x:=StringBuffer[k++]
            y:=StringBuffer[k++]
            Oled.LineA(x0,y0,x,y,c)
            x0:=x
            y0:=y
          'draw last line
          x:=StringBuffer[0]
          y:=StringBuffer[1]
          Oled.LineA(x0,y0,x,y,c)
          ser.tx(ACK)          

      "B":  'Set Background color
          BackgroundColor:=ser.rx<<8+ser.rx
          ser.tx(ACK)

      "A":  'Add user bitmapped character
          i:=ser.rx 'character#
          if i=>0 and i=<31
            repeat j from 0 to 7
              byte[@UserBitmappedChars+i*8][j]:=ser.rx
          ser.tx(ACK)

      "D":  'Display User Bitmapped character
          i:=ser.rx 'character#
          x:=ser.rx 'x location
          y:=ser.rx 'y location
          c:= ser.rx<<8+ser.rx  'color
          Oled.Set_GRAM_Access(x,x+8,y,y+8)
          repeat j from 0 to 7
            phsa:=byte[@UserBitmappedChars+i*8][j]      'use phsa for easy access to bits
            repeat k from 0 to 7
              if (x+k)<96 and y<64
                 if phsa[7-k]<>0
                    Oled.PutPixelA(x+k,y,c) 'set pixel
                 else
                    if not bTransparentText
                      Oled.PutPixelA(x+k,y,BackgroundColor)
            y++
          ser.tx(ACK)

      "G":  'Draw triangle
          Oled.Triangle(ser.rx,ser.rx,ser.rx,ser.rx,ser.rx,ser.rx,ser.rx<<8+ser.rx,bWireFrame)
          ser.tx(ACK)    

      "p":  'Set Pen size
          bWireFrame:=ser.rx
          ser.tx(ACK)

      "C":  'Draw circle
          Oled.Circle(ser.rx,ser.rx,ser.rx,not bWireFrame,ser.rx<<8+ser.rx)
          ser.tx(ACK)

      "c":  'Copy and paste screen area
          x:=ser.rx
          y:=ser.rx
          i:=ser.rx
          j:=ser.rx
          Oled.Copy (x, y, x+ser.rx-1, y+ser.rx-1, i, j)  'driver takes this slightly different format...
          ser.tx(ACK)

      "F":  'Set Font:  'Note new 8x12 and 16x32 fonts added using Prop's ROM Font
         nFont:=ser.rx&3  'valid values from 0..3
         ser.tx(ACK) 

      "t":  'Set text character (unformatted)     'cmd, char, column, row, colour(msb:lsb)
          if bTransparentText
            Oled.PutCharA(ser.rx,ser.rx,ser.rx,nFont,ser.rx<<8+ser.rx,-1,false,1,1)
          else
            Oled.PutCharA(ser.rx,ser.rx,ser.rx,nFont,ser.rx<<8+ser.rx,BackgroundColor,false,1,1)
          ser.tx(ACK)   

      "T":  'Set text character (formatted)     'cmd, char, column, row, colour(msb:lsb)
          if bTransparentText
            Oled.PutCharA(ser.rx,ser.rx,ser.rx,nFont,ser.rx<<8+ser.rx,-1,true,1,1)
          else
            Oled.PutCharA(ser.rx,ser.rx,ser.rx,nFont,ser.rx<<8+ser.rx,BackgroundColor,true,1,1)
          ser.tx(ACK)   

      "O":  'select opaque (1) or transparent (0) text
          if (ser.rx==0)
            bTransparentText:=true
          else
            bTransparentText:=false
          ser.tx(ACK)

      "S": 'Unformatted text string '
          x:=ser.rx
          y:=ser.rx
          i:=ser.rx  'font
          c:=ser.rx<<8+ser.rx  'color
          nx:=ser.rx
          ny:=ser.rx
          j:=ser.rx
          if bTransparentText
            repeat
              if j==0
                quit
              if Oled.PutCharA(j,x,y,i,c,-1,false,nx,ny)
                x+=Oled.GetFontWidth(i)*nx
                j:=ser.rx
              else
                y+=Oled.GetFontHeight(i)*ny   'try dropping down one line
                x:=0
                if y>63    'catch overflow 
                  repeat
                    j:=ser.rx
                  until j==0
                  quit
          else
            repeat
              if j==0
                quit
              if Oled.PutCharA(j,x,y,i,c,BackgroundColor,false,nx,ny)
                x+=Oled.GetFontWidth(i)*nx 
                j:=ser.rx
              else
                y+=Oled.GetFontHeight(i)*ny   'try dropping down one line
                x:=0
                if y>63   'catch overflow 
                  repeat
                    j:=ser.rx
                  until j==0
                  quit
          ser.tx(ACK)

      "b": 'Text button        'cmd, state, x, y, buttonColour(msb:lsb), font, textColour(msb:lsb),textWidth, textHeight, char1, .., charN, terminator
          w:=ser.rx  'state 0=down, 1=up
          x0:=ser.rx  'x0,y0 is top-left corner of button
          x:=x0+1   'text starts 1 pixel down and over
          y0:=ser.rx
          y:=y0+1
          z:=ser.rx<<8+ser.rx  'buttoncolor
          i:=ser.rx  'font
          c:=ser.rx<<8+ser.rx  'textcolor
          nx:=ser.rx    'character scaling in x
          ny:=ser.rx    'character scaling in y
          'read in text
          j:=ser.rx
          repeat
            if j==0  'end of string
              quit
            if Oled.PutCharA(j,x,y,i,c,z,false,nx,ny)
              x+=Oled.GetFontWidth(i)*nx 
              j:=ser.rx
            else 
              repeat  'catch overflow
                j:=ser.rx
              until j==0
              quit
          'set x and y to lower right corner    
          y+=Oled.GetFontHeight(i)*nx
          'and draw border lines
          if w==1 'button up
            i:=198
            j:=80
          else
            i:=80
            j:=198
          Oled.Line(x0,y0,x0,y, i,i,i)
          Oled.Line(x0,y0,x,y0, i,i,i)
          Oled.Line(x,y,x,y0, j,j,j)
          Oled.Line(x,y,x0,y, j,j,j)          
          ser.tx(ACK)           

      "s": 'Formatted text string '
          x:=ser.rx
          y:=ser.rx
          i:=ser.rx  'font
          c:=ser.rx<<8+ser.rx  'color
          j:=ser.rx
          if bTransparentText
            repeat
              if j==0
                quit
              if Oled.PutCharA(j,x,y,i,c,-1,true,1,1)
                x++
                j:=ser.rx
              else
                y++   'try dropping down one line
                x:=0
                if y>8  'catch overflow
                  repeat
                    j:=ser.rx
                  until j==0
                  quit
          else
            repeat
              if j==0
                quit
              if Oled.PutCharA(j,x,y,i,c,BackgroundColor,true,1,1)
                x++
                j:=ser.rx
              else
                y++   'try dropping down one line
                x:=0
                if y>8    'catch overflow 
                  repeat
                    j:=ser.rx
                  until j==0
                  quit       
          ser.tx(ACK)
          
      "I":  'Display image.  Image comes as raw 16-bit data
          x:=ser.rx
          y:=ser.rx
          nx:=ser.rx
          ny:=ser.rx
          k:=ser.rx 'mode 8 or 16 bits per pixel
          case k
            16:
              'read 16-bit data and send directly to Oled
              Oled.Set_GRAM_Access(x, x+nx-1, y, y+ny-1)
              Oled.Write_Start_GRAM
              repeat nx*ny*2
                Oled.Write_GRAM_Byte(ser.rx)
              Oled.Write_Stop_GRAM
            8:
              'Need to switch to 8-bit (256 color) mode for a moment
              Oled.Write_cmd(Oled#REMAP_COLOUR_SETTINGS)               ' Set Re-map Color/Depth
              Oled.Write_cmd(Oled#_256_COLOURS)                        ' 256 colors as 1 byte
              Oled.Set_GRAM_Access(x, x+nx-1, y, y+ny-1)
              Oled.Write_Start_GRAM
              repeat nx*ny
                Oled.Write_GRAM_Byte(ser.rx)
              Oled.Write_Stop_GRAM
              'Now, go back to the usual 16-bit color
              Oled.Write_cmd(Oled#REMAP_COLOUR_SETTINGS)               ' Set Re-map Color/Depth     
              Oled.Write_cmd(Oled#_65K_COLOURS)                        ' 65K 8bit R->G->B
          ser.tx(ACK)

      "V": 'Send device info
         i:=ser.rx  '0=serial port only, 1=serial+display
         'send info
         ser.tx(0) 'device type=OLED
         ser.tx(HardwareVersion) 'hardware version 
         ser.tx(FirmwareVersion) 'firmware version 
         ser.tx($96) '96 pixels of horizontal
         ser.tx($64) '64 pixels of vertical
         if (i==1) 'show info on display
           Oled.ClsA(BackgroundColor)
           Oled.PutText (0,0,2, 255,255,255, String("Oled-Prop-96"))
           Oled.PutText (0,2,0, 255,255,255, String("Hardware Ver.",HardwareVersion+"0" ))
           Oled.PutText (0,3,0, 255,255,255, String("Firmware Ver.",FirmwareVersion+"0" ))
           Oled.PutText (0,4,0, 255,255,255, String("Hor. Pixels: 96"))
           Oled.PutText (0,5,0, 255,255,255, String("Ver. Pixels: 64"))

      "Y":  'OLED Control Functions
         i:=ser.rx 'mode (0=display on/off, 1=set contrast, 2=power on/off)
         case i
           0: 'display on/off
             if ser.rx==0
               Oled.Write_cmd(Oled#DISPLAY_OFF)
             else 
               Oled.Write_cmd(Oled#DISPLAY_ON)
           1: 'set contrast
               Oled.Write_cmd(Oled#CONTRAST_MASTER)   ' Set master contrast
               Oled.Write_cmd(ser.rx)
           2: 'power on/off
             if ser.rx==0
               Oled.PowerDown_Seq
             else 
               Oled.PowerUp_Seq  'Note: You will need to turn display on again too!
         ser.tx(ACK)                 
             
           
      "$":  'Display Specific Commands
         case ser.rx
            "W":  'Write command to OLed controller
              Oled.Write_cmd(ser.rx) 
              ser.tx(ACK)
            "F":  'flip display upside-down
              case ser.rx
                1:   'Rotated 180
                  oled.Write_cmd(oled#REMAP_COLOUR_SETTINGS)               ' Set Re-map Color/Depth
                  oled.Write_cmd(%0110_0000)  'flip vertical (mirror+backward scan)
                0:  'Normal
                  oled.Write_cmd(oled#REMAP_COLOUR_SETTINGS)               ' Set Re-map Color/Depth  
                  oled.Write_cmd(%0111_0010)  'normal
                  {'is portrait mode possible?
                2:  'Portrait
                  oled.Write_cmd(oled#REMAP_COLOUR_SETTINGS)               ' Set Re-map Color/Depth  
                  oled.Write_cmd(%0111_0011)  'rotate
                  } 
              ser.tx(ACK)
                      
            "D":  'Dim Screen Area
              x:=ser.rx
              y:=ser.rx
              Oled.DimWindow(x,y,x+ser.rx-1,y+ser.rx-1) 
              ser.tx(ACK)
              
            "S":  'Scroll command
              j:=true
              case ser.rx 'get command
                0: 'enable/disable scrolling
                  i:=ser.rx
                  if i==0 'disable scrolling
                    Oled.ScrollStop
                  elseif i==1 'enable scrolling
                    Oled.ScrollSetup(ScrollHorizontalStep, ScrollVerticalStep, ScrollStartRow, ScrollingRows, ScrollSpeed)
                    Oled.ScrollStart       
                2: 'set scroll speed
                  ScrollSpeed:=ser.rx
                3: 'Set Horizontal step
                  ScrollHorizontalStep:=ser.rx
                4: 'set starting row
                  ScrollStartRow:=ser.rx
                5: 'set #rows to scroll
                  ScrollingRows:=ser.rx
                6: 'set vertical step
                  ScrollVerticalStep:=ser.rx
                other:
                  j:=false  'unknown scroll command                  
              if j==true
                ser.tx(ACK)
              else
                ser.tx(NAK)

      "@":  'Display Specific Commands  (mostly SD card functions)
         case ser.rx
            "D":  'View SD Card directory:  transmit directory text as null terminated string
              if (bMountFailure)
                bMountFailure:=\SD.mountSD  'try again to mount SD card
              if (bMountFailure)                
                ser.str(string("SD card failed to mount."))  'something wrong with SD
                ser.tx(0)
              else
                ser.str(string(" Directory of SD Card: ", 13,10))
                ser.str(string("===================================", 13,10))
                ser.str(string("Filename        Size in Bytes", 13,10))
                ser.str(string("------------    -------------", 13,10))

                y:=0 'init total size 
                sd.opendir
                repeat while 0 == sd.nextfile(@tbuf)
                  repeat 12-strsize(@tbuf)
                   ser.tx(" ")
                  ser.str(@tbuf)
                  ser.str(string("   "))
                  x:=sd.fsize
                  y+=x
                  ser.str(num.tostr(x,num#DSDEC14))
                  ser.tx(13)
                  ser.tx(10)
                
                'Show total bytes  
                ser.str(string(13,10,13,10,"Total: "))
                ser.str(num.tostr(y,num#DSDEC14))   
                ser.str(string(13,10,13,10,"bytes"))
                ser.tx(0) 'end of string
                'Note this function returns string instead of ACK or NAK
                
                
            "B":  'Display Windows bitmap from SD card

              'get x,y coordinates of top-left corner
              x:=ser.rx
              y:=ser.rx
              'get filename
              i:=0
              j:=0  'flag to indicate that a "." character recieved
              repeat
                tbuf[i]:=ser.rx
                if (tbuf[i]==".")
                  j:=i
              until tbuf[i++]==0
              if j==0  '.bmp extension not given, so adding it
                bytemove(@tbuf[i-1],string(".bmp"),5)
              if (bMountFailure)
                bMountFailure:=\SD.mountSD  'try again to mount SD card
              if (bMountFailure)                
                ser.tx(NAK)  'something wrong with SD
              else  
                if BMP(x,y,@tbuf[0])==0 'show bitmap
                  ser.tx(ACK) 'OK
                else
                  ser.tx(NAK) 'failed
                  
            "I":  'Display image from data file on SD card
              'get x,y coordinates of top-left corner
              x:=ser.rx
              y:=ser.rx
              'get filename
              i:=0
              j:=0  'flag to indicate that a "." character recieved
              repeat
                tbuf[i]:=ser.rx
                if (tbuf[i]==".")
                  j:=i
              until tbuf[i++]==0
              if j==0  'extension not given, so adding it
                bytemove(@tbuf[i-1],string(".dat"),5)
              if (bMountFailure)
                bMountFailure:=\SD.mountSD  'try again to mount SD card
              if (bMountFailure)                
                ser.tx(NAK)  'something wrong with SD
              else   
                if Image(x,y,@tbuf[0])==0 'show bitmap
                  ser.tx(ACK) 'OK
                else
                  ser.tx(NAK) 'failed

            "s":  'Display slideshow from data file on SD card
              'get x,y coordinates of top-left corner
              x:=ser.rx
              y:=ser.rx
              'get milliseconds to pause between pictures
              z:=ser.rx<<8+ser.rx
              'get filename
              i:=0
              j:=0  'flag to indicate that a "." character recieved
              repeat
                tbuf[i]:=ser.rx
                if (tbuf[i]==".")
                  j:=i
              until tbuf[i++]==0
              if j==0  'extension not given, so adding it
                bytemove(@tbuf[i-1],string(".dat"),5)
              if (bMountFailure)
                bMountFailure:=\SD.mountSD  'try again to mount SD card
              if (bMountFailure)                
                ser.tx(NAK)  'something wrong with SD
              else
                ser.tx(ACK)  'say ok before starting
                Slideshow(x,y,z,@tbuf[0])  'slideshow will play continuously until any character sent
                  
            "Y":  'Ymodem file transfer session with terminal application
                ser.tx(ACK)
                YModemSession
                
            "L":  'Run a binary program from SD card                
                'get filename
                i:=0
                j:=0  'flag to indicate that a "." character recieved
                repeat
                  tbuf[i]:=ser.rx
                  if (tbuf[i]==".")
                    j:=i
                until tbuf[i++]==0
                if j==0  'extension not given, so adding it
                  bytemove(@tbuf[i-1],string(".bin"),5)
                  
                if (bMountFailure)
                  bMountFailure:=\SD.mountSD  'try again to mount SD card
                if (bMountFailure)                
                  ser.tx(NAK)  'something wrong with SD
                else                    
                  ser.tx(ACK) 'OK   'give ack now because about to run another program!
                  i:=SD.bootFile(@tbuf) 'run program
                  
            "F":  'run femtobasic from SD card            
                if (bMountFailure)
                  bMountFailure:=\SD.mountSD  'try again to mount SD card
                if (bMountFailure)                
                  ser.tx(NAK)  'something wrong with SD
                else  
                  ser.tx(ACK) 'OK   'give ack now because about to run another program!    
                  SD.bootFile(string("fBasic.bin")) 'run program
              
            "S":  'Save screen as 24-bit Windows Bitmap to sd card
                'get filename
                i:=0
                j:=0  'flag to indicate that a "." character recieved
                repeat
                  tbuf[i]:=ser.rx
                  if (tbuf[i]==".")
                    j:=i
                until tbuf[i++]==0
                if j==0  'extension not given, so adding it
                  bytemove(@tbuf[i-1],string(".bmp"),5)
                  
                if (bMountFailure)
                  bMountFailure:=\SD.mountSD  'try again to mount SD card
                if (bMountFailure)                
                  ser.tx(NAK)  'something wrong with SD
                else
                  if sd.popen(@tbuf,"w")<>0
                    ser.tx(NAK)
                  else
                    ser.tx(ACK) 'OK   'give ack now because about to take some time and write file
                    PrintScreen

            "R":  'Open file on SD card for reading                                
                'get filename
                i:=0
                repeat
                  tbuf[i]:=ser.rx
                until tbuf[i++]==0
                if (bMountFailure)
                  bMountFailure:=\SD.mountSD  'try again to mount SD card
                if (bMountFailure)                
                  ser.tx(NAK)  'something wrong with SD
                else
                  if sd.popen(@tbuf,"r")<0
                    ser.tx(NAK)
                  else
                    ser.tx(ACK) 'OK   'give ack now because about to take some time and write file

            "W":  'Open file on SD card for writing                               
                'get filename
                i:=0
                repeat
                  tbuf[i]:=ser.rx
                until tbuf[i++]==0
                if (bMountFailure)
                  bMountFailure:=\SD.mountSD  'try again to mount SD card
                if (bMountFailure)                
                  ser.tx(NAK)  'something wrong with SD
                else
                  if sd.popen(@tbuf,"w")<>0
                    ser.tx(NAK)
                  else
                    ser.tx(ACK) 'OK   'give ack now because about to take some time and write file

            "E":  'Erase file on SD card                               
                'get filename
                i:=0
                repeat
                  tbuf[i]:=ser.rx
                until tbuf[i++]==0
                if (bMountFailure)
                  bMountFailure:=\SD.mountSD  'try again to mount SD card
                if (bMountFailure)                
                  ser.tx(NAK)  'something wrong with SD
                else
                  if sd.popen(@tbuf,"d")<>0
                    ser.tx(NAK)
                  else
                    ser.tx(ACK) 'OK   'give ack now because about to take some time and write file
                    
            "C":  'close open file on SD card
                sd.pclose
                ser.tx(ACK)

            "r":  'Read bytes from SD card file   (up to 255)
               'file must have already been opened with @R command
               i:=ser.rx  'get # bytes to read
               repeat i
                 j:=sd.pgetc
                 ser.tx(j)
               ser.tx(ACK)

            "w":  'Write bytes to SD card file   (up to 255) 
               'file must have already been opened with @W command
               i:=ser.rx  'get # bytes to write
               repeat i
                 j:=ser.rx
                 sd.pputc(j)
               ser.tx(ACK)

                               
                   
                    
      other:    'Unknown command 
         ser.tx(NAK)    'Send NAK                         
       

PUB PrintScreen|x,y,c   'saves display to windows bitmap on SD card file already opened
  'note that this routine is not optimized and takes about 10 seconds to complete!
  'First, write the header 
  biWidth:=96
  biHeight:=64
  bfSize:=biWidth*biHeight*3+54  
  sd.pwrite(@bfType,2)
  sd.pwrite(@bfSize,4)   
  sd.pwrite(@bfReserved1,2)   
  sd.pwrite(@bfReserved2,2)   
  sd.pwrite(@bfOffBits,4)   
  sd.pwrite(@biSize,4)   
  sd.pwrite(@biWidth,4)   
  sd.pwrite(@biHeight,4)   
  sd.pwrite(@biPlanes,2)   
  sd.pwrite(@biBitCount,2)   
  sd.pwrite(@biCompression,4)   
  sd.pwrite(@biSizeImage,4)   
  sd.pwrite(@biXPelsPerMeter,4)   
  sd.pwrite(@biYPelsPerMeter,4)
  sd.pwrite(@biClrUsed,4)   
  sd.pwrite(@biClrImportant,4)
  
  'next, spit out 24-bit color pixels (in reverse order) 
  repeat y from biHeight-1 to 0 
      'vertical line loop
      repeat x from 0 to biWidth-1   'biWidth*3 should be multiple of 4 to avoid padding
        'horizontal loop  
        c:=oled.GetPixelA(x,y)  'do a dummy pixel read (required by controller for pipelining)
        c:=oled.GetPixelA(x,y)  'real pixel read
        RGB_r:=oled.RValue(c)
        RGB_g:=oled.GValue(c)
        RGB_b:=oled.BValue(c)        
        sd.pwrite(@RGB,3)
  sd.pclose 


PUB Slideshow(X,Y,delay,sFilename)|i,j,w,h,mode,bytesread,rx
'Display images from a data file onto the screen as a slideshow
    rx:=ser.rxcheck  'this will stay negative until a byte is sent (indicator to stop show)

    if delay<1
      delay:=1  'enforce minimum delay
    
    'this is much faster than BMP display because data is already in correct format...
    repeat 
      i:=\sd.popen(sFilename,"r") 'open image for reading
      if i<>0  'check for open failure      
        return i
        
      w:=sd.pgetc  'width of images
      h:=sd.pgetc  'height of images 
      mode:=sd.pgetc  '8 or 16 bits /pixel
      if mode==8
        bytesread:=w  'flag to indicate when end of file reached
      else
        bytesread:=w*2
       
      case mode
        8:  '8 bits per pixel
          'Need to switch to 8-bit (256 color) mode for a moment
            'Note that this breaks the screen rotation scheme...   
          Oled.Write_cmd(Oled#REMAP_COLOUR_SETTINGS)               ' Set Re-map Color/Depth
          Oled.Write_cmd(Oled#_256_COLOURS)
          Oled.Set_GRAM_Access (x, x+w-1, y, y+h-1)
          Oled.Write_Start_GRAM
          repeat until (bytesread<w) or (rx=>0)
            repeat h 
              bytesread:=sd.pRead(@lineBuffer,w)
                if (bytesread<w)
                  quit
              Oled.Write_GRAM_Bytes(@lineBuffer,w)  'using assembly to speed it up
            waitcnt(cnt+(clkfreq/1000)*delay)
            rx:=ser.rxcheck              
          Oled.Write_Stop_GRAM 
          'Now, go back to the usual 16-bit color
          Oled.Write_cmd(Oled#REMAP_COLOUR_SETTINGS)               ' Set Re-map Color/Depth     
          Oled.Write_cmd(Oled#_65K_COLOURS)      
           
        16:  '16 bits per pixel
          Oled.Set_GRAM_Access (x, x+w-1, y, y+h-1)
          Oled.Write_Start_GRAM
          repeat until (bytesread<(w*2)) or (rx=>0)  
            repeat h
              bytesread:=sd.pRead(@lineBuffer,w*2)
              if (bytesread<(w*2))
                quit
              Oled.Write_GRAM_Words(@lineBuffer,w)   'using assembly to speed it up
            waitcnt(cnt+(clkfreq/1000)*delay)
            rx:=ser.rxcheck  
          Oled.Write_Stop_GRAM   
        
      sd.pclose
      
    until rx=>0  'keep going until a byte is received   
    return 0  
  
PUB Image(X,Y,sFilename)|i,j,w,h,mode
'Draw a image from data file onto the screen
    'this is much faster than BMP display because data is already in correct format...
    i:=\sd.popen(sFilename,"r") 'open image for reading
    if i<>0  'check for open failure      
      return i
      
    w:=sd.pgetc
    h:=sd.pgetc 
    mode:=sd.pgetc 


    case mode
      8:  '8 bits per pixel
        'Need to switch to 8-bit (256 color) mode for a moment
          'Note that this breaks the screen rotation scheme...   
        Oled.Write_cmd(Oled#REMAP_COLOUR_SETTINGS)               ' Set Re-map Color/Depth
        Oled.Write_cmd(Oled#_256_COLOURS)
        Oled.Set_GRAM_Access (x, x+w-1, y, y+h-1)
        Oled.Write_Start_GRAM
        repeat h 
          sd.pRead(@lineBuffer,w)
          Oled.Write_GRAM_Bytes(@lineBuffer,w)  'using assembly to speed it up
        Oled.Write_Stop_GRAM 
        'Now, go back to the usual 16-bit color
        Oled.Write_cmd(Oled#REMAP_COLOUR_SETTINGS)               ' Set Re-map Color/Depth     
        Oled.Write_cmd(Oled#_65K_COLOURS)      
         
      16:  '16 bits per pixel
        Oled.Set_GRAM_Access (x, x+w-1, y, y+h-1)
        Oled.Write_Start_GRAM
        repeat h
          sd.pRead(@lineBuffer,w*2)
          Oled.Write_GRAM_Words(@lineBuffer,w)   'using assembly to speed it up  
        Oled.Write_Stop_GRAM   
      
    sd.pclose
    return 0  
    
PUB EmbeddedImage(X,Y,pDat)|i,j,w,h,mode
'Draw a image from embedded data file onto the screen
    w:=byte[pDat++]
    h:=byte[pDat++] 
    mode:=byte[pDat++] 


    case mode
      8:  '8 bits per pixel
        'Need to switch to 8-bit (256 color) mode for a moment   
        Oled.Write_cmd(Oled#REMAP_COLOUR_SETTINGS)               ' Set Re-map Color/Depth
        Oled.Write_cmd(Oled#_256_COLOURS)
        Oled.Set_GRAM_Access (x, x+w-1, y, y+h-1)
        Oled.Write_Start_GRAM
        repeat h 
          Oled.Write_GRAM_Bytes(pDat,w)  'using assembly to speed it up
          pDat+=w
        Oled.Write_Stop_GRAM 
        'Now, go back to the usual 16-bit color
        Oled.Write_cmd(Oled#REMAP_COLOUR_SETTINGS)               ' Set Re-map Color/Depth     
        Oled.Write_cmd(Oled#_65K_COLOURS)      
         
      16:  '16 bits per pixel
        Oled.Set_GRAM_Access (x, x+w-1, y, y+h-1)
        Oled.Write_Start_GRAM
        repeat h
          Oled.Write_GRAM_Words(pDat,w)   'using assembly to speed it up
          pDat+=w<<1  
        Oled.Write_Stop_GRAM   

    return 0      
      

PUB BMP(X,Y,sFilename)|i,j,r,g,b,c,d
'Draw a bitmap file onto the screen
    'note that bitmaps are stored from bottom line to top line!
    i:=\sd.popen(sFilename,"r") 'open image for reading
    if i<>0
      return i   
    sd.pread(@bfType,2) 'read bmp header
    sd.pread(@bfSize,4) 'read bmp header  
    sd.pread(@bfReserved1,4) 'read bmp header  
    sd.pread(@bfOffBits,16) 'read bmp header
    sd.pread(@biPlanes,4)
    sd.pread(@biCompression,24)  



    if (biHeight<1) or (biWidth<1)
      return -1  'some kind of problem
      
    case biBitCount
      24:  'true color (3 bytes per pixel)
        repeat j from biHeight+y-1 to y 
          'point to current row
          Oled.Set_GRAM_Access (x, 95, j, 63)
          Oled.Write_Start_GRAM
          'adding assembly function to speed this up...
          sd.pRead(@lineBuffer,biWidth*3) 
          Oled.Write_Gram_BMP24(@lineBuffer,biWidth)
          'commented out here is the non-assembly version...
          'repeat i from x to biWidth-1+x   
          '  b:=sd.pgetc  'read one pixel of color
          '  g:=sd.pgetc  'read one pixel of color
          '  r:=sd.pgetc  'read one pixel of color
          '  R := Oled.RGB(R,G,B)  ' Convert R,G,B to 16 bit color 
          '  Oled.Write_GRAM_Word(r.word[0])
          Oled.Write_Stop_GRAM
          i:=biWidth//4
          repeat while i>0  'note that each line is padded to have an even # of longs  
            sd.pgetc
            i--
      8:  '256-Palette mode
        'first need to read in palette  (rgbquad (4 bytes) * # pallete entries)
        'calculate actual bytes in palette
        i:=bfOffBits-54
        'read in palette
        sd.pread(@BmpPalette,i)
        'now paint picture
        repeat j from biHeight+y-1 to y 
          'point to current row
          Oled.Set_GRAM_Access (x, 95, j, 63)
          Oled.Write_Start_GRAM   
          repeat i from x to biWidth+x-1
            c:=sd.pgetc  'read in next pixel
            c:=BmpPalette[c]  'get RGBQuad
            b:=c.byte[0]  
            g:=c.byte[1]  
            r:=c.byte[2]  
            R := Oled.RGB(R,G,B)  ' Convert R,G,B to 16 bit color 
            Oled.Write_GRAM_Word(r.word[0])
          Oled.Write_Stop_GRAM
          i:=biWidth//4
          repeat while i>0  'note that each line is padded to have an even # of longs  
            sd.pgetc
            i--
      4:  '16-Palette mode
        'first need to read in palette  (rgbquad (4 bytes) * # pallete entries)
        'calculate actual bytes in palette
        i:=bfOffBits-54
        'read in palette
        sd.pread(@BmpPalette,i)
        'now paint picture
        repeat j from biHeight+y-1 to y 
          'point to current row
          Oled.Set_GRAM_Access (x, 95, j, 63)
          Oled.Write_Start_GRAM   
          repeat i from x to biWidth+x-1 step 2
            c:=sd.pgetc  'read in next pixel
            d:=BmpPalette[c>>4]  'get RGBQuad of first pixel
            b:=d.byte[0]  
            g:=d.byte[1]  
            r:=d.byte[2]  
            R := Oled.RGB(R,G,B)  ' Convert R,G,B to 16 bit color 
            Oled.Write_GRAM_Word(r.word[0])
            d:=BmpPalette[c&$F]  'get RGBQuad of second pixel
            b:=d.byte[0]  
            g:=d.byte[1]  
            r:=d.byte[2]  
            R := Oled.RGB(R,G,B)  ' Convert R,G,B to 16 bit color 
            Oled.Write_GRAM_Word(r.word[0])           
          Oled.Write_Stop_GRAM
          i:=biWidth//4
          repeat while i>0  'note that each line is padded to have an even # of longs  
            sd.pgetc
            i--
        
    sd.pclose
    return 0

PRI AutoBaudDetect:bDetected|t0,cog
  'Detect baud rate of host, knowing that a "U"=$55 is being sent
  'can detect up to 57600 baud
  'Returns true when detected
  'init vars
  bBaudAutoDetected:=false
  'Wait up to AutoBaudTimeout (see CON section) seconds then returns false
  t0:=cnt  'record start time
  'launch cog to wait for "U" character
  cog:=cognew(BaudDetect,@stack)

  'monitor detection progress
  repeat
    if bBaudAutoDetected==true
      quit
    if (cnt-t0)>(AutoBaudTimeout*clkfreq)
      'times up
      cogstop(cog)
      return false
    
  return true  
    
    
  
PRI BaudDetect|t1,t2,t3,t4,i,ClocksPerBit,mask
  'Do the detection of "U"=$55 character
  'SPIN with this clock setting can detect up to 57600 baud
  mask:=1<<RxPin  'generate bit mask for waitpeq command
  repeat  'can loop forever because main routine will kill this cog after 5 seconds  
    'first wait for pin to go low     
    waitpeq(0, mask, 0)
    t1:=cnt
    'then wait to go high
    waitpeq(mask, mask, 0)
    t2:=cnt
    'wait for pin to go low
    waitpeq(0, mask, 0)
    t3:=cnt
    'wait to go high
    waitpeq(mask, mask, 0)
    t4:=cnt 
     
    'examine time differences to see if they make sense for some baud rate
    t1:=t2-t1 
    t2:=t3-t2
    t3:=t4-t3
    'test to make sure other values match t1
    if ((||(t1-t2))<100) and  ((||(t1-t3))<100)
      'Now, see what baud rate it is
      repeat i from 1 to 9
        BaudRate:=lookup(i: 300, 600, 1200, 2400, 4800, 9600, 19200, 38400, 57600)
        ClocksPerBit:=clkfreq/BaudRate
        if t1<(ClocksPerBit*120/100) and t1>(ClocksPerBit*80/100)
           bBaudAutoDetected:=true  'flag that baud rate found    
           return  'this will kill this cog


PUB Splash

   
  oled.putChar ("u", 2,5,1, 255,255,255)
  oled.putChar ("O", 3,5,1, 255,0,0)
  oled.putChar ("L", 4,5,1, 0,255,0)
  oled.putChar ("E", 5,5,1, 0,0,255)

  
  oled.putChar ("D", 6,5,1, 255,255,0)
  oled.putChar ("-", 7,5,1, 255,255,255)
  oled.putChar ("9", 8,5,1, 255,255,255)
  oled.putChar ("6", 9,5,1, 255,255,255)
   
  oled.putChar ("P", 4,7,1, 255,0,0)
  oled.putChar ("R", 5,7,1, 255,0,0)  
  oled.putChar ("O", 6,7,1, 255,0,0)  
  oled.putChar ("P", 7,7,1, 255,0,0) 
   
  EmbeddedImage(28,3,@logo)


        

CON  'Ymodem Constants Section

  'XMODEM chars from ymodem.txt
  SOH=$01
  STX=$02
  EOT=$04
  'ACK=$06
  'NAK=$15
  CAN=$18
  Cee=$43  'liberties here
  Zee=$1A  'or SUB  (DOS EOF?)


var  'Ymodem variables
   'byte tbuf[20]
   'byte stack[100]
   long Mounted
   byte fbuf[30]
   byte sbuf[30]
   byte pdata[1028] 'packet data

PUB YModemSession|cog,key,crc,i,z   
  'start a ymodem session with terminal client (such as Hyperterminal)
  'using existing serial connection 


   'Establish serial link (wait for client to hit spacebar)
  key:=0
  repeat until key==32
    waitcnt(cnt+clkfreq)
    ser.str(string(27,"[2J Hit spacebar to begin.  "))',10,13))
    repeat 
      key:=ser.rxcheck
    while key>0 and key<>32
    
  'Show welcome logo
  ser.str(string(27,"[2J Welcome to the YModem file transfer utility!",10,13))

  'use a new cog to try to mount SD card (because it can hang if it fails)
  Mounted:=-1
  repeat until Mounted==0
    cog:=cognew(Mount,@stack)
    waitcnt(cnt+clkfreq/2)  'give it a moment
    cogstop(cog)  'force it to terminate
     
    if Mounted<>0
      Waitkey(32,string("SD Card Mount Failed:  Press spacebar to retry",10,13))

  waitcnt(cnt+clkfreq/2)  'let user soak it up for a second

  Repeat
    'Show welcome logo again
    ser.str(string(27,"[2J      YModem Utility Menu",10,13))
    ser.str(string(       "=============================", 13,10,13))
    ser.str(string(       "D = Directory of SD card", 13,10))
    ser.str(string(       "S = Send files to SD card", 13,10))
    ser.str(string(       "R = Receive a file from SD card", 13,10))
    ser.str(string(       "X = Erase file on SD card", 13,10)) 
    ser.str(string(       "Q = Quit", 13,10))   
    key:=0
    repeat
      key:=ser.rxcheck
    until key>0
    case key
      "D","d": 'directory
        dir
      "Q","q": 'quit
        ser.str(string(27,"[2J Quitted."))
        'sd.stop  'Not actually stopping, just returning control to main routine...
        'ser.stop
        return 'all done
      "R","r":  'receive file
        Receive 
      "S","s":  'send file
        Send
      "X","x":  'erase file
        Erase
         
     
    Waitkey(32,string(13,10,"Press spacebar to continue",13,10))

PUB erase|key,i
  ser.str(string(13,10,"Erase a file from SD card."))
  ser.str(string(13,10,">Enter filename in 8.3 format (press ESC to abort):"))
  key:=0
  i:=0
  
  repeat until key==13
    key:=ser.rx
    if (key==27)
      ser.str(string(13,10,"Aborted by keystroke."))
      return 'abort
    ser.tx(key)
    if key<>13
      fbuf[i++]:=key
    else
      fbuf[i]:=0  'append end of string mark

  if strsize(@fbuf)>12
      ser.str(string(13,10,"Filename too long!  Use 8.3 format."))
      return 'fail

  ser.str(string(13,10,"Are you sure? (Y/N)"))
  i:=ser.rx
  if i<>"Y" and i<>"y"
    ser.str(string(13,10,"Aborted by keystroke."))
    return

  i:=sd.popen(@fbuf,"d")
  if i<0
    ser.str(string(13,10,"Erase Failed."))
  else
    ser.str(string(13,10,"Erase Complete."))

  return  

      

PUB send|key,i,packet,crc,j,k,timer,bytes,done
  'get file from computer and save to SD
  'Ymodem protocol: http://timeline.textfiles.com/1988/10/14/1/FILES/ymodem.txt

  ser.str(string(13,10,"Send file via ymodem within 15 seconds..."))
  repeat  'batch reception loop
    'wait for first packet
    packet:=0
    repeat until packet==1
      key:=0
        waitcnt(cnt+clkfreq*15)   'give user 15 seconds to initiate transfer
        ser.tx(Cee)
        timer:=cnt
        repeat until i==SOH
          i:=ser.rxcheck
          if i>0
            key:=i
          if (cnt-timer)>clkfreq*5   '5 second timeout
            ser.tx(EOT)
            ser.str(string(13,10,"No response from host... Aborting."))
            return
      'analyze first packet
      if (ser.rx==0)
        if (ser.rx==$FF)

          crc:=0
          j:=0
          i:=-1
          done:=0
          'filename
          repeat until i==0
            i:=ser.rx
            if i==0 and j==0
              'End of session
              done:=1
            fbuf[j++]:=i
            crc:=UpdateCRC(i,crc)
            
          i:=-1
          k:=j
          j:=0

          repeat until i==0 or i==32
            i:=ser.rx
            if i<>32
              sbuf[j++]:=i
            else
              sbuf[j++]:=0
            crc:=UpdateCRC(i,crc)
          k+=j

          bytes:=num.fromstr(@sbuf,num#dec)
     

          
          repeat j from k+1 to 128
            i:=ser.rx
            crc:=UpdateCRC(i,crc)
        else
          ser.tx(NAK)
      else
        ser.tx(NAK)
 
      i:=ser.rx

      j:=ser.rx

      if i<>(crc>>8) or j<>(crc&$FF)
        ser.tx(NAK)

        
      else
        packet:=1
     

    ser.tx(ACK)
     
    if done==1
      ser.str(string("Batch file reception complete."))
      return 
     
     
    ser.tx(Cee)
     
    'open output file
    if sd.popen(@fbuf,"w")<0

      ser.tx(EOT)
      ser.str(string("Can't open file... Aborting."))
      return
      
    'receive packets
    k:=0
    repeat until k==EOT
      k:=ser.rx
      if k==SOH
        '128 byte packets
        packet:=ser.rx
        i:=ser.rx
        if (255-i)<>packet

          repeat
        else
          'text.str(string("Good packet header"))
        crc:=0
        repeat j from 0 to 127

          i:=ser.rx
          crc:=UpdateCRC(i,crc)
          pdata[j]:=i
        i:=ser.rx
        j:=ser.rx
        if i<>(crc>>8) or j<>(crc&$FF)
          ser.tx(NAK)

        else
          'write data
          if bytes>128
            sd.pwrite(@pdata,128)
            bytes-=128
          else
            sd.pwrite(@pdata,bytes)
            bytes:=0
          'get more
          ser.tx(ACK)
      else
        if k==STX
          '1024 byte packets
          repeat j from 0 to 1027
            pdata[j]:=ser.rx
           
          packet:=pdata[0]
          i:=pdata[1]
          if (255-i)<>packet

            repeat


          crc:=0
          repeat j from 2 to 1025
            i:=pdata[j]
            crc:=UpdateCRC(i,crc)
          i:=pdata[1026]
          j:=pdata[1027]
          if i<>(crc>>8) or j<>(crc&$FF)
            ser.tx(NAK)
          else
            'write data
            if bytes>1024
              sd.pwrite(@pdata+2,1024)
              bytes-=1024
            else
              sd.pwrite(@pdata+2,bytes)
              bytes:=0
            'get more
            ser.tx(ACK)

          

    ser.tx(ACK)
    sd.pclose 
  
      
                
  
    
    
  

  

PUB receive|key,i,size,seconds,timer,packet,d,crc,p,j,k,deot
  'Ymodem protocol: http://timeline.textfiles.com/1988/10/14/1/FILES/ymodem.txt
  '                 http://en.wikipedia.org/wiki/XMODEM
  
  ser.str(string(13,10,"Receive a file from SD card."))
  ser.str(string(13,10,">Enter filename in 8.3 format (press ESC to abort):"))
  key:=0
  i:=0
  
  repeat until key==13
    key:=ser.rx
    if (key==27)
      ser.str(string(13,10,"Aborted by keystroke."))
      return 'abort
    ser.tx(key)
    if key<>13
      fbuf[i++]:=key
    else
      fbuf[i]:=0  'append end of string mark

  if strsize(@fbuf)>12
      ser.str(string(13,10,"Filename too long!  Use 8.3 format."))
      return 'fail       


  'Transmit file to host
  if sd.popen(@fbuf,"r")<>0
    ser.str(string(13,10,"File not found!"))
    return 'fail
  size:=sd.fsize
  ser.str(string(13,10,"Transmitting file.  Instruct terminal to receive YMODEM file now."))

  
  timer:=cnt
  key:=0
  'Wait for NAK from host:  Signal to start sending
  repeat until key==Cee
    i:=ser.rxcheck
    if i>0
      key:=i
    i:=cnt
    if ((cnt-timer)/clkfreq)>30           '30 second timeout
      ser.str(string(13,10,"Failure.  No response from host.."))
      return 'fail  

  
  'start sending packets
  packet:=0
  repeat
    timer:=cnt
    crc:=0
    deot:=false  
    'send header
    ser.tx(SOH)
    ser.tx(packet)
    ser.tx(!packet)

    'construct packet
    if packet==0
      'Send filename and length
      i:=strsize(@fbuf)
      bytemove(@pdata,@fbuf,i+1)
      p:=num.tostr(size,num#DEC)
      j:=strsize(p)
      bytemove(@pdata+i+1,p,j+1)
      repeat k from i+1+j+1 to 128
        pdata[k]:=0
    else  
      'data packet
      repeat i from 0 to 127
        d:=sd.pgetc
        if d==-1
          'end of file
          repeat i from i to 127
            d:=EOT'Zee
            pdata[i]:=d
            deot:=true
          quit          
        else
          if d<0 
            d:=EOT
            ser.tx(d)
            return 'fail      

        pdata[i]:=d

    'send packet
    repeat i from 0 to 127
      ser.tx(pdata[i])

      crc:=UpdateCRC(pdata[i],crc)
       

    ser.tx((crc>>8)&$FF)
    ser.tx(crc&$FF)
    

    repeat
      i:=ser.rxcheck
      if i==ACK
        quit
      if i==NAK
        'retransmit packet
        repeat i from 0 to 127
          ser.tx(pdata[i])
          ser.tx((crc>>8)&$FF)
          ser.tx(crc&$FF)
      if ((cnt-timer)/clkfreq)>10
        ser.tx(EOT)
        ser.str(string(13,10,"Timeout failure."))
        return 'fail
    if (deot==true)'Zee) 'done
      quit
    else
      packet++
      timer:=cnt
    

  'send EOT wait for ACK and send end of batch packet
  ser.tx(EOT)
  repeat
    i:=ser.rxcheck
    if i==ACK
      'now, wait for "C"
      timer:=cnt
      key:=0
      repeat until key==Cee
        i:=ser.rxcheck
        if i>0
          key:=i
        i:=cnt
        if ((cnt-timer)/clkfreq)>10           '10 second timeout
          ser.str(string(13,10,"Failure.  No response from host.."))
          return 'fail
      'now, transmit null packet and wait for ACK
      key:=0
      repeat until key==ACK
        ser.tx(SOH)
        ser.tx(0)
        ser.tx($FF)
        crc:=0
        repeat 128
          ser.tx(0)
          crc:=UpdateCRC(0,crc)
        ser.tx((crc>>8)&$FF)
        ser.tx(crc&$FF)
        'wait for ack
        key:=ser.rx
        if key<>ACK and key<>NAK
          return 'fail  
      quit  'all done!
    if i>0
      ser.tx(EOT)

  ser.str(string(13,10,"YModem receive from SD complete.",13,10))

    
      
    
PRI UpdateCRC(data,crc):newcrc|i,icrc
 'look here:http://web.mit.edu/6.115/www/miscfiles/amulet/amulet-help/xmodem.htm

  crc:=crc^(data<<8)
  repeat i from 0 to 7
    if crc&$8000
      crc:=((crc<<1)&$FFFF)^$1021
    else
      crc:=(crc<<=1)&$FFFF

  return crc&$FFFF


          
      
      


PUB Mount|key

  'Try to mount SD card

  Mounted:=sd.mountSD
  case Mounted
    -20: ' not a fat16 volume
      ser.str(string("Error:  Not a FAT16 volume.",10,13))
    -21: ' bad bytes per sector
      ser.str(string("Error:  Bad bytes per sector.",10,13))
    -22: ' bad sectors per cluster  
      ser.str(string("Error:  Bad sectors per cluster.",10,13))
    -23: ' bad bytes per sector
      ser.str(string("Error:  Missing second FAT.",10,13))
    -24: ' bad FAT signature
      ser.str(string("Error:  Bad FAT signature.",10,13))
    -25: ' bad FAT signature
      ser.str(string("Error:  Too many clusters.",10,13))
    0:  'OK
      ser.str(string("SD card mounted successfully.",10,13))
  




pub dir|lines,key,total,size,i
  lines:=0   
  ser.str(string(27,"[2J Directory of SD Card: ", 13,10))
  ser.str(string("===================================", 13,10))
  ser.str(string("Filename        Size in Bytes", 13,10))
  ser.str(string("------------    -------------", 13,10))

  
  sd.opendir
  repeat while 0 == sd.nextfile(@tbuf)
    repeat 12-strsize(@tbuf)
     ser.tx(" ")
    ser.str(@tbuf)
    ser.str(string("   "))
    size:=sd.fsize
    total+=size
    ser.str(num.tostr(size,num#DSDEC14))
    ser.tx(13)
    ser.tx(10)
    if ++lines>20
      Waitkey(32,string(13,10,"Press spacebar to continue",13,10))
      lines:=0

  'Show total bytes  
  ser.str(string(13,10,10,"Total: "))
  ser.str(num.tostr(total,num#DSDEC14))   
  ser.str(string("  bytes"))
      

Pub Waitkey(k,str)|key  'show string and wait for key=k
  ser.str(str)
  key:=0
  repeat until key==k
    repeat 
      key:=ser.rxcheck
    while key>0 and key<>k   

    
DAT

UserBitmappedChars byte
        byte 0[32*8]  '32 user characters that are 8x8 bits (or 8 bytes each)

BMPHeader  byte 'Mostly using info from here:  http://www.fortunecity.com/skyscraper/windows/364/bmpffrmt.html
bfType byte "B","M"  ' 19778
bfSize long 0
bfReserved1 word 0
bfReserved2 word 0
bfOffBits long 54
biSize long 40
biWidth long 0
biHeight long 10
biPlanes word 1
biBitCount word 24
biCompression long 0
biSizeImage long 0
biXPelsPerMeter long 0
biYPelsPerMeter long 0
biClrUsed long 0
biClrImportant long 0

RGB byte  'used for writing 24-bit color data
RGB_b byte 0
RGB_g byte 0
RGB_r byte 0

BmpPalette long 0[256]      'container for bmp palette entries

logo byte    'embedded Propeller hat logo image
file "PropLogo.dat"

{{
                            TERMS OF USE: MIT License

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
}}
   