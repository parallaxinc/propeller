'
'************************************* debugChar ********************************************
'Call #debugChar sends byte to the terminal (may wait for room in buffer).
'A 32-bit long variable "debugVar" contains the byte to be sent to the terminal.
'******************************************************************************************** 
'
'                  mov     debugVar,#"H"
'                  call    #debugChar                'Send "H" char to the terminal           
'
'************************************* debugDec *********************************************
'Call #debugDec sends a decimal number to the terminal.
'A 32 bit long variable 'debugVar" contains the number to be sent to the terminal.
'********************************************************************************************
'
'                  mov     debugVar,myVariable1  
'                  call    #debugDec             'Send DEC number 2147483647 to the terminal
'
'myVariable1       long    2_147_483_647    
'
'************************************* multiply *********************************************
'Call #multiply is an unsigned 32-bit multiplication routine.
'Two 32-bit long variables "multiC" and "multiP" are multiplied. 
'A 32-bit long variable "product" returns the corresponding value.
'If the product is greater than 2_147_483_647, product returns "zero".
'If "multiC" or "multiP" are negative, product returns "zero".
'********************************************************************************************
'
'                  mov     multiC,myVariable3
'                  mov     multiP,#9       
'                  call    #multiply                 'Multiply myVariable3 X 9
'                  
'                  mov     debugVar,product
'                  call    #debugDec                 'Send decimal product to the terminal
'
'myVariable3       long    123456789              
'
CON '################################## SPAD BLOCK 1 ########################################
                                                                                          '##
  _clkmode        = xtal1 + pll16x                   '5 MHz system  (Demo Board)          '##
  _xinfreq        = 5_000_000                        '5 MHz system                        '##
'  _clkmode        = xtal1 + pll8x                   '10 MHz system (Spin Stamp)          '##
'  _xinfreq        = 10_000_000                      '10 MHz system                       '##
                                                                                          '##
  CR = 13                                                                                 '##
  CLS = 0                                                                                 '##
  SPACE = 32                                                                              '##
                                                                                          '##
'############################################################################################
OBJ '################################## SPAD BLOCK 2 ########################################
                                                                                          '##
  SPAD : "SimplePropellerAssemblyDebugger"                                                '##
                                                                                          '##
'############################################################################################
PUB SimplePropAsmDebugger_LedDemo '#### SPAD BLOCK 3 ########################################
                                                                                          '##
  SPAD.DebugPropASM                                                                       '##
                                                                                          '##
  cognew(@Entry,0)                                                                        '##
                                                                                          '##
'############################################################################################
DAT '################################## SPAD BLOCK 4 ########################################
                                                                                          '##
                  ORG     0                                                               '##
Entry             jmp     #Code                                                           '##
                                                                                          '##
multiP            long    0                                                               '##
multiC            long    0                                                               '##
product           long    0                                                               '##
dividend          long    0                                                               '##
divisor           long    0                                                               '##
quotient          long    0                                                               '##
remainder         long    0                                                               '##
debugVar          long    0                                                               '##
debug_Var         long    0                                                               '##
debugInVar        long    0                                                               '##
debugDelay        byte    $F1,$B7,$BC,$A0,$61,$B6,$BC,$80,$00,$B6,$BC,$F8,$0B,$10,$FC,$E4 '##
debugDelay_ret    ret                                                                     '##
debugWatchDog     byte    $56,$BA,$BC,$08,$57,$10,$3C,$08,$58,$12,$3C,$08,$02,$BA,$7C,$0C '##
                  byte    $F1,$B7,$BC,$A0,$60,$B6,$BC,$80,$00,$B6,$BC,$F8                 '##
debugWatchDog_ret ret                                                                     '##
debugDec          byte    $4E,$BA,$BC,$08,$47,$9A,$FC,$5C                                 '##
debugDec_ret      ret                                                                     '##
debugChar         byte    $4F,$BA,$BC,$08,$47,$9A,$FC,$5C                                 '##
debugChar_ret     ret                                                                     '##
debugBin          byte    $50,$BA,$BC,$08,$47,$9A,$FC,$5C                                 '##
debugBin_ret      ret                                                                     '##
debugStr          byte    $04,$B6,$FC,$A0,$08,$BC,$BC,$A0,$5E,$4A,$BC,$50,$00,$00,$00,$00 '##
                  byte    $5E,$B8,$BC,$A0,$5C,$10,$BC,$A0,$FF,$10,$FC,$62,$31,$00,$68,$5C '##
                  byte    $51,$BA,$BC,$08,$47,$9A,$FC,$5C,$08,$B8,$FC,$20,$26,$B6,$FC,$E4 '##
                  byte    $01,$BC,$FC,$80,$5E,$4A,$BC,$50,$04,$B6,$FC,$A0,$25,$00,$7C,$5C '##
