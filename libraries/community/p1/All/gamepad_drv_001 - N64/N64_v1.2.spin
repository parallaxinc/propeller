'CJ's N64 Controller Driver version 1.2
' fixed a problem with Y axis LSB
'
' uses one cog to read a standard Nintendo 64 controller 
'
'
' 
'  ___   flat side up
' (ooo) - looking into the console/extension cable port
'  123
'
'  1 - Ground
'  2 - Data, connect to propeller IO pin. pulled up to 3.3V with 1k resistor
'  3 - 3.3V
'
obj


var
        long N64_data
        long cog

pub start(N64_pin)

  pin := N64_pin
  uS    := clkfreq / 1_000_000
  uS2   := 2 * uS
  speed := clkfreq / 200
  if cog
    cogstop(cog~ - 1)   
  cog := cognew(@N64, @N64_data) + 1

pub A        'A button
  return (N64_data & $80000000) >> 31

pub B        'B button
  return (N64_data & $40000000) >> 30

pub Z        'Z button
  return (N64_data & $20000000) >> 29

pub ST       'Start button
  return (N64_data & $10000000) >> 28

pub DU       'Dpad up
  return (N64_data & $08000000) >> 27

pub DD       'Dpad down
  return (N64_data & $04000000) >> 26

pub DL       'Dpad left
  return (N64_data & $02000000) >> 25

pub DR       'Dpad right
  return (N64_data & $01000000) >> 24

pub L        'L button
  return (N64_data & $00200000) >> 21

pub R        'R button
  return (N64_data & $00100000) >> 20

pub CU       'C up
  return (N64_data & $00080000) >> 19

pub CD       'C down
  return (N64_data & $00040000) >> 18

pub CL       'C left
  return (N64_data & $00020000) >> 17

pub CR       'C right
  return (N64_data & $00010000) >> 16

pub Cpad     'Cpad at once for case use
  return (N64_data & $000F0000) >> 16
  
pub Dpad     'Dpad at once for case use
  return (N64_data & $0F000000) >> 24

pub JoyX     'Joystick X axis
  return (N64_data & $0000FF00) >> 8

pub JoyXu    'Joystick X axis unsigned
  return (N64_data & $0000FF00) >> 8 + $80

pub JoyY     'Joystick Y axis
  return (N64_data & $000000FF)

pub JoyYu    'Joystick Y axis unsigned
  return (N64_data & $000000FF) + $80 

dat
              org 0
N64           mov gcpin, #1          'initialize pin mask
              shl gcpin, pin         
              
loop          mov data1, #0          'clear old data
              
              movs ctra, pin         'set Apins
              movs ctrb, pin
              
              movi ctra, #%01000_000              'counter a adds up high time
              movi ctrb, #%01100_000              'counter b adds up low time

              mov  frqa, #1
              mov  frqb, #1
              
              mov time, cnt          'setup for clean timing on transmit
              add time, uS

              mov reps, #9           'transmit bitcount    
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
                                                         
              mov reps, #31          'receive bitcount
receive1      cmp lowtime, phsa  wc   'compare lowtime to hightime for bit that was just captured
              RCL data1, #1
              mov phsa, #0            'clear high count
              waitpeq gcpin, gcpin    'wait for high
              mov lowtime, phsb       'capture low count
              mov phsb, #0            'reset low count
              waitpne gcpin, gcpin    'wait for low
              djnz reps, #receive1    'repeat for remainder of long

              cmp lowtime, phsa  wc
              RCL data1, #1

put_data      wrlong data1, par       'globalize datasets
              
              ror command, #9        'reset command word
              mov time, cnt
              add time, speed
              waitcnt time, #0        'wait for next update period
              jmp #loop        

command       long %0000_0001_1000_0000_0000_0000_0000_0000     'command for standard controller
pin           long 0
gcpin         long 0
uS            long 0
uS2           long 0           
time          long 0
reps          long 0
data1         long 0
speed         long 0
lowtime       long 0