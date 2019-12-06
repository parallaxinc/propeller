'' very crappy implementation of a OV6620 module
obj
    p: "pinout" ' this must be in EVERY antbot spin file, even if it's not used. Just in case.

con

' do not move these
PIN_Y0     =  0
PIN_Y1     =  1
PIN_Y2     =  2
PIN_Y3     =  3
PIN_Y4     =  4
PIN_Y5     =  5
PIN_Y6     =  6
PIN_Y7     =  7

' these should ideally be = the standard i2c pins on the prop
PIN_SCL    = 28
PIN_SDA    = 29

' feel free to move these
PIN_RESET  = -1
PIN_FODD   = 8 
PIN_HREF   = 9                
PIN_VSYNC  = 10                              
PIN_PXLCLK = 11


' other stuff on the OV6210 isn't connected

con ARRAYSIZE = COLS * ROWS  ' resolution (as I said not very high, but you can get decent ascii art out of a terminal this way)
COLS = 67
ROWS = 36
var
' these must be adjacent for preproc to work
long p_max
long p_min
long p_sum
long p_maxofs
long p_minofs
long impdone
byte frame[ARRAYSIZE]

dat
framecog long 0
pub start
if P#CAMERA <> 1
   return

bytefill(@frame, FINISH, ARRAYSIZE)
persist := 1

repeat
    framecog := cognew(@FrameGrab, @frame) + 1
until framecog
return framecog

pub stop
    if persist and framecog
       cogstop(framecog~ - 1)
    
pub runonce(wait) 
if P#CAMERA <> 1
   return
bytefill(@frame, FINISH, ARRAYSIZE)
persist~
repeat
    framecog := cognew(@FrameGrab, @frame) + 1
until framecog 
if wait
   repeat until byte[@frame +constant(ARRAYSIZE-COLS)] <> FINISH
framecog~

pub pxladdr(xoffs,yy)  ' yy can be FALSE. if so, this returns the offset. if YY is something, return the ADDRESS of the coords, so for example, byte[cam.addr(13,20)]
    yy *= COLS
    result := @frame + xoffs + yy
pub pxl(xoffs,yy)      ' returns the value of the pixel at that offset, works same as above.
    yy *= COLS
    result := xoffs + yy
    result += @frame
    result := byte[result]
pub setpxl(whatto,xoffs,yy) ' forces a pixel to this or that value
    yy *= COLS
    xoffs += yy
    xoffs += @frame
    byte[xoffs] := whatto & $FF
pub ofs(xx,yy) : offset  ' convert from offset to coords and back
    offset := (yy*COLS)+xx
pub x(offs) : coord      ' convert from offset to coords and back
    coord := offs // COLS
pub y(offs) : coord      ' convert from offset to coords and back
    coord := offs / COLS    
pub frm                  ' just returns the frame address
    return @frame
pub getmaxmin(wait) : mmcog ' quickly calculates the maxval, minval, and median within the frame
    if P#CAMERA <> 1
       return
    p_max := p_sum := p_min := FINISH
    impdone~
    repeat
       mmcog := cognew(@FindMaxMin, @p_max) + 1
    until mmcog
    if(wait)
       repeat until impdone'p_min < FINISH
pub pmax
    return p_max
pub pmin
    return p_min
pub pmaxofs
    return p_maxofs
pub pminofs
    return p_minofs
pub pmed
    return p_sum / ARRAYSIZE

con
DELIMITER = $FF                 ' indicate end of line
FINISH    = $FF                 ' indicates end of field (unused)
MINIMUM   = 17
MAXIMUM   = 240

dat

' Basic image processing: reads in the entire array, returns maximum brightness value, minimum brightness value, and sum of all pixels that can be used to calculate a median.
FindMaxMin     org
               mov mmaddr,      par
               add mmaddr,      varsoffs
               add mmsize,      mmaddr

mmloop      rdbyte brttest,     mmaddr

               cmp brttest,     maxmax wc  ' C = Val1 < Val2 make sure we're staying away from flag values
         if_nc jmp              #mmloop2   ' if brttest > maxmax, don't do the check
               cmp brttest,     minmin wc  ' C = Val1 < Val2 
          if_c jmp              #mmloop2   ' if brttest < minmin, don't do the check

               cmp brttest,     mmax wc    ' C = Val1 < Val2 
         if_nc mov mmax,        brttest    ' save result
         if_nc mov maxoffs,     mmaddr       ' also save offset
         
          
               cmp brttest,     mmin wc    ' C = Val1 < Val2 
          if_c mov mmin,        brttest    ' save result
          if_c mov minoffs,     mmaddr       ' also save offset

               add msum,        brttest    ' sum of all valid pixel values

               
mmloop2       add mmaddr,       #1
              cmp mmsize,       mmaddr   wc ' ' C = Val1 < Val2 amake sure we're not overflowing
         if_c jmp               #calcdone' if mmsize > mmaddr, go home
              jmp               #mmloop               

                               
