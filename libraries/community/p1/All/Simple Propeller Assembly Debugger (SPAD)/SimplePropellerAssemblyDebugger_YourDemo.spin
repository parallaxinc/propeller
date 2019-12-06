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
PUB SimplePropAsmDebug_YourDemo '###### SPAD BLOCK 3 ########################################
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


                  fit
                       