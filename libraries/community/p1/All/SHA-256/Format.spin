{
/**
 * This library provides formatted string output and scan methods based on the
 * standard C sprintf and sscanf functions.  With this class you can convert
 * byte, word and long types into binary, octal, decimal or hexadecimal formatted
 * strings.  You can specify the minimum and maximum number of columns to
 * display your values, and these values can be left or right justified, with
 * or without padded zeros.  Methods are included for the following C library
 * functions: itoa, atoi, sprintf and sscanf.
 *
 * This implementation defines the functions bprintf and bscanf that take one,
 * and only one, variable parameter. The original format string must be split
 * into pieces that all have one format specifier. This normally is not a
 * problem since most format strings consists of fixed text with format
 * specifiers for values.
 *
 * @version 1.2 Dec 16, 2007
 * @author Peter Verkaik (verkaik6@zonnet.nl)
 */
}


VAR
  byte buf[33] '// for integer conversions (base2 is 32 binary digits plus closing null)

  
PUB isxdigit(ch): YesNo
  '/**
  ' * Test if character is a hexdigit.
  ' *
  ' * @param ch Character to be tested
  ' * @return True if ch is a hexdigit
  ' */
  YesNo := ((ch =< "9") AND (ch => "0")) OR ((ch =< "F") AND (ch => "A")) OR ((ch =< "f") AND (ch => "a"))


PUB isdigit(ch): YesNo
  '/**
  ' * Test if character is a digit.
  ' *
  ' * @param ch Character to be tested
  ' * @return True if ch is a digit
  ' */
  YesNo := (ch =< "9") AND (ch => "0")


PUB isspace(ch): YesNo
  '/**
  ' * Test if character is a space (0x20), tab (\t) or newline (\n).
  ' *
  ' * @param ch Character to be tested
  ' * @return True if ch is a space, tab or newline
  ' */
  YesNo := (ch == 32) OR (ch == 9) OR (ch == 10)


PUB reverse(s) | c,k
  '/**
  ' * Reverse string in place.
  ' *
  ' * @param s Character array to reverse
  ' */
  k := s + strsize(s) - 1 'address of last character
  repeat while (s < k)
    c := byte[s]
    byte[s++] := byte[k]
    byte[k--] := c


