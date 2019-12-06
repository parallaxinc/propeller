{

            Program Hack by earl@uphi.net  to read the SMD500 module
            
After the start condition the master sends the module address write command and register address
to read Temp or Pressure
The register address selects the read register:

Temperature or pressure value

UT or UP  register    0xF6
PROM data register F1 0xF8
PROM data register F2 0xFA
PROM data register F3 0xFC
PROM data register F4 0xFE

Then a restart condition needs to be sent by the master followed by the module address read
that will be acknowledged by theSMD500 (ACKS).
It sends first the 8 MSB, acknowledged by the master (ACKM) then the 8 LSB.
The master sends a not acknowledge (NACKM) and finally a stop condition.

F1 = 40851
F2 = 29891
F3 = 21009
F4 = 38946

AC1 = 8083
AC2 = 234
AC3 = 195
AC4 = 4625
AC6 = 2082
B1 = 6114
B2 = 47
}
CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000
  

OBJ
  Baro  : "EC_i2c_readbaro"
  tv    : "tv_text"

VAR
  word tempF,tempc,BaroP,tempfraw,temp1,temp2
  word UT,UP,p,B3,B4,B6,Y1,f1,f2,f3,f4,ac1,ac2,ac3,ac4,ac5,ac6,b1,b2
  word x1,x1a,x2,y2,x3,y3,x4,y4,b5,t,mmHg
  word altitudeM,altitudeF
 
PUB init

   Baro.init(28,29)                'scl and sda on pin 28 and pin 29
   tv.start(12)                    ' start TV display  base pin 12
   mainLoop
   
PUB mainLoop

    repeat
    
           Baro.start_adcPres                            ' start the adc then
           Baro.readBaro                                 ' read data via i2c bus
           UP :=  baro.baro_f6 * 256 + baro.baro_f7      'raw 16 bit pressure data put in UP

     
                                     'Calibration Data
       F1 := 39535 '((baro.baro_f8 * 256) + baro.baro_f9)        'F1 my module data 
       F2 := 40600 '((baro.baro_fa * 256) + baro.baro_fb)        'F2 my module data
       F3 := 3707  '((baro.baro_fc * 256) + baro.baro_fd)        'F3 my module data
       F4 := 26866 '((baro.baro_fe * 256) + baro.baro_ff)        'F4 my module data

       AC1 := 6767        ' calculated values from MY module (only need to do once)
       AC2 := 634
       AC3 := 152
       AC4 := 3707
       AC5 := 7
       AC6 := 2290
      
       B1 := ((AC3 - 1984) * (-17268)) / 2048 - 8970
       B2 := ((AC2 - 457) * B1 / 8) / (AC3 - 1984)



      X1 := UT  - (AC6 + 1415) * 8                          'X1 =  4310
      X2 := X1 * X1 / 8192                                  'X2 =  2267
      Y2 := -4955 * X2 / 8192                               'Y2 = -1372
      X3 := X2 * X1 / 65536                                 'X3 =  149
      Y3 := 11611 * X3 / 4096                               'Y3 =  422
      X4 := X2 * X2 / 65536                                 'X4 =  78
      Y4 := -12166 * X4 / 16384                             'Y4 =  -58
      B5 := (AC5 + 4096)* (2 * X1 + Y2 + Y3 + Y4)/ 1024     'B5 =  4237
      T  := (B5 + 8) / 8                                    'T =   265  T is degrees C times 10

      TempC := T /100
      TempF := TempC *  (9/5) + 32   
         
           '      calculate coefficients B3 and B4
       B6 := B5 - 4000                                    ' B6 = 237
       X1 := (B2 * (B6 * B6 / 4096 )) / 1024              ' X1 = 0
       X2 := (AC2 - 457) * B6 / 512                       ' X2 = -103
       X3 := ((X1 + X2) + 2) / 2                          ' X3 = -26
       B3 := (AC1 - 2218) * 2 + X3                        ' B3 = 11704
       Y1 := (AC3 -1984) * B6 / 1024                      ' Y1 = -415
       Y2 := (B1 * (B6 * B6 / 4096 )) / 65535             ' Y2 = 1
       Y3 := ((Y1 + Y2) + 2) / 2                          ' Y3 = -103
       B4 := (AC4 + 8808) * (Y3 + 32768) / 16384          ' B4 = 26781
       
                                 'calculate true pressure
       p  := ((UP - B3) * 100000) / B4                    ' p   =  95732
       X1 := (p / 2^8 ) * (p / 256 )                      ' X1  = 139129
       X1a:= (X1 * 3038) / 65535                          ' X1a = 6449
       X2 := (- 7357 * p) / 65535                         ' X2  = -10747
       p  := p + (X1a + X2 + 3791) / 8                    ' p   = 95700
       mmHg := p / 100                                    ' mmHg ~600   in Mountainair,NM

        altitudeF:= (1000*mmhg*mmhg) / 42017 - (72346*mmhg) / 1000 + 41214
        altitudeM := altitudeF / 3 ' Actully 3.280839895 but I havent converted it to int math yet
             
     
     
      print
           
       waitcnt(100000 + cnt)     'wait for a while before doing it all again

        '****************** Print out all values *********************

