{{
   Methods to manipulate the 4 LEDs  
}}
var
   byte start
   byte end
   byte repeatCount
   byte ratePerSecond
   
pub pins(_start,_end)
   start := _start
   end := _end
   dira[start..end]~~
   repeatCount := 5
   ratePerSecond := 5  
pub config(rate, count)
     ratePerSecond := rate
     repeatCount := count

pub on 
    show(%1111)

pub off
    show(%0000)
    
pub flash |i
  on
  repeat i from 1 to repeatCount
     waitcnt(clkfreq/ratePerSecond + cnt)
     show(!show(%0000))
  off   


pub sweep | j,k, m
  repeat j from 1 to repeatCount
     m := %1000
     repeat k from 0 to 3
       show(m)
       waitcnt(clkfreq/ratePerSecond + cnt)
       m >>= 1

pub side2side | j,k, m
  repeat j from 1 to repeatCount

     m := %1000
     repeat k from 0 to 3
       show(m)
       waitcnt(clkfreq/ratePerSecond + cnt)
       m >>= 1

     m := %0001
     repeat k from 0 to 3
       show(m)
       waitcnt(clkfreq/ratePerSecond + cnt)
       m <<= 1

pub join_part
     playInvert(%1001)

pub dance
   playInvert(%1010)
       
pub playInvert(m)  | k
     repeat k from 0 to repeatCount
       show(m)
       waitcnt(clkfreq/ratePerSecond + cnt)
       m :=!m

     
pub show (val)
   result :=  outa[start..end]
   outa[start..end] := val


'  time is in hundredth of a second
pub showTimed(val, time)
   result :=  outa[start..end]
   outa[start..end] := val
   waitcnt((clkfreq/100)*time + cnt)
   off
   
pub showBackward (val)
   outa[end..start] := val   