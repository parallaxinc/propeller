{SPI Slave
Once started, this cog monitors a Chip Select pin.  When that pin goes active,
the cog accumulates up to 32 bits (shifting to the left) until the CS pin goes not active.
It then returns the accumulated data (as a long) and the actual bit count (as a byte) and
again waits for Chip select to go active again.
This cog will support a clock of up to 1.8 MHz.}
CON
        _clkmode = xtal1 + pll16x    'Standard clock mode 
        _xinfreq = 5_000_000         '* crystal frequency = 80 MHz
        
VAR                             
  byte  Cog                            'used to stop PASM cog if needful
  long  MyParm[3]                      'parameters to machine cog
  
PUB start(clkpin, datapin, cspin, DataAdrs, CountAdrs) 'start the PASM cog
    stop                     'stop PASM cog if already running (standard start/stop logic)
    myParm[0] := (clkpin<<24 | datapin<<16 | cspin<<8) 'give pin numbers to PASM cog
    myParm[1] := DataAdrs               'this is an address in hub memory
    myParm[2] := CountAdrs               'so is this 
    cog := cognew(@SPSCog, @MyParm) + 1 'start the cog (+1 'cause might be cog 0)       
    return (cog - 1)                     'return the actual cog number

PUB stop                               'kill the PASM cog if it is running
    if (cog) 
      cogstop(cog-1)                    'make the cog available
      cog := 0
          
DAT
SPSCog  org   0                'SPI Slave Receiver
        mov AdPar,Par          'get the address of the parameter list
        rdlong Work1, AdPar    'pin numbers
        mov Work2, Work1       'get working copy
        shr Work2, #24         'right align clock pin
        and Work2, #$1F        'just pin number
        mov ClkMask, #1        'form a mask with a single 1
        shl ClkMask, Work2     'corresponding to clock pin
        mov Work2, Work1       'just the same for data pin
        shr Work2, #16
        and Work2, #$1F
        mov DatMask, #1
        shl DatMask, Work2
        mov Work2, Work1       'and now the CS pin
        shr Work2, #8
        and Work2, #$1F
        mov CsMask, #1
        shl CsMask, Work2 
        add AdPar, #4
        rdlong AdResult, AdPar 'The address where to return the result
        add AdPar, #4
        rdlong AdCount, AdPar  'and the address of the count

top     mov DLong, #0          'get set up for next burst
        mov BitCount, #0
        waitpne CSMask, CSMask  'and now wait for cs to go active

BLoop   test clkMask, ina wz   'look for active clock
        if_NZ jmp #GBit        'clock active, get the bit
        test CsMask, ina wz    'look for cs gone inactive
        if_Z jmp #BLoop        'cs is still active         
release wrlong DLong, AdResult   'store the result
        wrbyte BitCount, AdCount  'say we have stored "n" bits
        jmp #top 
        
GBit    test DatMask, ina wz   'see if the new bit is a '1'
        shl DLong, #1          'make room for it        
        if_NZ or DLong, #1     'if we saw a "1"
        add BitCount, #1       'one more to report
        waitpne ClkMask, ClkMask  'wait for clock to go inactive
        jmp #BLoop             'and get next bit
            
ClkMask     res  1                   'mask corresponding to clock pin
DatMask     res  1                   'mask corresponding to data pin
CsMask      res  1                   'mask corresponding to CS pin 
AdPar       res  1                   'address of parameter list
AdResult    res  1                   'where to return the result to
AdCount     res  1                   'address of bit count
BitCount    res  1                   'number of bits we received
Work1       res  1                   'generally useful
Work2       res  1 
DLong       res  1                   'variable being received

                                                                            