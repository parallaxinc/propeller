'' ADNS pixel dump
'' dumps an 18x18 pixel image from the ADNS chip.
'' you need a terminal progrram that converts this data to an image.
'' I use KRconnect available at Kronos Robotics.
'' www.kronosrobotics
'' 
''Explanation-register 0x48 contains the actual pixel data from the imaging array of the chip
''First set the config register(0x40) so that the chip is aways awake.  Then 324 sequential
''writes and reads will dump the data.  On write/read 325, the next image is acessed.

''NOTE: the aperature of the ADNS chip must have a lens over it to obtain an image.
''The lens that would be on a mouse would only give an image for an object less than a
''half an inch or so.  The lens from a cheap digital camera will work very well here.

CON
    _clkmode = xtal1 + pll16x                           
    _xinfreq = 5_000_000

    pixel_data = $48

obj
        adns: "adns"
        ser: "fullduplexserial"

pub     pixel_dump
        Ser.start(31, 30, 0, 19200)
        adns.init_ADNS
        adns.WR_config(1)
        repeat
          ser.tx(adns.RD_reg(pixel_data))