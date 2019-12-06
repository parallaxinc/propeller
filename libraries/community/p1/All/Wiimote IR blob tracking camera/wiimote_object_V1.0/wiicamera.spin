{{
Wiimote camera object v1.0
Graham Stabler  17th November 2009

The Nintendo Wii games console remote or "wiimote" includes an amazing piece of hardware
a small camera capable of tracking 4 blobs of light simultaneously at about 200hz.
The co-ordinates of these points along with other data are communicated to the wiimote
electronics via an industry standard I2C interface.  This means that if we remove the
camera we can interface it straight to the propeller.  And because
the propeller is so awesome we only need a single pull up resistor to do so!
____________________________________________________________________________________________
Camera specs:

Manufacturer: Pixart 
Camera pixel resolution: 128 X 96
Translates to blob positioning resolution: 1024 X 768
I2C bus: 400khz max
____________________________________________________________________________________________

How to wire up the wiimote camera:    

* Remove camera from wiimote carefully using hot air of solder wick.

* Pin out when viewed from the underside is:
            ____________
     ______|____________|_______
    |                           |
    |        7   5   3   1      |
    |      8   6   4   2        |
    |                           |
    |___________________________|

1:  Vcc (3.3V)
2:  GND
3:  GND
4:  Not connected
5:  SCL (Clock of I2C bus)
6:  SDA (Data line of I2C bus)
7:  CLK (Requires a 25Mhz clock, supplied by propeller!)
8:  !Reset (Active low reset pulled high by propeller but you could use a resistor).

Connections:
Wire Vcc and GND to the supply of propeller
Wire SCL to a propeller IO pin of your choice, note SDA pin must be one pin higher.
Wire SDA to the pin one higher than SCL (so if SCL is P0, SDA must be P1)
Add a 10k(approx) pull up from SDA line to Vcc (3.3v)
Wire CLK to a propeller IO pin of your choice
Wire Reset to a propeller IO pin of your choice (or use a pull up resisitor and capacitor)

____________________________________________________________________________________________
How to use the code:

1. Create an small array to contain the returned data
   mode 1 needs 8 longs. Mode 3 needs 12 and mode 5 needs 32
2. Create an array in the dat section for your sensitivity settings (see demo for examples)   
3. Include this object and run the start function: start(scl,clk,reset)
   Where scl is your scl pin, clk your 25Mhz clock pin and reset the reset pin.
4. Initialize the camera: initcam(scl,mode, settings)
   Where scl is the scl pin, mode is your chosen output format mode and settings is the address of your settings
   which will be stored in the DAT section of your code (see the demo program)
5. To get data run: getblobs(outaddr)
   Where outaddr is the address of your array created in step 1
6. The data is now held in outaddr in the following format

     Mode 1    Mode 3     Mode 5
0      x1        x1         x1
1      y1        y1         y1
2       .        size1     size1
3       .         .        xmin1            Each of the patterns are repeated 4 times
4      etc       etc       ymin1                    (once for each blob)
5       .         .        xmax1
6       .         .        ymax1
7       .         .      intensity1
.                             .
.                           etc

You can access this data manually for example if you did:

wii.getblobs(@data)          ' Reads from wiimote into the array: data

Then data[0] would hold x1 etc

But to make things easier I have provided helper functions:

getx
gety
getsize
getxmin
getymin
getxmax
getymax
getintensity

These take the location of your data, the blob you are interested in and the read mode you are using
as arguments.  Only mode 5 returns all of this data.
_______________________________________________________________________________________________________

Info on the data format directly from the camera:

This is mainly for completeness and interest as I format the raw data into more useable data in the assembly code.

General:

There are three report modes, 1,3 and 5.  The fastest should be mode 1, mode 3, 5 provide further information.

Mode 1:

10 bytes are returned from the camera
outdata[0] -> XXXXXXXX: First eight bits of x position 1
outdata[1] -> YYYYYYYY: First eight bits of y position 1
outdata[2] -> YYXX YYXX Bits 6,7 hold bits 8 and 9 of position 1
                        bits 4,5 hold bits 8 and 9 of x position 1
                        bits 3,2 hold bits 8 and 9 of y position 2
                        bits 0,1 hold bits 8 and 9 of x position 2
outdata[3] -> XXXXXXXX: First eight bits of x position 2
outdata[4] -> YYYYYYYY: First eight bits of y position 2

This is then repeated once for the remaining two blobs.

Mode 3: extended

12 bytes are returned from the camera
outdata[0] -> XXXXXXXX: First eight bits of x position 1
outdata[1] -> YYYYYYYY: First eight bits of y position 1
outdata[2] -> YYXXSSSS: bits 6,7 hold bits 8 and 9 of y position 1
                        bits 4,5 hold bits 8 and 9 of x position 1
                        bits 0-3 hold size of the blob detected (0-15 range)

This is then repeated for each of the remaining three blobs.

Mode 5: Full

36 bytes are returned from the camera in to out_data[]
outdata[0] -> XXXXXXXX: First eight bits of x position 1
outdata[1] -> YYYYYYYY: First eight bits of y position 1
outdata[2] -> YYXXSSSS: bits 6,7 hold bits 8 and 9 of y position 1
                        bits 4,5 hold bits 8 and 9 of x position 1
                        bits 0-3 hold size of the blob detected (0-15 range)
outdata[3] -> Xmin
outdata[4] -> Ymin
outdata[5] -> Xmax
outdata[6] -> Ymax
outdata[7] -> Not used
outdata[8] -> Intensity

This is again repeated three times.

____________________________________________________________________________________________________
Acknowledgments:

I used Mike Green's Basic_I2C_Driver from object exchange for I2C comms for the spin version of this code
and it still contains some of his comments, very helpful.
Thanks to Kako's website: http://www.kako.com/neta/2008-009/2008-009.html  (use google translate) 
Wiibrew:  http://wiibrew.org/wiki/Wiimote#IR_Camera                        (good info on formats)
Wiimoteproject: http://wiki.wiimoteproject.com/IR_Sensor                   (more good info)
Note the last two look at it from the point of view of the origional hardware not direct interfacing
so may be a bit confusing.
}}

