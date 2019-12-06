'':::::::[ Driver Object for the Scribbler 2 ]:::::::::::::::::::::::::::::::::
 
{{{
+---------------------------------------+
¦          Scribbler S2 Object          ¦
¦(c) Copyright 2010 Bueno Systems, Inc. ¦
¦   See end of file for terms of use.   ¦
+---------------------------------------+
This object provides both high- and low-level drivers for the
Parallax Scribbler S2 robot.

Version History
---------------

2010.09.16: Initial Version 1(M) release
2010.09.28: Version 1(N) release:
              Fixed bug in _ee* Spin routines.
              Upped size of sound buffer to 1200.
              Added calibration methods for light sensors.
              Added 1/2 sec. delay to start routine.
2010.10.18:   Added check for zero time in play_tone.
2010.10.25:   Added log response method for light sensors.
2010.10.27: Version 1(O) release:
              Added methods to save default line sensor threshold.
2010.10.28:   Fixed bugs in calibration methods.
2010.11.15: Version 1(P) release:
              Added self-documentation features.
              Added sensitivity setting for obstacle detection.
2010.11.24: Version 1(Q) release:
              Added sample programs to self-documentation.

This file has been modified from the original Music.spin file. The
song tables and the ability to play entire songs have been removed
to gain code space.  
}}

{{=======[ Introduction ]=========================================================

S2.spin provides low-level drivers for the S2 Robot's various functions, as well as
top-level access functions to interface with those drivers. Driver functions are
separated into four additional cogs:
''
''  1. Analog, button, and LED drivers.
''  2. Motor driver.
''  3. Sound sequencer and synthesizer.
''  4. Microphone envelope detector.
''
Driver #1 is required and is started with the S2 object's main `start method. The
other drivers are optional, depending upon the user's requirements, and have their
own start methods (`start_motors, `start_tones, `start_mic_env). The S2 object's
`stop method stops all driver cogs which have been started.

The analog, button, and LED drivers are the heartbeat of the system. The analog
driver continuously cycles through sixteen analog inputs and updates their states
with a one-millisecond cycle time. The button driver monitors the state
of the S2's single pushbutton and, depending on the user-selected button mode, can
cause it to reset the S2, while displaying the button-press count on the LEDs, and
record the number of button presses in EEPROM for use by the newly-restarted user
program. The LED driver manages the LEDs' polarity and PWMing to provide various
shades and hues from the S2's red/green LEDs and blue power LED. It does this via
the LEDs' shift register port.

}}


''=======[ Constants... ]=========================================================

CON

  ''-[ Version, etc. ]-
  {{ Version numbers and miscellaneous other constants. }}

  VERSION         = 1                   'Major version ID.
  SUBVERSION      = "Q"                 'Minor version ID.

  _TONE_Q_SIZE    = 10                'Sets the size of the sound buffer (words).

  NO_CHANGE       = -1          
  FOREVER         = $7fff_ffff  
  UNDEF           = $8000_0000
  ACK             = true
  NAK             = false

  #0, NONE, LEFT, RIGHT, CENTER, POWER  'Used with LEDs, light sensors, line sensors,
                                        'obstacle sensors, and wheels.
  
  ''-[ Button and LEDs ]-
  {{ The button constants are used internally for setting and testing button modes.
     The LED constants can be used for turning the LEDs on and off and for setting intensity, blinking, and colors. }}

  'Button constants:

  RST_ENA         = $02         'Bit selector for button reset enable.
  LED_ENA         = $01         'Bit selector for button reset LED indicator enable.

  'LED constants: 

  OFF             = 0           'Applies to all LEDs.
  
  RED             = $f0         'Apply to red/green LEDs only...
  ORANGE          = $b4
  YELLOW          = $78
  CHARTREUSE      = $4b
  GREEN           = $0f
  DIM_RED         = $70
  DIM_GREEN       = $07
  BLINK_RED       = $f1
  BLINK_GREEN     = $1f
  ALT_RED_GREEN   = $ff
  
  BLUE            = $f0         'Apply to power LED only...
  BLINK_BLUE      = $f1
  DIM_BLUE        = $70

  ''-[ Tone generator ]-
  {{ These constants are used to set the voices in the tone player and to form its commands. }}

  #0, SQU, SAW, TRI, SIN        'Square, sawtooth, triangle, sine.

  #1, STOP, PAUSE, PLAY         'Tone player immediate commands.
  #0, TONE, VOLU, SYNC, PAUS    'Tone player sequence commands.

  ''-[ Result array indices ]-
  {{ These constants can be used to reference the various values in the Results array. }}

  ADC_VSS         =  0
  ADC_VDD         =  1
  ADC_5V          =  2
  ADC_5V_DIV      =  3
  ADC_VBAT        =  4
  ADC_VTRIP       =  5
  ADC_IDD         =  6

  ADC_RIGHT_LGT   =  7
  ADC_CENTER_LGT  =  8
  ADC_LEFT_LGT    =  9

  ADC_RIGHT_LIN   = 10
  ADC_LEFT_LIN    = 11

  ADC_P6          = 12
  ADC_P7          = 13

  ADC_IMOT        = 14
  ADC_IDLER       = 15
  CNT_IDLER       = 16

  LED_BYTES       = 18 'and 19
  TIMER           = 20 'and 21
  BUTTON_CNT      = 22

  ''-[ Propeller pins ]-
  {{ Port names for pins A0 through A31. }}

  P0              =  0          'Hacker ports 0 - 5.
  P1              =  1
  P2              =  2
  P3              =  3
  P4              =  4
  P5              =  5  
  OBS_TX_LEFT     =  6          'Output to left obstacle IRED.
  LED_DATA        =  7          'Output to LED shift register data pin.
  LED_CLK         =  8          'Output to LED shift register clock pin.
  MIC_ADC_OUT     =  9          'Output (feedback) for microphone sigma-delta ADC.
  MIC_ADC_IN      = 10          'Input for microphone sigma-delta ADC.
  BUTTON          = 11          'Input for pushbutton.
  IDLER_TX        = 12          'Output to idler wheel encoder IRED.
  MOT_LEFT_ENC    = 13          'Input from left motor encoder.
  MOT_RIGHT_ENC   = 14          'Input from right motor encoder.
  OBS_TX_RIGHT    = 15          'Output to right obstacle IRED.
  MOT_LEFT_DIR    = 16          'Output to left motor controller direction pin.
  MOT_RIGHT_DIR   = 17          'Output to right motor controller direction pin.
  MOT_LEFT_PWM    = 18          'Output to left motor controller PWM pin.
  MOT_RIGHT_PWM   = 19          'Output to right motor controller PWM pin.
  OBS_RX          = 20          'Input from obstacle detector IR receiver.
  SPEAKER         = 21          'Output to speaker amplifier.
  MUX0            = 22          'Outputs to analog multiplexer address pins.
  MUX1            = 23
  MUX2            = 24
  MUX3            = 25
  _MUX_ADC_OUT    = 26          'Output (feedback) from main sigma-delta ADC.
  _MUX_ADC_IN     = 27          'Input to main sigma-delta ADC.
  SCL             = 28          'Output clock to EEPROMs.
  SDA             = 29          'Input/Output data from/to EEPROMs.
  TX              = 30          'Output to RS232.
  RX              = 31          'Input from RS232.

  ''-[ ADC constants ]-
  {{These constants pertain to the main sigma-delta analog-to-digital converter.}}
  ' These are the analog multiplexer addresses controlled by pins MUX0 through MUX3.

  _MUX_IMOT       =  0          'Motor current.
  _MUX_VTRIP      =  1          'Motor overcurrent threshold.
  _MUX_VBAT       =  2          'Battery voltage.
  _MUX_IDLER      =  3          'Idler encoder response.
  _MUX_VSS        =  4          'Vss reference (used for ADC self-calibration).
  _MUX_5V_DIV     =  5          '+2.5V reference(used to measure +5V vs. Vdd).               
  _MUX_5V         =  6          '+5V reference (used for ADC self-calibration).
  _MUX_VDD        =  7          '+3.3V reference (used for ADC self-calibration.)
  _MUX_P7         =  8          'Hacker port P7 analog input.
  _MUX_RIGHT_LGT  =  9          'Right light sensor.
  _MUX_CENTER_LGT = 10          'Center light sensor.
  _MUX_P6         = 11          'Hacker port P6 analog input.
  _MUX_IDD        = 12          'Vdd current.
  _MUX_LEFT_LGT   = 13          'Left light sensor.
  _MUX_RIGHT_LIN  = 14          'Right line sensor.
  _MUX_LEFT_LIN   = 15          'Left line sensor.

  ' These values are used by the ADC sequencer to retrieve analog values and store them
  ' in their respective array positions.

  _VSS            = _MUX_VSS << 12 | ADC_VSS << 8
  _VDD            = _MUX_VDD << 12 | ADC_VDD << 8
  _5V             = _MUX_5V << 12 | ADC_5V << 8
  _5V_DIV         = _MUX_5V_DIV << 12 | ADC_5V_DIV << 8
  _VBAT           = _MUX_VBAT << 12 | ADC_VBAT << 8
  _IDD            = _MUX_IDD << 12 | ADC_IDD << 8
  _IMOT           = _MUX_IMOT << 12 | ADC_IMOT << 8
  _VTRIP          = _MUX_VTRIP << 12 | ADC_VTRIP << 8
  _IDLER          = _MUX_IDLER << 12 | ADC_IDLER << 8
  _RIGHT_LGT      = _MUX_RIGHT_LGT << 12 | ADC_RIGHT_LGT << 8
  _LEFT_LGT       = _MUX_LEFT_LGT << 12 | ADC_LEFT_LGT << 8
  _CENTER_LGT     = _MUX_CENTER_LGT << 12 | ADC_CENTER_LGT << 8
  _RIGHT_LIN      = _MUX_RIGHT_LIN << 12 | ADC_RIGHT_LIN << 8
  _LEFT_LIN       = _MUX_LEFT_LIN << 12 | ADC_LEFT_LIN << 8
  _P6             = _MUX_P6 << 12 | ADC_P6 << 8
  _P7             = _MUX_P7 << 12 | ADC_P7 << 8

  ' These values are used in the ADC task list to define the precharge time before
  ' a conversion begins.

  _SOAK_1us       = 0 << 4
  _SOAK_2us       = 1 << 4
  _SOAK_4us       = 2 << 4
  _SOAK_8us       = 3 << 4
  _SOAK_16us      = 4 << 4
  _SOAK_32us      = 5 << 4
  _SOAK_64us      = 6 << 4
  _SOAK_128us     = 7 << 4
  _SOAK_256us     = 8 << 4
  _SOAK_512us     = 9 << 4
  _SOAK_1ms       = 10 << 4
  _SOAK_2ms       = 11 << 4
  _SOAK_4ms       = 12 << 4
  _SOAK_8ms       = 13 << 4
  _SOAK_16ms      = 14 << 4
  _SOAK_32ms      = 15 << 4

  ' These values are used in the ADC task list to define low-pass filtering time constants.

  _LPF_NONE       = 0 << 1
  _LPF_1ms        = 1 << 1
  _LPF_2ms        = 2 << 1
  _LPF_4ms        = 3 << 1
  _LPF_8ms        = 4 << 1
  _LPF_16ms       = 5 << 1
  _LPF_32ms       = 6 << 1
  _LPF_64ms       = 7 << 1

  ' These values are used in the ADC task list to define the reference voltage for each reading.

  _REF_3V3         = 0
  _REF_5V0         = 1

  ''-[ EEPROM addresses ]-
  {{ These are address pointers into the auxiliary EEPROM, used for storing calibration data,
     button-press counts, and user data. }}  

  EE_BASE          = 0                     'Base address for EEPROM data area.

  EE_RESET_CNT     = EE_BASE + 0           '[1 byte]  Reset count address.
  EE_WHEEL_CALIB   = EE_BASE + 1           '[5 bytes] Wheel calibration data.
  EE_LIGHT_CALIB   = EE_BASE + 6           '[4 bytes] Light sensor calibration data.
  EE_LINE_THLD     = EE_BASE + 10          '[2 bytes] Line sensor threshold data.
  EE_OBSTACLE_THLD = EE_BASE + 12          '[2 bytes] Obstacle threshold data.
  
  EE_USER_AREA     = EE_BASE + $400        'Beginning of unreserved user area.

  ''-[ Default values ]-
  {{ These values are assigned to their respective variables on startup, unless overriding values are stored
     in EEPROM. }}

  DEFAULT_FULL_CIRCLE   = 955
  DEFAULT_WHEEL_SPACE   = 153
  DEFAULT_LIGHT_SCALE   = 0
  DEFAULT_LINE_THLD     = 32
  DEFAULT_OBSTACLE_THLD = 20             

  ''-[ Motor constants ]-
  {{ Command, status bits, and indices into the motor debug array. }}

  'Command bits:

  MOT_IMM         = %001        'Sets immediate (preemptive) mode for motor command.
  MOT_CONT        = %010        'Sets continuous (non-distance) mode for motor command.
  MOT_TIMED       = %100        'Sets timeout mode for motor command.

  'Status bits:

  MOT_RUNNING     = %01
  MOT_STOPPED     = %00

  'Debug indices:
  'These are indices into the motor debug array.
  'Offsets are in bytes counting from @Motor_stat.
  'The prefix indicates size of each value (Byte, Word, Long)

  L_ALL_VEL       = 4           'All four control velocities.                                   
  B_TARG_VEL      = 4           'Target velocity.                        
  B_CUR_VEL       = 5           'Current (measured) velocity.
  B_END_VEL       = 6           'End velocity for this stroke.
  B_MAX_VEL       = 7           'Maximum velocity for this stroke.
  L_BOTH_DIST     = 8           'Both left and right stroke distances.
  W_RIGHT_DIST    = 8           'Right stroke distance.
  W_LEFT_DIST     = 10          'Left stroke distance.
  L_RIGHT_COUNT   = 12          'Right coordinated countdown value.
  L_LEFT_COUNT    = 16          'Left coordinated countdown value.
  L_DOM           = 20          'Dominant distance and count.
  W_DOM_DIST      = 20          'Total distance for dominant wheel to travel.
  W_DOM_COUNT     = 22          'Distance the dominant wheel has traveled.

''=======[ Public Spin methods... ]===============================================
''
''-------[ Start and stop methods... ]--------------------------------------------
''
'' Start and stop methods are used for starting individual cogs or stopping all
'' of them at once.

PUB start | i

  {{ This is the main start routine for S2 object. It stops ALL cogs, so
     IT MUST BE CALLED FIRST, before starting other cogs.
  ''
  '' `Example: s2.start
  ''
  ''     Start s2 object.
  }}
    
  stop_all
  results_addr := @Results
  wordfill(results_addr, 0, 40)
  seq_addr := @Adc_sequence
  if (Adc_cog := cognew(@adc_all, 0) + 1)
    outa := constant(1 << SCL)
    dira := constant(1 << SPEAKER | 1 << SCL)
    _i2c_stop
    if (Reset_count := _ee_rdbyte(EE_RESET_CNT))
      _ee_wrbyte(EE_RESET_CNT, 0)
    if Reset_count > 8
      Reset_count~
    read_wheel_calibration
    read_light_calibration
    read_line_threshold
    read_obstacle_threshold
    set_led(POWER, BLUE)
    delay_tenths(5)
    return true
  else
    return false

PUB start_motors

  {{ This method starts the motor control cog. It must be called before any
     of the drawing and motor control methods are used. 
  ''
  '' `Example: s2.start_motors
  ''
  ''     Start the motor controller.
  }}

  ifnot (Motor_cog)
    Motor_cmd~~
    midler_addr := @Results + (CNT_IDLER << 1)
    result := (Motor_cog := cognew(@motor_driver, @Motor_cmd) + 1) > 0
    repeat while Motor_cmd
    In_path~
    here_is(0, 0)
    heading_is(Qtr_circle)
    set_speed(7)

PUB start_tones

  {{ This method starts the tone (sound) sequencer and synthesizer. It must
     be called before any sound methods are invoked.
  ''
  '' `Example: s2.start_tones
  ''
  ''     Start the tone sequencer/generator.
  }}

  ifnot (Tone_cog)
    wordfill(@Tone_queue, 0, _TONE_Q_SIZE + 4)
    dttime := clkfreq / $1_0000 * 2
    queue_addr := @Tone_queue
    result := (Tone_cog := cognew(@tone_seq, 0) + 1) > 0
    command_tone(PLAY)
     
PUB stop_all

  {{ This method is used to stop all S2 cogs that have been started with the other
     start methods. It is called by `start, but its use is otherwise limited.
  ''
  '' `Example: s2.stop_all
  ''
  ''     Stop all S2 cogs.
  }}

  if (Adc_cog)
    cogstop(Adc_cog~ - 1)
  if (Tone_cog)
    cogstop(Tone_cog~ - 1)
  if (Motor_cog)
    cogstop(Motor_cog~ - 1)

{{
---------[ Drawing methods... ]---------------------------------------------------

   Drawing methods can be used for drawing with the S2 or in any application
   that requires keeping track of the robot's position and heading. When the S2 is
   started, it is assumed to be situated at point (0,0) and pointing in the direction
   of the y axis (90 degrees).
   ''
   Here's an example of a program segment that will draw a capital letter "D" 100 units
   (~50mm) high and 75 units (~37mm) wide at half speed:
}}
{{{
   s2.set_speed(7)         'Set speed to 50%.
   s2.begin_path           'Start a new path.
   s2.move_to(0, 100)      'Draw the long vertical segment.
   s2.move_by(50,0)        'Turn right and draw a short horizontal segment.
   s2.arc_to(75, 75, -25)  'Curve downward with a radius of 25.
   s2.move_by(0, -50)      'Draw the short vertical segment.
   s2.arc_to(50, 0, -25)   'Curve into the bottom.
   s2.move_to(0, 0)        'Draw the bottom horizontal segment.
   s2.end_path             'Signal that the path is complete.
}}
 
PUB begin_path

  {{ Begin a path of connected movements. This method should be called before starting
     any sequence of drawing movements that need to segue smoothly, one to the next.
     The path should end with a call to `end_path.
  ''
  '' `Example: s2.begin_path
  ''
  ''     Begin a new block of connected movements.
  }}

  ifnot (In_path)
    In_path := 1 
     
PUB end_path

  {{ Output the last movement in the path, if there is one, and end the path.
     `Note: Omitting this statement may cause the last path segment not to be drawn.
  ''
  '' `Example: s2.end_path
  ''
  ''     End the current path and draw the last segment.
  }}

  if (In_path == 2)
    run_motors(0, Path_Ldist, Path_Rdist, Path_time, Path_max_spd, 0)
  In_path~

PUB set_speed(spd)

  {{ Set the speed for the drawing methods, along with the "go_", "turn_",
     and "arc_" motion methods.
  ''
  ''     `spd (0 - 15): The top speed used in subsequent calls to these methods.
  ''
  '' `Example: set_speed(7)
  ''
  ''     Set the speed to half of maximum velocity.
  }}

  Current_spd := spd

PUB move_to(x, y)

  {{ Move directly to the point (x, y). Units are approximately 0.5mm.
  ''
  ''     `x and `y (-32000 - 32000):  Target coordinates of the move.
  ''
  '' `Example: s2.move_to(1000, 50)
  ''
  ''     Move to a point 500 mm to the right and 25mm above the origin.
  }}

  move_by(x - Current_x, y - Current_y)

PUB arc_to(x, y, radius)

  {{ Move to a chosen point via an arc of a specified radius. Units are approximately 0.5mm.
  ''
  ''     `x and `y (-32000 - 32000): Target coordinates of move.
  ''
  ''     `radius: Radius of turn. (Positive is counterclockwise; negative is clockwise).
  ''
     The Cartesian distance from the current location to the target position must be no more than
     2 * `radius. If it's greater than that, the robot will move in a straight line toward the target
     position first to make up the difference, then perform the arc.
  ''
  '' `Example: s2.arc_to(1000, 50, -100)
  ''
  ''     Move to the point 500 mm to the right and 25mm above the origin in a clockwise arc of radius 25mm.
  }}

  arc_by(x - Current_x, y - Current_y, radius)

PUB move_by(dx, dy) | angle

  {{ Move from the current location by a specified displacement. Units are approximately 0.5mm.
  ''
  ''     `dx and `dy (-32000 - 32000):  Displacement of the target position from the current position.
  ''  
  '' `Example: s2.move_by(100, 50)
  ''
  ''     Move to a point 50 mm to the right and 25mm above the current location.
  }}

  turn_to(angle := _atan2(dy, dx))
  go_forward(^^(dx * dx + dy * dy))
  here_is(Current_x + dx, Current_y + dy)

PUB arc_by(dx, dy, radius) | dist2, dist, diam, half_angle, tilt

  {{ Move from the current location by a specified displacement via an arc of a specified radius.
     Units are approximately 0.5mm
  ''
  ''     `x and `y (-32000 - 32000): Target coordinates of move.
  ''
  ''     `radius: Radius of turn. (Positive is counterclockwise; negative is clockwise).
  ''
     The Cartesian length of the displacement must be no more than
     2 * radius. If it's greater than that, the robot will move in a straight line to the target
     position first to make up the difference, then perform the arc. Units are approximately 0.5mm.
  ''
  '' `Example: s2.arc_by(50, 50, -100)
  ''
  ''     Move to the point 25 mm to the right of and 25mm above the current location in a clockwise arc of radius 50mm.
  }}

  dist2 := dx * dx + dy * dy
  dist := ^^dist2
  tilt := _atan2(dy, dx)
  diam := ||radius << 1
  if (dist > diam)
    turn_to(tilt)
    go_forward(dist - diam)
    dist := diam
    dist2 := dist * dist
  half_angle := _atan2(dist >> 1, ^^(radius * radius - (dist2 >> 2)))
  if (radius < 0)
    half_angle := - half_angle
  
  turn_to(tilt - half_angle)  
  arc(half_angle << 1, radius)
  here_is(Current_x + dx, Current_y + dy)
  heading_is(tilt + half_angle)

PUB align_with(heading) | dw

  {{ Turn so that the robot is pointed parallel to the desired heading (S2 angle units),
     either in the selected direction (returns 1) or opposite the selected direction
     (returns -1), whichever requires the shortest turn to achieve.
  ''
  ''     `heading: Direction to align with in S2 angle units.
  ''
  '' `Example: dir := s2.align_with(150)
  ''
  ''     Point the robot to angle 150 (S2 angle units) or opposite that angle. Set dir to ±1, accordingly.
  }}

  dw := (heading - Current_w) // Full_circle
  dw += Full_circle & (dw < 0)
  if (dw > Half_circle)
    dw -= Full_circle
  if (||dw =< Qtr_circle)
    result := 1
  else
    dw := dw - Half_circle + Full_circle & (dw < 0)
    result := -1
  turn(dw)
  heading_is(Current_w + dw)

PUB turn_to_deg(heading)

  {{ Turn the robot to the desired heading (degrees).
  ''
  ''     `heading: Direction to point in degrees north of east.
  ''
  '' `Example: s2.turn_to(135)
  ''
  ''     Point the robot to an angle of 135 degrees (i.e. northwest).
  }}

  turn_to(heading * Full_circle / 360)

PUB turn_to(heading)

  {{ Turn the robot to the desired heading (S2 angle units).
  ''
  ''     `heading: Direction to point in S2 angle units north of east.
  ''
  '' `Example: s2.turn_to(500)
  ''
  ''     Point the robot to an angle of 500 S2 angle units.
  }}

  turn_by(heading - Current_w)

PUB turn_by_deg(dw)

  {{ Turn the robot by the desired amount (degrees).
  ''
  ''     `dw: angle by which to turn, in degrees. (Positive is counterclockwise; negative is clockwise.)
  ''
     If the net turn angle is greater than 180 degrees, the shorter rotation
     in the opposite direction is used instead.
  ''
  '' `Example: s2.turn_by_deg(90)
  ''
  ''     Rotate the robot by an angle of 90 degrees CCW.
  }}

  turn_by(dw * Full_circle / 360)    

PUB turn_by(dw)

  {{ Turn the robot by the desired amount (degrees).
  ''
  ''     `dw: angle by which to turn, in S2 angle units. (Positive is counterclockwise; negative is clockwise.)
  ''
     If the net turn angle is greater than 180 degrees, the shorter rotation
     in the opposite direction is used instead.
  ''
  '' `Example: s2.turn_by(500)
  ''
  ''     Rotate the robot by an angle of 500 S2 angle units CCW.
  }}

  dw //= Full_circle
  dw += Full_circle & (dw < 0)
  if (dw > Half_circle)
    dw -= Full_circle
  turn(dw)
  heading_is(Current_w + dw)
  return 1    

PUB here_is(x, y)

  {{ Reset the current position. Units are approximately 0.5mm.
  ''
  ''     `x and `y (-32000 - 32000): New coordinates of current position.
  ''
  '' `Example: s2.here_is(0, 0)
  ''
  ''     Reset the origin to the current location.
  }}

  Current_x := x
  Current_y := y

PUB heading_is_deg(w)

  {{ Reset the current heading. Units are in degrees north of east.
  ''
  ''     `w: New value for current heading.
  ''
  '' `Example: s2.heading_is_deg(90)
  ''
  ''     Reset the current heading to 90 degrees.
  }}

  heading_is(w * Full_circle / 360)

PUB heading_is(w)

  {{ Reset the current heading.  Units are in S2 angle units north of east.
  ''
  ''     `w: New value for current heading.
  ''
  '' `Example: s2.heading_is(567)
  ''
  ''     Reset the current heading to 567.
  }}

  Current_w := w // Full_circle
  Current_w += Full_circle & (Current_w < 0)

{{
---------[ Motion methods... ]-------------------------------------------------

   Motion methods control the movement of the S2 robot. MOTION METHODS DO NOT
   KEEP TRACK OF THE S2'S POSITION AND HEADING, unless called from one of the
   drawing methods. As such, they should NOT be mixed with calls to drawing
   methods.
   ''
   There are two basic families of motion methods: the regular kind which perform
   the commanded movements in sequence, and the "now" methods (indicated by a
   trailing _now in the method name), which preempt any movements in progress.
   The "now" methods should be used for movements which have to react to sensor
   inputs, such as those found in line-following of obstacle-avoidance programs.
}}

PUB read_wheel_calibration | circle, space

  {{ Read wheel calibration values from EEPROM, and use them if they're reasonable.
     Returns a packed long containing the calibration values. (See `get_wheel_calibration.)
     If no valid values exist in EEPROM, sets (and returns) the default values.
  ''
  '' `Example: s2.read__wheel_calibration
  ''
  ''     Get previously-written wheel calibration values.
  }}

  if (_ee_rdblock(@circle, EE_WHEEL_CALIB, 4))
    space := circle >> 16
    circle &= $ffff
    if (circle > 900 and circle < 1000 and space > 100 and space < 200)
      return set_wheel_calibration(circle, space)
  return default_wheel_calibration

PUB write_wheel_calibration

  {{ Write current wheel calibration values to EEPROM.
     Returns true on success, false on failure.
  ''
  '' `Example: s2.write_wheel_calibration
  ''
  ''     Write Full_circle and Wheel_space to EEPROM.
  }}

  return  _ee_wrblock(@Full_circle, EE_WHEEL_CALIB, 4)

PUB default_wheel_calibration

  {{ Restore wheel calibration to default values. DOES NOT SAVE IN EEPROM.
     This method is optional unless read_calibration or set_calibration
     have been called.
  ''
  '' `Example: s2.default_calibration
  ''
  ''     Restore calibration defaults.
  }}

  return set_wheel_calibration(DEFAULT_FULL_CIRCLE, DEFAULT_WHEEL_SPACE)

PUB set_wheel_calibration(circle, space)

  {{ Set the wheel calibration values to method's arguments, if they're reasonable.
     IT DOES NOT SAVE THEM IN EEPROM.
  ''
  ''     `circle: The number of encoder pulses required to turn in place 360 degrees.
  ''
  ''     `space: The spacing between the wheels. (Units are approximately 1mm.)
  ''
  '' `Example: s2.set_wheel_calibration(960, 160)
  ''
  ''     Set `Full_circle to 960 and `Wheel_space to 160.
  }}
  
  Full_circle := circle
  Wheel_space := space
  _compute_calibration
  return get_wheel_calibration

PUB get_wheel_calibration

  {{ Return the current calibration values in the following format:
  ''
  '''  31                         16 15                          0
  ''' +----------------------------------------------------------+    
  ''' ¦         Full_circle         ¦         Wheel_space        ¦
  ''' +----------------------------------------------------------+
  ''
  '' `Example: one_rotation := s2.get_wheel_calibration >> 16
  ''
  ''     Assign the value of `Full_circle to `one_rotation.
  }}

  return Full_circle << 16 | Wheel_space

PUB go_left(dist)

  {{ Turn left and go forward from there by the indicated distance. Units are
     approximately 0.5mm.
  ''
  ''     `dist: Distance to move after turning left.
  ''
  '' `Example: s2.go_left(500)
  ''
  ''     Turn left and move forward 250mm.
  }}

  turn_deg(90)
  go_forward(dist)

PUB go_right(dist)

  {{ Turn right and go forward from there by the indicated distance. Units are
     approximately 0.5mm.
  ''
  ''     `dist: Distance to move after turning right.
  ''
  '' `Example: s2.go_right(500)
  ''
  ''     Turn right and move forward 250mm.
  }}

  turn_deg(-90)
  go_forward(dist)

PUB go_forward(dist)

  {{ Go forward by the indicated distance. Units are approximately 0.5mm.
  ''
  ''     `dist: Distance to move forward.
  ''
  '' `Example: s2.go_forward(500)
  ''
  ''     Move forward 250mm.
  }}

  if (||dist == FOREVER)
    move(100, 100, 0, Current_spd, 1)
  else
    move(dist, dist, 0, Current_spd, 0)

PUB go_back(dist)

  {{ Go backward by the indicated distance. Units are approximately 0.5mm.
  ''
  ''     `dist: Distance to move backward.
  ''
  '' `Example: s2.go_back(500)
  ''
  ''     Move backward 250mm.
  }}

  if (||dist == FOREVER)
    move(-100, -100, 0, Current_spd, 1)
  else
    move(-dist, -dist, 0, Current_spd, 0)
    
PUB turn_deg(ccw_degrees)

  {{ Turn in place counter-clockwise by the indicated number of degrees.
     Negative values will turn clockwise.
  ''
  ''     `ccw_degrees: Number of counterclockwise degrees to turn.
  ''
  '' `Example: s2.turn_deg(-90)
  ''
  ''     Turn right.
  }}
   
  arc_deg(ccw_degrees, 0)   

PUB arc_deg(ccw_degrees, radius) | r, l

  {{ Move in a counter-clockwise arc of the indicated radius by the specified
     number of degrees. Radius units are approximately 0.5mm. Negative angles
     result in a clockwise arc.
  ''
  ''     `ccw_degrees: Number of counterclockwise degrees by which to arc.
  ''
  ''     `radius: Radius of arc.
  ''
  '' `Example: s2.arc_deg(90, 500)
  ''
  ''     Make a sweeping left turn with a radius of 250mm.
  }}

  arc(Full_circle * ccw_degrees / 360, radius)

PUB turn(ccw_units)

  {{ Turn in place counter-clockwise by the indicated number of degrees.
     Negative values will turn clockwise.
  ''
  ''     `ccw_units: Number of S2 angle units by which to turn in place.
  ''
  '' `Example: s2.turn(-50)
  ''
  ''     Turn a bit to the right by 50 S2 angle units.
  }}
   
  arc(ccw_units, 0)  

PUB arc(ccw_units, radius) | r, l

  {{ Move in a counter-clockwise arc of the indicated radius by the specified
     number of S2 angle units. Radius units are approximately 0.5mm. Negative angles
     result in a clockwise arc.
  ''
  ''     `ccw_units: Number of counterclockwise S2 angle units by which to arc.
  ''
  ''     `radius: Radius of arc.    ''
  ''
  '' `Example: s2.arc(100, 50)
  ''
  ''     Arc a bit to the left by 100 S2 angle units with a 25mm radius.
  }}

  r := ccw_units * (radius + WHEEL_SPACE) / WHEEL_SPACE
  l := ccw_units * (radius - WHEEL_SPACE) / WHEEL_SPACE
  move(l, r, 0, Current_spd, 0)

PUB turn_deg_now(ccw_degrees)

  {{ Turn in place counter-clockwise by the indicated number of degrees.
     Negative values will turn clockwise.
     This is a `_now method, which preempts any current motion in progress.
  ''
  ''     `ccw_degrees: Number of counterclockwise degrees to turn.
  ''
  '' `Example: s2.turn_deg_now(-90)
  ''
  ''     Immediate turn right.
  }}
   
  arc_deg_now(ccw_degrees, 0)   

PUB arc_deg_now(ccw_degrees, radius) | r, l

  {{ Move in a counter-clockwise arc of the indicated radius by the specified
     number of degrees, preempting any motion in progress.
     Radius units are approximately 0.5mm. Negative angles
     result in a clockwise arc.
  ''
  ''     `ccw_degrees: Number of counterclockwise degrees by which to arc.
  ''
  ''     `radius: Radius of arc.
  ''
  '' `Example: s2.arc_deg_now(90, 500)
  ''
  ''     Make an immediate sweeping left turn with a radius of 250mm.
  }}

  arc_now(Full_circle * ccw_degrees / 360, radius)

PUB turn_now(ccw_units)

  {{ Turn in place counter-clockwise by the indicated number of degrees,
     preempting any motion in porgress. Negative values will turn clockwise.
  ''
  ''     `ccw_units: Number of S2 angle units by which to turn in place.
  ''
  '' `Example: s2.turn_now(-50)
  ''
  ''     Immediately turn a bit to the right by 50 S2 angle units.
  }}
   
  arc_now(ccw_units, 0)  

PUB arc_now(ccw_units, radius) | r, l

  {{ Move in a counter-clockwise arc of the indicated radius by the specified
     number of S2 angle units, preempting any motion in progress.
     Radius units are approximately 0.5mm. Negative angles result in a clockwise arc.
  ''
  ''     `ccw_units: Number of counterclockwise S2 angle units by which to arc.
  ''
  ''     `radius: Radius of arc.    ''
  ''
  '' `Example: s2.arc_now(100, 50)
  ''
  ''     Immediately arc a bit to the left by 100 S2 angle units with a 25mm radius.
  }}

  r := ccw_units * (radius + WHEEL_SPACE) / WHEEL_SPACE
  l := ccw_units * (radius - WHEEL_SPACE) / WHEEL_SPACE
  move_now(l, r, 0, Current_spd, 0)

PUB move(left_distance, right_distance, move_time, max_speed, no_stop) | max_d, max_pd, max_rvel, max_lvel, end_spd

  {{ This is the base-level non-reactive user move routine. It does not interrupt motion in progress.
     If called during path construction, velocities will blend. If no path, velocity ramps to zero at end.
     This method may not return right away if it has to wait for current motion to complete.
  ''  
  ''     `left_distance: Amount to move left wheel (-32767 - 32767) in 0.5mm (approx.) increments.
  ''
  ''     `right_distance: Amount to move right wheel (-32767 - 32767) in 0.5mm (approx.) increments.
  ''
  ''     `move_time: If non-zero, time (ms) after which to stop, regardless of distance traveled.
  ''
  ''     `max_speed (0 - 15): Maximum speed (after ramping).
  ''
  ''     `no_stop: If non-zero, keep running, regardless of distance traveled unless/until timeout or a preemptive change.
  ''
  '' `Example: s2.move(10000, 5000, 10000, 7, 0)
  ''
  ''     Move in a clockwise arc for 10000/2 mm on outside, or until 10 seconds elapse, whichever occurs first, at half speed.
  }}

  left_distance := -32767 #> left_distance <# 32767
  right_distance := -32767 #> right_distance <# 32767
  max_speed := 0 #> max_speed <# 15
  Current_spd := max_speed
  
  if (In_path == 2)
    if ((left_distance ^ Path_Ldist) & $8000 or (right_distance ^ Path_Rdist) & $8000)
      end_spd~
    else
      max_d := ||left_distance #> ||right_distance
      max_pd := ||Path_Ldist #> ||Path_Rdist
      max_rvel := ((||right_distance * max_speed + (max_d >> 1))/ max_d <# (||Path_Rdist * Path_max_spd + (max_pd >> 1))/ max_pd) {
        }         * max_d / (||right_distance #> 1)
      max_lvel := ((||left_distance * max_speed + (max_d >> 1))/ max_d <# (||Path_Ldist * Path_max_spd + (max_pd >> 1))/ max_pd) {
        }         * max_d / (||left_distance #> 1)
      end_spd := max_rvel <# max_lvel
    run_motors(0, Path_Ldist, Path_Rdist, Path_time, Path_max_spd, end_spd)
    result := end_spd
  if (In_path => 1)
    if (no_stop and move_time == 0)
      run_motors(MOT_CONT, left_distance, right_distance, move_time, max_speed, 0)
      In_path~
    else
      Path_Ldist := left_distance
      Path_Rdist := right_distance
      Path_time := move_time
      Path_max_spd := max_speed
      In_path := 2
  else
    run_motors(MOT_CONT & (no_stop <> 0), left_distance, right_distance, move_time, max_speed, 0)

PUB wheels_now(left_velocity, right_velocity, move_time)

  {{ Set the wheel speeds preemptively. This method interrupts the movement in progress and
     deletes all path information. IT method always returns immediately.
  ''
  ''     `left_velocity and `right_velocity (-255 to 255): Left and right wheel velocities, respectively.
  ''
  ''     `move_time: If > 0, time out after move_time ms; otherwise do not time out.
  ''
  '' `Example: s2.wheels_now(-255, 255, 5000)
  ''
  ''     Turn left, in place, at maximum speed, for five seconds.
  }} 

  move_now(left_velocity, right_velocity, move_time, (||left_velocity #> ||right_velocity <# 255) >> 4, 1)

PUB move_now(left_distance, right_distance, move_time, max_speed, no_stop)

  {{ This is the base-level preemptive user routine for reactive movements (e.g. for line following).
     It interrupts any movement in progress and deletes all path information.
     This method always returns immediately. 
  ''
  ''     `left_distance: Amount to move left wheel (-32767 - 32767) in 0.5mm (approx.) increments.
  ''
  ''     `right_distance: Amount to move right wheel (-32767 - 32767) in 0.5mm (approx.) increments.
  ''
  ''     `move_time: If non-zero, time (ms) after which to stop, regardless of distance traveled.
  ''
  ''     `max_speed (0 - 15): Maximum speed (after ramping).
  ''
  ''     `no_stop: If non-zero, keep running, regardless of distance traveled unless/until timeout or another preemptive change.
  ''
  '' `Example: s2.move_now(1000, -1000, 0, 15, 1)
  ''
  ''     Rotate in place clockwise at full speed until preempted.
  }}  

  In_path~
  run_motors(MOT_IMM | MOT_CONT & (no_stop <> 0), left_distance, right_distance, move_time, max_speed, 0)

PUB stop_now

  {{ Stop all movement immediately and delete all path information.
  ''
  '' `Example: s2.stop_now.
  ''
  ''     Halt the S2.
  }}

  In_path~
  run_motors(MOT_IMM, 0, 0, 0, 0, 0)

PUB wait_stop

  {{ Wait for all current and pending motions to complete.
  ''
  '' `Example: s2.wait_stop
  ''
  ''     Wait for motions to complete, then return.
  }}

  repeat while moving

PUB stalled | stat, mvel, ivel, itime, vstall, istall

  {{ Check whether the S2 is stalled by testing both the motor current
     and the activitity of the idler wheel encoder.
     Return `true if stalled; `false if not.
  ''
  '' `Example: repeat until s2.stalled
  ''
  ''     Execute the repeat block as long as the bot is not stalled.
  }}

  if ((stat := Motor_stat) & $03)
    mvel := ||(stat ~> 24 + stat << 8 ~> 24)
    itime := (stat >> 8) & $ff
    ifnot (ivel := (stat & $fc) << 3)
      ivel := 512 / itime
    if (vstall := mvel * 14 / ivel > 20 + Stall_hyst)
      Stall_hyst := -2
    else
      Stall_hyst := 2
    istall := get_adc_results(ADC_IMOT) > (75 * get_adc_results(ADC_VBAT)) >> 7
    return vstall or istall

PUB moving

  {{ Return `true if motion is in progress or pending, `false if stopped with no pending motions.
  ''
  '' `Example: repeat while s2.moving
  ''
  ''     Continuously execute the following repeat block until motions are finished.
  }}

  return Motor_stat & $03 <> 0

PUB motion

  {{ Return the current motion status as a packed long:
  ''
  ''' 31            24 23           16 15            8 7         2 1 0
  ''' +---------------------------------------------------------------+
  ''' ¦±  Left wheel  ¦±  Right wheel ¦  Idler timer  ¦ Idler spd ¦Mov¦ , where
  ''' +---------------------------------------------------------------+
  ''
  '' Left wheel and right wheel are signed, twos complement eight bit velocity values,
  '' Idler timer is the time in 1/10 second since the last idler edge,
  '' Idler spd is an unsigned six-bit velocity value, and
  '' Mov is non-zero iff one or more motors are turning.
  '' Left and right wheel velocities are instanteous encoder counts over a 1/10-second interval.
  '' Idler wheel wheel velocity is updated every 1/10 second and represents the idler encoder count during the last 1.6 seconds.
  ''
  '' `Example: left_vel := s2.motion ~> 24
  ''
  ''     Get the current left wheel velocity as a signed 32-bit value.
  }}
  
  return Motor_stat

PUB motion_addr

  {{ Return the address of the status and debug array.
  ''
  '' `Example: longmove(@my_stats, s2.motion_addr, 6)
  ''
  ''     Copy all status data to the local array my_stats.
  }}

  return @Motor_stat

PUB move_ready

  {{ Return `true if a new motion command can be accepted without waiting, `false if a command is still pending.
  ''
  '' `Example: repeat until s2.move_ready
  ''
  ''     Continuously execute the following repeat block until a new move can be accepted.
  }}

  return Motor_cmd == 0

PUB run_motors(command, left_distance, right_distance, timeout, max_speed, end_speed)

  {{ Base level motor activation routine. Normally, this method is not called by the user but is called by the
     many convenience methods available to the user.
  ''
  ''     `command: the OR of either or both of the following:
  ''
  ''        `MOT_IMM:   Commanded motion starts immediately, without waiting for prior motion to finish.
  ''        `MOT_CONT:  Commanded motion will continue to run at wheel ratio given by left and right distances,
  ''                     even after distances are covered.
  ''
  ''     `left_distance, `right_distance (-32767 to 32767): The distances to be covered by the left and right wheels,
  ''         respectively. Units are approximately 0.5mm.
  ''
  ''     `timeout (0 - 65535): If non-zero, time limit (ms) after which motion stops, regardless of distance covered.
  ''
  ''     `max_speed (0 - 15): Peak velocity to be reached during motion profile.
  ''
  ''     `end_speed (0 - 15): Velocity to be attained at end of motion profile. If non-zero, this is the velocity needed to
  ''         segue smoothly into the next motion profile. end_speed should never be greater than max_speed.
  ''
  '' `Example: s2.run_motors(s2#MOT_CONT, 100, -100, 5000, 8, 0)
  ''
  ''     Turn in place clockwise for 5 seconds at half speed.
  }} 

  if (command & MOT_IMM)
    long[@Motor_Rdist]~
    long[@Motor_cmd]~
  else
    repeat while long[@Motor_cmd]
  Motor_Rdist := -32767 #> right_distance <# 32767
  Motor_Ldist := -32767 #> left_distance <# 32767
  long[@Motor_cmd] := timeout << 16 | (0 #> max_speed <# 15) << 8 | (0 #> end_speed <# 15) << 4 | command & (MOT_IMM | MOT_CONT)
  if (left_distance or right_distance)
    timeout := cnt
    repeat until moving or cnt - timeout > 800_000

''-------[ Obstacle Sensor methods... ]-------------------------------------------------

{{ The obstacle sensor methods are used to set, save, and retrieve threshold data regarding the obstacle
   sensor and to detect obstacles in front of the robot, via reflections from its two infrared LEDs.
   ''
   `NOTE: The obstacle threshold methods affect only the obstacle sensor threshold used when
   `obstacle is called with a threshold value of zero.
}}

PUB read_obstacle_threshold | thld

  {{ Read the obstacle threshold value from EEPROM, and substitute it for the
     default if the checksum is correct and the value is within reasonable bounds.
     Returns the threshold value read on success.
     If no valid calibration values exist in EEPROM, sets to (and returns) the
     default value, DEFAULT_OBSTACLE_THLD.
  ''
  '' `Example: s2.read_obstacle_threshold
  ''
  ''     Get previously-written obstacle threshold value.
  }}

  if (_ee_rdblock(@thld, EE_OBSTACLE_THLD, 1))
    thld &= $ff
    if (thld > 0 and thld =< 100)
      return set_obstacle_threshold(thld)
  return default_obstacle_threshold
 
PUB write_obstacle_threshold

  {{ Write the current obstacle threshold value to EEPROM.
     Returns true on a successful write; false otherwise.
  ''
  '' `Example: s2.write_obstacle_threshold
  ''
  ''     Write current obstacle threshold value to EEPROM.
  }}

  return _ee_wrblock(@Obstacle_thld, EE_OBSTACLE_THLD, 1)

PUB default_obstacle_threshold

  {{ Restore the obstacle threshold to its default value. DOES NOT SAVE IN EEPROM.
     This method is optional unless `read_obstacle_threshold or `set_obstacle_threshold
     has been called successfully. Returns the default value, DEFAULT_OBSTACLE_THRESHOLD.
  ''
  '' `Example: s2.default_obstacle_threshold
  ''
  ''     Restore calibration default.
  }}

  return set_obstacle_threshold(DEFAULT_OBSTACLE_THLD)

PUB set_obstacle_threshold(thld)  

  {{ Set the obstacle sensor threshold. DOES NOT SAVE IN EEPROM. Returns the value set.
  ''
  ''     `thld: The new value for the default threshold.
  ''  
  '' `Example: s2.set_obstacle_threshold(10)
  ''
  ''     Set obstacle sensor threshold to 10.
  ''
     This becomes the value used when the `obstacle method is called with an argument of zero.
  }}
  
  return Obstacle_thld := thld

PUB get_obstacle_threshold

  {{ Returns the current obstacle sensor threshold.
  ''
  '' `Example: Thld := s2.get_obstacle_threshold
  ''
  ''     Set `Thld to the current obstacle threshold.
  }}
  
  return Obstacle_thld  
  
PUB obstacle(side, threshold)

  {{ Return the value of the obstacle detection: `true = obstacle; `false = no obstacle.
  '' 
  ''     `side (`LEFT or `RIGHT): Select the side to check.
  ''
  ''     `threshold (0 - 100): Set the threshold of the  detection. At high threshold values,
  ''         only very close objects will be detected. At low values, farther objects (and possibly
  ''         the rolling surface itself) will be detected. If `threshold == 0 the default (or
  ''         calibration) threshold setting will be used. 
  ''
  '' `Example: obstacle_both := s2.obstacle(s2#LEFT, 0) and s2.obstacle(s2#RIGHT, 0)
  ''
  ''     Obstacle_both is set on left AND right obstacles, using the default sensitivity.
  }}

  ifnot (threshold)
    threshold := Obstacle_thld
  threshold := threshold #> 1 <# 100
  frqa := 14000 * threshold + 20607 * (100 - threshold)
  if (side == LEFT)
    ctra := %00100 << 26 | OBS_TX_LEFT
    dira[OBS_TX_LEFT]~~
  elseif (side == RIGHT)
    ctra := %00100 << 26 | OBS_TX_RIGHT
    dira[OBS_TX_RIGHT]~~
  waitcnt(cnt + 24000)
  result := ina[OBS_RX] == 0
  dira[OBS_TX_LEFT]~
  dira[OBS_TX_RIGHT]~
  ctra~
  waitcnt(cnt + clkfreq / 1000)

''-------[ Line Sensor methods... ]-------------------------------------------------

{{ The line sensor methods are used to set, save, and retrieve threshold data regarding the line sensor
   and to detect dark vs. light markings underneath the robot to the immediate left and right of its
   centerline.
   ''
   `NOTE: The following line_threshold methods affect only the line sensor threshold used when
   line_sensor is called with a threshold value of zero.
}}

PUB read_line_threshold | thld

  {{ Read the line threshold value from EEPROM, and substitute it for the default
     if checksum is correct and value is reasonable.
     Returns the threshold value read on success.
     If no valid calibration values exist in EEPROM, sets to (and returns)the
     default value DEFAULT_LINE_THLD.
  ''  
  '' `Example: s2.read_line threshold
  ''  
  ''     Get previously-written line threshold value.
  }}

  if (_ee_rdblock(@thld, EE_LINE_THLD, 1))
    thld &= $ff
    if (thld > 5 and thld < 100)
      return set_line_threshold(thld)
  return default_line_threshold

PUB write_line_threshold

  {{ Write current line thrshsold value to EEPROM.
     Returns `true on a successful write; `false otherwise.
  ''
  '' `Example: s2.write_line_threshold
  ''
  ''     Write current line threshold value to EEPROM.
  }}

  return _ee_wrblock(@Line_thld, EE_LINE_THLD, 1)

PUB default_line_threshold

  {{ Restore line threshold to default value. DOES NOT SAVE IN EEPROM.
     This method is optional unless read_line_threshold or set_line_threshold
     have been called successfully.
     Returns the default value.
  ''
  '' `Example: s2.default_line_threshold
  ''
  ''     Restore calibration default.
  }}

  return set_line_threshold(DEFAULT_LINE_THLD)

PUB set_line_threshold(thld)  

  {{ Set the line sensor threshold. THE VALUE IS NOT SAVED IN EEPROM. Return the value set.
     This becomes the value used when the line_sensor method is called with an argument of zero.
  ''
  ''     `thld (1 - 255): The new threshold value.
  ''
  '' `Example: s2.set_line_threhsold(32)
  ''
  ''     Set line sensor threshold to 32.
  }}
  
  return Line_thld := thld

PUB get_line_threshold

  {{ Returns the current line sensor threshold.
  ''
  '' `Example: Thld := s2.get_line_threshold
  ''
  ''     Set the current line threshold value to `Thld.
  }}
  
  return Line_thld  
  
PUB line_sensor(side, threshold)

  {{ Return the value of the line sensor on the chosen side.
  ''
  ''     `side (`LEFT or `RIGHT): The side to sense.
  ''
  ''     `threshold: The value to compare the analog sensor value to.
  ''
  ''         If `threshold > 0,
  ''           return (`false == dark; `true == light) the value of the line sensor on the selected side,
  ''           compared to `threshold.
  ''         If `threshold == 0,
  ''           return (`false == dark; `true == light) the value of the line sensor on the selected side,
  ''           compared to either the default threshold or to a vlue retrieved from EEPROM.  
  ''         If threshold < 0,
  ''           return the analog value of the line sensor on the selected side.
  ''
  '' `Example: if (s2.line_sensor(s2#LEFT, 0))
  ''
  ''     The `if block is executed if the left line sensor is seeing a default bright reflection.
  }}

  if (side == LEFT)
    result := word[results_addr][ADC_LEFT_LIN] >> 8
  elseif (side == RIGHT)
    result := word[results_addr][ADC_RIGHT_LIN] >> 8
  if (threshold == 0)
    result =>= Line_thld
  elseif (threshold > 0)
    result =>= threshold

''-------[ Light Sensor methods... ]-------------------------------------------------

{{ The light sensor methods are used to set, save, and retrieve threshold data regarding the light sensors
   and to detect light levels from each of the left, center and right sensors.
   ''
   `NOTE: The following light_calibration methods affect only the light sensor calibration values used when
   `light_sensor_log is called. They do not influence the return values from `light_sensor, `light_sensor_raw,
   or `light_sensor_word.
}}

PUB read_light_calibration | cal

  {{ Read light calibration values from EEPROM, and use them if they're reasonable.
     Returns the calibration values (packed long) on success. (See `get_light_calibration.)
     If no valid calibration values exist in EEPROM, sets to (and returns)the
     default values.
  ''
  '' `Example: s2.read_light_calibration
  ''
  ''     Get previously-written light calibration values.
  }}

  if (_ee_rdblock(@cal, EE_LIGHT_CALIB, 3))
    return set_light_calibration(cal << 24 ~> 24, cal << 16 ~> 24, cal << 8 ~> 24)
  else
    return default_light_calibration

PUB write_light_calibration | cal

  {{ Write current light calibration values to EEPROM.
     Returns `true on a successful write; `false otherwise.
  ''
  '' `Example: s2.write_light_calibration
  ''
  ''     Write current light calibration values to EEPROM.
  }}

  cal := get_light_calibration
  return _ee_wrblock(@cal, EE_LIGHT_CALIB, 3)

PUB default_light_calibration

  {{ Restore the light calibration to default values. NEW VALUES ARE NOT SAVED IN EEPROM.
     This method is optional unless read_light_calibration or set_light_calibration
     has been called successfully.
     Return a packed long containing the default values. (See `get_light_calibration.)
  ''
  '' `Example: s2.default_light_calibration
  ''
  ''     Restore light calibration defaults.
  }}

  return set_light_calibration(DEFAULT_LIGHT_SCALE, DEFAULT_LIGHT_SCALE, DEFAULT_LIGHT_SCALE)

PUB set_light_calibration(left_scale, center_scale, right_scale) | i

  {{ Set the light calibration values. NEW VALUES ARE NOT SAVED IN EEPROM. These values are
     added to the preliminary result of each call to `light_sensor_log.
     Return a packed long containing the new values.
  ''
  ''     `left_scale, `center_scale, `right_scale (-128 - 127): New values for left, center, and right calibration.
  ''
  '' `Example: s2.set_light_calibration(-5, 25, 0)
  ''
  ''     Set left scale to -5, center scale to 25, and right scale to 0.
  ''
  }}
  
  repeat i from 0 to 2
    Light_scale[i] := left_scale[i] #> -128 <# 127
  return get_light_calibration

PUB get_light_calibration

  {{ Return a packed long containing the current light calibration values:
  ''
  '''  31          24 23          16 15           8 7           0
  ''' +----------------------------------------------------------+    
  ''' ¦       0      ¦  Right Scale ¦ Center Scale ¦  Left Scale ¦
  ''' +----------------------------------------------------------+
  ''
  '' `Example: CenterCal := (s2.get_light_calibration >> 8) & $ff
  ''
  ''     Assign the center calibration value to `CenterCal.
  }}
  
  return Light_Scale[0] | Light_Scale[1] << 8 | Light_Scale[2] << 16  
  
PUB light_sensor(side)

  {{ Return the square root (0 .. 255) of the value of the selected light sensor.
     The square-root-scaled value provides a wider dynamic range over a small numerical range than the
     raw values do.
  ''
  ''     `side (`LEFT, `CENTER, or `RIGHT): The selected light sensor.
  ''
  '' `Example: if (s2.light_sensor(s2#LEFT) > s2.light_sensor(s2#RIGHT))
  ''
  ''     Execute the `if block when the uncalibrated left sensor is brighter than the uncalibrated right one.
  }}

  if ((result := light_sensor_word(side)) == UNDEF)
    return 0
  ^^result

PUB light_sensor_log(side) | wsense, lsense, ssense, mant, char

  {{ Return a log-like function (0 - 255) of the value of the selected light sensor.
     The log-scaled value provides a wider dynamic range over a small numerical range than the
     raw values do and more sensitivity to change at lower light levels than the square-root funciton above.
     The final result has the calibration value for the selected sensor added to it.
  ''
  ''     'side (`LEFT, `CENTER, or `RIGHT): The selected light sensor.
  ''
  '' `Example: if (s2.light_sensor_log(s2#LEFT) > s2.light_sensor_log(s2#RIGHT))
  ''
  ''     Execute the `if block when the calibrated left sensor is brighter than the calibrated right one.
  }}

  if ((wsense := light_sensor_word(side)) == UNDEF)
    return 0
  if ((char := >| wsense - 1) < 0)
    return 0
  lsense := wsense << (31 - char) >> 20
  mant := word[$C000 + (lsense & $7ff) << 1]
  lsense := (((char << 4 | mant >> 12) << 8) / 245) <# 255
  ssense := ^^(((wsense << 15) / 30000) <# $ffff)
  result := ((ssense * (255 - ssense) + lsense * ssense) / 255) + (Light_Scale[lookdownz(side : LEFT, CENTER, RIGHT)] << 24 ~> 24) #> 0 <# 255
     
PUB light_sensor_raw(side)

  {{ Return the raw value (0 .. 4095) of the selected light sensor.
  ''
  ''     `side (`LEFT, `CENTER, or `RIGHT): The selected light sensor.
  ''
  '' `Example: if (s2.light_sensor_raw(s2#CENTER) > s2.light_sensor(s2#RIGHT))
  ''
  ''     Execute the `if block when the uncalibrated center sensor is brighter than the calibrated right one.
  }}

  if ((result := light_sensor_word(side)) == UNDEF)
    return 0
  result >>= 4

PUB light_sensor_word(side)

  {{ Although, the light sensors produce a nominal 12-bit value, there are four more, less-signficant bits used during
  '' low-pass filtering. This routine returns all sixteen bits for the selected sensor.
  ''
  ''     `side (`LEFT, `CENTER, or `RIGHT): The selected light sensor.
  ''
  '' `Example: if (s2.light_sensor_word(s2#LEFT) > s2.light_sensor_word(s2#RIGHT))
  ''
  ''     Execute the `if block when the calibrated left sensor is brighter than the calibrated right one.
  }}

  if (side == LEFT)
    return word[results_addr][ADC_LEFT_LGT]
  elseif (side == CENTER)
    return word[results_addr][ADC_CENTER_LGT]
  elseif (side == RIGHT)
    return word[results_addr][ADC_RIGHT_LGT]
  else
    return UNDEF

''-------[ Low-level result methods... ]-------------------------------------------------

{{ The low-level results methods provide access to all the values used and sensed by the Analog/Button/LED cog.
   They can be used to access data which otherwise have no dedicated convenience routines in this object.
}}

PUB get_results(index)

  {{ General accessor for the Results array: returns the full word value. When applied to ADC results, the word values
     returned include real-time low-pass filtering data in the eight LSBs.
  ''
  ''     `index: The pointer into the Results array. See the "Result array indices" constants for index names.
  ''
  '' `Example: battery_level := s2.get_adc_results(s2#ADC_VBAT)
  ''
  ''     Query the battery voltage and save in `battery_level.
  }}

  return word[results_addr][index]

PUB get_adc_results(index)

  {{ General accessor for ADC Results array: returns upper eight bits of word value.
  ''
  ''     `index: The pointer into the ADC Results array. See the "Result array indices" constants for index names.
  ''
  '' `Example: battery_level := s2.get_adc_results(s2#ADC_VBAT)
  ''
  ''     Query the battery voltage and save in battery_level.
  }}

  return word[results_addr][index] >> 8

''-------[ Button methods... ]-------------------------------------------------

{{ Button methods control and sense the user's interaction with the S2's push button.}}
 
PUB button_mode(led_enable, reset_enable)

  {{ Set the button LED echo and reset modes:
  ''
  ''     `led_enable (`true or `false): If `true, take over the LEDs to echo button press number.
  ''
  ''     `reset_enable (`true or `false): If 'true, record the number of presses in EEPROM (up to 8),
  ''          and reset the Propeller after 1 second of no presses.
  ''
  '' `Example: s2.button_mode(true, false)
  ''
  ''     Set the button mode, enabling the LED indicator, but disabling resets.
  }}

  byte[results_addr][constant((BUTTON_CNT << 1) + 1)] := LED_ENA & (led_enable <> 0) | RST_ENA & (reset_enable <> 0)

PUB button_press

  {{ Return `true if the button is down; `false if the button is up.
  ''
  '' `Example: if(s2.button_press)
  ''
  ''     The `if block is executed when the button is down.
  }}

  return ina[BUTTON] == 0

PUB button_count

  {{ Get the last count of button presses (0 - 8). Then zero the count.
  ''
  '' `Example: button_presses := s2.button_count
  ''
  ''     The varialbe `button_presses is set to the recent button press count, which is then zeroed.
  }}

  if(result := byte[results_addr][constant(BUTTON_CNT << 1)])
    byte[results_addr][constant(BUTTON_CNT << 1)]~

PUB reset_button_count

  {{ Return the reset button count (0- 8). Zero indicates a power-on or PC-initiated reset.
  ''
  '' `Example: reset_button_presses := s2.reset_button_count
  ''
  ''     The variable `reset_button_presses is set to the button press count that caused the reset.
  }}

  return Reset_count       

''-------[ LED methods... ]----------------------------------------------------

{{ LED methods control the red/green user LEDs and the blue "power" LED. Except for its hue,
   the so-called "power" LED is programmable like the other three. It is nominally turned on
   when the `start method is called, but it may subsequently be changed to suit the user's
   purposes.
}}
 
PUB set_leds(left_color, center_color, right_color, power_color)

  {{ Sets all LEDs for which the color argument <> NO_CHANGE (-1).
     See the above constant list for predefined indices and colors. See also
     `set_led (below) for a definition of the argument values.
  ''
  ''     `left_color, `center_color, `right_color, `power_color: The values to which to set the respective LEDs.
  ''
  '' `Example: s2.set_leds(s2#RED, s2#NO_CHANGE, s2#BLINK_GREEN, s2#OFF)
  ''
  ''     Set LEDs (L to R, and power): RED, no change, blinking GREEN, off.
  }}

  if (left_color <> NO_CHANGE)
    set_led(LEFT, left_color)
  if (center_color <> NO_CHANGE)
    set_led(CENTER, center_color)
  if (right_color <> NO_CHANGE)
    set_led(RIGHT, right_color)
  if (power_color <> NO_CHANGE)
    set_led(POWER, power_color)

PUB set_led(index, color) | shift

  {{ Light up selected LED using color value as follows:
  ''

  ''     `index (`LEFT, `CENTER, `RIGHT, or `POWER)
  ''     `color, as follows:
  ''
  ''         Color:  
  '''         +-------------------------------+
  '''         ¦      Red      ¦     Green     ¦
  '''         +-------------------------------+
  '''           7   6   5   4   3   2   1   0
  ''
     Each nybble in `color represents the intensity (0-15) of the
     chosen color. If Red + Green =< 15, the colors are blended.
     If red + green => 15, they're alternated at about 2 Hz.
     An intensity value of 1 is the same as 0. This allows blinking
     a single color, e.g. $1f or $f1.
     The power LED lights blue whenever red > 0.
     See the above constants for predefined indices and colors.
  ''
  '' `Example: s2.set_led(s2#CENTER, s2#YELLOW)
  ''
  ''     Set center LED to yellow.
  }}

  byte[results_addr + (LED_BYTES << 1) + (index & 3)] := color 

''-------[ Sound methods... ]--------------------------------------------------

{{ The S2 sound sequencer and synthesizer is capable of queueing and producing
   biphonic sound in four different voices: square-, triangle-, sawtooth-, and
   sine-waves. Each "note" has two pitches, two voices, and duration information
   encoded within it. Speaker volume is adjustable over a 0 to 100 range.
   There is also a synchronizing capability, so that other robot
   actions can be choreographed to the sounds produced.
}}
 
PUB beep

  {{ Set volume level to 50%, and send a 150ms 1 KHz tone, followed by a 350ms pause.
  ''
  '' `Example: s2.beep
  ''
  ''     Make the speaker beep.
  }}

  set_volume(50)
  set_voices(SIN, SIN)
  play_tone(150, 1000, 0)
  return play_tone(350, 0, 0)

PUB command_tone(cmd_tone)

{{ Send an immediate command to the sound generator:
''
''     'cmd_tone: One of the following:
''
''        `STOP:  Stops sound production immediately, then clears the sound queue.
''        `PAUSE: Pauses sound production after the note currently being played.
''        `PLAY:  Resumes sound production from the queue.
''
'' `Example: s2.command_tone(STOP)
''
''     Cause sounds to cease immediately.
}}

  case cmd_tone
    STOP, PAUSE, PLAY:
      Tone_cmd := cmd_tone
      repeat while Tone_cmd
      if (cmd_tone == STOP)
        Tone_enq_ptr := Tone_deq_ptr        

PUB set_volume(vol)

  {{ Set the speaker volume level for the notes to follow
  ''
  ''     `vol (0 - 100): the selected volume level.
  ''
  '' `Example: s2.set_volume(50)
  ''
  ''     Set volume level to 50%.
  }}

  return _enqueue_tone(constant(VOLU << 13) | ((vol #> 0 <# 100) * $1fff / 100))

PUB set_voices(v1, v2)

  {{ Set the voice for each channel for the notes to follow.
  ''
  ''     `v1, `v2 (SQU, SAW, TRI, SIN): Value for each voice, square-, sawtooth-, triangle-, or sine-wave.
  ''
  '' `Example: s2.set_voices(s2#SIN, s2#TRI)
  ''
  ''     Set voice 1 to sine wave; voice 2 to triangle wave.
  }}

  Tone_voice1 := v1 & 3
  Tone_voice2 := v2 & 3

PUB play_sync(value)

  {{ Insert a SYNC command into the sound queue.
     When the sound processor encounters it during playback, it writes the value
     to the hub variable `Tone_sync, then continues. This method can be used to
     synchronize motion to the sound being played.
  ''
  ''     `value (1 - 255): the value to insert into the queue.
  ''
  '' `Example: s2.play_sync(12)
  ''
  ''     Insert a `SYNC 12 into the sound queue. When encountered during playback,
  ''     the player will set the sync value to 12 (for `get_sync) and continue
  ''     with the next command.
  }}
  
  return _enqueue_tone(constant(SYNC << 13) | value & $ff)

PUB play_pause(value)

  {{ Insert a PAUS command into the sound queue.
     When the sound processor encounters it during playback, it writes the value
  '' to the the hub variable Tone_sync, then pauses.
  ''
  ''     `value (1 - 255): the value to insert into the queue.
  ''
  '' `Example: s2.play_pause(12)
  ''
  ''     Insert a PAUS 12 into the tone queue. When encountered during playback,
  ''     the player will set the sync value to 12 (for `get_sync) and wait for a
  ''     PLAY command to resume.
  }}

    return _enqueue_tone(constant(PAUS << 13) | value & $ff)

PUB get_sync

  {{ Get the current Tone_sync value.
  ''
  '' `Example: current_sync := s2.get_sync
  ''
  ''     Set `current_sync to the latest sync value written from the sound queue
  ''     while playing, then zero the sunc value if it was non-zero.
  }}
  
  if (result := Tone_sync)
    Tone_sync~
      
PUB wait_sync(value)

  {{ Wait for a particular sync value to be echoed from the sound queue during playback to echo
  '' or for the sound queue to become empty.
  ''
  ''     `value (0 - 255): If zero, wait for the queue to empty (i.e. for playback to stop;
  ''          otherwise, wait for the chosen sync value to be echoed.
  ''
  '' `Example: s2.wait_sync(12)
  ''
  ''     Wait until a sync value of 12 is returned from the tone queue.
  ''
     `Note: if `value is non-zero and no such SYNC value exists in the tone queue, this
     method will wait forever.
  }}

  if (Tone_cog)
    if (value)
      repeat until Tone_sync == value
    else
      repeat until Tone_deq_ptr == Tone_enq_ptr

PUB play_tone(time, frq1, frq2)

  {{ Queue a sound for immediate playback with a given duration, mixing up to two frequencies,
     using the current voice and volume settings.
  ''
  ''     `time (1 - 8191): The duration (milliseconds) of the tone(s).
  ''
  ''     `frq1, `frq2 (0 - 10000): The frequency (Hz) of each voice. (Zero == silence.)
  ''
  '' `Example: s2.play_tone(1000, 440, 880)
  ''
  ''     Play an A440 and A880 for 1000 milliseconds.
  }}

  ifnot (time)
    return false
  _enqueue_tone(time & $1fff)
  _enqueue_tone(Tone_voice1 << 14 | frq1 & $3fff)
  return _enqueue_tone(Tone_voice2 << 14 | frq2 & $3fff)

PUB play_tones(addr)

  {{ Add a command sequence to the tone queue.
  ''
  ''     'addr: The hub address of the command sequence to add, ending with a zero word.
  ''
  '' Commands are words in the following format:
  ''
  ''' 15  13 12                      0
  ''' +-------------------------------+
  ''' ¦ Cmd ¦          Data           ¦
  ''' +-------------------------------+
  ''
  '' Cmd: %000
  ''
  ''   Play tone for duration Data (0 - 8192ms),using the following `two words as
  ''   the voices, each having the following format:
  ''
  '''    15 14 13                        0
  '''     +-------------------------------+
  '''     ¦Voc¦         Frequency         ¦
  '''     +-------------------------------+
  ''
  ''      Voc (voice):
  ''
  ''        00 = square wave
  ''        01 = sawtooth wave
  ''        10 = triangle wave
  ''        11 = sine wave
  ''
  ''     Frequency : 0 (no sound) to 16363 Hz.
  ''
  '' Cmd: %001
  ''
  ''   Set volume to Data << 3 (0 - 99.98% of full volume)
  ''
  '' Cmd: %010
  ''
  ''   Set sync to Data & $ff
  ''
  '' Cmd: %011
  ''
  ''   Set sync to Data & $ff, then PAUSE.
  ''
  '' `Example: s2.play_tones(@tone_buffer)
  ''
  ''     Add tones from tone_buffer (word array) to tone queue until a zero word is encountered.
  }}         

  repeat while word[addr]
    result := _enqueue_tone(word[addr])
    addr += 2
   
''-------[ Time methods... ]---------------------------------------------------

{{ Time methods control and sense the S2's built-in millisecond timers and provide
   a convenient delay function.
}}
 
PUB start_timer(number)

  {{ Start a 1 KHz count-up timer number, which counts up from zero
     by one every millisecond.
  ''
  ''     `number (0 - 7): The number ID of the timer to start.
  ''
  '' `Example: s2.start_timer(4)
  ''
  ''     Restarts timer number four from zero.
  }}

  if (number => 0 and number < 8) 
    Timers[number] := long[results_addr + constant(TIMER >> 1)]

PUB get_timer(number)

  {{ Return the time (in milliseconds, up to 2 million seconds ~ 24 days) from the selected 1 KHz count-up timer.
  ''
  ''     `number: If 0 - 7, return the value of the selected timer;
  ''          otherwise, return the value of the master timer, which starts at 0 when the
  ''          Propeller is reset.
  ''
  '' `Example: elapsed_time := s2.get_timer(4)
  ''
  ''     Set `elapsed_time to the number of milliseconds elapsed since the Propeller reset
  ''          or timer #4 restart, whichever occurred last.
  }}

  return long[results_addr + constant(TIMER << 1)] - (Timers[number] & (number => 0 and number < 8))

PUB delay_tenths(time) | time0

  {{ Time delay in tenths of a second.
  ''
  ''     `tenths: Number of tenths of a second to delay before returning.
  ''
  '' `Example: s2.delay_tenths(20)
  ''
  ''     Wait a couple seconds.
  }}

  time0 := cnt
  repeat time
    waitcnt(time0 += clkfreq / 10)

''-------[ EEPROM methods... ]-------------------------------------------------

{{ EEPROM methods allow direct read access to the entire auxiliary EEPROM and direct write access to its user area.
   The user area begins at the address given by the constant `EE_USER_AREA.
}}

 
PUB ee_read_byte(addr)

  {{ Read a byte from the auxiliary EEPROM.
  ''
  ''     `addr (0 - 32767): The byte address from which to read.
  ''
  '' `Example: my_data := s2.ee_read_byte($2000)
  ''
  ''     Set `my_data equal to the byte at location $2000 (8192) in the auxiliary EEPROM.
  }}

  return _ee_rdbyte(addr)

PUB ee_write_byte(addr, data)

  {{ Write a byte to auxiliary EEPROM.
  ''
  ''     `addr (EE_USER_ADDR - 32767): The address to which the data is written. Writes outside this range are ignored.
  ''
  ''     `data (0 - 255): the byte value to write.
  ''
  '' `Example: s2.ee_write_byte(s2#EE_USER_AREA + 5, 35)
  ''
  ''     Write the value 35 to the sixth byte in the auxiliary EEPROM's user area.
  }}

  if (addr => EE_USER_AREA)
    _ee_wrbyte(addr, data)
    return true
  else
    return false

''
''
''=======[ Private Spin methods... ]==============================================
''
'' These private methods are used internally and are not accessible to the user.
''
''-------[ Miscellaneous... ]--------------------------------------------------

PRI _compute_calibration

  {{ Compute other values dependent on Full_circle to save time in methods. }}

  Half_circle := Full_circle >> 1
  Qtr_circle := Full_circle >> 2
  Atan_circle := Full_circle * 56841 / 100000
 
PRI _atan2(y, x) | arg, adder, n

  {{ Four-quadrant arctangent. `y and `x are signed integers.
     `Full_circle is an integer equal to the number of encoder units in a full circle.
  }}

  if ((n := >|(||x <# ||y)) > 21)
    x ~>= n - 21
    y ~>= n - 21 
  if (||x > ||y)                      
    arg := y << 10 / x 
    adder := (Half_circle) & (x < 0)
  else
    arg := -x << 10 / y
    adder := Qtr_circle + Half_circle & (y < 0)
  result := (||arg * Atan_circle / (914 + (arg * arg) >> 12) + 1) >> 2 - (||arg => 960)
  if (arg < 0)
    - result 
  result += adder
  result += Full_circle & (result < 0)     
                                         
PRI _enqueue_tone(tone_word) | next_ptr

  {{ Wait for tone queue to become non-full, then add tone_word to it. }}

  if (Tone_cog)
    next_ptr := Tone_enq_ptr + 1
    next_ptr &= (next_ptr < _TONE_Q_SIZE)
    repeat until Tone_deq_ptr <> next_ptr
    Tone_queue[Tone_enq_ptr] := tone_word
    Tone_enq_ptr := next_ptr
    return Tone_enq_ptr << 16 | Tone_deq_ptr
     
''-------[ I2C Methods... ]----------------------------------------------------

PRI _ee_rdblock(dest_addr, addr, size) | i, csum

  {{ Read a block of data, `size bytes long, into `dest_addr, from EEPROM at `addr.
     Read one additional checksum byte, and return `true if checksum is zero;
     `false, otherwise.
  }}

  csum := _ee_rdbyte(addr + size)
  repeat i from 0 to size - 1
    csum += (byte[dest_addr][i] := _ee_rdbyte(addr + i))
  return csum & $ff == 0

PRI _ee_wrblock(src_addr, addr, size) | i, data, csum

  {{ Write a block of data, `size bytes long, from `src_addr into EEPROM at `addr.
     Write one additional checksum byte at the end.
  }}

  csum~
  result~~
  repeat i from 0 to size - 1
    data := byte[src_addr][i]
    csum -= data
    result &= _ee_wrbyte(addr + i, data)
  result &= _ee_wrbyte(addr + size, csum & $ff)     

PRI _ee_rdbyte(addr)

  {{ Read a byte of data from the EEPROM at `addr. }}

  _i2c_waddr(addr)
  _i2c_start
  _i2c_wr(%1010_001_1)
  result := _i2c_rd(NAK)
  _i2c_stop

PRI _ee_wrbyte(addr, data)

  {{ Write the byte given by `data to the EEPROM at `addr. }}

  _i2c_waddr(addr)
  result := _i2c_wr(data)
  _i2c_stop

PRI _i2c_waddr(addr)

  {{ Work routine for EEPROM. Wait for EEPROM ready, then write a command, followed by the `addr byte. }}

  repeat
    _i2c_start
  until _i2c_wr(%1010_001_0)
  _i2c_wr(addr >> 8)
  _i2c_wr(addr & $ff)

PRI _i2c_rd(acknak)

  {{ Work routine for EEPROM. Read the next byte, and send ACK or NAK, depending on `acknak. }}

  repeat 8
    outa[SCL]~~
    result := result << 1 | ina[SDA]
    outa[SCL]~
  dira[SDA] := acknak <> 0
  outa[SCL]~~
  outa[SCL]~
  dira[SDA]~

PRI _i2c_wr(data)

  {{ Work routine for EEPROM. Write the next byte, given by data, and return `true for ACK, `false for NAK. }}

  repeat 8
    dira[SDA] := (data <<= 1) & $100 == 0
    outa[SCL]~~
    outa[SCL]~
  dira[SDA]~
  outa[SCL]~~
  result := ina[SDA] == 0
  outa[SCL]~

PRI _i2c_start

  {{ Set up an I2C `start condition. }}

  dira[SDA]~
  outa[SCL]~~
  dira[SDA]~~
  outa[SCL]~

PRI _i2c_stop

  {{ Set up an I2C `stop condition. }}

  outa[SCL]~
  dira[SDA]~~
  outa[SCL]~~
  dira[SDA]~

''=======[ Assembly Cogs... ]==================================================
  
DAT


''-------[ Tone Player ]-------------------------------------------------------

{{ This cog accepts commands from the tone queue and synthesizes the sounds indicated
    by each entry.
}}

              org       0
              
tone_seq      mov       ctra,tctra0             'Initialize counter for DUTY mode.
              mov       tacc,queue_addr
              add       tacc,queue_size
              add       tacc,queue_size
              mov       enq_ptr_addr,tacc
              add       tacc,#2
              mov       deq_ptr_addr,tacc
              add       tacc,#2
              mov       cmd_addr,tacc
              add       tacc,#1
              mov       sync_addr,tacc
              mov       ttime,cnt
              add       ttime,dttime

:get_cmd      call      #dequeue                'Get the next word from queue.
              mov       cmd,tacc                'Copy word to command.
              and       tacc,data_bits          'Isolate the 13 data bits.
              shr       cmd,#13 wz              'Isolate command bits. Is command == TONE?
        if_z  jmp       #:tone                  '  Yes: Go make some noise. 

              cmp       cmd,#VOLU wz            'Is command a set volume?
        if_nz jmp       #:try_sync

              shl       tacc,#3                 '  Yes: Normalize the volume value,
              mov       volume,tacc             '         and save it.
              jmp       #:get_cmd               '       Back for anohter command.

:try_sync     cmp       cmd,#SYNC wz            'Is command a sync?            
        if_z  jmp       #:do_sync               '  Yes: go do it.

              cmp       cmd,#PAUS wz            'Is command a pause-and-sync?
        if_nz jmp       #:get_cmd               '  No:  Invalid command; just skip it.

              mov       playing,#0              '  Yes: Stop playing.
:do_sync      wrbyte    tacc,sync_addr          '       Copy the sync value back to hub variable.
              jmp       #:get_cmd               '       Back for another command.              

:tone         mov       duration,tacc           'Multiply duration by 65 to get
              shl       tacc,#6                 '  approx milliseconds (within 1%)
              add       duration,tacc
              shr       duration,#1

              call      #dequeue                'Get the freq1 value.
              mov       freq1,tacc
              shl       freq1,#18 wz            'Isolate the frequency part.
              shr       freq1,#1                'Is it zero?
        if_z  mov       phase1,#0               '  Yes: Zero the phase, too.
              mov       voice1,tacc             'Isolate the voice part.
              shr       voice1,#14              
              call      #dequeue                'Get the freq2 value and process the same.
              mov       freq2,tacc
              shl       freq2,#18 wz
              shr       freq2,#1
        if_z  mov       phase2,#0
              mov       voice2,tacc
              shr       voice2,#14
              or        dira,tdira0

:tone_lp      rdbyte    tacc,cmd_addr           'Tone generation: first check for a STOP.
              cmp       tacc,#STOP wz           'Is it a STOP?
        if_z  jmp       #:get_cmd               '  Yes: Quit, and let dequeue handle it.
        
              add       phase1,freq1            'Tone generation: Increment the phases.
              add       phase2,freq2

              mov       phase,phase1            'Get the first phase and voice.
              mov       voice,voice1
              call      #get_amp                'Compute current amplitude.
              mov       amp,tacc                'Copy amplitude to amp.
              mov       phase,phase2            'Get the second phase and voice.
              mov       voice,voice2            
              call      #get_amp                'Compute the current amplitude.
              add       amp,tacc                'Add to the first amplitude.
              abs       tacc,amp                'Multiply the instantenous abs amplitude by the volume.
              mov       taccx,volume
              call      #fmult
              shl       amp,#1 wc               'Get the original sign of amp in carry.
              mov       amp,amp0                'Zero level is Vdd/2.
              sumc      amp,tacc                'Fix the sign and add to zero level.
              waitcnt   ttime,dttime            'Wait for sample interval.
              mov       frqa,amp                'Output the amplitude to DUTY-mode counter.
              djnz      duration,#:tone_lp      'Count down the duration and repeat.

              jmp       #:get_cmd               'Get the next command.

'-------[ Compute the instantaneous amplitude for one component. ]-------------              
              
get_amp       test      voice,#2 wc             'Test for waveform type.
              test      voice,#1 wz
        if_c  jmp       #:tri_sin               'Jump to appropriate sections based on waveform.
        
        if_nz jmp       #:saw

:squ          shl       phase,#1 wc,nr          'Square wave: Test sign bit of phase.
              negc      tacc,maxamp             'Add or subtract max based on sign
              jmp       get_amp_ret             'Return.
              
:saw          mov       tacc,phase              'Sawtooth wave: Get the phase.
              add       tacc,amp0               'Convert to signed.
              sar       tacc,#1                 'Signed divide by two.
              jmp       get_amp_ret             'Return.

:tri_sin
        if_nz jmp       #:sin

:tri          abs       tacc,phase              'Triangle wave: Get abs value.
              sub       tacc,maxamp               'Convert to pos and neg values.
              jmp       get_amp_ret             'Return.

:sin          shr       phase,#32-13            'Get 13-bit angle.
              test      phase,_0x1000 wz        'Get sine quadrant 3|4 into nz.
              test      phase,_0x0800 wc        'Get sine quadrant 2|4 into c.
              negc      phase,phase             'If sine quadrant 2|4, negate table offset.
              or        phase,_0x7000           'Insert sine table base address >> 1.
              shl       phase,#1                'Shift left to get final word address.
              rdword    tacc,phase              'Read sine word from table.
              negnz     tacc,tacc               'If quadrant 3|4, negate word.
              shl       tacc,#14                'Msb-justify result.
get_amp_ret   ret
              

'-------[ Dequeue next word in sequence. ]-------------------------------------

dequeue       rdbyte    tacc,cmd_addr           'Check for an immediate command first.
              cmp       tacc,#PAUSE wz          'Is it a PAUSE?
        if_nz cmp       tacc,#STOP wz           '  No:  Is it a STOP?
        if_z  mov       playing,#0              '  Yes:   Yes: Clear Playing flag.
        if_z  jmp       #:zapcmd                '              Go clear command.
        
              cmp       tacc,#PLAY wz           '         No:  Is it a PLAY?
        if_z  mov       playing,#1              '                Yes: Set playing flag.
:zapcmd if_z  wrbyte    zero,cmd_addr           '       Clear the command.

              test      playing,playing wz      'Are we playing something?
        if_z  jmp       #:decay                 '  No:  Go decay frqa for shutdown.
        
              rdword    enq_ptr,enq_ptr_addr    '  Yes: Get the queue pointers.
              rdword    deq_ptr,deq_ptr_addr
              cmp       enq_ptr,deq_ptr wz      '       Is the queue empty?
        if_nz jmp       #:get_it                 '         No:  Go get some data.
        
:decay        cmpsub    frqa,#511 wc            'Decay the output while waiting,
        if_nc andn      dira,tdira0             '  until it can be turned off without popping.
              mov       ttime,cnt               'Reinitialize ttime, so it's always current.
              add       ttime,dttime
              jmp       #dequeue                'Go check for a new command or data.

:get_it       shl       deq_ptr,#1
              add       deq_ptr,queue_addr      'Convert deq_ptr to an address.
              rdword    tacc,deq_ptr            'Get the data at the address.
              sub       deq_ptr,queue_addr      'Convert deq_ptr back to an index.
              shr       deq_ptr,#1
              add       deq_ptr,#1              'Bump the pointer by one word.
              cmpsub    deq_ptr,queue_size      'Return pointer to zero if over the end.
              wrword    deq_ptr,deq_ptr_addr    'Write the deq pointer back to hub.
dequeue_ret   ret                               'Return with new data.
       

'-------[ Fixed point multiply. ]----------------------------------------------

'    32 x 16.16 fixed-point unsigned multiply.

'    in:      tacc = 32-bit integer multiplicand
'             taccx = 32-bit fixed-point multiplier
              
'    out:     tacc = 32-bit product

fmult         mov       t0,#0                   'Initialize high long of product.
              mov       t1,#32                  'Need 32 adds and shifts.
              shr       tacc,#1 wc              'Seed the first carry.

:loop   if_c  add       t0,taccx wc             'If multiplier was a one bit, add multiplicand.
              rcr       t0,#1 wc                'Shift carry and 64-bit product right.
              rcr       tacc,#1 wc
              djnz      t1,#:loop               'Back for another bit.

              shr       tacc,#16                'Fractional product is middle 32 bits of the 64.
              shl       t0,#16
              or        tacc,t0
fmult_ret     ret


'-------[ Constants and hub-assigned parameters ]------------------------------

dttime        long      0-0
queue_addr    long      0-0
tctra0        long      %00110 << 26 | SPEAKER
tdira0        long      1 << SPEAKER
zero          long      0
amp0          long      $8000_0000
maxamp        long      $3fff_ffff
data_bits     long      $1fff
_0x1000       long      $1000
_0x0800       long      $0800
_0x7000       long      $7000
volume        long      $8000
playing       long      0
queue_size    long      _TONE_Q_SIZE

'-------[ Variables ]----------------------------------------------------------

  enq_ptr_addr  res       1
  deq_ptr_addr  res       1
  cmd_addr      res       1
  sync_addr     res       1
  enq_ptr       res       1
  deq_ptr       res       1
  phase1        res       1
  phase2        res       1
  phase         res       1
  freq1         res       1
  freq2         res       1
  voice1        res       1
  voice2        res       1
  voice         res       1
  duration      res       1
  ttime         res       1
  amp           res       1
  cmd           res       1
  tacc          res       1
  taccx         res       1
  t0            res       1
  t1            res       1
   
              fit

''-------[ Analog, Button, LED ]-----------------------------------------------

{{ This cog performs the analog sampling, filtering, and conversions from signals
   fed to the analog MUX. It also polls the pushbutton input and manages its interaction
   with the reset settings. Finally, it operates the LED shift register and manages
   the generation of hue, brightness, blinking, etc.
}}                          

              org       0
adc_all       mov       ctra,ctra0              'Initialize counter for ADC.
              mov       dira,dira0              'Set mux pins and feedback to outputs.
              mov       frqa,#1

'-------[ Calibrate ADC for 3.3V and 5V full-scale. ]--------------------------

              movd      :got_it,#intvl3         'Initialize pointers for VDD calibration.
              movd      :got_it+1,#loresult3
              movs      :set_mux,#_MUX_VDD
              mov       count,#2
              mov       soak_time,one_ms

:calibrate    mov       intvl,intvl0            'Initialize sample interval to high value.
              mov       dintvl,intvl0           'Set delta interval to half that (binary search).
              shr       dintvl,#1

:searchlp     mov       mux_addr,#_MUX_VSS       'Set mux to input Vss.
              call      #adc                    'Read the value.
              mov       loresult,acc            'Save it.
:set_mux      mov       mux_addr,#0-0           'Set mux to read voltage input.
              call      #adc                    'Read the value.
              sub       acc,loresult            'Subtract the zero result.
              cmps      acc,#255 wc,wz          'Does net result equal 255?
         if_z jmp       #:got_it                '  Yes: Perfect. We're done.  
        
              sumnc     intvl,dintvl            '  No:  Adjust interval accordingly.
              shr       dintvl,#1 wz            '       Cut delta in half. Equal to zero?
        if_nz jmp       #:searchlp              '         No:  Do another search iteration.

:got_it       mov       0-0,intvl               'Found 255 or delta == 0. Save calibration.
              mov       0-0,loresult
              movd      :got_it,#intvl5         'Now set up to calibrate for 5V full-scale.
              movd      :got_it+1,#loresult5
              movs      :set_mux,#_MUX_5V
              djnz      count,#:calibrate       'Go back and do 5V if not done.

'-------[ Main program loop: cycle through and record all ADC inputs. ]--------

              mov       loop_timer,cnt          'Initialize the loop timer.
              add       loop_timer,one_ms       'Executes onece per millisecond.

main_lp       waitcnt   loop_timer,one_ms       'Wait for next 1ms interval.
              mov       results_ptr,results_addr'Update timer.
              
              add       results_ptr,#TIMER*2
              rdlong    acc,results_ptr
              add       acc,#1
              wrlong    acc,results_ptr

              mov       seq_ptr,seq_addr        'Set sequence pointer to sequence beginning.
              add       loop_ctr,#1             'Increment the loop counter.

:sample_lp    rdword    acc,seq_ptr wz          'Read next command from sequence.
        if_z  jmp       #:do_button             'End of sequence if zero. Go do other stuff.

              add       seq_ptr,#2              'Bump sequence pointer to next word.
              
              mov       mux_addr,acc            'Unpack the MUX address for this sample.
              shr       mux_addr,#12

              mov       results_ptr,acc         'Unpack the Results index.
              shr       results_ptr,#7
              and       results_ptr,#$1e
              add       results_ptr,results_addr

              mov       count,acc               'Unpack and compute soak time.
              shr       count,#4
              and       count,#$0f
              mov       soak_time,#80
              shl       soak_time,count

              mov       filter,acc              'Unpack and compute filter value.
              shr       filter,#1
              and       filter,#$07

              call      #do_adc                 'Sample the input and do ADC.
              cmp       mux_addr,#_MUX_IDLER wz 'Is this the idler wheel?
        if_nz jmp       #:not_idler             '  No:  Skip next section.

              mov       accx,acc                '  Yes: Save the unilluminated value.
              or        outa,idler_on           '       Turn on the IRED
              andn      acc,#1                  '       Make sure to reference to 3.3V again.
              call      #do_adc                 '       Get the value with IRED on.
              andn      outa,idler_on           '       Turn off IRED.
              sub       acc,accx                '       Subtract unilluminated value.
              mins      acc,#0                  '       Make sure result is not negative.
              
:not_idler    rdword    count,results_ptr       'Get the current value of the result.
              mov       accx,count              'Transfer to temp accx.
              shr       accx,filter             'Shift it right by filter amount.
              sub       count,accx              'Subtract shifted value form current value.
              shl       acc,#8                  'Get new value into upper byte.
              shr       acc,filter              'Shift it right by filter amount.
              add       count,acc               'Add to create new value.
              wrword    count,results_ptr       'Save new value back to array.
        if_nz jmp       #:sample_lp             'Processing the idler wheel?

              shr       count,#8                '  Yes: Make idler value byte-sized.
              test      idler_state,#1 wz       '       Is current idler state high?
        if_nz mov       acc,#10                 '         Yes: Use lower threshold.
        if_z  mov       acc,#15                 '         No:  Use upper threshold.
              cmp       count,acc wc            '       Set carry if value is lower than threshold.
              muxnc     idler_state,#1          '       Set current idler state based on comparison.
    if_z_eq_c jmp       #:sample_lp             '       Done unless was low and went high or was high and went low.

              mov       results_ptr,results_addr'       Point to idler count result.
              add       results_ptr,#CNT_IDLER*2 
              rdword    count,results_ptr       '       Read the current count.
              add       count,#1                '       Bump it.
              wrword    count,results_ptr       '       Write it back.
              jmp       #:sample_lp             '       Done with idler.

:do_button    mov       results_ptr,results_addr'Point to button flags.
              add       results_ptr,#BUTTON_CNT*2+1
              rdbyte    btn_flgs,results_ptr    'Get them.
              test      btn_mask,ina wc         'Get state of button input into carry.
        if_nc mov       btn_timer,one_second    'Reset timer if button is down.
              rcl       btn_shift,#1 wz         'Shift into debounce register. Z set if down => 32ms.
              test      btn_cnt,#1 wc           'Was debounced button down last time.
        if_c  add       btn_shift,#1 wz,nr      '  Yes: Z set if up => 32ms. 
        if_z  add       btn_cnt,#1              'Increment count if debounced change of state.
              mov       accx,btn_cnt            'Get actual button count in acc,
              shr       accx,#1 wz              '  stripped of flag bits.
              max       accx,#8                 'Saturate button count to 8.
              cmpsub    btn_timer,#1 wc         'Decrement end-of-cluster timer. Was zero?
   if_z_or_c  jmp       #:do_leds               '  No:  Jump around.

              sub       results_ptr,#1          '  Yes: Point to button count in Results array.
              wrbyte    accx,results_ptr        '       Write the value.
              mov       btn_cnt,#0              '       Clear count.
              test      btn_flgs,#RST_ENA wc    'Is reset-on-button enabled?
        if_nc jmp       #:do_leds               '  No:  Skip to the LED stuff.

              cogid     acc                     'Who am I? (Need to stop every cog but me.)
              mov       count,#7                'Eight cogs to go.
              
:stop_cogs    cmp       acc,count wz            'Is this me?
        if_nz cogstop   count                   '  No:  Stop the cog.
              sub       count,#1 wc
        if_nc jmp       #:stop_cogs             

              mov       ee_addr,#EE_RESET_CNT   'Save button count to aux EEPROM.
              call      #i2c_waddr              'Send the address.
              mov       acc,accx                'Get the data.
              call      #i2c_wr                 'Send that, too.
              call      #i2c_stop               'Stop the transfer and finish the write.
              mov       dintvl,#0               'Turn off all the LEDs.
              call      #show_leds
              clkset    reeboot                 'Reset the Prop.
                            
:do_leds      test      btn_flgs,#LED_ENA wc    'Are LEDs enabled for tracking button presses?
   if_z_or_nc jmp       #:reg_led               'If not, or if button count is zero, skip around.

              mov       acc,led_seq             'Get the LED shift sequence in accx.
              shr       acc,accx                'Shift right by button count, times two.
              shr       acc,accx
              mov       dintvl,#0               'Initialize the LED shift register to zero.
              mov       count,#6                'Three LEDs x 2 pins per LED.
              mov       intvl,#$10              'Start with left-hand LED.

:led_seq_lp   shr       acc,#1 wc               'Get the next bit.
              muxc      dintvl,intvl            'Insert it into the shift register.
              test      intvl,#$20 wc           'Rolling over from Left = $20 to Center = %01
              and       intvl,#$1f
              rcl       intvl,#1
              djnz      count,#:led_seq_lp      'Back for next bit.         
   
              test      loop_ctr,#$40 wc        'Want power LED to flash if reset is enabled.
              test      btn_flgs,#RST_ENA wz    'Is it enabled?
        if_nz muxc      dintvl,#$80             '  Yes: Insert bit for pwoer LED.
              jmp       #:show_leds             'It's showtime! 
              
:reg_led      mov       results_ptr,results_addr'Point to LED bytes in Results array.
              add       results_ptr,#LED_BYTES*2
              mov       count,#4                'Four LEDs to do.
              mov       intvl,loop_ctr          'Last four bits of loop_ctr for PWM.
              and       intvl,#$0f
              add       intvl,#1

:led_lp       rdbyte    acc,results_ptr         'Get the LED byte.
              add       results_ptr,#1          'Increment pointer.
              mov       accx,acc                'Red is accx.
              shr       accx,#4
              and       acc,#$0f                'Green is acc.
              mov       soak_time,acc           'Get the total PWM time.
              add       soak_time,accx
              cmp       soak_time,#16 wc        'Is total greater than 15?
        if_nc test      loop_ctr,#$100 wz       '  Yes: Alternate color is red? Or green?
  if_nc_and_z mov       acc,#0                  '         Red:   Zero out green.
 if_nc_and_nz mov       accx,#0                 '         Green: Zero out red.

              cmp       acc,#1 wz               'Map 1->0 so flashing works without stray color.
        if_z  mov       acc,#0
              cmp       accx,#1 wz
        if_z  mov       accx,#0
               
              mov       soak_time,acc           'Compute total PWM time again.
              add       soak_time,accx

              shl       dintvl,#2               'Shift %00 into register slot for this color.
              cmp       soak_time,intvl wc      'Is total PWM for this LED => PWM interval?
        if_c  jmp       #:next_led              '  No:  LED is off for this time slot.

              cmp       acc,intvl wc            '  Yes: Is green PWM for this LED => PWM interval?
        if_nc or        dintvl,#%01             '         Yes: Set green color.         
        if_c  or        dintvl,#%10             '         No:  Set red color.

:next_led     djnz      count,#:led_lp          'Go back for next LED.

:show_leds    call      #show_leds
              jmp       #main_lp

'-------[ Clock out the LED data in dintvl. ]----------------------------------

show_leds     mov       count,#8                'Eight bits to shift.
           
:send_lp      shr       dintvl,#1 wc            'Get next bit in carry.
              muxc      outa,#1<<LED_DATA       'Put it on data line.
              or        outa,#1<<LED_CLK        'Pulse the clock.
              andn      outa,#1<<LED_CLK
              djnz      count,#:send_lp         'Back for next bit.

              andn      outa,#1<<LED_DATA       'Force data low to avoid power light on reset.
show_leds_ret ret              

'-------[ Complete ADC routine: applies calibration data. ]--------------------

do_adc        test      acc,#1 wc               'Test it: is it a one?
        if_nc mov       loresult,loresult3      '  No:  Set up for 3.3V full-scale.
        if_nc mov       intvl,intvl3
        if_c  mov       loresult,loresult5      '  Yes: Set up for 5V full-scale.
        if_c  mov       intvl,intvl5
              test      $,#1 wc                 'Set carry to enable post-processing.
              jmp       #_adc                   'Go do the work.

'-------[ Basic ADC routine. ]-------------------------------------------------

adc           test      $,#0 wc                 'Clear carry to skip post processing.

_adc          shl       mux_addr,#MUX0          'Steer mux address to proper bit position.
              mov       acc,outa                'Read the output buffer.
              andn      acc,mux_mask            'Zap the old mux address.
              or        acc,mux_addr            'Insert the new one.
              mov       outa,acc                'Write it to the mux pins.
              shr       mux_addr,#MUX0          'Restore the mux address.
              mov       adc_timer,cnt           'Read the count register.
              add       adc_timer,soak_time     'Bump it a little for the wait.
              waitcnt   adc_timer,intvl         'Synchronize the read of phsa to waitcnt.
              neg       acc,phsa                'Read phsa and negate it into acc.
              waitcnt   adc_timer,#0            'Wait for the calibrated time interval.
              add       acc,phsa                'Add the new result to get a delta value.
                                                'Post-processing?        
        if_c  sub       acc,loresult            '  Yes: Subtract the zero reference.            
        if_c  mins      acc,#0                  '       Make sure result is between 0
        if_c  maxs      acc,#255                '         and 255.
adc_ret
do_adc_ret    ret                               'Return to caller.

'-----------[ i2c routines ]--------------------------------------------------

'i2c_waddr: Write address in ee_addr to aux eeprom.

i2c_waddr     call      #i2c_start              'Do start condition.
              mov       acc,#%1010_001_0        'Get write address command in acc.
              call      #i2c_wr                 'Send it.
        if_c  jmp       #i2c_waddr              'Restart if not acknowledged (may be busy writing a page).
        
              mov       acc,ee_addr             'Get high byte of address.
              shr       acc,#8
              call      #i2c_wr                 'Send it.
              mov       acc,ee_addr             'Get low byte of address.
              call      #i2c_wr                 'Send it.
i2c_waddr_ret ret                               'Over and out.

'i2c_rd_nak: Read a byte from eeprom and send NAK.

i2c_rd_nak    test      $,#1 wc                 'Set carry flag (odd parity) for NAK.
              jmp       #i2c_rd

'i2c_rd_ack: Read a byte from eeprom and send ACK.

i2c_rd_ack    test      $,#0 wc                 'Clear carry flag (even parity) for ACK.

'i2c_rd: Read a byte from eeprom and send ACK/NAK based on carry.

i2c_rd        mov       acc,#$ff                'Make sure no zeroes get written.
              jmp       #i2c_rd_wr

'i2c_wr: Write a byte to eeprom, returning ACK in carry.

i2c_wr        test      $,#1 wc                 'Set carry flag (odd parity) to read ACK.

'i2c_byte: Combo read and write byte routine.

i2c_rd_wr     mov       count,#9                'Nine bits, including ACK.
              rcl       acc,#24                 'Get byte into 8 MSBs, and ACK/NAK into next bit.

:wrlp         rcl       acc,#1 wc               'Rotate carry into acc and next write bit out.
              muxnc     dira,sda_pin            'Pull sda low iff carry is clear.
              call      #delay650               'Wait 650ns.
              or        outa,scl_pin            'Drive SCL high.
              call      #delay650               'Wait 650ns.
              test      sda_pin,ina wc          'Get sda pin state into carry (parity). (Last time is ACK/NAK.)
              andn      outa,scl_pin            'Drive SCL low.
              call      #delay650               'Wait 650ns.
              djnz      count,#:wrlp            'Back for next bit.

              and       acc,#$ff                'Acc has data read from i2c; carry has ACK/NAK.
i2c_rd_ack_ret
i2c_rd_nak_ret
i2c_rd_ret
i2c_wr_ret    ret

'i2c_start: Set a start condition.
            
i2c_start     andn      dira,sda_pin            'Let sda float high.
              call      #delay650               'Wait 650ns.
              or        outa,scl_pin            'Drive SCL high.
              or        dira,scl_pin
              call      #delay650               'Wait 650ns.
              or        dira,sda_pin            'Pull sda low.
              call      #delay650               'Wait 650ns.
              andn      outa,scl_pin            'Drive SCL low.
              call      #delay650               'Wait 650ns.
i2c_start_ret ret

'i2c_stop: Set a stop condition.

i2c_stop      andn      outa,scl_pin            'Pull SCL low.
              call      #delay650               'Wait 650ns.
              or        dira,sda_pin            'Pull sda low.
              call      #delay650               'Wait 650ns.
              or        outa,scl_pin            'Drive SCL high.
              call      #delay650               'Wait 650ns.
              andn      dira,sda_pin            'Let sda float high.
              call      #delay650               'Wait 650ns.
              andn      dira,scl_pin            'Let SCL float.
i2c_stop_ret  ret

'-------[ Delay routines. ]-----------------------------------------------------

'delay650: Wait 650 ns.

delay650      mov       adc_timer,#52
              add       adc_timer,cnt
              waitcnt   adc_timer,#0
delay650_ret  ret

'-------[ Assembly constants and predefined variables. ]-----------------------

ctra0         long      %01001 << 26 | _MUX_ADC_OUT << 9 | _MUX_ADC_IN
dira0         long      1 << _MUX_ADC_OUT | %1111 << MUX0 | 1 << IDLER_TX | 1 << LED_DATA | 1 << LED_CLK
idler_on      long      1 << IDLER_TX           'Mask for idler IRED.
mux_mask      long      %1111 << MUX0           'Mask for multiplexer address bits.
scl_pin       long      1 << SCL
sda_pin       long      1 << SDA
intvl0        long      2048                    'Initial calibration interval.
one_ms        long      80_000                  'Clock ticks for 1 ms at 80 MHz.
one_second    long      1_000                   'Ticks for one second at 1 KHz.
reeboot       long      $80                     'Used with clkset to reset the Prop chip.
btn_mask      long      1 << BUTTON             'Input mask for push button.
btn_cnt       long      0                       'Number of debounced button transitions.
btn_shift     long      $ffff_ffff              'Shift register for debouncing.
btn_timer     long      0                       'Countdown timer for last button press.
idler_state   long      0                       'Current state of idler wheel.
results_addr  long      0-0                     'Points to beginning of Results array.
seq_addr      long      0-0                     'Points to beginning of ADC sequence array.
led_seq       long      %101010_010101_0000_00  'LED sequence for button presses R->L.

'-------[ Assembly variables. ]------------------------------------------------

mux_addr      res       1                       'Mux address: 0..15
seq_ptr       res       1                       'Points to current ADC command.                      
results_ptr   res       1                       'Points into Results array.
soak_time     res       1                       'Current soak time.
filter        res       1                       'Current filter value.
loop_timer    res       1                       'Next cnt value for loop interval.
adc_timer     res       1                       'Timer for analog acquisition.
loresult      res       1                       'Zero reference (offset) for ADC.
intvl         res       1                       'Time interval for ADC.
dintvl        res       1                       'Delta interval fro calibration.
loresult3     res       1                       'Offset for 3.3V full-scale.
intvl3        res       1                       'Time interval for 3.3V full-scale.
loresult5     res       1                       'Offset for 5V full-scale.
intvl5        res       1                       'Time interval for 5V full-scale.
acc           res       1                       'General-purpose accumulator.
accx          res       1                       'Another general-purpose register.
count         res       1                       'General-purpose counter.
loop_ctr      res       1                       'Loop counter.
btn_flgs      res       1                       'Flags that control button behavior.
ee_addr       res       1

              fit

DAT

''-------[ Motors ]------------------------------------------------------------

{{ This cog accepts commands for the motors and handles ramping, PWMing, timing,
   and coordination with the encoders.
}}
              org       0
motor_driver  mov       dira,mdira0             'Set dir and pwm pins to output.
              mov       frqa,#1                 'Initialize PWM counter frequencies.
              mov       frqb,#1
              mov       mpar_addr,par           'Get the displacement parameter address.
              add       mpar_addr,#4
              mov       mstat_addr,par          'Get the status address.
              add       mstat_addr,#8
              mov       mtime,cnt               'Initialize timer.
              add       mtime,mdt
              test      right_enc_bit,ina wc    'Get right encoder input.
              rcl       right_enc,#1            'Shift it into register.
              test      left_enc_bit,ina wc     'Same for left encoder.
              rcl       left_enc,#1
              mov       nominal_pwm,#0          'Zero the current PWM value.
              call      #clr_stat
              wrlong    mzero,par               'Tell caller we're ready for a new command.
              
:main_lp      rdlong    mcmd,par wz             'Is there a command waiting?
       if_nz  jmp       #:do_cmd                '  Yes: Go do it.

:stop         mov       ctra,#0                 '  No:  Force stop. Turn off PWMs.
              mov       ctrb,#0
              call      #clr_stat               '       Clear the velocity and idler status.

:chk_cmd      rdlong    mcmd,par wz             'Get the next command. Is it non-zero?
        if_z  jmp       #:chk_cmd               '  No:  Try again.

:do_cmd       mov       motor_timer,mcmd        'Get and isolate the timeout value.
              shr       motor_timer,#16 wz      'Is it non-zero?
        if_nz muxnz     mcmd,#MOT_TIMED         'Set timeout flag according to motor_timer <> 0
              mov       max_vel,mcmd            'Isolate the maximum velocity parameter.
              shr       max_vel,#8
              and       max_vel,#$0f
              mov       end_vel,mcmd            'Isolate the end velocity parameter.
              shr       end_vel,#4
              and       end_vel,#$0f
              min       end_vel,#8              'Ramp down speed is 8 min.
              and       mcmd,#$0f               'Isolate the command bits.

              rdlong    right_dist,mpar_addr wz 'Get the right and left distances.
              wrlong    mzero,par               'Got everything, so signal caller.
        if_z  jmp       #:stop                  'If both are zero, nothing to do, so stop.
        
              mov       maccx,outa              'Get current motor directions in maccx.
              mov       left_dist,right_dist    'Left distance is upper 16 bits, signed.
              sar       left_dist,#16
              shl       right_dist,#16          'Right distance is lower 16 bits, signed.
              sar       right_dist,#16
              abs       right_dist,right_dist wc'Get abs distance.
        if_nc xor       maccx,right_dir_bit     'Toggle maccx dir bit if direction is positive.
              shl       right_dist,#1           'Double it.
              min       right_dist,#1           'Have to move at least one encoder pulse.
              muxnc     outa,right_dir_bit      'Set the direction according to former sign.
              abs       left_dist,left_dist wc  'Same for left side.
        if_nc xor       maccx,left_dir_bit
              shl       left_dist,#1
              min       left_dist,#1
              muxnc     outa,left_dir_bit
              test      maccx,both_dir_bits wz  'Did either direction change from last time?
        if_nz call      #rst_vel                '  Yes: Reset the current velocity status.
              mov       max_dist,left_dist      'Compute the maximum of the two distances.
              min       max_dist,right_dist
              mov       ramp_count,#0           'Zero the ramp counter.
              mov       macc,left_dist          'Get ready to multiply distances.
              mov       maccx,right_dist
              call      #umult                  'Now multiply distances together.
              mov       right_count,macc        'And save in left and right count-down counters.
              mov       left_count,macc
              cmp       left_dist,right_dist wc 'Is left distance less than right distance?
        if_c  mov       right_dom,#1            '  Yes: Right wheel is dominant.
        if_c  mov       left_dom,#0
        if_nc mov       left_dom,#1             '  No:  Left wheel is dominant.
        if_nc mov       right_dom,#0
              mov       phsa,#0                 'Kill the PWM.
              mov       phsb,#0
              mov       ctra,mctra0             'Initialize counters.
              mov       ctrb,mctrb0
              mov       mtime,cnt               'Initialize timer.
              add       mtime,mdt
              mov       mdtimeout,mdto          'Initialize timeout interval timer.
              mov       mot_stat,#MOT_RUNNING   'Tell hub we're moving.
              call      #put_stat
              rdword    idler_cnt,midler_addr   'Reinitialize idler count.

:motor_lp     tjnz      stat_ctr,#:chk_spd          
              
              mov       left_vel,#0
              mov       right_vel,#0
              mov       stat_ctr,#5         

:chk_spd      tjnz      motor_ctr,#:go

              mov       motor_ctr,#400          'Beginning of speed epoch. Set epoch length.
              mov       vel_ctr,#0              'Initialize velocity counter.

:go           rdlong    macc,par                'Peek at command word.
              test      macc,#MOT_IMM wz        'Is there an immediate command there?
        if_nz jmp       #:chk_cmd               '  Yes: Drop everything and go do it.

              mov       targ_vel,#15            'Initialize target velocity to max.
              test      mcmd,#MOT_TIMED wz      'Are we timing this stroke?
        if_z  jmp       #:timeout_ok            '  No:  Skip timing part.

              djnz      mdtimeout,#:timeout_ok  '  Yes: Count the LSBs down first. Zero?

              mov       mdtimeout,mdto          '         Yes: Reinitialize LSBs.
              sub       motor_timer,#1 wz       '              Decrement main timeout timer. Zero?
        if_z  jmp       #:main_lp               '                Yes: Done, so get another command.              

              mov       macc,motor_timer        '                No:  Need to ramp down if nearing end.
              shr       macc,#4
              max       targ_vel,macc
        
:timeout_ok   test      mcmd,#MOT_CONT wz       'Running continuously?
        if_z  jmp       #:ramp_down             '  No:  Skip continuous adjustment.

              cmp       right_count,top_dist wc,wz'Yes: Can right and left counts be augmented?
   if_z_or_c  cmp       left_count,top_dist wc,wz
   if_z_or_c  add       right_count,top_dist    '         Yes: Augment both the same.
   if_z_or_c  add       left_count,top_dist     
              jmp       #:ramp_up               '       Skip the ramp down. 

:ramp_down    mov       macc,max_dist           '  No:  Compute distance from end of stroke.
              sub       macc,ramp_count
              shr       macc,#3                 '       Divide by eight.
              min       macc,end_vel            '       But no less than end velocity.
              max       targ_vel,macc           '       This is ramp-down velocity.
              
:ramp_up      mov       macc,ramp_count         'Get distance from beginning of stroke.
              shr       macc,#2                 'Divide by two.
              add       cur_vel,#1
              min       macc,cur_vel            'But no less than current velocity.
              sub       cur_vel,#1
              max       targ_vel,macc           'This is ramp-up velocity. Use the smaller of the two ramp values.
              
              max       targ_vel,max_vel        'But no bigger than max velocity,
              min       targ_vel,#2             '  and no less than two.

:cont_ok      test      right_enc_bit,ina wc    'Get right encoder input.
              rcl       right_enc,#1            'Shift it into register.
              test      right_enc,#%11 wc       'Test last two bits.
        if_c  add       right_vel,#1            'If different, increment right wheel velocity.
        if_c  cmpsub    right_count,left_dist wz'If different, subtract left distance from counter if any counts left.
        if_c  add       vel_ctr,right_dom       'If different and if this wheel dominates, increment velocity counter.
        if_c  add       ramp_count,right_dom    'Also increment ramp_counter if this wheel dominates. 
  if_c_and_z  mov       ctra,#0                 'If counter is zero, done with this motor. Kill output.
              test      left_enc_bit,ina wc     'Same for left encoder.
              rcl       left_enc,#1
              test      left_enc,#%11 wc
        if_c  add       left_vel,#1
        if_c  cmpsub    left_count,right_dist wz
        if_c  add       vel_ctr,left_dom
        if_c  add       ramp_count,left_dom
  if_c_and_z  mov       ctrb,#0
              max       ramp_count,max_dist     'Make sure ramp_count doesn't overflow.

              mov       right_pwm,nominal_pwm   'Initialize both PWMs to nominal value,
              mov       left_pwm,nominal_pwm    '  ahead of pulse-deletion.
              
              cmp       right_count,left_count wz,wc'Is either encoder ahead of the other?
        if_z  jmp       #:coord_ok              '      No:  Jump around. No pulse deletions this time. 

        if_nc jmp       #:lahead                '      Yes: Jump if left side is ahead.                 

:rahead       mov       macc,left_count         'Right side is ahead. More than one pulse?
              sub       macc,right_dist
              cmp       right_dist,left_dist wz,wc'Dominant?
 if_nc_and_nz cmp       right_count,macc wc     '    Yes: Must be two pulses ahead to delete PWM.
   if_c_or_z  mov       right_pwm,#0            'Drop PWM pulse if too far ahead.
              jmp       #:coord_ok              'Done here.

:lahead       mov       macc,right_count        'Left side is dominant. Same logic as right side's.
              sub       macc,left_dist
              cmp       left_dist,right_dist wz,wc
 if_nc_and_nz cmp       left_count,macc wc
   if_c_or_z  mov       left_pwm,#0
        
:coord_ok     call      #put_debug              'Send debug data to hub.
              or        right_count,left_count nr,wz'Are both counters now zero?
        if_z  jmp       #:main_lp               '      Yes: Target reached; we're done. (Already stopped individually.)
        
              waitcnt   mtime,mdt               'Wait for next PWM period to start.
              neg       phsa,right_pwm          'Put PWM widths into each counter.
              neg       phsb,left_pwm
              djnz      motor_ctr,#:motor_lp    'End of this velocity epoch? Loop back if not.

              mov       cur_vel,vel_ctr         'Current velocity is velocity counter at end of epoch.
              cmp       cur_vel,targ_vel wc,wz  'How does it compare to target velocity?
              mov       macc,cur_vel
              shl       macc,#4
              min       macc,#256
        if_nz sumnc     nominal_pwm,macc        'Correct PWM to get closer to target velocity.
              mins      nominal_pwm,#0
              maxs      nominal_pwm,mdt
              djnz      stat_ctr,#:motor_lp     'Back for more unless stat inteval is over.

              rdword    maccx,midler_addr       'Get the current idler count.
              sub       maccx,idler_cnt wz      'Subtract the previous count. Any change?
        if_nz mov       idler_timer,#0          '  Yes: Reset the idler timer.
        if_z  add       idler_timer,#1          '  No:  Increment the idler timer,
        if_z  max       idler_timer,#255        '         but not past 255.         
              add       idler_cnt,maccx         'Make idler_cnt equal current count.
              max       maccx,#3                'Saturate instantaneous count to 3.
              add       idler_vel,maccx         'Add to idler velocity.
              shr       maccx,#1 wc             'Shift two bits into idler_reg.
              rcr       idler_reg,#1 wc
        if_c  sub       idler_vel,#1            'Subtract the value that comes out the other end.
              shr       maccx,#1 wc
              rcr       idler_reg,#1 wc
        if_c  sub       idler_vel,#2
              mov       mot_stat,#MOT_RUNNING   'Indicate that we're still running.
              call      #put_stat               'Write status info to hub.
              jmp       #:motor_lp              'Back for another 1/10 second.

'-------[ Clear status info to hub. ]------------------------------------------

clr_stat      call      #rst_vel
              mov       mot_stat,#MOT_STOPPED

'-------[ Write status info to hub. ]------------------------------------------

put_stat      test      outa,left_dir_bit wc    'Create status long. Get sign of left velocity.
              max       left_vel,#127           'Saturate left velocity magnitude to 127. 
              negnc     maccx,left_vel          'Move signed velocity into maccx.
              shl       maccx,#24               'Move it into position.
              or        mot_stat,maccx          'OR it into status long.
              test      outa,right_dir_bit wc   'Do the same for right wheel.
              max       right_vel,#127
              negnc     maccx,right_vel
              shl       maccx,#24               
              shr       maccx,#8
              or        mot_stat,maccx
              mov       maccx,idler_timer       'Get the idler timer into position.
              shl       maccx,#8
              or        mot_stat,maccx          'OR it into the status long.                
              mov       maccx,idler_vel         'Get the idler velocity into position.
              shl       maccx,#2
              or        mot_stat,maccx          'OR it into the status long.
              wrlong    mot_stat,mstat_addr     'Write the status to the hub.
put_stat_ret
clr_stat_ret  ret

'-------[ Write debug info to hub. ]-------------------------------------------

put_debug     mov       maccx,mstat_addr
              add       maccx,#4
              mov       macc,max_vel
              shl       macc,#8
              or        macc,end_vel
              shl       macc,#8
              or        macc,cur_vel
              shl       macc,#8
              or        macc,targ_vel
              wrlong    macc,maccx
              add       maccx,#4
              mov       macc,left_dist
              shl       macc,#16
              or        macc,right_dist
              wrlong    macc,maccx
              add       maccx,#4
              mov       macc,right_count
              wrlong    macc,maccx
              add       maccx,#4
              mov       macc,left_count
              wrlong    macc,maccx
              add       maccx,#4
              mov       macc,ramp_count
              shl       macc,#16
              or        macc,max_dist
              wrlong    macc,maccx
put_debug_ret ret

'-------[ Reset the idler wheel status ]---------------------------------------

rst_vel       neg       idler_reg,#1            'Reinitialize idler shift register to all ones. 
              mov       idler_vel,#48           'Reinitialize idler speed to 16 * 3
              mov       idler_timer,#0          'Clear the time since last idler pulse.
              mov       left_vel,#0
              mov       right_vel,#0
              mov       cur_vel,#0
              mov       stat_ctr,#0
              mov       motor_ctr,#0
rst_vel_ret   ret

'-------[ Unsigned 16 x 16 = 32 Multiply ]-------------------------------------

' maccx[31..0] = maccx[15..0] x macc[15..0]

umult         shl       maccx,#16               'Get multiplicand into acc[31..16].
              mov       mcnt,#16                'Ready for 16 multiplier bits.
              shr       macc,#1 wc              'Get initial multiplier bit into C.
:loop   if_c  add       macc,maccx wc           'If C set, add multiplicand into product.
              rcr       macc,#1 wc              'Get next multiplier bit into C, shift product.
              djnz      mcnt,#:loop             'Loop until done.
umult_ret     ret                               'Return with product in acc[31..0].

'-------[ Constants and Initialized Variables ]--------------------------------

right_dir_bit long      1 << MOT_RIGHT_DIR
left_dir_bit  long      1 << MOT_LEFT_DIR
both_dir_bits long      1 << MOT_RIGHT_DIR | 1 << MOT_LEFT_DIR 
right_enc_bit long      1 << MOT_RIGHT_ENC
left_enc_bit  long      1 << MOT_LEFT_ENC
mdira0        long      1 << MOT_RIGHT_PWM | 1 << MOT_LEFT_PWM | 1 << MOT_RIGHT_DIR | 1 << MOT_LEFT_DIR
mctra0        long      %00100 << 26 | MOT_RIGHT_PWM
mctrb0        long      %00100 << 26 | MOT_LEFT_PWM
top_dist      long      $ffff
mdt           long      4000                    'Clocks in one PWM period.
mdto          long      20                      'PWM periods in one timeout tick.
mtime         long      0
mzero         long      0
idler_vel     long      0
midler_addr   long      0-0
stat_ctr      long      0
motor_ctr     long      0      

'-------[ Variables ]----------------------------------------------------------

mpar_addr     res       1       'Address of command parameters. (Coommand address is par.)
mstat_addr    res       1       'Address of status registers.
macc          res       1       'General-purpose accumulator.
maccx         res       1       'General-purpose accumulator extension.
mcnt          res       1       'General-purpose counter.
mcmd          res       1       'Command word.
motor_timer   res       1       'Timeout timer.
mdtimeout     res       1       'Timeout timer LSBs.
right_enc     res       1       'Shift register for right encoder.
left_enc      res       1       'Shift register for left encoder.
right_dist    res       1       'Total distance for right wheel to travel.
left_dist     res       1       'Total distance for left wheel to travel.
max_dist      res       1       'Maximum of left_dist and right_dist.
right_count   res       1       'Countdown for right wheel.
left_count    res       1       'Countdown for left wheel.
ramp_count    res       1       'Countup for ramp computations.
max_vel       res       1       'Maximum velocity for this stroke.
end_vel       res       1       'End velocity for this stroke.
cur_vel       res       1       'Current instantaneous velocity.
targ_vel      res       1       'Target instantaneous velocity.
right_vel     res       1
left_vel      res       1
vel_ctr       res       1       'Countup for velocity computation.
idler_cnt     res       1
right_dom     res       1       '1 when right wheel dominates; 0 otherwise.
left_dom      res       1       '1 when left wheel dominates; 0 otherwise.
nominal_pwm   res       1       'Nominal PWM value for dominant wheel.
right_pwm     res       1       'Actual PWM value for right wheel (nominal_pwm or 0).
left_pwm      res       1       'Actual PWM value for left wheel (nominal_pwm or 0).
idler_reg     res       1
idler_timer   res       1
mot_stat      res       1       'Mirror of status long in hub.

              fit

''=======[ Default ADC sequence ]==============================================

{{ This is a program, of sorts, that's interpreted by the ADC controller. It controls
   how each ADC sample is taken and how the results are posted. Here is how each
   entry is formatted:
''
'''     15        12 11        8 7         4 3      1 0 
'''     +-----------------------------------------------+
'''     ¦    MUX    ¦   Index   ¦   Soak    ¦ Filter ¦ R¦
'''     +-----------------------------------------------+
''
''       `MUX[4]: The address of the analog multiplexer input.
''       `Index[4]: The index of this ADC value in the `Results array.
''       `Soak[4]: The amount of pre-charge time required tofore beginning a conversion.
''       `Filter[3]: Lowpass filter time constant.
''       `R[1]: Reference voltage for conversion (0: 3.3V; 1: 5V).
''
   `Note: `MUX and `Index are combined in the source code. (See the constant list as
   a reference.)
}}

Adc_sequence  word      _VSS|_SOAK_1us|_LPF_64ms|_REF_3V3
              word      _VDD|_SOAK_1us|_LPF_64ms|_REF_3V3
              word      _5V |_SOAK_1us|_LPF_64ms|_REF_5V0
              word      _5V_DIV|_SOAK_1us|_LPF_64ms|_REF_3V3
              word      _VBAT|_SOAK_1us|_LPF_64ms|_REF_3V3
              word      _VTRIP|_SOAK_1us|_LPF_64ms|_REF_3V3
              word      _IDD|_SOAK_1us|_LPF_64ms|_REF_5V0
              word      _IMOT|_SOAK_1us|_LPF_4ms|_REF_3V3
              word      _IDLER|_SOAK_64us|_LPF_4ms|_REF_3V3
              word      _RIGHT_LGT|_SOAK_1us|_LPF_64ms|_REF_3V3
              word      _CENTER_LGT|_SOAK_1us|_LPF_64ms|_REF_3V3
              word      _LEFT_LGT|_SOAK_1us|_LPF_64ms|_REF_3V3
              word      _RIGHT_LIN|_SOAK_64us|_LPF_4ms|_REF_3V3
              word      _LEFT_LIN|_SOAK_64us|_LPF_4ms|_REF_3V3
              word      _P6|_SOAK_16us|_LPF_4ms|_REF_5V0
              word      _P7|_SOAK_16us|_LPF_4ms|_REF_5V0
              word      0

''=======[ Hub variables ]=====================================================

{{These are the global variables used by the various methods.}}

Timers        long      0[8]                    'Eight 1 KHz count-up timers.
Current_x     long      0-0                     'Current drawing position and angle.
Current_y     long      0-0
Current_w     long      0-0
Stall_hyst    long      0                       'Hysteresis for stall detector.
Full_circle   word      DEFAULT_FULL_CIRCLE     'Wheel calibration values.
Wheel_space   word      DEFAULT_WHEEL_SPACE
Half_circle   word      DEFAULT_FULL_CIRCLE / 2
Qtr_circle    word      DEFAULT_FULL_CIRCLE / 4
Atan_circle   long      DEFAULT_FULL_CIRCLE * 56841 / 100000
Light_scale   byte      DEFAULT_LIGHT_SCALE[3]  'Ligtht sensor calibration values.
Line_thld     byte      DEFAULT_LINE_THLD       'Line sensor default threshold.
Obstacle_thld byte      DEFAULT_OBSTACLE_THLD   'Obstacle sensor default threshold.
_filler       byte      0[3]                    '...Needed to end on long boundary.
Motor_cmd     word      0                       ' +
Motor_time    word      0                       ' ¦
Motor_Rdist   word      0                       ' +- Must begin on a long boundary
Motor_Ldist   word      0                       ' ¦  and be contiguous in this order.
Motor_stat    long      0[6]                    ' +
Path_Rdist    long      0                       'Drawing variables.
Path_Ldist    long      0
Path_time     long      0
Path_max_spd  long      0
Results       word      0[24]                   'Must begin on a long boundary.
Tone_queue    word      0[_TONE_Q_SIZE]         ' +
Tone_enq_ptr  word      0                       ' ¦
Tone_deq_ptr  word      0                       ' ¦
Tone_cmd      byte      0                       ' +- Must be contiguous and in this order.
Tone_sync     byte      0                       ' ¦
Tone_voice1   byte      0                       ' ¦
Tone_voice2   byte      0                       ' +
In_path       byte      0

Adc_cog       byte      0                       'Cog numbers for cogs started with cognew.
Tone_cog      byte      0
Motor_cog     byte      0
Reset_count   byte      0                       'Reset button count, read on reset.
Current_spd   byte      0                       'Current velocity.

''=======[ Sample Programs... ]================================================

{{ These sample programs can be copied and pasted into the Propeller Tool in order
   to try out the S2 object. To copy a sample program to try, click its `SOURCE `CODE...
   tag, then click anywhere within the source to select it, followed by Ctrl-C to copy
   it to the clipboard. It can then be pasted into the Propeller Tool.
}}

''-------[ Draw a Star ]-------------------------------------------------------

{{ This program will draw a five-pointed star with the S2 robot.}}

{{{...
CON

  _clkmode      = xtal1 + pll16x
  _xinfreq      = 5_000_000

OBJ

  s2 : "s2"

PUB start

  s2.start                       'Start the S2 object
  s2.start_motors                'Start the motor cog.
  s2.button_mode(true, true)     'Set button mode to display in LEDs and to reset.
  s2.set_led(s2#POWER, s2#BLUE)  'Turn on the power LED.
  s2.default_wheel_calibration   'Use the default wheel calibration (or change if needed).
  if (s2.reset_button_count)     'Do only if reset was via a button, rather than powerup.
    s2.here_is(0, 125)           'Start on top left point.
    s2.begin_path                'Begin a smooth drawing path.
    s2.move_to(200, 125)         'Move to top right point.
    s2.move_to(40, 0)            'Move to bottom left point.
    s2.move_to(100, 200)         'Move to tip-top point.
    s2.move_to(170, 0)           'Move to bottom right point.
    s2.move_to(0, 125)           'Finish at top left point.
    s2.end_path                  'End the drawing path. 
}}   

''-------[ Obstacle Sensor Sounds ]--------------------------------------------

{{ This program uses the obstacle sensors to compute distance-dependent values,
   which are then converted to tones from the speaker. }} 
{{{...
CON

   _clkmode       = xtal1 + pll16x
   _xinfreq       = 5_000_000

OBJ

  s2    : "s2"

PUB  Start | x, y

  s2.start                                          'Start the S2 object.
  s2.start_tones                                    'Start the tone generator.
  repeat                                            'Repeat forever...
    x := distance(s2#LEFT)                          'Get left and right obstacle "distances".
    y := distance(s2#RIGHT)                         
    s2.wait_sync(0)                                 'Wait for previous tone to finish playing.
    s2.play_tone(50, (99 - x) * 10, (99 - y) * 20)  'Play two tones, based on distance reading.

PUB distance(side) : x | dx, sum                    'Compute obstacle distance.

  x := 64                                           'Set x to middle value.
  dx := 32                                          'Set dx to half that.
  repeat while dx                                   'Do a binary search.
    sum~
    repeat 3                                        'Use best two out of three readings
      sum -= s2.obstacle(side, x)                   '  to determine proximity at this threshold setting.
    if (sum => 2)                                   'Detected?
      x += dx                                       '  Yes: Set threshold higher.
    else
      x -= dx                                       '  No:  Set threshold lower.
    dx >>= 1                                        'Cut increment in half.
  x := 100 - (x <# 100)                             'Invert threshold to obtain distance.
}}

''=======[ License ]===========================================================
{{{
+--------------------------------------------------------------------------------------+
¦                            TERMS OF USE: MIT License                                 ¦                                                            
+--------------------------------------------------------------------------------------¦
¦Permission is hereby granted, free of charge, to any person obtaining a copy of this  ¦
¦software and associated documentation files (the "Software"), to deal in the Software ¦
¦without restriction, including without limitation the rights to use, copy, modify,    ¦
¦merge, publish, distribute, sublicense, and/or sell copies of the Software, and to    ¦
¦permit persons to whom the Software is furnished to do so, subject to the following   ¦
¦conditions:                                                                           ¦
¦                                                                                      ¦
¦The above copyright notice and this permission notice shall be included in all copies ¦
¦or substantial portions of the Software.                                              ¦
¦                                                                                      ¦
¦THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,   ¦
¦INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A         ¦
¦PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT    ¦
¦HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF  ¦
¦CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE  ¦
¦OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                                         ¦
+--------------------------------------------------------------------------------------+
}}


              