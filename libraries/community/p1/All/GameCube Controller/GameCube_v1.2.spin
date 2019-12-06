'CJ's Gamecube controller driver v1.2
' fixed a bug with the capture of the LSBs for each long
'
'basic support for a standard GC controller model DOL-003
'
' keep clockspeed 40Mhz and up
'
' looking into the female socket on an extension or console
'   7 flat top
' /123\
'| === |
' \456/
' 1 - 5v - can be omitted
' 2 - data - pullup to 3.3 with 1K, connect to propeller pin, it is an open drain link
' 3 - gnd 
' 4 - gnd
' 5 - NC
' 6 - 3.3v supply
' 7 - shielding (outer connector at the flat side
'
'
'

obj


var
        long gcube_data[2]
        long cog

pub start(gcube_pin)

  pin := gcube_pin
  uS    := clkfreq / 1_000_000
  uS2   := 2 * uS
  address := @gcube_data + 4
  speed := clkfreq / 200
  if cog
    cogstop(cog~ - 1)   
  cog := cognew(@gcube, @gcube_data) + 1  
           
pub A
  if gcube_data & %1_00000000_00000000_00000000
    return true
  return false

pub B
  if gcube_data & %10_00000000_00000000_00000000
    return true
  return false

pub X
  if gcube_data & %100_00000000_00000000_00000000
    return true
  return false

pub Y
  if gcube_data & %1000_00000000_00000000_00000000
    return true
  return false
pub ST
  if gcube_data & %10000_00000000_00000000_00000000
    return true
  return false

pub L
  if gcube_data & %1000000_00000000_00000000
    return true
  return false

pub R
  if gcube_data & %100000_00000000_00000000
    return true
  return false

pub Z
  if gcube_data & %10000_00000000_00000000
    return true
  return false

pub Up
  if gcube_data & %1000_00000000_00000000
    return true
  return false


pub Down
  if gcube_data & %100_00000000_00000000
    return true
  return false

pub Left
  if gcube_data & %1_00000000_00000000
      return true
    return false
    
pub Right
  if gcube_data & %10_00000000_00000000
    return true
  return false

pub JoyX
  return (gcube_data >> 8) & $FF

pub JoyY
  return gcube_data & $FF

pub CX                   'C-stick X axis
  return (gcube_data[1] >> 24) & $FF
  
pub CY                   'C-stick Y axis
  return (gcube_data[1] >> 16) & $FF

pub LAnalog              'Left trigger analog
  return (gcube_data[1] >> 8) & $FF

pub RAnalog              'Right trigger analog
  return gcube_data[1] & $FF

pub Dpad                 'get all four directions at once
  return (gcube_data >> 16) & $F

dat
              org 0
gcube         mov gcpin, #1          'initialize pin mask
              shl gcpin, pin         
              
loop          mov data1, #0          'clear old data
              mov data2, #0
                         

              movs ctra, pin         'set Apins
              movs ctrb, pin
              
              movi ctra, #%01000_000              'counter a adds up high time
              movi ctrb, #%01100_000              'counter b adds up low time

              mov  frqa, #1
              mov  frqb, #1
              
              mov time, cnt          'setup for clean timing on transmit
              add time, uS

              mov reps, #25          'transmit bitcount    
transmit      waitcnt time, uS          
              or dira, gcpin         'pull line low
              rol command, #1 wc     'read bit from command into c flag
              waitcnt time, uS2      'wait 1uS
        if_c  andn dira, gcpin       'if the bit is 1 then let the line go
              waitcnt time, uS       'wait 2uS
              andn dira, gcpin       'if not released already, release line
              djnz reps, #transmit   'repeat for the rest of command word

first_bit     mov phsb, #0            'ready low count
              waitpne gcpin, gcpin    'wait for low
              mov phsa, #0            'ready high count
              waitpeq gcpin, gcpin    'wait for high
              mov lowtime, phsb       'capture low count
              mov phsb, #0            'reset low count
              waitpne gcpin, gcpin    'wait for low

              mov reps, #31           'receive bitcount
receive1      cmp lowtime, phsa  wc   'compare lowtime to hightime for bit that was just captured
              rcl data1, #1
              mov phsa, #0            'clear high count
              waitpeq gcpin, gcpin    'wait for high
              mov lowtime, phsb       'capture low count
              mov phsb, #0            'reset low count
              waitpne gcpin, gcpin    'wait for low
              djnz reps, #receive1    'repeat for remainder of long
              cmp lowtime, phsa  wc
              rcl data1, #1        
              
              mov reps, #32           'receive bitcount
receive2      cmp lowtime, phsa  wc   'compare lowtime to hightime for bit that was just captured     
              rcl data2, #1                                            
              mov phsa, #0            'clear high count                                               
              waitpeq gcpin, gcpin    'wait for high                                                  
              mov lowtime, phsb       'capture low count                                              
              mov phsb, #0            'reset low count                                                
              waitpne gcpin, gcpin    'wait for low                                                   
              djnz reps, #receive2    'repeat for remainder of long
              cmp lowtime, phsa  wc
              rcl data2, #1                          

put_data      wrlong data1, par       'globalize datasets
              wrlong data2, address  

              ror command, #25        'reset command word
              mov time, cnt
              add time, speed
              waitcnt time, #0        'wait for next update period
              jmp #loop
                            
              
              




command       long %0100_0000_0000_0011_0000_0000_1_000_0000     'command for standard controller
pin           long 0
gcpin         long 0
uS            long 0
uS2           long 0           
time          long 0
reps          long 0
data1         long 0
data2         long 0
address       long 0
speed         long 0
lowtime       long 0