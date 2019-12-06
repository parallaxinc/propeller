'
'************************************* debugChar ********************************************
'Call #debugChar sends byte to the terminal (may wait for room in buffer).
'A 32-bit long variable "debugVar" contains the byte to be sent to the terminal.
'******************************************************************************************** 
'
'                  mov     debugVar,#"H"
'                  call    #debugChar                'Send "H" char to the terminal
'
'************************************* debugDelay *******************************************
'Call #debugDelay activates a time delay for a certain number of quarter seconds from now.
'A 32-bit long variable "debugVar" contains the number of quarter seconds delay.
'********************************************************************************************
'
'                  mov     debugVar,#4
'                  call    #debugDelay               'Delay 4 quater seconds or 1 second
'
'************************************* debugStr *********************************************                                    
'Call #debugStr sends zero terminated string to the terminal.
'A 32-bit long variable "debugVar" contains the memory address of the string to be sent.
'SPAD strings must be terminated with a zero. 
'SPAD strings must end on a long.
'********************************************************************************************
' 
'                  mov     debugVar,#str1         
'                  call    #debugStr                 'Send string str1 to the terminal
' 
'                  mov     debugVar,#str2         
'                  call    #debugStr                 'Send string str2 to the terminal                                        
'
'str1              byte    "SPAD strings must end on a long***",13,0     'Pad not needed
'str2              byte    "SPAD strings must end on a long**",13,0,0    'Pad with one 0s
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
'************************************* debugBin ********************************************* 
'Call #debugBin sends a 32 character representation of a binary number to the terminal.
'A 32 bit long variable "debugVar" contains the number to be sent to the terminal.
'A 32 character representation is displayed 0000_0000_0000_0000_0000_0000_0000_0000
'********************************************************************************************
'
'                  mov     debugVar,myVariable1  
'                  call    #debugBin             'Send BIN number 2147483647 to the terminal
'
'************************************* debugWatchDog ****************************************                                        
'Call #debugWatchDog activates a WatchDog timer to send a selected char at a selected time. 
'A 32-bit long variable "debugVar" contains the selected number of quarter seconds delay.
'A 32-bit long variable "debug_Var" contains the selected char to be sent.
'********************************************************************************************
'
'                  mov     debugVar,#7               'WatchDog timer = 7 qtrSec
'                  mov     debug_Var,#"#"            'WatchDog char = "#"
'                  call    #debugWatchDog            'WatchDog timer on
'
'************************************* debugInChar ******************************************                  
'Call #debugInChar gets byte from the terminal.
'A 32 bit long variable "debugInVar" returns the corresponding value.
'********************************************************************************************
'
'                  call    #debugInChar              'Get char sent by WatchDog timer
'                  
'                  mov     debugVar,debugInVar
'                  call    #debugChar                'Send WatchDog timer char to the terminal
'
'************************************* debugInDec *******************************************                     
'Call #debugInDec gets decimal characer representation of a number from the terminal.
'A 32 bit long variable "debugInVar" returns the corresponding value.
'Number should be equal or greater than -2_147_483_648 and equal or less than 2_147_483_647.
'Exceeding limits on either side returns "zero".
'Each complete number entry should be followed by a single carriage return. 
'Entering a carriage return without a number returns "zero".
'Entering a carriage return from the WatchDog timer without a number returns "zero". 
'********************************************************************************************
'
'                  call    #debugInDec               'Get Dec input from the terminal
'
'                  mov     debugVar,debugInVar
'                  call    #debugDec                 'Send Dec input to the terminal
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
'************************************* divide ***********************************************                  
'Call divide is an unsigned 32-bit division routine.
'A 32-bit long variable "dividend" is divided by a 32-bit long variable "divisor".
'A 32-bit long variable "quotient" returns the corresponding value.
'A 32-bit long variable "remainder" returns the corresponding value.
'If the "dividend" is negative or "zero", the "quotient" and "remainder" are "zero".
'If the "divisor" is negative or "zero", the "quotient" and "remainder" are "zero".
'******************************************************************************************** 
' 
'                  mov     dividend,myVariable3
'                  mov     divisor,#8
'                  call    #divide                   'Divide myVariable3 / 8
'                  
'                  mov     debugVar,quotient
'                  call    #debugDec                 'Send decimal quotient to the terminal
'
'                  mov     debugVar,#13
'                  all     #debugChar                'Send carriage return to the terminal
'                  
'                  mov     debugVar,remainder
'                  call    #debugDec                 'Send decimal remainder to the terminal
'
'                  mov     debugVar,#13
'                  call    #debugChar                'Send carriage return to the terminal
'              
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
  BELL = 7                                                                                '##
  SPACE = 32                                                                              '##
  BKSP = 8                                                                                '##
                                                                                          '##
