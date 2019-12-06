''********************************************
''*  1Mbaud Full-Duplex Serial Driver v1.0   *
''*  Author: David Sloan                     *
''*  Copyright (c) 2017 David Sloan          *
''*  See end of file for terms of use.       *
''********************************************

''this is and example of assembly write using Ser1Mb control registers
''it also shows locking mechanisms to syncronize multiple core access to tx functions 

con

  'configure for 80MHz clock using 5MHz crystal
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

obj                  
  ser : "Ser1Mb"                   

pub main | ch

  'lock resource id (0-7)
  lockId := 0

  lockclr(lockId)                                  
  ser.start(31, 30)
  start_async_asm  
  

  repeat
    ch := ser.rx
    LockSerTx
      WriteStr(string("Spin Echo:"))
      WriteHex(ch, 2)
      ser.tx(13)
    UnlockSerTx

pub start_async_asm
  pTxDataReg := ser.TxRegAddr     
  pMessage := string("message from assembly", 13) 
  cognew(@asm_start, 0)                      
    

pri LockSerTx
  repeat while (lockset(lockId))                                                                                   

pri UnlockSerTx   
  lockclr(lockId)  

pri WriteStr(pStr)
  repeat while (byte[pStr] <> 0)
    ser.tx(byte[pStr++])

pri WriteHex(value, digits) | ch
  'rotate right
  value ->= digits * 4
  repeat digits      
    'rotate left
    value <-= 4
    ch := value & $f
    if (ch < 10)
      ser.tx("0" + ch)
    else
      ser.tx("a" + ch - 10)   

dat
org
asm_start                                  

              mov       time, cnt
              add       time, sec
msg_loop
              waitcnt   time, sec
              mov       r1, pMessage
              call      #asm_writeStr     
              jmp       #msg_loop      

'Assembly Write Hex value example. parameters(value:r1, digits:r2)
asm_writeHex
              mov       hexValue, r1
              mov       hexDigits, r2
              'multiply digit rotation by 4
              mov       r2, hexDigits
              shl       r2, #2
              'rotate value for initial digit
              ror       hexValue, r2
hexDigitLoop
              rol       hexValue, #4
              mov       r1, hexValue
              and       r1, #$f
              cmp       r1, #10                 wc, wz
        if_ae jmp       #hexLetter
hexNumeral
              add       r1, #"0"
              call      #asm_writeByte
              jmp       #hexDigitLoop_inc
hexLetter
              add       r1, #("a" - 10)
              call      #asm_writeByte
hexDigitLoop_inc
              djnz      hexDigits, #hexDigitLoop
asm_writeHex_ret
              ret


'Assembly Write String example. parameters(stringAddress:r1)
asm_writeStr
              mov       strPtr, r1
writeStr_loop
              rdbyte    r1, strPtr              wz
              'mov       r1, #"a"                 wz
        if_z  jmp       #asm_writeStr_ret
              call      #asm_writeByte
              add       strPtr, #1
              jmp       #writeStr_loop
asm_writeStr_ret
              ret

     
'Assembly Write byte example. parameters(value:r1)
asm_writeByte
              rdlong    r2, pTxDataReg
              and       r2, TxRtsFlag           nr, wz
        if_z  jmp       #asm_writeByte
              andn      r1, TxRtsFlag
              wrlong    r1, pTxDataReg
asm_writeByte_ret
              ret


lock_tx
              lockset   lockId                  wc
        if_c  jmp       #lock_tx
lock_tx_ret
              ret


unlock_tx
              lockclr   lockId
unlock_tx_ret
              ret

                             
lockId        long      0
pTxDataReg    long      0
TxRtsFlag     long      ser#TX_RTS

pMessage      long      0    
                                     
sec           long      80_000_000

r1            res       1
r2            res       1
r3            res       1   

strPtr        res       1
msg           res       1  
hexValue      res       1
hexDigits     res       1

time          res       1
    
fit 

{{

--------------------------------------------------------------------------------------------------------------------------------
|                                                   TERMS OF USE: MIT License                                                  |                                                            
--------------------------------------------------------------------------------------------------------------------------------
|Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation    | 
|files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,    |
|modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software|
|is furnished to do so, subject to the following conditions:                                                                   |
|                                                                                                                              |
|The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.|
|                                                                                                                              |
|THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE          |
|WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR         |
|COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,   |
|ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                         |
--------------------------------------------------------------------------------------------------------------------------------
}}
                                                            