PUB print
     
     tv.str(string($A,1,$B,3))          'set tv position to col 1 line 2      
     
     tv.str(string("UP Raw Data = "))
     tv.dec(UP)
     tv.str(string("  mmHg Pres = "))
     tv.dec(mmHg)
     tv.str(string(13," AltFeet  = "))
       tv.dec(altitudeF)
      tv.str(string("      AltMeters = "))
       tv.dec(altitudeM)

      tv.str(string($A,1,$B,5))          'set tv position to col 1 line 5      
      
     tv.str(string("TempC = "))         
      tv.dec(TempC)
     tv.str(string("           TempF = "))         
      tv.dec(TempF)
      
      tv.str(string($A,1,$B,6))          'set tv position to col 1 line 6      
           tv.str(string("Reg   Value   Reg   Value",13))         '
     
      tv.str(string("           "))
      tv.str(string($A,1,$B,7))          'set tv position to col 1 line 7
        tv.str(string("0xF6  "))            
      tv.hex(baro.baro_f6,2)                        
            tv.str(string("      0xF7  "))            
       tv.hex(baro.baro_f7,2)                    
     
      tv.str(string($A,1,$B,8))          'set tv position to col 1 line 8     
      tv.str(string("                ")) 'errase most of the line 
           tv.str(string($A,1,$B,8))     'set tv position to col 1 line 8     
      tv.str(string("0xF8  "))            
             tv.hex(baro.baro_f8,2)                     
          tv.str(string("      0xF9  "))          
       tv.hex(baro.baro_f9,2)                           
      
      tv.str(string($A,1,$B,9))          'set tv position to col 1 line 9    
      tv.str(string("                ")) 'errase most of the line   
      tv.str(string($A,1,$B,9))          'set tv position to col 1 line 9
      tv.str(string("0xFA  "))           
        tv.hex(baro.baro_fA,2)                           
           tv.str(string("      0xFB  "))          
        tv.hex(baro.baro_fB,2)                  
      
      tv.str(string($A,1,$B,10))          'set tv position to col 1 line 10      
      tv.str(string("                ")) 'errase most of the line   
      tv.str(string($A,1,$B,10))          'set tv position to col 1 line 10
        tv.str(string("0xFC  "))            
        tv.hex(baro.baro_fC,2)                          
      tv.str(string("      0xFD  "))            
          tv.hex(baro.baro_fD,2)                    
      
      tv.str(string($A,1,$B,11))         'set tv position to col 1 line 11      
      tv.str(string("                ")) 'errase most of the line   
      tv.str(string($A,1,$B,11))         'set tv position to col 1 line 11
        tv.str(string("0xFE  "))           
        tv.hex(baro.baro_fE,2)                         
             tv.str(string("      0xFF  "))          
        tv.hex(baro.baro_fF,2)
       tv.str(string($A,1,$B,1))         'set tv position to col 1 line 1
       tv.str(string(12))
        TV.str(String(" SMD500 Temp/Pressure Module Display"))

       