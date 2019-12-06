pub crc8_maxim(array,numchar) | crcvalue, addr, t1, i
  crcvalue := 0
  i := 0
    repeat numchar
      addr :=  byte[array][i]
       i++
      repeat 8
        t1 := addr
        addr ->= 1
        t1 ^= crcvalue
        crcvalue ->= 1
        if (t1 & 1) == 1
          crcvalue ^= $8C
      
  return crcvalue
  