'############################################################################################
OBJ '################################## SPAD BLOCK 2 ########################################
                                                                                          '##
  SPAD : "SimplePropellerAssemblyDebugger"                                                '##
                                                                                          '##
'############################################################################################
PUB SimplePropAsmDebugger_MainDemo '### SPAD BLOCK 3 ########################################
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

                  mov     debugVar,#6
                  call    #debugDelay               'Delay 6 qtrSec
        
                  mov     debugVar,#CLS
                  call    #debugChar                'CLS out

                  mov     debugVar,#str1
                  call    #debugStr                 'str1 string out

                  mov     debugVar,#str2
                  call    #debugStr                 'str2 string out

                  mov     debugVar,#6               'WatchDog timer = 6 qtrSec
                  mov     debug_Var,#BELL           'WatchDog char = BELL
                  call    #debugWatchDog            'WatchDog timer on
                      
                  call    #debugInChar              'Char input in
                      
                  mov     debugVar,debugInVar
                  call    #debugBin                 'Bin input out

                  mov     debugVar,#str11
                  call    #debugStr                 'str11 string out

                  mov     debugVar,debugInVar
                  call    #debugChar                'Char input out
                      
                  cmp     debugInVar,#CR wz         'Char input = CR ?
          if_z    jmp     #code1

                  cmp     debugInVar,#BELL wz       'Char input = BELL ?
          if_z    jmp     #Code

                  mov     debugVar,#3
                  call    #debugDelay               'Delay 3 qtrSec
                      
                  jmp     #Code

code1             mov     debugVar,#CLS
                  call    #debugChar                'CLS out

                  mov     debugVar,#str3
                  call    #debugStr                 'str3 string out

                  mov     debugVar,#str4
                  call    #debugStr                 'str4 string out

                  mov     debugVar,#28
                  call    #debugDelay               'Delay 28 qtrSec
                      
                  mov     index,#0                  'index = 0
                  call    #countDown                'diagonal pattern