VAR
  long command,outaddr_,mode_hub,settingaddr   

PUB Start(scl,clk,reset)
{{
  Starts cog with assembly code for reading camera data.  See docs above for details of pin assignment and connection.
  Set reset to -1 if prop is not used to provide the reset. 
}}
  sclpin_   := scl
  clkpin_   := clk
  resetpin  := reset
  command   := 0
  cognew(@entry, @command)                            'Starts cog, passes pointer to globals

PUB getblobs(outaddr)
{{
  Gets the data from the camera and loads the processed data in to outaddr.  
}}
  outaddr_ := outaddr            ' asm code reads location for data from outaddr_
  command  := 2                  ' Tells asm code to do the read 
  repeat                         ' Waits until complete
  while command <> 0
  
PUB initcam (mode, settings_addr)
{{
  Initialises the camera for the required read mode and with the specified sensitivity settings
}}
  settingaddr := Settings_addr   ' asm code reads from settingaddr
  mode_hub := mode               ' and mode_hub
  command  := 1                  ' Tells the asm code to run init code
  repeat                         ' Waits until it has done so
  while command <> 0

PUB getx(data_addr,mode,blob)
{{
  Returns x for a given blob
}}
case mode
  1: return long[data_addr][blob*2]
  3: return long[data_addr][blob*3]
  5: return long[data_addr][blob*8]  

PUB gety (data_addr,mode,blob)
{{
  Returns y for a given blob
}}
case mode
  1: return long[data_addr][(blob*2)+1]
  3: return long[data_addr][(blob*3)+1]
  5: return long[data_addr][(blob*8)+1]
     
PUB getsize(data_addr,mode,blob)
{{
  Returns size of a given blob
}}
case mode
  1: return 0                            'Not supported for mode 1
  3: return long[data_addr][(blob*3)+2]
  5: return long[data_addr][(blob*8)+2]   
 
