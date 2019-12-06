CON

  ' These values are only used when running this module by itself (demo mode).
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000


OBJ

  txx:          "txx"           ' Serial port transmitter

VAR

  long  value         ' Buffer for printing a single value
  long  pcmd          ' Pointer to command in Txx module

PUB Demo | n, i, j, k, d, zero

  ' Give the user a chance to start and enable the terminal
  waitcnt(cnt + (3 * clkfreq))

  ' Start a Txx cog for the usual TXD pin
  Start(30, 3_000_000)
  n := txx.Wait
  
  txx.Str(string(13, "TXX demo.", 13, "Init cycles="))
  DecLong(n)
  Tx(13)
  
  ' Determine time to print empty string
  zero := 0
  Str(@zero)
  n := Wait
  Str(string("Empty string="))
  DecLong(n)
  Tx(13)

  d := n

  ' Determine time to print various numbers of characters
  repeat i from 1 to 10
    Str(string("String of "))
    DecLong(i)
    Str(string(" characters: "))
    Str(GetCmd(txx#in_SPEC, txx#out_CHAR, i, string("1234567890")))
    n := Wait
    Str(string(": "))
    DecLong(n)
    Str(string(" (difference "))
    DecLong(n - d)
    d := n
    Str(string(")",13))

  ' Determine times to print various values in different ways
  repeat i from 1 to 4 ' output modes: decimal, signed, hex, binary
    repeat j from 1 to 3 ' input modes: byte, word, long  
      repeat k from 1 to 4 ' values to print: 0, $FFFF_FFFF, $7FFF_FFFF, $8000_0000
        Str(string("Printing "))
        Str(lookup(i: string("decimal "), string("signed "), string("hex "), string("binary ")))
        Str(lookup(j: string("byte"), string("word"), string("long")))
        Str(string(" for value $"))
        n := lookup(k: 0, $FFFF_FFFF, $7FFF_FFFF, $8000_0000)
        HexLong(n)
        Str(string(": "))
        Str(GetCmd(lookup(j: txx#in_BYTE, txx#in_WORD, txx#in_lONG), lookup(i: txx#out_DEC, txx#out_SGD, txx#out_HEX, txx#out_BIN), 1, @n))
        n := Wait
        Str(string(": "))
        DecLong(n)
        Tx(13)
        'waitcnt(cnt + (3 * clkfreq))
        
  ' Dump the start of memory
  ' Your mileage may vary; at the highest speed, some characters will get
  ' lost because there's no handshaking. On my system the transfer seems
  ' to go right at 1 megabit per second or slower.
  'Str(GetCmd(txx#in_SPEC, txx#out_DUMP, $FFF, 0))

  repeat


PUB Start(par_txpin, par_baudrate)
'' Starts serial transmitter in a new cog.

  return (pcmd := txx.Start(par_txpin, par_baudrate))  


PUB Stop
'' Stop the tx cog, if any.

  txx.Stop

PUB Wait
'' Wait until previous command is done.

  return txx.Wait  

PUB GetCmd(par_inmode, par_outmode, par_len, par_address)
'' Build a command value at runtime. The result can be passed to Str.
''
'' This is less efficient than calculating the command in a constant( )
'' expression, but it helps to make the reader understand how things work.
''
'' This cannot be used for RSET commands. Otherwise the result is invalid.

  result := (par_inmode << txx#sh_IN0) | (par_outmode << txx#sh_OUT0) | (par_len << txx#sh_LEN0) | (par_address { << txx#sh_ADDR0 })

PUB GetResetCmd(par_txpin, par_baudrate)
'' Build a reset command. The result can be passed to Str.
''
'' This is less efficient than calculating the command in a constant( )
'' expression, but it helps to make the reader understand how things work.
''
'' This can only be used for RSET commands. Otherwise the result is invalid.

  result := (txx#in_SPEC << txx#sh_IN0) | (txx#out_RSET << txx#sh_OUT0) | (par_txpin << txx#sh_PIN0) | ((clkfreq / par_baudrate) { << txx#sh_BITTIME0 })
     
PUB Str(parm_cmd)
'' Send string or command
''
'' The subroutine in txx waits for the previous command to finish before
'' posting the new command

  txx.Str(parm_cmd)

    
PUB Tx(par_char)
'' Send character

  ' Wait until any previous command has finished
  txx.Wait

  value := par_char
  
  ' Set command to print one character
  long[pcmd] := GetCmd(txx#in_SPEC, txx#out_CHAR, 1, @value)

PUB Dec(par_value, par_inmode)
'' Send an unsigned decimal number

  ' Wait until any previous command has finished
  txx.Wait

  value := par_value

  ' Set command to print one decimal value
  long[pcmd] := GetCmd(par_inmode, txx#out_DEC, 1, @value)  

PUB DecByte(par_value)

  Dec(par_value, txx#in_BYTE)
    
PUB DecWord(par_value)

  Dec(par_value, txx#in_WORD)
    
PUB DecLong(par_value)

  Dec(par_value, txx#in_LONG)
    
PUB SignedDec(par_value, par_inmode)
'' Send a signed decimal number

  ' Wait until any previous command has finished
  txx.Wait

  value := par_value

  ' Set command to print one signed decimal value
  long[pcmd] := GetCmd(par_inmode, txx#out_SGD, 1, @value)  

PUB SignedDecByte(par_value)

  SignedDec(par_value, txx#in_BYTE)
    
PUB SignedDecWord(par_value)

  SignedDec(par_value, txx#in_WORD)
    
PUB SignedDecLong(par_value)

  SignedDec(par_value, txx#in_LONG)
    
PUB Hex(par_value, par_inmode)
'' Send a hexadecimal number

  ' Wait until any previous command has finished
  txx.Wait

  value := par_value

  ' Set command to print one hex value
  long[pcmd] := GetCmd(par_inmode, txx#out_HEX, 1, @value)  

PUB HexByte(par_value)

  Hex(par_value, txx#in_BYTE)
    
PUB HexWord(par_value)

  Hex(par_value, txx#in_WORD)
    
PUB HexLong(par_value)

  Hex(par_value, txx#in_LONG)
    
PUB Bin(par_value, par_inmode)
'' Send a binary number

  ' Wait until any previous command has finished
  txx.Wait

  value := par_value

  ' Set command to print one binary value
  long[pcmd] := GetCmd(par_inmode, txx#out_BIN, 1, @value)

PUB BinByte(par_value)

  Bin(par_value, txx#in_BYTE)
    
PUB BinWord(par_value)

  Bin(par_value, txx#in_WORD)
    
PUB BinLong(par_value)

  Bin(par_value, txx#in_LONG)