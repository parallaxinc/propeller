{{
  Switches.spin
  Methods to faciliate getting user input
}}
CON
  _xinfreq = 5_000_000
  _clkmode = xtal1 + pll16x 
var
  long userWait
  long bpushTime  ' button push time
  byte start
  byte end
  byte loc
  byte binary

pub pins(_start, _end)
start := _start
end := _end
  dira[start..end]~

pub wait
  userWait := 0
  binary := read
  repeat until (binary == 1  or binary == 2 or binary == 4 or binary == 8)
         userWait++
         binary := read

  bpushTime := 0
  repeat until read == 0  ' holdon until the button is released
      bpushTime++
    
  loc := binary/2
  if loc == 4
     loc := 3

pub waitTimed( milliSeconds) | startCnt, allowedTime
  startCnt := cnt
  allowedTime := milliSeconds/1000 * clkfreq
  
  binary := read
  repeat until (binary == 1  or binary == 2 or binary == 4 or binary == 8 or cnt-startCnt > allowedTime )
         userWait++
         binary := read

  bpushTime := 0
  repeat until read == 0  ' holdon until the button is released
      bpushTime++
    
  loc := binary/2
  if loc == 4
     loc := 3
    
pub read
  result := ina[start..end]

pub location
  return loc

pub binaryValue
    return binary
      
pub pushTime
  return bpushTime
      