PUB getxmin(data_addr,mode,blob)
{{
  Returns smallest x value for bounding box surrounding a given blob
}} 
if mode == 5
   return long[data_addr][(blob*8)+ 3]
else
   return 0                             ' Only supported for mode 5
   
PUB getymin(data_addr,mode,blob)
{{
  Returns smallest y value for bounding box surrounding a given blob
}} 
if mode == 5
   return long[data_addr][(blob*8)+ 4]
else
   return 0                             ' Only supported for mode 5

PUB getxmax(data_addr,mode,blob)
{{
  Returns max x value for bounding box surrounding a given blob
}} 
if mode == 5
   return long[data_addr][(blob*8)+ 5]
else
   return 0                             ' Only supported for mode 5
   
PUB getymax(data_addr,mode,blob)
{{
  Returns max y value for bounding box surrounding a given blob
}} 
if mode == 5
   return long[data_addr][(blob*8)+ 6]
else
   return 0                             ' Only supported for mode 5
   
PUB getintensity(data_addr,mode,blob)
{{
  Returns intensity of a given blob
}} 

if mode == 5
   return long[data_addr][(blob*8)+ 7]
else
   return 0                             ' Only supported for mode 5
  
DAT

              ORG  0           
entry         shl  sclmask,sclpin_         'scl pin mask
              mov  sdapin_,sclpin_
              add  sdapin_,#1              'sda always the next pin
              shl  sdamask,sdapin_
              shl  clkmask,clkpin_         'Clock pin mask
              or   dira,clkmask            'Make clock pin an output
              add  clockset,clkpin_        'Set up clock
              mov  ctra,clockset
              mov  frqa,MHz25
              cmp  resetmask,minusone  wz  'If a reset pin is specified, reset      
      if_nz   call #resetcam               

'*********************MAIN LOOP********************************************
                      
:start        mov p,par               
:loop         rdlong   do,p            ' Is a command requested
              cmp     do,#1       wc
      if_c    jmp      #:loop          ' If not requested loop around
          
              cmp  do,#1     wz        ' If command is 1 = initilize camera
        if_z  call #init
              cmp  do,#2     wz        ' If command is 2 = read data from camera
        if_z  call #Readcam     

              mov   p,par
              wrlong zero,p            ' Indicate command is complete by clearing command
              jmp   #:start            ' And wait for another command

'************************************************************************
'********************    Camera routines   ******************************
'************************************************************************

'********************* InitCam function *********************************
{
The user supplies the address to an array of 11 values used to set up the
camera and these are sent to the camera along with various other commands.
There are examples in the demo program, details are sketchy!
}            
init
              add p,#8
              rdlong  mode_,p          ' Read mode
              add p,#4
              rdlong  set_addr,p       ' Address of initialisation settings
              call  #startl
              mov   data,#$B0          ' Device address
              call  #write
              mov   data,#$30          ' Control register
              call  #write
              mov   data,#$01          ' Begin config
              call  #write
              call  #stop
              call  #initdelay
              call  #startl
              mov   data,#$B0          ' Device address
              call  #write
              mov   data,#$00          ' Register $00
              call  #write

              mov   loopcount,#7
:initloop1    rdbyte  data,set_addr    'Write 7 of the values from array
              add   set_addr,#1               
              call  #write
              djnz  loopcount,#:initloop1
              call  #stop
              call  #initdelay

              call  #startl
              mov   data,#$B0          
              call  #write
              mov   data,#$07          ' Register $07              
              call  #write
              rdbyte  data,set_addr    ' Two more values from array
              add   set_addr,#1        
              call  #write
              rdbyte  data,set_addr
              add   set_addr,#1     
              call  #write
              call  #stop
              call  #initdelay

              call  #startl
              mov   data,#$B0            
              call  #write
              mov   data,#$1A            
              call  #write             ' Last two values from array
              rdbyte  data,set_addr
              add   set_addr,#1   
              call  #write
              rdbyte  data,set_addr
              add   set_addr,#1              
              call  #write                                                              
              call  #stop
              call  #initdelay

              call  #startl
              mov   data,#$B0            
              call  #write
              mov   data,#$33            
              call  #write
              mov   data,mode_        ' Read format    
              call  #write
              call  #stop
              call  #initdelay                                            

              call  #startl
              mov   data,#$B0            
              call  #write
              mov   data,#$30            
              call  #write
              mov   data,#$08        ' End of config    
              call  #write
              call  #stop                                                
              call  #initdelay
