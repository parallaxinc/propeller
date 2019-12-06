{{
   The HT16K33 is a 16*8 LED controller that accepts display commands
   through an I2C interface. The chip controls LED grids organized as
   16-rows by 8-columns. Those LEDs could be true LED grids, or they
   could be individual segments in a multi-segment display.
                                            
   Adafruit makes several HT16K33 "backpacks" that drive different displays
   that they sell. This code will communicate with all of their backpackes
   (and any other HT16K133 chip), but the graphics functions at the very
   bottom of the code are specific to the LED geometry of the 8x8 bicolor
   matrix backpack here:

   http://www.adafruit.com/products/902 

   You can remove these functions from the code or tweak them for your own
   display.

   The adafruit backpacks have built-on pullups for SDA and SCL. Thus
   hooking multiple backpacks to the same SCL/SDA lines will place these
   pullups in parallel and reduce the resistance. This will increase the
   current consumption.   
}}

var   
  byte ADDR        ' Backpack I2C address
  byte PIN_SCL     ' I/O pin connected to SCL (SDA is very next pin)
  
  ' 8x8 bicolor specific
  byte raster[16]  ' Raster buffer for (x,y) graphics

OBJ
  i2c : "Basic_I2C_Driver_1"    
      
PUB init(i2cAddress,pinSCL)
'' Initialize the object with the given I2C-address and hardware pins.
'' The driver I am using requires SDA to be the next pin after SCL.
'   
  ADDR := i2cAddress
  PIN_SCL := pinSCL   

  i2c.Initialize(PIN_SCL)
  
  setOscillator(1)            ' Start the oscillator
  setBlink(1,0)               ' Power on, no blinking                       
  setBrightness(15)           ' Max brightness      
 
PUB setOscillator(on) | address
'' Turn the oscillator on (or off)
'
'  0010_xxx_p
'
  address := ADDR << 1 ' # R/-W bit = 0 (write)
  on := on & 1
  on := on | $20
  
  i2c.Start(PIN_SCL)
  i2c.Write(PIN_SCL,address)
  i2c.Write(PIN_SCL,on)
  i2c.Stop(PIN_SCL)              

PUB setBlink(power,rate)  | address
'' Set the display power and blink rate
''   rate = 00 = Off
''          01 = 2Hz
''          10 = 1Hz
''          11 = 0.5Hz
'
'  1000_x_rr_p
'
  address := ADDR << 1 ' # R/-W bit = 0 (write)
  rate := rate & 3
  rate := rate << 1
  power := power & 1
  rate := rate | power
  rate := rate | $80
  
  i2c.Start(PIN_SCL)
  i2c.Write(PIN_SCL,address)
  i2c.Write(PIN_SCL,rate)
  i2c.Stop(PIN_SCL)    

PUB setBrightness(level) | address
'' Set the display brightness
'' level: 0000=minimum, 1111=maximum
'
'  1110_vvvv
'
  address := ADDR << 1 ' # R/-W bit = 0 (write)
  level := level & 15
  level := level | $E0
  
  i2c.Start(PIN_SCL)
  i2c.Write(PIN_SCL,address)
  i2c.Write(PIN_SCL,level)
  i2c.Stop(PIN_SCL)

PUB writeDisplay(register,count,data) | address
'' Write a number of data values beginning with the
'' given register.

  address := ADDR << 1 ' # R/-W bit = 0 (write)
  i2c.Start(PIN_SCL)
  i2c.Write(PIN_SCL,address)
  i2c.Write(PIN_SCL,register)
    
  repeat while count>0
    i2c.Write(PIN_SCL,byte[data])
    data := data +1
    count := count -1
  
  i2c.Stop(PIN_SCL)

'
' Specific to the adafruit 8x8 bicolor backpack.
' Leave them out or tweak them.
'

'' The 8x8 bicolor matrix is wired as follows:
''   register 0: Row 0/green (LSB is left pixel, MSB is right pixel)
''   register 1: Row 0/red (LSB is left pixel, MSB is right pixel)
''   register 2: Row 1/green (LSB is left pixel, MSB is right pixel)
''   etc
''
'' Turn both red and green on to make orange

PUB clearRaster | i
  repeat i from 0 to 15
    raster[i] := 0
    
PUB drawRaster
  writeDisplay(0,16,@raster)

PUB setPixel(x,y,color) | p, ov1, ov2, mask
  p := y<<1
  mask := 1
  ov1 := color & 1
  ov2 := (color >> 1) & 1  
  ov1 := ov1 << x
  ov2 := ov2 << x
  mask := mask << x
  raster[p]   := raster[p]   & !mask | ov1
  raster[p+1] := raster[p+1] & !mask | ov2
  
pub drawLine(x0, y0, x1, y1, color) | dx, dy, difx, dify, sx, sy, ds
''Draw a straight line from (x0, y0) to (x1, y1)
'' By Phil Pilgrim:
'' http://forums.parallax.com/showthread.php/102051-Line-drawing-algorithm-anyone-create-one-in-spin?p=716238&viewfull=1#post716238
'
  difx := ||(x0 - x1)           'Number of pixels in X direciton.
  dify := ||(y0 - y1)           'Number of pixels in Y direction.
  ds := difx <# dify            'State variable change: smaller of difx and dify.
  sx := dify >> 1               'State variables: >>1 to split remainders between line ends.
  sy := difx >> 1
  dx := (x1 < x0) | 1           'X direction: -1 or 1
  dy := (y1 < y0) | 1           'Y direction: -1 or 1
  repeat (difx #> dify) + 1     'Number of pixels to draw is greater of difx and dify, plus one.
    setPixel(x0, y0,color)      'Draw the current point.
    if ((sx -= ds) =< 0)        'Subtract ds from x state. =< 0 ?
      sx += dify                '  Yes: Increment state by dify.
      x0 += dx                  '       Move X one pixel in X direciton.
    if ((sy -= ds) =< 0)        'Subtract ds from y state. =< 0 ?
      sy += difx                '  Yes: Increment state by difx.
      y0 += dy                  '       Move Y one pixel in Y direction.
 