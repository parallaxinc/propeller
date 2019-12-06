{{*********************************************************************************************
* Serial Communications Decimal Point Inserter                                                *
*                                                                                             *
* (C) 2009 Tom Smuts                                                                          *
***********************************************************************************************
Use this method with or within FullDuplexSerial (FDS)or ExtendedFullDuplexSerial (EFDS)to add
decimal point support for integers.  DecDP allows you to insert a decimal point into an integer
with a specified number of digits to the right of the decimal point. Zeros will be inserted
after the decimal point as req'd to make up the number of places desired.
_______________________________________________________________________________________________
Why use DecDP?:
If all you want to do is to print the ratio of two numbers and not lose the remainder of the
division, simply multiply your numerator by a power of ten, ie 10, 100, 1000, etc. before
dividing and use DecDP to put a decimal point at the appropriate place.  You might save a cog
or two if you don't have to use one of the float routines.  You do have to consider the PosX
and NegX limits.  For a more specific example, let's say we have a 12 bit ADC with full scale
at 3.000 VDC.  To get the output in volts multiply the ADC out by 3000 and divide by 4096 and
call DecDP with the result and DP equal to 3. The string transmitted would then be the actual
voltage at the ADC input.
_______________________________________________________________________________________________
Operation:
The number to string algorithm is the same as used in FDS and EFDS except the ASCII characters
representing the digits are stored in a buffer instead of being transmitted serially
immediately after parsing.

The first thing that is done is to check if the number is negative. If yes, then a minus ("-")
character is transmitted using the "Tx" method in FDS or EFDS and the sign of the number is
changed to positive.

The next thing to happen is the buffer is filled with the null character (zero) and the index
into the buffer is zeroed.

The positive number is then parsed, storing the ASCII equivalent of each digit in the buffer. 
 
After parsing is completed, the number of digits to be shifted to the right is determined along
with how far to the right to shift them.  Zeros are inserted as necessary and a decimal point
is inserted.  If the first character would be a decimal point, another zero is added at the
front of the string.  The string is then transmitted serially using the "Str" method in FDS or
EFDS.
_______________________________________________________________________________________________
Use:
There are two ways this method can be implemented.  They are:

1)      Copy and paste this method directly into FDS or EFDS and use like any other function
        in the FDS or EFDS object.

2)      Copy and paste this method into the object which starts FDS or EFDS then add the object
        symbol and a period the the left of "tx" and "str" in the DecDP method.

In both cases a byte array must be declared in the object which contains the method. ie:

VAR
  byte  dp_buffer[13]         
_______________________________________________________________________________________________
Sample output:

value = 12345

dp = 0,  12345
dp = 1,  1234.5
dp = 2,  123.45
dp = 3,  12.345
dp = 4,  1.2345
dp = 5,  0.12345
dp = 6,  0.012345
dp = 7,  0.0012345
dp = 8,  0.00012345
dp = 9,  0.000012345
dp = 10, 0.0000012345
'############################################################################################}}
PUB DecDP(value, dp) | index, divisor, numDigits
'' Print a number with a decimal point to a specified number of places
'' Author: Tom Smuts
' value is the number to be printed.
' dp is the number of digits to the right of the decimal point (0 <= dp <= 10)
'--------------------------------------------------------------------------------------------  
  if value < 0                  ' Test to see if negative
    tx("-")                     ' If so, print the negative sign
    -value                      ' Change value to positive
'--------------------------------------------------------------------------------------------
  Bytefill(@dp_buffer, 0, 16)   ' Clear buffer before use
  index := 0                    ' initialize index
'--------------------------------------------------------------------------------------------    
  divisor := 1_000_000_000      ' Max pos is 2_147_483_647, max neg is -2_147_483_648
  repeat 10                     ' Parse through all ten possible digits
    if value => divisor         ' Detects 1st instance of (value => divisor)
      dp_buffer[index++] := (value / divisor + "0") ' ASCII char is stored in dp_buffer[index]
      value //= divisor         ' Modulus divide, returns 32 bit remainder
      result~~                  ' Result starts as 0 (False) and is changed to -1 (True)
                                ' when the 1st non-zero digit is reached. Stays at -1
                                ' through the remainder of the repeat loop
    elseif result OR divisor == 1   ' 1st non-zero digit or last time through repeat loop
      dp_buffer[index++] := ("0") ' ASCII "0" is stored in dp_buffer[index]
    divisor /= 10               ' Divide divisor by 10
'--------------------------------------------------------------------------------------------
  dp #>= 0                      ' Limit minimum dp value to 0
  dp <#= 10                     ' Limit maximum dp value to 10
  
  if (dp > 0)                   ' No action required if dp = 0
    numDigits := index          ' Calculate the number of digits in the string

    if (dp < numDigits)         ' When True, no 0 insertion req'd, only a decimal point

      repeat dp                 ' Shift all bytes that need shifting to the right one place
        dp_buffer[index--] := dp_buffer[index - 1]      ' Shift one place to the right     
      dp_buffer[index] := (".") ' Insert decimal point

    else                        ' 0 insertion req'd in addition to decimal point

      repeat numDigits          ' Shift all bytes that need shifting to the right
        dp_buffer[index-- + dp - numDigits + 1] := dp_buffer[index - 1]
      repeat (dp - numDigits)           ' Insert zeros as req'd
        dp_buffer[index--  + dp - numDigits + 1] := ("0")             
      dp_buffer[1] := (".")     ' Insert decimal point        
      dp_buffer[0] := ("0")     ' Insert leading "0"
'--------------------------------------------------------------------------------------------
  str(@dp_buffer)               ' Print number
  