init_ret      ret

' ******************** Read data from camera ****************************** 
{
Supplies a number of commands and then calls the relevant routine to read
and format the data returned from the camera.
}
ReadCam       add   p,#4               ' Read values from hub ram
              rdlong  rtnaddr,p        ' Address where data will be written
              call  #startl            ' Initialize for read
              mov   data,#$B0
              call  #write               
              mov   data,#$36
              call  #write
              call  #stop
              call  #delay
              call  #startl
              mov   data,#$B1          ' Setting bit 0 means a read request
              call  #write              
              cmp  mode_,#1     wz
        if_z  call #format1            ' Basic
              cmp  mode_,#3     wz
        if_z  call #format3            ' Enhanced
              cmp  mode_,#5     wz
        if_z  call #format5            ' Full
ReadCam_ret   ret

' ******************** Format1 ******************************
{
Reads data from camera and formats for basic mode
} 

format1       call  #read                   ' First returned byte always empty
              mov   rtn_,rtnaddr            ' Address of element in hub array
              mov   loopcount, #2           ' We process the blobs in two pairs
                          
:mode3loop    'Read first blob of pair
              call #read
              mov  formattedx,data
              call #read
              mov  formattedy,data
              call #read
              mov  xys,data
              ' Format x
              mov   t1,xys                  ' Make a copy of xxyyxxyy byte 
              shl   t1,#4                   ' Shift to align two x bits with bits 8,9
              and   t1,mask89               ' Mask
              or    formattedx, t1          ' Combine to create formatted x
              ' Format y
              mov   t1,xys                  ' Make a copy of xxyyxxyy byte 
              shl   t1,#2                   ' Shift to align two x bits with bits 8,9
              and   t1,mask89               ' Mask
              or    formattedy, t1          ' Combine to create formatted x
              wrlong  formattedx,rtn_       ' Write to hub ram
              add     rtn_,#4               ' Increment address (hub addressed in bytes)
              wrlong  formattedy,rtn_       '
              add     rtn_,#4               ' Shift to put in upper nibble (just to make procesing the same)
              'Read second blob of pair  
              call  #read
              mov   formattedx,data
              call  #read
              mov   formattedy,data
              call  #read
              mov   xys,data
              shl   xys,#4
               ' Format x
              mov   t1,xys                  ' Make a copy of xxyyxxyy byte 
              shl   t1,#4                   ' Shift to align two x bits with bits 8,9
              and   t1,mask89               ' Mask
              or    formattedx, t1          ' Combine to create formatted x
              ' Format y
              mov   t1,xys                  ' Make a copy of xxyyxxyy byte 
              shl   t1,#2                   ' Shift to align two x bits with bits 8,9
              and   t1,mask89               ' Mask
              or    formattedy, t1          ' Combine to create formatted x
              wrlong  formattedx,rtn_       ' Write to hub ram
              add     rtn_,#4               ' Increment address (hub addressed in bytes)
              wrlong  formattedy,rtn_       '
              add     rtn_,#4              
              djnz    loopcount,#:mode3loop              
format1_ret   ret

' ******************** Format3 ****************************** 
{
Reads data from camera and formats for enhanced mode
} 
format3       call #read                    ' First byte always empty              
              mov   rtn_,rtnaddr            ' Address of element in hub array
              mov   loopcount, #4  

