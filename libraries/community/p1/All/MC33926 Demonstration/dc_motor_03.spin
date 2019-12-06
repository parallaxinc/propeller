{{
dc_motor_03.spin
May 30, 2012
Greg Denson

Allows user to turn two DC motors on and off, and
change their direction by making changes to the
Pin settings in the routine below.

This Spin program is for use with the MC33926 dual motor driver carrier sold by Parallax.
I used this with the Gadget Gangster Propeller Platform USB, but it could
be used with any Propeller platform that has enough pins available to support this dual
motor controller.  For example, the Propeller Demo Board may not have enough available pins
to do everything you may want to do with this dual controller.  However, it may have enough pins
for this simple demo that doesn't use all the MC33926's pins.  Also, the Demo board probably has
sufficient pins for the single motor version of this motor controller carrier board.

Connections:

Power:
   PROPELLER BOARD              MOTOR CRIVER CARRIER BOARD (MC33926)
   Vin                          Vin (small pin on carrier board)
   Gnd                          Gnd (small pin on carrier board)
   -                            VIN (screw-type power connector) connect to POS on 12V power supply
   -                            GND (screw-type power connector) connect to GND on 12V power supply 
   -                            POS terminal on Motor 1 to one of the M1OUT1 screw terminals on carrier board
   -                            NEG terminal on Motor 1 to one of the M1OUT2 screw terminals on carrier board
   -                            POS terminal on Motor 2 to one of the M2OUT1 screw terminals on carrier board
   -                            NEG terminal on Motor 2 to one of the M2OUT2 screw terminals on carrier board
NOTE:  Since the motor direction is controlled by the carrier board, it doesn't matter which motor wire goes to
       which M#OUT# connector.  However, it would be a good idea to connect the two motors in similar patterns.
       For example, my motor has red and yellow wires.  I connected the red wire to the (+) terminal on each of
       the motors, and then connected the red wire on Motor 1 to M1OUT1 on the carrier board.  The yellow wire
       went to the (-) terminal on Motor 1, and to M1OUT2 on the carrier board.  Then, I made similar color
       connections for Motor 2.  Wiring them in similar order makes programming them to go in the direction
       you want a lot easier. And for senior citizens like myself, it's also easier to remember!   
   
Motor Control Connections (Motors 1 & 2):
   PROPELLER BOARD              MOTOR DRIVER CARRIER BOARD (MC33926)
   -                            18 M2FB   (Feedback of current draw - not used in this basic demo)   
   -                            17 M2SF   (Status Flag - Not used in this basic demo)
   P10                          16 M2D1   (PWM), (GND - OVERRIDE), (Motor 2, Disable 1)
   P9                           15 M2D2   (PWM), (VDD - OVERRIDE), (Motor 2, Disable 2)
   P8                           14 M2IN1  (Motor 2, Input 1)
   P7                           13 M2IN2  (Motor 2, Input 2)
   -                            12 INV    (VDD - OVERRIDE), (Not used in this basic demo)
   -                            11 SLEW   (VDD - OVERRIDE), (Not used in this basic demo)
   P15                          10 EN     (VDD - OVERRIDE), (Enable - connect to Vin to enable carrier)
   -                            9  M1FB   (Feedback of current draw - not used in this basic demo) 
   -                            8  M1SF   (Status Flag - not used in this basic demo)
   P3                           7  M1D1   (PWM), (GND - OVERRIDE) (Motor 1, Disable 1)
   P2                           6  M1D2   (PWM), (VDD - OVERRIDE) (Motor 1, Disable 2)
   P1                           5  M1IN1  (Motor 1, Input 1)
   P0                           4  M1IN2  (Motor 1, Input 2)
   -                            3  VDD    (Not used in this basic demo.)
   Gnd                          2  GND    (Also covered in Power connections above)
   Vin                          1  VIN    (Also covered in Power connections above)

}}

CON _CLKMODE=XTAL1 + PLL2X                              ' The system clock spec
  _XINFREQ = 5_000_000                                  ' Crystal

PUB Go
  dira[0..3]~~         ' Main Cog - Set direction of Pins 0-3 to output (Controls for Motor 1)
  dira[7..10]~~        ' Main Cog - Set direction of Pins 7-10 to output (Controls for Motor 2)
  dira[15]~~           ' Main Cog - Set direction of Pin 15 to output (Enable Carrier Board)
  repeat
    outa[0]~~          ' Set Pin 0 (M1IN2) to high - Reversing the setings on Pins 0 & 1 will reverse motor direction
    outa[1]~           ' Set Pin 1 (M1IN1) to low
    outa[2]~~          ' Set Pin 2 (M1PWM) to high (100% or full speed)  -  Setting Pin 2 to low will stop motor  
    outa[3]~           ' Set Pin 3 (M1D1) to low turns off the Disable setting for Motor 1
    
    outa[7]~~          ' Set Pin 7 (M2IN2) to high - Reversing the setings on Pins 7 & 8 will reverse motor direction
    outa[8]~           ' Set Pin 8 (M2IN1) to low
    outa[9]~~          ' Set Pin 9 (M2PWM) to high (100% or full speed)  -  Setting Pin 9 to low will stop motor    
    outa[10]~          ' Set Pin 10 (M2D1) to low turns off the Disable setting for Motor 2
    
    outa[15]~~         ' Set Pin 15 (EN)to high to enable carrier board

 'NOTE:  Above settings turn both motors in Forward directon.  Switching the settings on Pins 0 & 1 will reverse
 '       the direction of Motor 1.  Switching the settings on Pins 7 & 8 will reverse the direction of Motor 2.

 '       Changing setting of Pin 15 will disable the entire board.  Changing setings on Pis 3 and 10 can disable
 '       the individual motors.             