code5             mov     debugVar,#CLS
                  call    #debugChar                'CLS out

                  mov     debugVar,#str6 
                  call    #debugStr                 'str6 string out

                  mov     debugVar,#1
                  call    #debugDelay               'Delay 1 qtrSec

                  cmp     autoStart,#1 wz
            if_z  mov     debugInVar,#501           'autoStart input = 501

           if_nz  call    #debugInDec               'Dec input in
                    
                  mov     debugVar,debugInVar
                  call    #debugDec                 'Dec input out                      
                    
                  mov     debugVar,#CR           
                  call    #debugChar                'CR out

                  mov     debugVar,debugInVar
                  call    #debugBin                 'Bin input out
                                
                  mov     debugVar,#CR               
                  call    #debugChar                'CR out

                  mov     debugVar,#CR               
                  call    #debugChar                'CR out

                  mov     multiP,debugInVar         'multiP = Dec input
                  mov     dividend,debugInVar       'dividend = Dec input

                  mov     debugVar,#str7 
                  call    #debugStr                 'str7 string out

                  cmp     autoStart,#1 wz
            if_z  mov     debugInVar,#499           'autoStart input = 499
                    
           if_nz  call    #debugInDec               'Dec input in
                      
                  mov     debugVar,debugInVar
                  call    #debugDec                 'Dec input out

                  mov     debugVar,#CR                
                  call    #debugChar                'CR out

                  mov     debugVar,debugInVar
                  call    #debugBin                 'Bin input out

                  mov     debugVar,#CR               
                  call    #debugChar                'CR out

                  mov     debugVar,#CR               
                  call    #debugChar                'CR out

                  mov     multiC,debugInVar         'multiC = Dec input
                  mov     divisor,debugInVar        'divisor = Dec input
  
                  call    #multiply                 'multiply

                  mov     debugVar,#str8 
                  call    #debugStr                 'str8 string out

                  mov     debugVar,product 
                  call    #debugDec                 'Dec product out

                  mov     debugVar,#CR
                  call    #debugChar                'CR out

                  mov     debugVar,product
                  call    #debugBin                 'Bin product out
        
                  mov     debugVar,#CR           
                  call    #debugChar                'CR out

                  mov     debugVar,#CR               
                  call    #debugChar                'CR out

                  call    #divide                   'divide

                  mov     debugVar,#str9 
                  call    #debugStr                 'str9 string out

                  mov     debugVar,quotient
                  call    #debugDec                 'Dec quotient out

                  mov     debugVar,#CR           
                  call    #debugChar                'CR out

                  mov     debugVar,quotient
                  call    #debugBin                 'Bin quotient out

                  mov     debugVar,#CR           
                  call    #debugChar                'CR out

                  mov     debugVar,#CR               
                  call    #debugChar                'CR out

                  mov     debugVar,#str10 
                  call    #debugStr                 'str10 string out

                  mov     debugVar,remainder
                  call    #debugDec                 'Dec remainder out

                  mov     debugVar,#CR           
                  call    #debugChar                'CR out

                  mov     debugVar,remainder
                  call    #debugBin                 'Bin remainder out

                  cmp     autoStart,#1 wz           'autoStart = 1 ?
            if_z  jmp     #code3

                  mov     debugVar,#CR           
                  call    #debugChar                'CR out

                  mov     debugVar,#CR               
                  call    #debugChar                'CR out

                  mov     debugVar,#CR               
                  call    #debugChar                'CR out

code2             mov     debugVar,#str12 
                  call    #debugStr                 'str12 out
                        
                  call    #debugInChar              'Char input in

                  cmp     debugInVar,#BKSP wz       'Char input = BKSP ?
            if_z  jmp     #code5                    'repeat
                      
                  cmp     debugInVar,#CR wz         'Char input = CR ?
           if_nz  jmp     #code2                    'try again
            if_z  jmp     #code4                    'ok  move on

code3             mov     debugVar,#28
                  call    #debugDelay               'Delay 28 qtrSec

code4             mov     debugVar,#CLS
                  call    #debugChar                'CLS out

                  mov     debugVar,#str5
                  call    #debugStr                 'str5 string out

                  mov     debugVar,#str4
                  call    #debugStr                 'str4 string out

                  mov     debugVar,#28
                  call    #debugDelay               'Delay 28 qtrSec

                  mov     index,#1                  'index = 1                                                     
                  call    #countDown                'verticle pattern

                  cmp     autoStart,#0 wz           'autoStart = 0 ?
            if_z  jmp     #code1

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
            if_z  jmp     #code1          
                  jmp     #led_state_1

wait1             mov     waitCount,cnt
                  add     waitCount,counts
                  waitcnt waitCount,#0
                        
wait1_ret         ret

