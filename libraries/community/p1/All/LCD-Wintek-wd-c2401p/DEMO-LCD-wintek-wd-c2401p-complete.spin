CON
  _CLKMODE      = XTAL1 + PLL16X                        
  _XINFREQ      = 5_000_000

OBJ
  LCD : "LCD-wintek-wd-c2401p-complete"
  DELAY : "Timing"  ' from parallel lcd object by Dan Miller
                    ' http://obex.parallax.com/objects/113/

VAR
    Byte R1,R2,R3,R4,R5,R6,R7,R8
  
PUB DEMO
    LCD.START

    ' LCD.INIT  ' the high level way
    
    ' init manually via low level calls
    DELAY.pause1ms (15)     ' pause - from the timing library
    LCD.PW (1,0,0)          ' power control
    LCD.DO                  ' display on                         
    LCD.DC                  ' display control                          
    LCD.CN (15)             ' contrast control                                        
    LCD.CR (0,0,0)          ' cursor control                                           
    LCD.CL                  ' clear the screen

    ' set up the CGRAM
    ' bits for character 0 (address 0x00)
    R1 := %00000011
    R2 := %00000100
    R3 := %00001010
    R4 := %00010000
    R5 := %00010010
    R6 := %00001001
    R7 := %00000100
    R8 := %00000011
    ' push bits in to CGRAM
    LCD.CA (0,R1,R2,R3,R4,R5,R6,R7,R8)

    ' bits for character 1 (address 0x08)
    R1 := %00011000
    R2 := %00000100
    R3 := %00001010
    R4 := %00000001
    R5 := %00001001
    R6 := %00010010
    R7 := %00000100
    R8 := %00011000
    LCD.CA (8,R1,R2,R3,R4,R5,R6,R7,R8)

    repeat
        LCD.CL 

        LCD.DAl(0)  ' low level to position cursor to address 0x00
        LCD.STR(STRING("Hello World!")) ' high level call to display normal strings
         
        DELAY.pause1s (5)
        LCD.CL

        ' here we didn't explicitly set cursor position, but the clear above sets to 0x00
        LCD.STR(STRING("bit math:"))
        LCD.BIN(%101+%101,8)    ' high level call to display binary numbers including digit places

        DELAY.pause1s (5)
        LCD.CL
         
        LCD.DAl(4)
        LCD.STR(STRING("1 - 5 = "))
        LCD.INT(1-5)    ' high level call to display integers
         
        DELAY.pause1s (5)
        LCD.CL
         
        LCD.DAl(2)
        LCD.STR(STRING("HEX(255,4) = 0x"))
        LCD.HEX(255,4)  ' high level call to display hexadecimal numbers including digit places
         
        DELAY.pause1s (5)
        LCD.CL
         
        LCD.DAl(0)
        LCD.STR(STRING("BIN(170,8) = "))
        LCD.BIN(170,8)
         
        DELAY.pause1s (5)
        LCD.CL
         
        LCD.DAl(0)
        LCD.STR(STRING("END OF DEMO. HAVE FUN!"))

        ' finally write our cgram characters!
        ' again note, we didn't move the cursor or clear, so it's just at the next position
        LCD.WD(0)   ' write the character at cgram address 0
        LCD.WD(1)

        DELAY.pause1s (15)
       