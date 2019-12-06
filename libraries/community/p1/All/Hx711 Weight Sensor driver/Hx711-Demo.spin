{{
 Sample code for Hx711

 Demo project for the Weight Sensor Module Product Code: SEN0160 Brand: DFRobot
 
 http://www.dfrobot.com/index.php?route=product/product&product_id=1031#.Us57pPQW2yn
 
 
<Revision>
- 0.1

<Author>
- Lee McLaren
 

}}
CON
_clkmode = xtal1 + pll16x
_xinfreq = 5_000_000

  DB = 0                      ' DEBUG port number, for fullDuplexSerial4port to use when sending to terminal
  DBAUD = 115_200             ' has to match the terminal program on the other end
  DRX_PIN = 31
  DTX_PIN = 30

  CR = 13                     ' new line
  SP = 32                     ' space


OBJ
  fds : "fullDuplexSerial4port"
  dio : "dataIO4port"
  wei : "Hx711"
   
                       
VAR

                              
PUB Main | AccValue, RChar

  start_uarts

  wei.start(5,4)                                  ' start and specify data and clock pins

  pause(3000)

  fds.str(DB, string(CR,"Starting", CR))

  repeat
    RChar := fds.rxcheck(DB)                        ' main loop for ever
    if RChar <> -1
      case RChar
        "z":                                        ' if you send a 'z' the scale will be zeroed
          fds.str(DB, string(CR,"Zero:"))
          dio.decx(DB,wei.ZeroOffset,6)
          fds.str(DB, string(CR))

    dio.decDp(DB,wei.ReadSmooth(49) ,2)             ' print the smoothed value
    fds.str(DB, string(CR))

PUB start_uarts
'' port 0-3 port index of which serial port
'' rx/tx/cts/rtspin pin number                          #PINNOTUSED = -1  if not used
'' prop debug port rx on p31, tx on p30
'' cts is prop input associated with tx output flow control
'' rts is prop output associated with rx input flow control
'' rtsthreshold - buffer threshold before rts is used   #DEFAULTTHRSHOLD = 0 means use default=buffer 3/4 full
''                                                      note rtsthreshold has no effect unless RTS pin is enabled
'' mode bit 0 = invert rx                               #INVERTRX  bit mask
'' mode bit 1 = invert tx                               #INVERTTX  bit mask
'' mode bit 2 = open-drain/source tx                    #OCTX   bit mask
'' mode bit 3 = ignore tx echo on rx                    #NOECHO   bit mask
'' mode bit 4 = invert cts                              #INVERTCTS   bit mask
'' mode bit 5 = invert rts                              #INVERTRTS   bit mask
'' baudrate                                             desired baud rate, e.g. 9600

  fds.init                        ' sets up and clears the buffers and pointers, returns a pointer to the internal fds data structure
                                  ' always call init before adding or starting ports.

  fds.AddPort(DB, DRX_PIN, DTX_PIN,-1,-1,0,0,DBAUD) ' debug to the terminal screen, without flow control, normal non-inverted mode
  fds.Start
  pause(100)   ' delay to get going before sending or receiving any data

PUB pause(ms)

  waitcnt(clkfreq/1000*ms + cnt)

dat
 