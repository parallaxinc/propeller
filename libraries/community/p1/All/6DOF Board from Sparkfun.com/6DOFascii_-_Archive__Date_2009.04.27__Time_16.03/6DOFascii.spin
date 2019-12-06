{
    The Atomic 6DOF Reader Object
    from Sparkfun.com
    By earl@uphi.net

    call readDOF to get a buffer full of data @115200 baud on pins 22 & 23
    starting with "A" then tab deliniated data (count,x,y,z accl x,y,z gyro) "Z" end char
    as such ------>
    
    "A tab count tab xxx tab yyy tab zzz tab xxx tab yyy tab zzz tab Z"  without spaces and quotes
    
    One problem is the count may be 1 to 8 characters long so the position of all other data changes
    in the string. This makes it difficult to parse the data. I have it set up for counts
    between 1000 and 9999 the data is valid. Make changes to parse correctly fot 1 to 8 digit counts.
}
CON

  _CLKMODE            = XTAL1 + PLL16X
  _XINFREQ            = 5_000_000

' 6DOF PIN Assignments                                   
  DOFin     = 22                                       ' fm GPS NEMA data
  DOFout    = 23                                       ' to GPS (to set baud, SIRF or NMEA etc. May be needed for your GPS)


' Video Output Assignments                              
  TVBase    = 12                                        ' TV  base pin         
                                                                                                                 
VAR

  byte buffer [ 36]
  byte cdat [ 12]
  byte xdat [ 12]
  byte ydat [ 12]
  byte zdat [ 12]
  byte Rx,loop,tabcount
  long cptr ,count
  long x,y,z,Pitch,roll,yaw
  
OBJ                                                    
  clock      :  "Clock"                                 ' overall timers 
  tv         :  "tv_text"                               ' TV video output driver
  uart       :  "FullDuplexSerialPlus"                  ' serial driver

PUB start

''Initialize all necessary routines as appropriate
 
Clock.Init(_XINFREQ)                    ' set up clock for accurate 10/second
Clock.SetClock(_CLKMODE)                ' video update rate
Clock.MarkSync
tv.start(TVBase)                        ' start TV display
uart.start(22,23,0,115200)              ' start uart on pins 22,23 for 6DOF Atomic board

                                         
Main                                   ' go do main program of getting and printing 6DOF serial data

PUB Main                               ' primary loop

readDOF                                ' Put the data in a buffer from 6DOF


tv.str(string($A,1,$B,10,8)) ' print to line 10 column 1
tv.str(buffer)

tv.str(string($A,1,$B,1,$c,33,8,"Count Then String Representation "))
bytemove (@cdat,@buffer+3,4)           
tv.dec(uart.StrToDec(@cdat))                                    
count := uart.StrToDec(@cdat)

tv.str(string($A,20,$B,2)) ' print to line 11 column 30

'tabcount :=0
'if (buffer[tabcount] <>9 )
'  tabcount ++
' tv.hex(tabcount,2)
'if (buffer[tabcount] <>9 )
'  tabcount ++
' tv.hex(tabcount,2)

tv.str(string($A,1,$B,2,13,"X-Accl  ")) 
bytemove (@xdat,@buffer +8,3)
tv.dec(uart.StrToDec(@xdat))                                    
x :=uart.StrToDec(@xdat)
               
tv.str(string(10,10,13,"Y-Accl  "))   
bytemove (@ydat,@buffer+12,3)          
tv.dec(uart.StrToDec(@ydat))           
y := uart.StrToDec(@ydat)

tv.str(string(10,10,13,"Z-Accl  "))    
bytemove (@zdat,@buffer+16,3)          
tv.dec(uart.StrToDec(@zdat))           
z :=uart.StrToDec(@zdat)                                        

tv.str(string(13,10,10,13,"Pitch   ")) 
bytemove (@xdat,@buffer+20,3)          
tv.dec(uart.StrToDec(@xdat))                                    
Pitch := uart.StrToDec(@xdat)      
                   
tv.str(string(10,10,13,"Roll    "))    
bytemove (@ydat,@buffer+24,3)          
tv.dec(uart.StrToDec(@ydat))                                    
Roll := uart.StrToDec(@ydat)

tv.str(string(10,10,13,"Yaw     "))    
bytemove (@zdat,@buffer+28,3)          
tv.dec(uart.StrToDec(@zdat))                                    
Yaw := uart.StrToDec(@zdat)      

tv.str(string($A,1,$B,10,8,"                     ")) ' print to line 11 column 1
tv.str(string($A,1,$B,10,8,"Desimal Values ")) ' print to line 11 column 1
tv.dec(x)
tv.str(string(32))                    
tv.dec(y)
tv.str(string(32))                     
tv.dec(z)
tv.str(string(32))
tv.dec(Pitch)
tv.str(string(32))                    
tv.dec(Roll)
tv.str(string(32))                    
tv.dec(Yaw)

tv.str(string($A,1,$B,11,8)) ' print to line 11 column 1
tv.str(buffer)

tv.str(string($A,1,$B,10,8)) ' print to line 11 column 1
tv.str(@buffer)


waitcnt (1000 +cnt)

Main                                     'Do everything over and over !
 


PUB readDOF
                                         ' call here for just getting a buffer full of data
   repeat while Rx <>= "A"               ' wait for the "A" to insure we are starting with
     Rx := uart.rx                       ' a complete 6dof sentence
        cptr := 0                        ' zero the buffer pointer to start

      repeat while Rx <>= "Z"            ' continue to collect data until the end of sentence ("Z")
      
           Rx := uart.rx                 ' get character from uart Rx
                  buffer[cptr++] := Rx   ' save the character in the buff
        buffer[cptr] :=0                 ' make sure the buffer ends with a 0

    return                               ' return to calling routine

   