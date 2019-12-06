{{
PASM RFID Test
}}
CON

  { ==[ CLOCK SET ]== }
  _CLKMODE      = XTAL1 + PLL16X
  _XINFREQ      = 5_000_000      

OBJ

  DEBUG  : "FullDuplexSerial"                           ' for debugging
  RFID   : "RFID"

VAR

  BYTE outtag[12]
  BYTE output
  WORD tag_ret

PUB Main | i, time

  DEBUG.start(31, 30, 0, 57600)
  waitcnt(clkfreq + cnt)  
  DEBUG.tx($D) 
                                                      
  RFID.start_rfid(24, 25, @output, @outtag, @tag_ret, 6, @tags)
  'RFID.start_rfid(24, 25, @output, @outtag, @tag_ret, 6, 0)

  time := cnt
  REPEAT
    REPEAT WHILE (cnt - time < clkfreq)
      IF (output)
        DEBUG.bin(output, 2) 
        DEBUG.str(string(" - "))
        DEBUG.dec(tag_ret)
        DEBUG.tx($D)
        
        REPEAT i FROM 1 TO 10
          IF (outtag[i] > 31)
            DEBUG.tx(outtag[i])
          
        DEBUG.tx($D)
        output := 0             'clear output so we know when a new key has arrived
    time += clkfreq * 2
    RFID.disable
    
    waitcnt(clkfreq + cnt)
    RFID.enable      

DAT
                '' Key#         Key Byte values   Key ID
        tags       {1}  byte    "1234567890"    ' 0098765432
                   {2}  byte    "2345678901"    ' 0087654321
                   {3}  byte    "3456789012"    ' 0076543210
                   {4}  byte    "4567890123"    ' 0065432109
                   {5}  byte    $23, $89, $6F, $58, $69, $11, $12, $A2, $7C, $41 ' 0023569832
                   {6}  byte    "5678901234"    ' 0054321098

                                                   