PUB itoa(n,s) | sign,sorg
  '/**
  ' * Convert signed integer to signed decimal string.
  ' *
  ' * @param n Integer value to convert
  ' * @param s Character array to hold output
  ' */
  sorg := s
  sign := n                              '// record sign
  if n < 0                              
    n := -n                              '// make n positive
  repeat                                 '// generate digits in reverse order
    byte[s++] := ((n//10) + "0")         '// get next digit
    n := n/10
  until n == 0
  if sign < 0
    byte[s++] := "-"                     '// sign character only if negative
  byte[s] := 0                           '// closing 0
  reverse(sorg)


PUB atoi(s): val | sign,n
  '/**
  ' * Convert signed decimal string to signed integer.
  ' *
  ' * @param s Character array that holds decimal string
  ' * @return Value of signed decimal string
  ' */
  repeat while isspace(byte[s])
    ++s                                  '// skip over any white space
  sign := 1                              '// assume positive
  case byte[s]
    "-": sign := -1                      '// is negative
         ++s                             '// advance only if sign (- or +) present
    "+": ++s
  n := 0
  repeat while isdigit(byte[s])
    n := (10*n) + (byte[s++] - "0")      '// calculate value
  val := sign * n                        '// adjust for sign


PUB sprintf(str,fmt,arg): index
  '/**
  ' * Print formatted string to character buffer.
  ' * This sprintf only accepts one argument to print.
  ' * See bprintf how to print multiple arguments.
  ' *
  ' * format specifiers for byte, word, long: %c,%d,%i,%b,%o,%u,%x
  ' * format specifier for string: %s
  ' * field specification (example)
  ' *   %-05.7d where - for left justify, default right justify
  ' *                 0 for padding with zeroes, default spaces
  ' *                 5 minimum field width
  ' *                 . field separator
  ' *                 7 maximum field width
  ' *
  ' * An original C sprintf statement like:
  ' * sprintf(buffer,"outside temperature %d celsius",24);
  ' * would be written as:
  ' * OBJ
  ' *   fmt: "Format"
  ' * VAR
  ' *   byte buffer[128]
  ' * PUB
  ' *   fmt.sprintf(@buffer,string("outside temperature %d celsius"),24)
  ' *
  ' * @param str Character array for formatted output
  ' * @param fmt String defining format
  ' * @param arg value parameter
  ' * @return Index in str pointing beyond last written character (eg. size of output string)
  ' */
  index := bprintf(str,0,fmt,arg)
  byte[str+index] := 0


PUB bprintf(str,si,fmt,arg): index | pad,len,maxlen,minlen,bi,left,strtype,sorg
  '/**
  ' * Print formatted string to character buffer, maintaining buffer index.
  ' * (special version of sprintf, to ease porting printf and sprintf with multiple arguments)
  ' *
  ' * format specifiers for byte, word, long: %c,%d,%i,%b,%o,%u,%x
  ' * format specifier for string: %s
  ' * field specification (example)
  ' *   %-05.7d where - for left justify, default right justify
  ' *                 0 for padding with zeroes, default spaces
  ' *                 5 minimum field width
  ' *                 . field separator
  ' *                 7 maximum field width
  ' *
  ' * An original C sprintf statement like:
  ' * sprintf(buffer,"outside temperature %d %s inside temperature %d %s",12,"fahrenheit",24,"celsius");
  ' * would be written as:
  ' * OBJ
  ' *   fmt: "Format"
  ' * VAR
  ' *   byte buffer[128]
  ' *   word k
  ' * PUB
  ' *   k := fmt.bprintf(@buffer,0,string("outside temperature %d "),12)
  ' *   k := fmt.bprintf(@buffer,k,string("%s "),string("fahrenheit"))
  ' *   k := fmt.bprintf(@buffer,k,string("inside temperature %d "),24)
  ' *   k := fmt.bprintf(@buffer,k,string("%s"),string("celsius"))
  ' *   buffer[k] := 0
  ' * The original sprintf is simply split up in smaller bprintf statements that take only 1 argument.
  ' * The end result is the same: a single output string in buffer.
  ' *
  ' * @param str Character array for formatted output
  ' * @param si Start index in str
  ' * @param fmt String defining format
  ' * @param arg value parameter
  ' * @return Index in str pointing beyond last written character
  ' */
  sorg := str 'save start address of output buffer
  len := 0
  str += si 'start from index
  repeat while byte[fmt] <> 0
    if byte[fmt] <> "%"
      if byte[fmt] <> "\"
        byte[str++] := byte[fmt++]
      else
        fmt++ 'skip backslash
        case byte[fmt]
          "\": byte[str++] := "\"
               fmt++
          "t": byte[str++] := $09
               fmt++
          "n": byte[str++] := $0A
               fmt++
          "r": byte[str++] := $0D
               fmt++
          other: byte[str++] := "\" 'output skipped backslash
                 byte[str++] := byte[fmt++]
      next
    else
      fmt++ 'skip control character %
    if byte[fmt] == "%"
      byte[str++] := byte[fmt++] '%%
      next
    if byte[fmt] == "-"
      left := true
      ++fmt 'skip -
    else
      left := false
    if byte[fmt] == "0"
      pad := "0"
    else
      pad := " "
    if isdigit(byte[fmt])  '// minimum field width
      bi := 0
      repeat while isdigit(byte[fmt])
        buf[bi++] := byte[fmt++]
      buf[bi] := 0
      minlen := atoi(@buf)
    else
      minlen := 0
    if byte[fmt] == "."   '// maximum field width
      ++fmt 'skip .
      bi := 0
      repeat while isdigit(byte[fmt])
        buf[bi++] := byte[fmt++]
      buf[bi] := 0
      maxlen := atoi(@buf)
    else
      maxlen := 0
    strtype := false 'assume no string value
    case byte[fmt++]
      "c": buf[0] := arg       '// character
           buf[1] := 0
           len := 1
      "d","i": itoa(arg, @buf)  '// signed decimal
               len := strsize(@buf)
      "b": itoab(arg, @buf, 2)  '// binary
           len := strsize(@buf)
      "o": itoab(arg, @buf, 8)  '// octal
           len := strsize(@buf)
      "u": itoab(arg, @buf, 10) '// unsigned decimal
           len := strsize(@buf)
      "x": itoab(arg, @buf, 16) '// hexadecimal
           len := strsize(@buf)
      "f": 'not supported yet  '// 32bit floating point
           buf[0] := 0
           len := 0
      "s": strtype := true
           len := strsize(arg) '// string
      other: buf[0] := 0       '// no valid format specifier
             len := 0
    if (maxlen <> 0) AND (maxlen < len)
      len := maxlen
    if (minlen > len)
      minlen := minlen - len
    else
      minlen := 0
    bi := 0
    if left == false
      if (buf[bi] == "-") AND (pad == "0")
        byte[str++] := buf[bi++]
        len--
      repeat while minlen > 0
        minlen--
        byte[str++] := pad
    repeat while len > 0
      len--
      if strtype == false
        byte[str++] := buf[bi++]  'copy ascii string of value
      else
        if (byte[arg] == 0)
          quit
        byte[str++] := byte[arg++]  'copy string argument
    if left == true
      repeat while minlen > 0
        minlen--
        byte[str++] := pad
  return str-sorg


PUB sscanf(str,fmt,arg): index
  '/**
  ' * Scan formatted string into variable, maintaining formatted string index
  ' * This sscanf only accepts one argument to scan.
  ' * See bscanf how to scan multiple arguments.
  ' *
  ' * format specifiers for byte, word, long: %c,%d,%i,%b,%o,%u,%x
  ' * format specifier for string: %s
  ' * field specification (example)
  ' *   %*4d where * specifies to scan but not assign scanned value
  ' *              4 (maximum) field width to scan
  ' *
  ' * Example:
  ' * An original C sscanf statement like
  ' * sscanf(buffer,"outside temperature %d celsius",&outtemp);
  ' * would be written as:
  ' * OBJ
  ' *   fmt: "Format"
  ' * VAR
  ' *   byte buffer[128] 'holds string to scan
  ' *   long outtemp
  ' * PUB
  ' *   fmt.sscanf(@buffer,string("outside temperature %d celsius"),@outtemp)
  ' *
  ' * @param str Character array holding formatted string to be scanned
  ' * @param fmt String defining format
  ' * @param arg address of variable to hold scanned value
  ' * @return Index in str pointing at next position to read (just after scanned argument)
  ' */
  index := bscanf(str,0,fmt,arg)


PUB bscanf(str,si,fmt,arg): index | width,bi,sign,p,skip,sorg
  '/**
  ' * Scan formatted string into variable, maintaining formatted string index
  ' * (special version of sscanf, to ease porting scanf and sscanf with multiple arguments)
  ' * format specifiers for byte, word, long: %c,%d,%i,%b,%o,%u,%x
  ' * format specifier for string: %s
  ' * field specification (example)
  ' *   %*4d where * specifies to scan but not assign scanned value
  ' *              4 (maximum) field width to scan
  ' *
  ' * Example:
  ' * An original C sscanf statement like
  ' * sscanf(buffer,"outside temperature %d %s inside temperature %d %s",&outtemp,outunit,&intemp,inunit);
  ' * would be written as:
  ' * OBJ
  ' *   fmt: "Format"
  ' * VAR
  ' *   byte buffer[128] 'holds string to scan
  ' *   byte outunit[16] 'to hold celsius/fahrenheit
  ' *   byte inunit[16]  'to hold celsius/fahrenheit
  ' *   long outtemp
  ' *   long intemp
  ' *   word k
  ' * PUB
  ' *   k := fmt.bscanf(@buffer,0,string("outside temperature %d "),@outtemp)
  ' *   k := fmt.bscanf(@buffer,k,string("%s "),@outunit)
  ' *   k := fmt.bscanf(@buffer,k,string("inside temperature %d "),@intemp)
  ' *   k := fmt.bscanf(@buffer,k,string("%s"),@inunit)
  ' *
  ' * The original sscanf is simply split up in smaller bscanf statements that take only 1 argument.
  ' * The variable k keeps track of the parsing position.
  ' *
  ' * @param str Character array holding formatted string to be scanned
  ' * @param si Start index in str to read from
  ' * @param fmt String defining format
  ' * @param arg address of variable to hold scanned value
  ' * @return Index in str pointing at next position to read
  ' */
  sorg := str
  str += si
  repeat while byte[fmt] <> 0
    if isspace(byte[fmt])                    '// white space in format
      repeat while isspace(byte[str])
        ++str           '// skip white space in str
      if byte[str] == 0
        return 0
      ++fmt
      next
    if byte[fmt] <> "%"            '// non-white space in format but no %
      repeat while isspace(byte[str])
        ++str           '// skip white space in str
      if byte[str] == 0
        return 0
      if byte[str] <> byte[fmt]
        return str-sorg      '// no match in str
      ++str
      ++fmt
      next
    ++fmt                                      '// skip over %
    if byte[fmt] == "*"
      skip := true
      ++fmt
    else
      skip := false
    if isdigit(byte[fmt])                     '// field width
      bi := 0
      repeat while isdigit(byte[fmt])
        buf[bi++] := byte[fmt++]
      buf[bi] := 0
      width := atoi(@buf)
    else
      width := 32767
    repeat while isspace(byte[str])
      ++str
    if byte[str] == 0
      return 0
    case byte[fmt]
      "c": if !skip
             byte[arg] := byte[str]
           ++str
      "s": bi := 0
           repeat while (width > 0) AND !isspace(byte[str])
             width--
             if !skip
               byte[arg++] := byte[str]
             ++str
           if !skip
             byte[arg] := 0            '// closing 0
           if byte[str] == 0
             return 0
      other: if byte[str] == "-"
               sign := -1
               ++str
             else
               if byte[str] == "+"
                 sign := 1
                 ++str
               else
                 sign := 1
             if isxdigit(byte[str])              '// integer value
               bi := 0
               repeat while (width > 0) AND isxdigit(byte[str])
                 width--
                 buf[bi++] := byte[str++]
               buf[bi] := 0
               case byte[fmt]
                 "d","i": p := sign * atoi(@buf)
                 "b": p := atoib(@buf, 2)
                 "o": p := atoib(@buf, 8)
                 "u": p := atoib(@buf, 10)
                 "x": p := atoib(@buf, 16)
                 "f": 'not supported yet        '//32bit floating point
                      skip := true
                      p := 0
                 other: skip := true
                        p := 0
               if !skip
                 LONG[arg] := p
    ++fmt
  return str-sorg


PUB itoab(n,s,b) | lowbit,sorg
  '/*
  ' * Convert unsigned integer to unsigned string using specific base.
  ' * (This is a non-standard function). Used by <code>printf</code>.
  ' *
  ' * @param n Integer value to convert
  ' * @param s Character array to hold output
  ' * @param b Base for output (2=binary, 8=octal, 10=decimal, 16=hexadecimal)
  ' */
  sorg := s
  b := (b >> 1) & $F
  repeat                             '// generate digits/letters in reverse order
    lowbit := n & 1
    n := (n >> 1) & $7FFFFFFF
    byte[s] := ((n // b) << 1) + lowbit
    if (byte[s] < 10)
      byte[s] += "0"
    else
      byte[s] += ("A"-10)
    ++s
    n := n/b
  until (n == 0)
  byte[s] := 0                        '// closing 0
  reverse(sorg)


PUB atoib(s,b): val | n,digit,sorg
  '/*
  ' * Convert unsigned string to unsigned integer using specific base.
  ' * (This is a non-standard function). Used by <code>scanf</code>.
  ' *
  ' * @param s Character array holding unsigned string
  ' * @param b Base for conversion (2=binary, 8=octal, 10=decimal, 16=hexadecimal)
  ' * @return Unsigned integer value
  ' */
  sorg := s
  n := 0
  repeat while isspace(byte[s])
    ++s
  digit := (127 & byte[s++])
  repeat while digit => "0"
    if digit => "a"
      digit -= ("a"-10)
    else
      if digit => "A"
        digit -= ("A"-10)
      else
        digit -= "0"
    if (digit => b)
      quit
    n := (b * n) + digit
    if (byte[s] == 0)
      quit
    digit := (127 & byte[s++])
  return n

  