calcdone      

              mov mmaddr,       par
              sub maxoffs,      mmaddr
              sub maxoffs,      varsoffs
              sub minoffs,      mmaddr
              sub minoffs,      varsoffs

           wrlong mmax,         mmaddr

              add mmaddr,       four
           wrlong mmin,         mmaddr    

              add mmaddr,       four
           wrlong msum,         mmaddr    

              add mmaddr,       four
           wrlong maxoffs,      mmaddr    

              add mmaddr,       four
           wrlong minoffs,      mmaddr    

              add mmaddr,       four   ' just writes in a "i'm done" flag.
           wrlong four,         mmaddr ' just writes in a "i'm done" flag.   

            cogid brttest      ' get out
          cogstop brttest

brttest  long 0
mmaddr   long 0
mmax     long 0
mmin     long 255
msum     long 0
varsoffs long 24 ' 6 longs
four     long 4
maxmax   long MAXIMUM
minmin   long MINIMUM
othaddr  long 0
maxoffs  long 0
minoffs  long 0



mmsize  long    ARRAYSIZE
dat

' Grabs a VERY low res frame out of the OV6620 module, either stops itself when done, or goes back and does it all over again

FrameGrab     org     
              mov    addr,            par           ' predecrement address (because we need to) and store it
              add    maxsize,         par          ' see what the max address is
              sub    maxsize,         #COLS
              mov    dira,            zero ' reset not used ' mask_reset   ' makes sure they're all inputs except reset as far as this cog is concerned
              mov    outa,            zero'#0           ' and make sure reset is low!
              
waitvsync
              mov     inval,                #FINISH
              wrbyte  inval,                addr
              mov     addr,                 par ' restore array address to first location
              
              waitpeq mask_vsync,                 mask_vsync ' wait for vsync to cycle
              waitpne mask_vsync,                 mask_vsync ' wait for vsync to cycle
              jmp     #waithsync                 ' now that vsync is good, check hsync
              
waithsync     waitpne mask_href,                 mask_href     ' optional: wait for HREF to go down
              waitpeq mask_href,                 mask_href     ' wait for HREF to go up

              waitpne mask_href,                 mask_href     ' optional: wait for HREF to go down
              waitpeq mask_href,                 mask_href     ' wait for HREF to go up

              waitpne mask_href,                 mask_href     ' optional: wait for HREF to go down
              waitpeq mask_href,                 mask_href     ' wait for HREF to go up

              waitpne mask_href,                 mask_href     ' optional: wait for HREF to go down
              waitpeq mask_href,                 mask_href     ' wait for HREF to go up


shiftin
              'waitpeq mask_pxlclk,          mask_pxlclk ' wait for pixel clock to settle
              waitpne mask_pxlclk,          mask_pxlclk ' wait for pixel clock to settle
              mov     tempina,              ina     ' this is where stuff actually happens : read in the port
              mov     inval,                tempina ' this is where stuff actually happens : read in the port
              nop
              wrbyte  inval,                addr ' copy byte to main memory -- higher 3 bytes are ignored anyway
              add     addr,                 #1  ' increment the destination address

checkhsync
              mov     testval,              tempina
              and     testval,              mask_href   ' only concern self with the href pin
              tjnz    testval,              #shiftin    ' if it's not zero (pin high), go get another pixel



skipline2     waitpne mask_href,                 mask_href     ' optional: wait for HREF to go down
              waitpeq mask_href,                 mask_href     ' wait for HREF to go up

              waitpne mask_href,                 mask_href     ' optional: wait for HREF to go down
              waitpeq mask_href,                 mask_href     ' wait for HREF to go up

              waitpne mask_href,                 mask_href     ' optional: wait for HREF to go down
              waitpeq mask_href,                 mask_href     ' wait for HREF to go up

              waitpne mask_href,                 mask_href     ' optional: wait for HREF to go down
              waitpeq mask_href,                 mask_href     ' wait for HREF to go up



checkvsync     ' checkvsync doesn't work, i have to do the overflow check below -- anyone have any idea?
              or      tempina,              ina   ' double check
              mov     testval,              tempina         ' read ina again
              and     testval,              mask_vsync  ' only concern self with the vsync pin
              tjnz    testval,              #suicide'waitvsync    ' if it's not zer (pin high), go we're at another cycle


' if we're done with a line but not at a new page, keep going
doneline
              'add      addr,              #1      ' add a delimiter...
              'mov     inval,              #DELIMITER    ' ,,, to the byte array
              cmp     maxsize,            addr   wc ' amake sure we're not overflowing
         if_c jmp                         #suicide   ' if maxsize < addr,  go home, else go get another line

              'wrbyte  inval,              addr
              jmp                         #waithsync ' go get another line

suicide       test  persist,              persist wz ' see what's inside extrapar (tests to itself affects flags to see if it's 0 or not)
        if_nz jmp   #waitvsync            ' do it all over again
              cogid testval               ' or stop self
              cogstop testval


' RES statements don't work!!! (?) using presets for everything for now



' these can be modified                            
inval                   long    0
testval                 long    0
tempina                 long    0
linecnt                 long    0
addr                    long    0


persist                 long    0 ' modified in spin; decides whether the cog is persistent or only grabbing one frame




' THESE SHOULD BE LEFT ALONE!!!!
mask_vsync              long    |< PIN_VSYNC
mask_href               long    |< PIN_HREF
mask_pxlclk             long    |< PIN_PXLCLK
mask_reset              long    |< PIN_RESET
zero                    long    0
maxsize                 long    ARRAYSIZE
bitmask                 long    $00_00_00_FF

fit 496