debugStr_ret      ret                                                                     '##
multiply          byte    $52,$BA,$BC,$08,$01,$10,$BC,$A0,$02,$12,$BC,$A0,$47,$9A,$FC,$5C '##
                  byte    $57,$06,$BC,$08                                                 '##
multiply_ret      ret                                                                     '##
divide            byte    $53,$BA,$BC,$08,$04,$10,$BC,$A0,$05,$12,$BC,$A0,$47,$9A,$FC,$5C '##
                  byte    $57,$0C,$BC,$08,$58,$0E,$BC,$08                                 '##
divide_ret        ret                                                                     '##
debugInDec        byte    $54,$BA,$BC,$08,$47,$9A,$FC,$5C,$57,$14,$BC,$08                 '##
debugInDec_ret    ret                                                                     '##
debugInChar       byte    $55,$BA,$BC,$08,$47,$9A,$FC,$5C,$57,$14,$BC,$08                 '##
debugInChar_ret   ret                                                                     '##
cog_init          byte    $59,$BE,$3C,$08,$57,$10,$3C,$08,$58,$12,$3C,$08,$02,$BA,$7C,$0C '##
                  byte    $59,$B4,$BC,$0A,$4B,$00,$54,$5C                                 '##
cog_init_ret      ret                                                                     '##
variables1        long    $7FD0,$7FD4,$7FD8,$7FDC,$7FE0,$7FE4,$7FE8,$7FEC,$7FF0,$7FF4     '##
variables2        long    $7FF8,$7FFC,0,0,0,0,0,1,30_000,20_000_000                       '##
                                                                                          '##
'############################################################################################
'###################################### SPAD BLOCK 5 ########################################  
                                                                                          '##
Code              nop     'Start your assembly language program here!                     '##       

                  mov     debugVar,#CLS
                  call    #debugChar                'CLS out
 
                  or      dira,pinMask_16_17        'pins 16,17 output
                  andn    outa,pinMask_16_17        'pins 16,17 low
                  
                  mov     blinkCounter,#0           'blinkCounter = 0
                  mov     counts,initialCount       'counts = initialCount = 40_000_000
                  mov     blinkExit,#1              'blinkExit = 1

led_state_1       or      outa,pinMask_16           'pin 16 high
                  andn    outa,pinMask_17           'pin 17 low  

                  call    #wait1                    'delay blink

led_state_2       andn    outa,pinMask_16                                                                                           'pin 16 low
                  or      outa,pinMask_17           'pin 17 high
                                                
                  call    #wait1                    'delay blink

                  add     blinkCounter,#1           'blinkCounter = blinkCounter + 1
                        
                  mov     debugVar,blinkCounter
                  call    #debugDec                 'Dec blinkCounter out
                        
                  mov     debugVar,#SPACE
                  call    #debugChar                'SPACE out
                     
                  cmp     blinkCounter,blinkExit wz 'blinkCounter = blinkExit ?
           if_nz  jmp     #led_state_1              'not done, keep blinking
               
                  mov     blinkCounter,#0           'blinkCounter = 0

                  mov     multiP,blinkExit
                  mov     multiC,#2
                  call    #multiply                 'calculate new blinkExit
                  mov     blinkExit,product         'blinkExit = blinkExit * 2

                  mov     debugVar,#CR
                  call    #debugChar                'CR out

                  mov     debugVar,#CR
                  call    #debugChar                'CR out

                  sub     counts,deltaCounts wz     'counts = counts - deltaCounts
            if_z  jmp     #code   '1          
                  jmp     #led_state_1

wait1             mov     waitCount,cnt
                  add     waitCount,counts
                  waitcnt waitCount,#0
                        
wait1_ret         ret   

blinkCounter      long   0   
initialCount      long   40_000_000
deltaCounts       long   5_000_000
done              long   5_000_000 
waitCount         long   0
counts            long   0
blinkExit         long   0
pinMask_16_17     long   (|< 16) | (|< 17)   'Construct pinmask for pins 16,17
pinMask_16        long   (|< 16)             'Construct pinmask for pin 16
pinMask_17        long   (|< 17)             'Construct pinmask for pin 17                                                         

                  fit
             