'' *****************************
'' *  Simple_Numbers           *
'' *  (c) 2006 Parallax, Inc.  *
'' *****************************
''
'' Provides simple numeric conversion methods; all methods return a pointer to
'' a string.


CON

  str_max = 64                                          ' 63 chars + zero terminator

  
VAR

  long  idx                                             ' pointer into string
  byte  nstr[str_max]                                   ' string for numeric data


PUB dec(value) | div, zpad

'' Convert signed decimal to string

  clrstr(@nstr, str_max)                                ' clear output string  
  return decstr(value)                                  ' return pointer to numeric string
    

PUB decf(value, width) | tval, field

'' Put signed decimal value in fixed-width (space padded) string

  clrstr(@nstr, str_max)
  width := 1 #> width <# 63                             ' qualify field width 

  width #>= 1                                           ' must be at least 1
  tval := ||value                                       ' work with absolute
  field~                                                ' clear field

  repeat while tval > 0                                 ' count number of digits
    field++
    tval /= 10

  field #>= 1                                           ' min field width is 1
  if value < 0                                          ' if value is negative
    field++                                             '   bump field for neg sign indicator
  
  if field < width                                      ' need for space pad?
    repeat (width - field)                              ' yes
      nstr[idx++] := " "                                '   print space(s)

  return decstr(value)


PRI decstr(value) | div, zpad   

'' Converts value to to signed decimal string
'' -- does not clear output string; caller must do that  

  if (value < 0)                                        ' negative value? 
    -value                                              '   yes, make positive
    nstr[idx++] := "-"                                  '   and print sign indicator

  div := 1_000_000_000                                  ' initialize divisor
  zpad~                                                 ' clear zero-pad flag

  repeat 10
    if (value => div)                                   ' printable character?
      nstr[idx++] := (value / div + "0")                '   yes, print ASCII digit
      value //= div                                     '   update value
      zpad~~                                            '   set zflag
    elseif zpad or (div == 1)                           ' printing or last column?
      nstr[idx++] := "0"
    div /= 10 

  return @nstr


PUB hex(value, digits)

'' Print a hexadecimal number

  clrstr(@nstr, str_max) 
  digits := 1 #> digits <# 8                            ' qualify digits
  value <<= (8 - digits) << 2                           ' prep MS digit
  repeat digits
    nstr[idx++] := lookupz((value <-= 4) & %1111 : "0".."9", "A".."F")

  return @nstr


PUB ihex(value, digits)

'' Print and indicated hexadecimal number

  clrstr(@nstr, str_max)
  nstr[idx++] := "$"
  digits := 1 #> digits <# 8
  value <<= (8 - digits) << 2
  repeat digits
    nstr[idx++] := lookupz((value <-= 4) & %1111 : "0".."9", "A".."F")

  return @nstr    
    

PUB bin(value, digits)

'' Print a binary number

  clrstr(@nstr, str_max)
  digits := 1 #> digits <# 32                           ' qualify digits 
  value <<= 32 - digits                                 ' prep MSB
  repeat digits
    nstr[idx++] := (value <-= 1) & 1 + "0"              ' move digits (ASCII) to string

  return @nstr        


PUB ibin(value, digits)

'' Print an indicated binary number

  clrstr(@nstr, str_max)
  nstr[idx++] := "%"                                    ' preface with binary indicator
  digits := 1 #> digits <# 32 
  value <<= 32 - digits
  repeat digits
    nstr[idx++] := (value <-= 1) & 1 + "0"

  return @nstr      


PRI clrstr(str_addr, size)

  bytefill(str_addr, 0, size)                           ' clear string to zeros
  idx~                                                  ' reset index
  
       