countDown         cmp     index,#0 wz               'index = 0 ?
            if_z  mov     debugVar,#str_three
           if_nz  mov     debugVar,#str_three_ 
                  call    #debugStr                 'str_three or str_three_ out

                  mov     debugVar,#BELL
                  call    #debugChar                'Char = BELL out

                  mov     debugVar,#3               'WatchDog timer = 3 qtrSec
                  mov     debug_Var,#BELL           'WatchDog char = BELL
                  call    #debugWatchDog            'WatchDog timer on

                  call    #debugInChar              'Char input in
                      
                  cmp     debugInVar,#BELL wz       'Char = BELL ?
          if_nz   jmp     #countDown1               'no BELL, char entered, exit countDown 
 
                  cmp     index,#0 wz               'index = 0 ?
            if_z  mov     debugVar,#str_two
           if_nz  mov     debugVar,#str_two_ 
                  call    #debugStr                 'str_two or str_two_ out

                  mov     debugVar,#BELL
                  call    #debugChar                'Char = BELL out
       
                  mov     debugVar,#3               'WatchDog timer = 3 qtrSec
                  mov     debug_Var,#BELL           'WatchDog char = BELL
                  call    #debugWatchDog            'WatchDog timer on

                  call    #debugInChar              'Char input in
                      
                  cmp     debugInVar,#BELL wz       'Char input = BELL ?
          if_nz   jmp     #countDown1               'no BELL, char entered, exit countDown
 
                  cmp     index,#0 wz               'index = 0 ?
            if_z  mov     debugVar,#str_one
           if_nz  mov     debugVar,#str_one_ 
                  call    #debugStr                 'str_one or str_one_ out

                  mov     debugVar,#BELL
                  call    #debugChar                'Char = BELL out

                  mov     debugVar,#3               'WatchDog timer = 3 qtrSec
                  mov     debug_Var,#BELL           'WatchDog char = BELL
                  call    #debugWatchDog            'WatchDog timer on

                  call    #debugInChar              'Char input in
                      
                  cmp     debugInVar,#BELL wz       'Char input = BELL ?
          if_nz   jmp     #countDown1               'no BELL, char entered, exit countDown
 
                  cmp     index,#0 wz               'index = 0 ?
            if_z  mov     debugVar,#str_zero
           if_nz  mov     debugVar,#str_zero_ 
                  call    #debugStr                 'str_zero or str_zero_ out

                  mov     debugVar,#BELL
                  call    #debugChar                'Char = BELL out

                  mov     debugVar,#3               'WatchDog timer = 3 qtrSec
                  mov     debug_Var,#BELL           'WatchDog char = BELL
                  call    #debugWatchDog            'WatchDog timer on

                  call    #debugInChar              'Char input in
                      
                  cmp     debugInVar,#BELL wz       'Char input = BELL ?
          if_nz   jmp     #countDown1               'no BELL, char entered, exit countDown
                                                    
                  mov     autoStart,#1              'autoStart = 1
                  jmp     #countDown_ret

countDown1        mov     autoStart,#0              'autoStart = 0

                  mov     debugVar,#2
                  call    #debugDelay               'Delay 2 qtrSec
 
countDown_ret     ret

blinkCounter      long   0   
initialCount      long   40_000_000
deltaCounts       long   5_000_000
done              long   5_000_000 
waitCount         long   0
counts            long   0
blinkExit         long   0
pinMask_16_17     long    (|< 16) | (|< 17)   'Construct pinmask for pins 16,17
pinMask_16        long    (|< 16)             'Construct pinmask for pin 16
pinMask_17        long    (|< 17)             'Construct pinmask for pin 17
str1              byte   "Enter CR to start program or enter any character to exercise WatchDog timer.",13,13,0,0
str2              byte   "Depress key now........",13,13,13,13,0
str3              byte   "Enter any character when instructed to start multiply/divide routine or ",0,0,0,0
str4              byte   "program will autoRun in 6 secs.",13,13,13,13,0
str5              byte   "Enter any character when instructed to bypass led routine or ",0,0,0 
str6              byte   "Enter number + CR:  ",0,0,0,0 
str7              byte   "Enter smaller or equal number + CR:  ",0,0,0
str8              byte   "Product:  ",0,0
str9              byte   "Quotient:  ",0
str10             byte   "Remainder:  ",0,0,0,0
str11             byte   "   ",0,0,0,0,0
str12             byte   "Enter CR to continue or BKSP to repeat.",13,0,0,0,0 
str_three         byte   " 3 Depress key now...",10,0,0
str_three_        byte   " 3 Depress key now...",13,13,0 
str_two           byte   " 2 Depress key now...",10,0,0
str_two_          byte   " 2 Depress key now...",13,13,0 
str_one           byte   " 1 Depress key now...",10,0,0
str_one_          byte   " 1 Depress key now...",13,13,0 
str_zero          byte   " 0 Depress key now...",10,0,0
str_zero_         byte   " 0 Depress key now...",13,13,0
autoStart         long   0
index             long   0                                                   

                    fit
             