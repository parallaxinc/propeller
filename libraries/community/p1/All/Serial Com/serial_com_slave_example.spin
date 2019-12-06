con
  sda = 13
  clk = 11
  cs = 9
  _clkmode = xtal1 + pll4x
  _xinfreq = 10_000_000
       
var
  long motor, monitor
  
obj
  ser : "serial_com_slave"
  
pub main
  dira[0]~~                                             'set optional LED indicator to output, low state
  outa[0]~                    
  ser.initialize(sda, clk, cs)                          'start the slave device library
  waitpeq(|< sda, |< sda, 0)                            'wait for the master to finish booting and to drive the
                                                            'CLK line high before beginning commands 
  motor := 1                                            'set the counter to 1 
  repeat                                               
    ser.checkstart                                      'halt routine until start signal issued (low state CS pin)
    outa[0]~~                                           'activate optional indicator on pin A0
    monitor := ser.rx                                   'receive byte from master
    ser.tx(motor)                                       'transmit counter value as response to master
    ser.stop                                            'send termination signal (high state CS pin)
    outa[0]~                                            'turn off optional indicator on pin A0
    motor ++                                            'increment counter by 1
    
pub pause(delay)
  waitcnt(delay + cnt)
  