:mode3loop    call #read
              mov  formattedx,data
              call #read
              mov  formattedy,data
              call #read
              mov  xys,data             
              ' Format x
              mov   t1,xys                  ' Make a copy of xys byte 
              shl   t1,#4                   ' Shift to align two x bits with bits 6,7
              and   t1,mask89               ' Mask
              or    formattedx, t1          ' Combine to create formatted x
              ' Format y
              mov   t1,xys                  ' Make a copy of xys byte 
              shl   t1,#2                   ' Shift to align two x bits with bits 6,7
              and   t1,mask89               ' Mask
              or    formattedy, t1          ' Combine to create formatted x 
              ' Format xys
              and     xys,#%00001111        ' Just mask out the xy bits}
              wrlong  formattedx,rtn_       ' Write to hub ram
              add     rtn_,#4               ' Increment address (hub addressed in bytes)
              wrlong  formattedy,rtn_       '
              add     rtn_,#4               '
              wrlong  xys,rtn_              '
              add     rtn_,#4               '
              call    #delay            
              djnz    loopcount,#:mode3loop
              call    #stop            
format3_ret   ret

' ******************** Format5 ****************************** 
{
Reads data from camera and formats for full mode
} 
format5       call #read                    ' First byte always empty              
              mov   rtn_,rtnaddr            ' Address of element in hub array
              mov   loopcount, #4  

:mode5loop    call #read
              mov  formattedx,data
              call #read
              mov  formattedy,data
              call #read
              mov  xys,data             
              ' Format x
              mov   t1,xys                  ' Make a copy of xys byte 
              shl   t1,#4                   ' Shift to align two x bits with bits 6,7
              and   t1,mask89               ' Mask
              or    formattedx, t1          ' Combine to create formatted x
              ' Format y
              mov   t1,xys                  ' Make a copy of xys byte 
              shl   t1,#2                   ' Shift to align two x bits with bits 6,7
              and   t1,mask89               ' Mask
              or    formattedy, t1          ' Combine to create formatted x 
              ' Format xys
              and     xys,#%00001111          ' Just mask out the xy bits
              wrlong  formattedx,rtn_       ' Write to hub ram
              add     rtn_,#4               ' Increment address (hub addressed in bytes)
              wrlong  formattedy,rtn_       '
              add     rtn_,#4               '
              wrlong  xys,rtn_              ' Sensitivity
              add     rtn_,#4               '
              call   #read                  ' Xmin
              wrlong  data,rtn_
              add     rtn_,#4               ' 
              call   #read                  ' Ymin
              wrlong  data,rtn_
              add     rtn_,#4               ' 
              call   #read                  ' Xmax
              wrlong  data,rtn_
              add     rtn_,#4               ' 
              call   #read                  ' Ymax
              wrlong  data,rtn_
              add     rtn_,#4               ' 
              call   #read                  ' Empty
              call   #read                  ' Intensity
              wrlong  data,rtn_
              add     rtn_,#4               '                                            
              djnz    loopcount,#:mode5loop
              call    #stop            
format5_ret   ret

' ******************** Reset the camera ************************** 
{
A reset signal can be provided to the camera with a capacitor/resistor but this function can be used
to allow the propeller to provide the reset signal.
}
resetcam      shl   resetmask,resetpin        'Dont run this function more than once
              or    dira, resetmask
              andn  outa, resetmask
              mov   t1,cnt
              add   t1,startdelay
              waitcnt t1,0
              or    outa,resetmask
resetcam_ret  ret

'*************************************************************
'********************    I2C routines   **********************
'*************************************************************

'******************** I2C_Start ******************************

startl        or    outa,sclmask         ' Initially drive SCL HIGH              
              or    dira,sclmask              
              or    outa,sdamask         ' Initially drive SDA HIGH 
              or    dira,sdamask
              call  #delay
              andn  outa,sdamask         ' Now drive SDA LOW
              call  #delay
              andn  outa,sclmask         ' Leave SCL LOW
              call  #delay
startl_ret    ret

' ******************** I2C_Stop ******************************
            
stop          or    outa,sclmask         ' Drive SCL HIGH
              call  #delay
              or    outa,sdamask         ' Then SDA HIGH
              call  #delay
              andn  dira,sclmask         ' Now let them float
              andn  dira,sdamask         ' If pullups present, they'll stay HIGH              
stop_ret      ret

' ******************** I2C_Read ******************************

