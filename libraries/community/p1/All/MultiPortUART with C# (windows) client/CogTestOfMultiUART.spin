CON
  CR   = 13     'carriage return character value
  NULL = 0      'null terminator for strings
  DQ   = 34     'double quote character
  
DAT
  cog         long  0               'cog flag/id

  'The following locations will be filled by the start() procedure
  param1      long  0   'holds address of the txreg to use
  param2      long  0   'holds address of the rxreg to use               

PUB start( addressOfTxreg, addressOfRxreg ) : okay
  'stop   'comment this line out to allow multiple cogs to be loaded
  param1 := addressOfTxreg
  param2 := addressOfRxreg
  okay := cog := cognew(@begin, @param1) + 1

PUB stop
  if cog
    cogstop(cog~ - 1)
    
DAT
  
ORG     0

begin                   mov     t1,par
                        rdlong  txAddr,t1       'load txAddr with the hub address of txreg
                        add     t1,#4
                        rdlong  rxAddr,t1       'load rxAddr with the hub address of rxreg                        

                        'write a string through the assigned UART txreg to show that we're
                        'up and running
                        mov     strAddr,#helloString
                        call    #writeStr
                        
                        'now wait for any character (which will be discarded) and show
                        'the current value of pi and cnt
:waitrx                 rdword  t1,rxAddr       'check for rxreg non-empty
                        cmp     t1,EMPTY        wz
              if_z      jmp     #:waitrx        'wait for rxreg to be filled
                        wrword  EMPTY,rxAddr    'show that we got the char (it's in t1)

                        'Compose the following string:
                        '
                        '   |"pi = {0:f6} at cnt = {1,14:n0}",vxxxxxxxx,uxxxxxxxx|
                        '
                        '   where xxxxxxxx stands for the output of writeHex routine
                        '
                        'When sent to the SerialPort Terminal client, it will result in a
                        'call to String.Format( "pi = {0:f6} at cnt = {1,14:n0}",piValue,cnt)
                        'where the type of piValue is float and the type of cnt is unsigned int,
                        'thus making available the full power of C# formatting for showing output
                        'from the propeller.
                        
                        mov     strAddr,#fmtStringA
                        call    #writeStr

                        call    #writeComma
                        call    #writeCharv     'set floating point flag
                        mov     hexOut,piValue
                        call    #writeHex
                        call    #writeComma
                        call    #writeCharu     'set unsigned integer flag
                        mov     hexOut,cnt      'pickup current value of cnt to display
                        call    #writeHex
                        mov     strAddr,#fmtStringB
                        call    #writeStr       'finish the barred format string   

                        jmp     #:waitrx        'go look for more input
                        
:loop                   jmp     #:loop    

'=================================== writeStr =================================                       
writeStr                movs    :fetch,strAddr  'initialize ptr to first 4 bytes
:again                  mov     loopCnt,#4      'initialize byte counter
:fetch                  mov     fourBytes,0-0   'pickup next four bytes

:nextByte               call    #outputByte     'output low order byte
                        shr     fourBytes,#8    'shift next byte into poeition
                        djnz    loopCnt,#:nextByte
                        
                        add     :fetch,#1        'move to next 4 bytes
                        jmp     #:again

writeStr_ret            ret

outputByte              mov     wordOut,fourBytes
                        and     wordOut,#$ff    wz
              if_z      jmp     #writeStr_ret   'exit writeStr upon null found
              
                        call    #waitForTxreg   'wait for txreg to be available
                        wrword  wordOut,txAddr  'write the character
outputByte_ret          ret
'==============================================================================

'=================================== waitForTxreg =============================
waitForTxreg            rdword  t1,txAddr
                        cmp     t1,EMPTY        wz
              if_nz     jmp     #waitForTxreg
waitForTxreg_ret        ret              
'==============================================================================

'=================================== sendChar =================================
sendChar                call    #waitForTxreg
                        wrword  wordOut,txAddr
sendChar_ret            ret                        
'==============================================================================
'=================================== writeComma ===============================
writeComma              mov     wordOut,#","
                        call    #sendChar
writeComma_ret          ret                        
'==============================================================================

'=================================== writeCharv ===============================
writeCharv              mov     wordOut,#"v"
                        call    #sendChar
writeCharv_ret          ret                        
'==============================================================================

'=================================== writeCharu ===============================
writeCharu              mov     wordOut,#"u"
                        call    #sendChar
writeCharu_ret          ret                            
'==============================================================================
                     
'=================================== writeHex =================================
writeHex                mov     loopCnt,#8      'initialize for 8 hex chars

:again                  rol     hexOut,#4       'move next nibble to low 4 bits
                        mov     t2,hexOut
                        and     t2,#$f          'leave low order 4 bits
                        
                        'convert the 4 bits in t2 to a hex character
                        cmp     t2,#9           wz,wc
               if_be    add     t2,#"0"
               if_a     add     t2,#"a"-10

                        'output the hex character
                        call    #waitForTxreg
                        wrword  t2,txaddr       'write the character
                        
                        djnz    loopCnt,#:again
writeHex_ret            ret                                               
'==============================================================================

EMPTY         long      $ffff
piValue       long      3.14159265    'could have used built-in PI

              long      'force helloString to be long aligned
helloString   byte      "Ok",CR,NULL

'The SerialPort Terminal client looks for strings enclosed in vertical bars.
'It extracts those and sends them to C# (specifically String.Format( fmtString,obj[] )
'so that the full power of C# formatting is availbale for displaying output from
'the propeller.  Of course, C# needs to know the type of the parameters.  So we use an
'artifice: all paramters are supplied as hex strings and are to be converted to Int32
'unless the leading character is u (in which case the hex string is converted to Uint32)
'or a v (in which case the hex string is converted to a float ).

              long      'force fmtStringA to be long aligned
fmtStringA    byte      "|",DQ,"pi = {0:f6} at cnt = {1,14:n0}",DQ,NULL

              long      'force fmtStringB to be long aligned
fmtStringB    byte      "|",CR,NULL              

              
fourBytes     res       1       'holds the next long (4 bytes) of the string
hexOut        res       1       'holds long that is to be output as hex string
wordOut       res       1       'working register for extracting single byte
t1            res       1       'general purpose temp
t2            res       1       'general purpose temp
txAddr        res       1       'holds hub address of txreg
rxAddr        res       1       'holds hub address of rxreg
strAddr       res       1       'holds cog address of start of string
loopCnt       res       1