
{Convert double precision binary to BCD
Uses conventional method of repeatedly subtracting powers of 10, beginning
with 1E19 and finishing with 1E0.  Subtracts each power of ten until
the residual is negative, does a restoring add, and goes on to next
smaller power of ten. Including storing the result in hub memory,
the worst case timing is less than 50 usec
The inner loop is:

SubLo   sub ValLo, 0-0 wc           'subtract low part
SubHi   subx ValHi, 0-0 wc          'hi part
        if_NC djnz count, #SubLo    'subtract again if didn't borrow;
                                     also accumulate a count of successful subtracts}

CON     _clkmode = xtal1 + pll16x    'Standard clock mode 
        _xinfreq = 5_000_000         '* crystal frequency = 80 MHz
  
VAR   long  Command                  'used to pass addresses to cog
      long  Binary[2]                'most significant, least sig
      byte  BCD[20]                  'result in bcd
      byte  digit                    'used to display decimal

OBJ  pst      : "parallax serial terminal"
  
PUB main                                    
    pst.Start (115_200)                        'start up ser terminal
    pst.str(String("hello, world   "))         'runs in cog 1
    pst.NewLine
    waitcnt(clkfreq/10+cnt)

    cognew(@BCog, @Command)           'install the conversion cog

    Bin2BCD                            'do zero first  

    Binary[0] := 0                          'demo first 32 powers of 2
    Binary[1] := 1      
    repeat 32
      Bin2BCD
      Binary[1] := Binary[1] << 1

    Binary[0] := 1                          'next 32 powers of 2
    Binary[1] := 0      
    repeat 32
       Bin2BCD
       Binary[0] := Binary[0] << 1

    binary[0] := $FFFF_FFFF                '2^64 minus 1
    binary[1] := $FFFF_FFFF
    Bin2BCD

    binary[0] := $8ac7_2304                 'dec 999...999
    binary[1] := $89e7_ffff
    Bin2BCD
       
    binary[0] := $8ac7_2304                 'dec 100..000
    binary[1] := $89e8_0000
    Bin2BCD
                    
PUB Bin2BCD                                 
    Command := (@Binary << 16) | @BCD      'addresses to conversion cog
    repeat while (command <> 0)            'wait on cog
    pst.newline
    pst.hex(Binary[0]>>16,4)               'format taken from SUBX description
    pst.char("_")
    pst.hex(Binary[0],4)
    pst.char(":")
    pst.hex(Binary[1]>>16,4)
    pst.char("_")
    pst.hex(Binary[1],4)
    
    pst.str(string("      "))
    repeat digit from 0 to 19               'all 20 digits
       if ((digit // 3) == 2)               'stuff comma
          pst.char(",")     
       pst.char(bcd[digit] + "0")
 
DAT   '***********conversion cog******************8
BCog    org   0                '               '
        mov AdCommand,Par     'get the address of the command long
        'or dira, syncMask      'uncomment to see timing on I/O 0
        
loop    rdlong HubAdrs, AdCommand wz 'see if a command active
        if_Z jmp #loop              'none
        or outa, syncmask           'officially busy         
        mov BCDAdrs, HubAdrs        'get a copy of addresses
        and BCDAdrs, HubMask        'address of BCD array in hub
        shr HubAdrs, #16            'scale source address
        and HubAdrs, HubMask        'address of input arguments
        rdlong ValHi, HubAdrs       'get high order argument
        add HubAdrs, #4             'point to low order
        rdlong ValLo, HubAdrs       'fetch lo order half
        
'**********Here we initialize the five modified instructions to point to 10^19
        movd SaveBCD, #CogBCD       'point to top of bcd list
        movs SubLo, #E19+1          'the subtractors
        movs SubHi, #E19
        movs AddLo, #E19+1          'the restoring adds
        movs AddHi, #E19               
        mov CogDig, #20            'will do 20 digits
                  
NextDig mov Count, #0               'counter of subtracts (negative count)
SubLo   sub ValLo, 0-0 wc           'subtract low part
SubHi   subx ValHi, 0-0 wc          'hi part
        if_NC djnz count, #SubLo    'do again if didn't borrow; accum count
SaveBCD abs 0-0, Count              'absolute value of negative count of subtracts                
AddLo   add ValLo, 0-0 wc           'once too many, restoring add
AddHi   addx ValHi, 0-0
 
'******Here we go on to the next BCD digit by modifying five instructions*************
        add SaveBCD, NextDest        'point to next BCD digit
        add SubLo, #2                'point to next (smaller) power of 10
        add SubHi, #2
        add AddLo, #2
        add AddHi, #2                        
        djnz CogDig, #NextDig         'do next digit
           
        movd stuff, #CogBCD          'set up to move BCD to hub
        mov CogDig, #20              'all 20 digits
stuff   wrbyte 0-0, BCDAdrs          'move one digit
        add Stuff, NextDest          'cog address
        add BCDAdrs, #1              'hub address
        djnz CogDig, #stuff           '20 times
                                     
        andn outa, syncmask            'finished 
        wrlong  zero,  AdCommand       'release spin cog
        jmp #loop                      'and await more
            
Zero         long  0
NextDest     long  $200          'increment one in dest field
HubMask      long  $7FFF         'mask address into hub
syncMask     long   1             'scope sync on 0

'***********Here are the first 20 powers of 10*************
E19      long  2328306436, 2313682944  
         long  232830643, 2808348672
         long  23283064, 1569325056
         long  2328306, 1874919424
         long  232830, 2764472320
         long  23283,  276447232
         long  2328, 1316134912
         long  232, 3567587328
         long  23, 1215752192
         long  2, 1410065408
         long  0, 1000000000
         long  0, 100000000
         long  0, 10000000
         long  0, 1000000
         long  0, 100000
         long  0, 10000
         long  0, 1000
         long  0, 100
         long  0, 10
E0       long  0, 1             

CogBCD       res   20   'resultant bcd
CogDig       res       'which digit we are doing
AdCommand    res         'command address
ValHi        res        'high order half of input argument
ValLo        res        'low order half
HubAdrs      res         'address into hub
BCDAdrs      res         'address where to put result   
Count        res         'counts passes via djnz
                          