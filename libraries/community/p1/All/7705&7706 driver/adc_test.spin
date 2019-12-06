' Simple command interpreter for the new etrac circuit
CON

  _clkmode = xtal1 + pll1x ' the prop runs at 5Mhz in order to save power. main side effect: no higher baud rates
  _xinfreq = 5_000_000




con

selectpin = 14    ' can just be tied high on the adc if desired
clokpin = 15
rxpin =  17
txpin =  17 '16   ' can be same as rx pin if tied high with a 10k resistor
rdypin = -1 '18   ' optional
OBJ
com:"FullDuplexSerial"
adc:"AD7706-2wire"

con         ' a valid setup is MODE | GAIN | BU | BUFFER | FSYNC
MODE_NORM = %0000_0000
MODE_SCAL = %0100_0000 ' cal auto from refs
MODE_CALW = %1000_0000 ' cal 0
MODE_CALM = %1100_0000 ' cal 65535

con ADCCLOCK_SLOW = %0000_1101
    ADCCLOCK_FAST = %0000_0101
var
byte setup[3] 




pub start

com.start(31,30,0,9600)
com.str(string("Test circuit for the ADC thingie",13,10))
dira[selectpin]~~
outa[selectpin]~~
adc.init(clokpin,rxpin,txpin,rdypin)

adc.ConfigureChannel1(ADCCLOCK_FAST,%01_000_1_0_0) 
adc.ConfigureChannel2(ADCCLOCK_FAST,%01_000_1_0_0) 
adc.ConfigureChannel3(ADCCLOCK_FAST,%01_000_1_0_0)
''shiftout 9,8,1,[%0010_0000] ' Configure a write to CLOCK register
'shiftout 9,8,1,[%0000_1101] ' Master clock ENABLE, 4.9152 MHz config, 60 Samp/sec
''shiftout 9,8,1,[%0001_0000] ' Configure a write to the SETUP register
'shiftout 9,8,1,[%0101_0010] ' Self calibration, gain=4, bipolar buffered input




repeat
  com.str(string("Test circuit for the ADC thingie  "))
  com.dec(adc.GetChannel1)
  com.tx(" ")
  com.dec(adc.GetChannel2)
  com.tx(" ")
  com.dec(adc.GetChannel3)
  com.tx(13)
  com.tx(10)
