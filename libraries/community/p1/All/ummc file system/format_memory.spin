{{ format_memory.spin

  Bob Belleville

  2007/03/20 - separated to this module
  
  p* memory format methods

  These methods take a pointer to a byte location in hub
  memory and other data.  Data is then formatted into a
  stream of bytes starting at p.  An updated p is returned.
  
}}

PUB pbyte(p,c)
''  single byte - one byte from c copied to p
  byte[p++] := c
  return p

PUB pbin(p,a,n)
''  binary output - n bytes at a copied to p
  repeat while n--
    byte[p++] := byte[a++]
  return p

PUB pstrz(p,stz) | c
''  zero terminated string copied up to the null
''    but null not copied
  repeat while c := byte[stz++]
    byte[p++] := c
  return p

PUB pstrn(p,stn,n)
''  n bytes starting at stn are copied to p (identical to pbin)
  repeat while n--
    byte[p++] := byte[stn++]
  return p

PUB phex(p,value,digits)
''  value as hex text with so many digits
  value <<= (8 - digits) << 2
  repeat digits
    byte[p++] := lookupz((value <-= 4) & $F : "0".."9", "A".."F")
  return p

PUB pdec(p,value) | i
''  value as decimal text

  if value < 0
    -value
    byte[p++] := "-"

  i := 1_000_000_000

  repeat 10
    if value => i
      byte[p++] := value / i + "0"
      value //= i
      result~~
    elseif result or i == 1
      byte[p++] := "0"
    i /= 10
  return p

PUB pcomma(p)
''  add a ,
  byte[p++] := ","
  return p
    
PUB pspace(p)
''  add a space
  byte[p++] := " "
  return p
    
PUB peol(p,type)
''  add an end of line type:
''  0     crlf
''  1     lf
''  2     cr
''  other add do nothing
  if type == 0 or type == 2
    byte[p++] := 13
  if type == 0 or type == 1
    byte[p++] := 10
  return p
    
PUB null(p)
''  add a zero
  byte[p++]~
  return p

