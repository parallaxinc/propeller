{EaDog_Driver_demo}
CON
        _clkmode = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq = 5_000_000

OBJ
  disp      : "EaDog_driver"
  
PUB Main | i, d ''Testing EaDog128L display.Please check or change I/O pin first! 
disp.Init                       'Can init
disp.Blight(1)                  'Switch on backlight led
waitcnt(80_000_000 + cnt)       'Wait second
disp.ctrl_en(1)                 'Display select
repeat i from 0 to 7            'Can fill display $FF
  disp.ch_page($B0 + i)
  repeat 128
    disp.send_data($FF)

waitcnt(80_000_000 + cnt)
disp.cls                        'Can Clear screen

waitcnt(80_000_000 + cnt)
d += 2                          'Jump 2 byte file header (.blv file created EA LCD tools)
repeat i from 0 to 7
  disp.ch_page($B0 + i)         'Step Page address
  repeat 128
    disp.send_data(byte[@pic][d++]) 'step one byte in file
disp.ctrl_en(0)                 'Display no longer selected 


repeat                          'propeller can't stop

DAT
pic file "test.blv"     