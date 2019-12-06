{{┌──────────────────────────────────────────┐
  │ I2C slave object                         │      
  │ Author: Chris Gadd                       │     
  │ Copyright (c) 2013 Chris Gadd            │     
  │ See end of file for terms of use.        │     
  └──────────────────────────────────────────┘

  This object creates an I2C slave device with 32 byte-sized registers on the Propeller, which an I2C master device can read from and write to using standard protocol:
    7-bit device ID + read/write bit, 8-bit register address, 8 bits of data
    Supports single, repeated, and page reads and writes
    Does NOT check for overruns - Writing 5 bytes starting at register 31 may produce unexpected results
  
  To use:
    slave.start(28,29,$42)                 Start the slave object using p28 for clock, p29 for data, with device ID $42
    slave.check                            Returns the index (31-0) of the highest byte in the register that was written to by a master
                                             Subsequent calls to slave.check return the index of the next highest byte with new data
    slave.check_reg(5)                     Returns the contents of register 5 only if the new-data flag for that register is set, returns -1 otherwise                                                      
    slave.get(10)                          Returns the value of register 10
    slave.put(11,#2)                       Stores the value 2 in register 11
    slave.flush                            Clears all 32 registers to 0
    slave.address                          Returns the base address of the slave registers - useful for directly operating on the registers
                                             by higher-level objects

  Tested up to 769Kbps (max transmit speed of the master object)


  Modified by AKH to correct what appears to be a bug in detect_st_or_sp:

  Changed both occurances of the following:
          if_z          jmp       detect_st_or_sp_ret
  to:
          if_z          jmp       #detect_st_or_sp_ret

}}                                                                                                                                                
VAR
  long  flags                                           ' Used to determine if a register has new data from the master

  byte  _slave_address
  byte  SCL_pin
  byte  SDA_pin

  byte  register[32]
  
  byte  cog

PUB start(clk_pin, data_pin, slave_address) : okay
  stop
  _slave_address := slave_address
  SCL_pin := clk_pin
  SDA_pin := data_pin
  
  okay := cog := cognew(@entry, @flags) + 1

PUB stop
  if cog
    cogstop(cog~ - 1)

PUB address
  return @register
 
PUB check : index
{{
  Returns the number of the highest byte that was written to:
    If an I2C master wrote to addresses 3 and 7 of the slave's buffer, #7 is returned
    The flag for the highest byte is then cleared, so a subsequent check would return #3
  Returns -1 if all updated byte addresses have been returned (no new data)
}}                                                                                      
  index := (>| flags) - 1                               
  flags := flags & !(|< index)                          ' Clear the highest set bit
  
PUB check_reg(index)
{{
  Returns the value of the indexed register if that register has new data
  Returns -1 otherwise
}}
                                 
  if |< index & flags
    flags := flags & !(|< index)
    return register[index]
  return -1

PUB get(index)
  return register[index]

PUB put(index,data)
  register[index] := data
  
PUB flush | i  
  flags~
  repeat i from 0 to 31
    register[i]~
    
DAT                     org
entry
                        mov       t1,par                                        
                        mov       flags_address,t1                              ' Retrieve all of the addresses and                  
                        add       t1,#4                                         '  pin assignments from the VAR block,
                        rdbyte    device_address,t1                             '  and create bit masks
                        shl       device_address,#1
                        add       t1,#1
                        rdbyte    t2,t1
                        mov       SCL_mask,#1                                 
                        shl       SCL_mask,t2
                        add       t1,#1
                        rdbyte    t2,t1
                        mov       SDA_mask,#1
                        shl       SDA_mask,t2
                        add       t1,#1
                        mov       register_address,t1
                        mov       idle_mask,SCL_mask
                        or        idle_mask,SDA_mask
'----------------------------------------------------------------------------------------------------------------------
main
                        call      #wait_for_start
start_detected
                        call      #receive
                        mov       t1,I2C_byte
                        and       t1,#%1111_1110                                ' clear the read/write flag and compare received                                 
                        cmp       t1,device_address           wz                '  device address with assigned address
          if_ne         jmp       #main
                        call      #ack
                        test      I2C_byte,#%0000_0001        wc                ' test read(1) or write(0) bit of device address
          if_nc         jmp       #write
read  '(from_master)
                        call      #respond                                      ' The master sends an ACK or NAK in response to  
                        add       data_address,#1                               '  every byte sent back from the slave                       
          if_nc         jmp       #read                                         '  Send another byte if ACK (c=0)
                        jmp       #main                                         '  Stop if NAK (c=1)
write '(from_master)
                        rdlong    t1,flags_address                              ' Use t1 to hold all flags
                        mov       t2,#1                                         ' Use t2 to hold the flag of the current register
                        mov       data_address,register_address                 ' Prepare the to store new data
                        call      #receive                                      ' First byte received is a register address
                        add       data_address,I2C_byte                         
                        shl       t2,I2C_byte                                   ' Shift the flag to the appropriate register
                        call      #ack
:loop
                        call      #receive                                      ' Receive a data byte
                        wrbyte    I2C_byte,data_address                         ' Store in the addressed register
                        add       data_address,#1                               ' Address the next register
                        or        t1,t2                                         ' Update the flags
                        wrlong    t1,flags_address
                        shl       t2,#1                                         ' Shift the flag to the next register
                        call      #ack
                        jmp       #:loop
'======================================================================================================================
wait_for_start                                                                  ' SCL         
                        waitpeq   idle_mask,idle_mask                           ' SDA         
:loop                                                                                                 
                        waitpne   SDA_mask,SDA_mask                                                   
                        test      SCL_mask,ina                wc                                      
          if_nc         jmp       #wait_for_start
wait_for_start_ret      ret
'----------------------------------------------------------------------------------------------------------------------
receive                                                                         '      (Read) 
                        mov       loop_counter,#8                               '          
                        mov       I2C_byte,#0                                   ' SCL 
:loop                                                                           ' SDA ───────
                        waitpne   SCL_mask,SCL_mask
                        waitpeq   SCL_mask,SCL_mask
                        test      SDA_mask,ina                wc
                        rcl       I2C_byte,#1
                        call      #detect_st_or_sp                              ' Check to see if the received bit is a stop or restart
                        djnz      loop_counter,#:loop
receive_ret             ret
'----------------------------------------------------------------------------------------------------------------------
respond                                                                         '   (Write)      (Read ACK or NAK)
                        mov       loop_counter,#8                               '                             
                        rdbyte    I2C_byte,data_address                         ' SCL             
                        shl       I2C_byte,#32-8                                ' SDA  ───────           
:loop
                        waitpne   SCL_mask,SCL_mask
                        shl       I2C_byte,#1                 wc
                        muxnc     dira,SDA_mask
                        waitpeq   SCL_mask,SCL_mask
                        waitpne   SCL_mask,SCL_mask
                        djnz      loop_counter,#:loop
                        andn      dira,SDA_mask
'receive_ack_or_nak
                        waitpne   SCL_mask,SCL_mask
                        waitpeq   SCL_mask,SCL_mask
                        test      SDA_mask,ina                wc                ' C is set if NAK
                        call      #detect_st_or_sp
respond_ret             ret                                          
'----------------------------------------------------------------------------------------------------------------------
ack                                                                             ' SCL 
                        waitpne   SCL_mask,SCL_mask                             ' SDA 
                        or        dira,SDA_mask
                        waitpeq   SCL_mask,SCL_mask
                        waitpne   SCL_mask,SCL_mask
                        andn      dira,SDA_mask
ack_ret                 ret                        
'----------------------------------------------------------------------------------------------------------------------
nak                                                                             ' SCL 
                        waitpne   SCL_mask,SCL_mask                             ' SDA 
                        waitpeq   SCL_mask,SCL_mask
                        call      #detect_st_or_sp
                        waitpne   SCL_mask,SCL_mask
nak_ret                 ret                        
'----------------------------------------------------------------------------------------------------------------------
detect_st_or_sp
'                       test      SDA_mask,ina                wc                ' routine is called with C already set to SDA
          if_c          jmp       #:detect_restart
:detect_stop                                                                    ' SCL 
                        test      SCL_mask,ina                wz                ' SDA 
          if_z          jmp       #detect_st_or_sp_ret
                        test      SDA_mask,ina                wz
          if_nz         jmp       #main                                        
                        jmp       #:detect_stop
:detect_restart                                                                 ' SCL 
                        test      SCL_mask,ina                wz                ' SDA 
          if_z          jmp       #detect_st_or_sp_ret
                        test      SDA_mask,ina                wz
          if_z          jmp       #start_detected
                        jmp       #:detect_restart
detect_st_or_sp_ret     ret
'----------------------------------------------------------------------------------------------------------------------
SCL_mask                res       1
SDA_mask                res       1
idle_mask               res       1

device_address          res       1
register_address        res       1
data_address            res       1
flags_address           res       1

I2C_byte                res       1
loop_counter            res       1
t1                      res       1
t2                      res       1


                        fit

DAT                     
{{
┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                   TERMS OF USE: MIT License                                                  │                                                            
├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation    │ 
│files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,    │
│modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software│
│is furnished to do so, subject to the following conditions:                                                                   │
│                                                                                                                              │
│The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.│
│                                                                                                                              │
│THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE          │
│WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR         │
│COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,   │
│ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                         │
└──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
}}                      