read          mov   data,#0
              mov   loopcount2,#8
              andn  dira,sdamask         ' Make SDA an input
              call  #delay
              
:byteloop     or    outa,sclmask         ' Receive data from SDA
              call  #delay               
              shl   data,#1              ' Sample SDA when SCL is HIGH                 
              mov   in,ina               ' data := (data << 1) | ina[SDA] 
              and   in,sdamask
              shr   in,sdapin_
              or    data,in
              call  #delay
              andn  outa,sclmask
              call  #delay
              call  #delay
              djnz  loopcount2, #:byteloop
              
              mov   t1,#0               ' Output the ackbit, I'm not doing error checking so always make zero
              shl   t1,sdapin_          ' so this bit could be simplified but I want to make it more general code                 
              cmp   t1,sdamask  wz      ' Two lines are needed to make sure
              muxz  outa,sdamask        ' outa reflects the state of ack (written without assuming state of ack)                
              or    dira,sdamask
              call  #delay   
              or    outa,sclmask        ' Toggle SCL from LOW to HIGH to LOW
              call  #delay
              call  #delay     
              andn  outa,sclmask
              call  #delay 
              call  #delay  
              andn  outa,sdamask        ' Leave SDA driven LOW}
              call  #delay                                                 
read_ret      ret                                              

' ******************** I2C_Write ******************************
   
write         mov   ackbit,#0
              shl   data,#24            ' Shifts byte to MSB position 
              mov   loopcount3,#8       '
                                      
:writeloop    rol   data,#1             ' Moves msb to lsb
              mov   out,data            ' Make a copy of data 
              and   out,#1              ' Mask to consider the LSB only              
              shl   out,sdapin_         ' Shift to align with sdapin in outa                           
              cmp   out,sdamask  wz     ' Do we want to output a 1?  z is one if out is 1
              muxz  outa,sdamask        ' Write z to outa masked with sdamask
              call  #delay             
              or    outa,sclmask        ' Make scl hgh
              call  #delay
              call  #delay
              andn  outa,sclmask        ' Make scl low
              call  #delay
              djnz  loopcount3,#:writeloop
              
              or    dira,sdamask        ' Set SDA to input for ACK/NAK      
              or    outa,sclmask        ' Make SCL high
              call  #delay
              or    ackbit,ina          ' Load ina into ackbit
              and   ackbit,sdamask      ' Mask for sda
              shr   ackbit,sdapin_      ' shift to LSB
              call  #delay        
              andn  outa,sclmask        ' Make SCL low again
              andn  outa,sdamask        ' Leave SDA driven low
              or    dira,sdamask                  
              call  #delay               
write_ret     ret

'*****************************************************************
'********************    General routines   **********************
'*****************************************************************

' ******************** delay for SLC ***************************** 

delay         mov   time,cnt
              add   time, delay_
              waitcnt time,0
delay_ret     ret

' ******************** init delay, 100ms ************************ 

initdelay     mov   time,cnt
              add   time, ms100
              waitcnt time,0
initdelay_ret ret

clkpin_   long    0
clkmask   long    1
sdapin_   long    0 
sclpin_   long    0
resetmask long    1
resetpin  long    0
sclmask   long    1
sdamask   long    1
ackbit    long    0
data      long    0
in        long    0
out       long    0
mode_     long    0
dataddr   long    0
rtnaddr   long    0
zero      long    0
ten       long    10
time      long    0
delay_    long    200             'Used for I2C timing
startdelay long   20000000
formattedx long   0
formattedy long   0
rtn_       long   0
xys        long   0
minusone   long   $FFFFFFFF
mask89     long   %11_0000_0000   ' Mask for bits 8 and 9
clockset   long   %00100 << 26    ' NCO mode
MHz25      long   1342177280      ' To provide a 25Mhz clock, based on 80Mhz system clock
ms100      long   (80000000/1000)*100
set_addr   long   0

loopcount  res  1
loopcount2 res  1
loopcount3 res  1
do         res  1
p          res  1
t1         res  1
t2         res  1
t3         res  1
t4         res  1
index      res  1