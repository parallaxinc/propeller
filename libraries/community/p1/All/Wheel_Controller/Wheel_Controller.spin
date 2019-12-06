'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'' Wheel_Controller.spin
''
'' This file provides the code for a Wheel Control object which is designed to
'' provide a user friendly interface to a Parallax Inc. Motor Mount and Wheel
'' Kit (#27971) with Position Controllers (#29319).  The Position Controllers
'' are connected to a pair of Parallax HB-25 Motor Controllers (#29144).
'' Although it is not necessary for the user of this Wheel Controller object
'' to understand how the interface actually works, it is recommended that they
'' obtain the appropriate documentation from Parallax Inc. and acquire a basic
'' understanding of how everything works.
''
'' The provided public methods allow the user to command the wheel kit to go
'' a specified distance in inches, set the speed in feet per minute and perform
'' stationary turns in degrees.  Methods are also provided for biasing the
'' wheel speeds to produce moving turns or arcs.  The user may request at any
'' time the current wheel positions and speeds.
''
'' A status is provided so that the user may determine if the Wheel Controller
'' has failed.  In such a case the user may reset the Wheel Controller Cog.
'' All communications with the Position Controllers is via a dedicated Cog
'' running an assembly language routine. 
''
'' There is a set of constants which the user may use to customize the Wheel
'' Controller object.  However, probably the only one you will need to modify
'' is the wheel base (see WHEEL_BASE).  All other constants have been optimized
'' during bench tests.
''
'' In Version 1.1 a Joy Stick method was added for those users that wish to
'' control the wheels in a remote control fashion.  No other method needs to be
'' used.  See the comments for the JoyStick method.  This function has been
'' bench tested.  It has not actually been tested with a remote control device.
'' I would like to know if anyone is successful with a remote device.  I am
'' willing to fix any problems that may occur.  Note that this object was
'' originally designed for autonomous control.
''
'' Designer: Don W. Ternyila
'' E-Mail: ternyila@forwardyne.com
''
'' Version: 1.1 (Aug 20, 2009)
''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

CON

  ' Serial I/O, Wheel and Position Controller Constants.  These values may
  ' be changed to accomodate different hardware configurations and desired
  ' initialization states.  The MAX_SPEED value is the encoder units per 1/2
  ' second beyond which the wheel kit seems to fail.  The user may want to
  ' experiment with this value.
                                                                
  WHEEL_DIAM    = 600    ' Diameter of drive wheels (inches * 100)
  WHEEL_BASE    = 1075   ' Wheel base (inches * 100)
  ENCODER_UNITS = 36     ' Encoder units per rotation
  SIO_BAUD_RATE = 19200  ' Position Controller serial I/O baud rate
  INIT_RWMS     = 36     ' Initial right wheel max speed (188 ft/min)
  INIT_RWRS     = 15     ' Initial right wheel ramp speed 
  INIT_LWMS     = 36     ' Initial left wheel max speed
  INIT_LWRS     = 15     ' Initial left wheel ramp speed
  TX_DELAY      = 20     ' Position Controller transmit delay (0-255)
  ARRIVAL_TOL   = 3      ' Arrival check tolerance
  MAX_SPEED     = 48     ' Maximum encoder speed (48 = 235 ft/min)
  TRVL_THRSH    = 400    ' Auto Travel Threashold

  ' Encoder Unit Distance -- This is the distance (inches * 1000) of travel
  ' for one encoder unit (ie: 523 for 6 inch wheel and 36 position encoder):   

  UNIT_INCHES = (314 * WHEEL_DIAM) / (ENCODER_UNITS * 10)

  ' Turn constant -- This is the distance (inches per degree * 1000) a wheel
  ' will have to travel to turn one degree:

  DEGREE_INCHES = (314 * WHEEL_BASE) / 3600
    
  ' Position Controller Command Constants:
  
  QPOS = $08    ' Query Position
  QSPD = $10    ' Query Speed
  CHFA = $18    ' Check for Arrival
  TRVL = $20    ' Travel Number of Positions
  CLRP = $28    ' Clear Position
  SREV = $30    ' Set Orientation as Reversed
  STXD = $38    ' Set TX Delay
  SMAX = $40    ' Set Speed Maximum
  SSRR = $48    ' Set Speed Ramp Rate

  ' Position Controller Wheel IDs:
                                                                                
  ALL_WHEELS  = 0
  RIGHT_WHEEL = 1
  LEFT_WHEEL  = 2

  ' Wheel Controller Command parameters:
  
  LEFT_TURN  = 0
  RIGHT_TURN = 1
  FORWARD    = 0
  REVERSE    = 1
     
  ' Data structure access offsets:
         
  io_pin_              = 04
  bit_ticks_           = 08
  sec_ticks_           = 12  
  have_arrived_        = 16
  right_wheel_pos_     = 20
  left_wheel_pos_      = 24
  right_wheel_spd_     = 28
  left_wheel_spd_      = 32                   
  right_wheel_max_spd_ = 36
  left_wheel_max_spd_  = 40
  right_wheel_rmp_spd_ = 44
  left_wheel_rmp_spd_  = 48
  trvl_rw_             = 52
  trvl_lw_             = 56
  mutex_id_            = 60
  req_flags_ptr_       = 64
  trvl_thrsh_rw_       = 68
  trvl_thrsh_lw_       = 72

  ' Request Flag Array (req_flags) offsets:
   
  clear_req_           = 0      ' Clear Request
  go_req_              = 1      ' Go Distance Request
  rw_trvl_req_         = 2      ' Right Wheel Travel Request
  lw_trvl_req_         = 3      ' Left Wheel Travel Request
  rw_setspd_req_       = 4      ' Right Wheel Set Speed Request
  lw_setspd_req_       = 5      ' Left Wheel Set Speed Request
  rw_setrmp_req_       = 6      ' Right Wheel Set Ramp Speed Request
  lw_setrmp_req_       = 7      ' Left Wheel Set Ramp Speed Request
  auto_trvl_           = 8      ' Automatic Travel Mode
  
  
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
VAR
  
  ' Global Variables:
  
  long  stack[40]               ' Cog stack space
  byte  Cog                     ' Cog ID
  long  PC_Pin                  ' Position Controller I/O pin
  long  TurnSpd                 ' Current turn max speed (outside wheel)
  long  TurnBias                ' Current turn bias (+/- 100)
  long  JS_Spd                  ' Joy Stck speed (+/- 100)
  long  JS_Bias                 ' Joy Stick turn bias (+/- 100)
  long  JS_Clear                ' Joy Stick clear flag
  
  ' The following flag is used to abort any active wait condition:
  
  byte AbortWait                ' TRUE if "abort"
       
  ' The following data structure (19 longs) is used to pass information
  ' between the Wheel Controller object methods and the Wheel Controller Cog:

  long cog_stat            ' +00: Cog status 
  long io_pin              ' +04: Serial I/O pin
  long bit_ticks           ' +08: Clock cycles per serial I/O bit transfer
  long sec_ticks           ' +12: Clock cycles per second
  long have_arrived        ' +16: Have arrived flag
  long right_wheel_pos     ' +20: Right wheel current position
  long left_wheel_pos      ' +24: Left wheel current position
  long right_wheel_spd     ' +28: Right wheel current speed
  long left_wheel_spd      ' +32: Left wheel current speed                   
  long right_wheel_max_spd ' +36: Right wheel current max speed
  long left_wheel_max_spd  ' +40: Left wheel current max speed
  long right_wheel_rmp_spd ' +44: Right wheel current ramp speed
  long left_wheel_rmp_spd  ' +48: Left wheel current ramp speed
  long trvl_rw             ' +52: Right wheel travel units
  long trvl_lw             ' +56: Left wheel travel units
  long mutex_id            ' +60: Mutex Id
  long req_flags_ptr       ' +64: Request Flags arrary pointer
  long trvl_thrsh_rw       ' +68; Right wheel auto travel threashold  
  long trvl_thrsh_lw       ' +72; Left wheel auto travel threashold 

  ' Request Flag Array -- The following byte array provides flags that are used
  ' by Wheel Controller methods to trigger Wheel Controller Cog functions:
  
  byte req_flags[9]        ' Request flags Array

                                      
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''  
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'' Open Wheel Controller Object Method
''
'' Call this method to open the Wheel Controller object.  This method must be
'' called before any member methods are called.  If this method is not called or
'' it returns a FALSE condition then indeterminate results will occur when a
'' member method is called.  Member methods do not check for a successful open.
'' After this method has been called successfully, the Start method must be
'' called before commands can be processed by the Wheel Controller cog.
''
'' Input: pin -- Position Controller I/O pin
''
'' Return Value: non-zero if successful

PUB Open(pin) : success

  PC_Pin := pin                               
  Close           ' Make certain the cog is not currently running.    
  init_dat        ' Initialize data.   
                                                   
  ' Create mutex.
  
  mutex_id := locknew
  if mutex_id == -1
    success := 0     'Failed to get lock id
    
  else

    ' Load and start the Cog.  Start will need to be called before any
    ' Cog processing will take place.
      
    success := (Cog := cognew(@wc_entry, @cog_stat) + 1)

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'' Start (Restart) Method
''
'' This method should be called when the Wheel Controller Cog is to start
'' processing commands.  It should be called after the 'Open' method is called.
'' It generally is good practice to not call this method until it is certain
'' that the Position and Motor Controllers have been properly powered up.
''
'' If this method is called when the Wheel Controller is already running then
'' a reset is effectively performed by closing down the cog and restarting it.
''
'' Return Value: non-zero if successful

PUB start : success

  if cog_stat <> 0
    Close
    init_dat
    success := (Cog := cognew(@wc_entry, @cog_stat) + 1)
  else
    success := Cog

  ' If everything is OK then cog_stat is set to trigger the Cog to start
  ' processing.
   
  if success <> 0
    cog_stat := 1

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'' Initialize Data Method
''
'' This is a private method used by the Open and Start methods to initialize
'' Wheel Controller data and flags.

PRI init_dat

  AbortWait := 0
  
  longfill(@cog_stat, 0, 19)
  bytefill(@req_flags, 0, 9)
              
  req_flags_ptr := @req_flags                 
  TurnSpd := 0
  TurnBias := 0
  JS_Spd := 0
  JS_Bias := 0
  JS_Clear := 0
  
  right_wheel_max_spd := INIT_RWMS
  left_wheel_max_spd  := INIT_LWMS
  right_wheel_rmp_spd := INIT_RWRS
  left_wheel_rmp_spd  := INIT_LWRS
                             
  sec_ticks := clkfreq                     'Set cycles per second
  bit_ticks := clkfreq / ||SIO_BAUD_RATE   'Calculate serial bit time
  io_pin := PC_Pin                         'Set serial I/O pin

  ' Set request flags for startup.
  
  req_flags[clear_req_]     := 1
  req_flags[rw_setspd_req_] := 1 
  req_flags[lw_setspd_req_] := 1
  req_flags[rw_setrmp_req_] := 1
  req_flags[lw_setrmp_req_] := 1
                                                                                    
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'' Close Method.
''
'' Call this method to shut down the Wheel Controller Cog.

PUB Close

  if Cog
    cogstop(Cog~ - 1)           ' Shut down Wheel Controller Cog 
    dira[io_pin]~               ' Float serial I/O pin
    lockret(mutex_id)
     
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'' Get Status Method
''
'' Call this method to obtain the Wheel Controller status variable.  This status
'' variable is incremented by the Wheel Controller Cog approximately every 1/4
'' second.  The user may use this status to determine if the the Cog has stopped.
'' This may happen if the Cogs receive method (which blocks) stops receiving
'' data.  If the status variable is seen to freeze then the Position Controllers
'' have most likely failed due to a drop off in power, so check your power
'' supply.  Improper setting of the transmit delay values, either on the
'' Position Controller or Wheel Controller Cog side, may also cause the Cog to
'' freeze up.
''
'' Return Value: status = 0..0xFFFFFFFF
  
PUB get_Status : status

  status := cog_stat

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'' Clear Method
''
'' Call this method to reset the Position Controllers.  This is a "soft reset"
'' which will reset the current positions and end points.  The Max speed and
'' Ramp Speed parameters are not changed.  A 'Clear" will cause an abrupt stop
'' which may not be desirable if the wheels are moving fast. 

PUB Clear

  req_flags[clear_req_] := 1
  
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'' Stop Method
''
'' Call this method to stop all wheels. It in effect performs a "go distance"
'' request with a zero distance.  The stop will be smooth.

PUB Stop

  go_Distance(0, FORWARD)
  
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'' Go Distance Method
''
'' Call this method to command both wheels to travel a specified distance
'' forward or backward.  The current wheel speeds and turn bias stay in effect.
'' So if the speeds are different (bias present) then a steady turn will occur,
'' creating a move in an arc.  A command to zero distance will cause the wheels
'' to come to a smooth stop.
''
'' Note that this method will block if there is an active "set speed" command.
''
'' Inputs: distance  -- distance to travel in inches (zero for stop)
''         direction -- FORWARD or REVERSE 

PUB go_Distance(distance, direction) | dist, rem

  ' Wait if there is an active speed change command.

  SpdChkWait
  
  ' Convert distance to +/- incoder units.
   
  dist := distance * 1000
  rem := dist // UNIT_INCHES
  dist := dist / UNIT_INCHES
  if rem > (UNIT_INCHES / 2)
    dist++

  trvl_rw := dist
  trvl_lw := dist

  ' If there is an active turn bias then the distance of the inside wheel
  ' should be less than that of the outside wheel.  This will allow for a
  ' smooth stop at the end of the arc.

  if TurnBias <> 0
    dist := (dist * (100 - ||TurnBias)) / 100
    if TurnBias > 0
      trvl_rw := dist           'Right turn
    else
      trvl_lw := dist           'Left turn

  ' Adjust for reverse.
  
  if direction == REVERSE
    trvl_rw := -trvl_rw
    trvl_lw := -trvl_lw

  ' Flag Wheel Controller Cog to perform "go distance" request. If there is
  ' a turn bias then individual wheel travel requests are used. 

  if TurnBias <> 0 
    req_flags[rw_trvl_req_] := 1
    req_flags[lw_trvl_req_] := 1
  else
    req_flags[go_req_] := 1
    
  have_arrived := 0  
                          
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'' Spin Turn Method
''
'' This method will perform a spin turn to the right or left. A spin turn is
'' executed by turning the wheels in apposite directions.  This method should
'' only be called when the wheels are stopped.  No action will be taken if a
'' wheel is turning.  Wheels are assumed to be moving if the "arrived state"
'' is false. Do not use this method when in Joy Stick mode.
'' 
'' Note that this method will block if there is an active 'set speed' command.
''
'' Inputs: direction -- RIGHT_TURN or LEFT_TURN
''         degrees   -- degrees to turn
''
'' Output: xero if successful, -1 if failure (wheels still moveing)
 
PUB spin_turn(direction, degrees) : success | right_dist, left_dist

  if have_arrived == 0
    return -1

  ' Wait if there is an active speed change command.

  SpdChkWait
          
  ' Convert distance from inches to incoder positions.
    
  right_dist := (degrees * DEGREE_INCHES) / UNIT_INCHES
  left_dist := right_dist

  ' Modify for direction.
  
  if direction == RIGHT_TURN
    -right_dist
  else
    -left_dist

  ' Trigger Position Controller request.
                                      
  trvl_rw := right_dist
  trvl_lw := left_dist  
  req_flags[go_req_] := 1
  have_arrived := 0

  return 0

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'' Turn Method (turning the steering wheel)
''
'' This method will bias the wheel speeds to cause a turning action.  The
'' caller will indicate a +/- percent bias.  Bias to the right is '+' and bias
'' to the left is '-'.  For example if the caller indicates a +10 bias, the
'' right wheel is slowed to 90% of the left wheel, causing a turn to the right.
'' A zero percent bias will cause the speed of both wheels to be the same and
'' effectively terminate the turn.  A value of +/- 100 will cause the inside
'' wheel to stop. 
''
'' Note that, during a turn, any other action made by the user that effects the
'' speed of either wheel will cause unpredictable results.
''
'' The turn bias is sticky.  That is to say, it stays in effect until a call to
'' this method is made with a bias of zero.  Any "go distance" commands are
'' effected by a non-zero turn bias.  When a "go distance" command is made with
'' an active turn bias, the wheel distances are adjusted so that both stop at
'' the same time at the end of the arc.
''
'' This method should not be used when the Joy Stick mode is active.  However,
'' it is used by the Joy Stick mode to adjust wheel speeds and turn bias.  
''
'' This method will block if there is an active "set speed" command.
''
'' Inputs: bias = (+/-) 100

PUB turn(bias) | bias_, outside_spd, inside_spd, inside_wheel 

  ' Wait if there is an active speed change command.

  SpdChkWait
  
  ' Adjust for values beyond +/- 100.
   
  bias_ := bias
  if bias > 100
    bias_ := 100
  elseif bias < -100
    bias_ := -100  

  ' If bias is zero then we assume that a turn has been completed and both
  ' wheels are to be reset to the original max speed which may be zero if
  ' the Joy Stick mode is active.
   
  if bias_ == 0
      right_wheel_Max_spd := TurnSpd
      left_wheel_max_spd := TurnSpd
      TurnSpd := 0
      TurnBias := 0

  else

    ' Reverse the outside wheel speed if turn is going from one side to
    ' the other.
    
    if (bias_ < 0) AND (TurnBias > 0)                                      
      right_wheel_max_spd := TurnSpd      'Going from right turn to left turn.
    elseif (bias_ > 0) AND (TurnBias < 0)                                       
      left_wheel_max_spd := TurnSpd       'Going from left turn to right turn.       

    ' Determine the inside wheel and speed of the outside wheel.
  
    if bias_ > 0
      inside_wheel := RIGHT_WHEEL
      outside_spd := left_wheel_max_spd
    else
      inside_wheel := LEFT_WHEEL
      outside_spd := right_wheel_max_spd

    ' If the outside wheel speed is zero then save the bias and exit.
    ' Saving the bias here will cause a turn if "go distance" is used.
    
    if outside_spd == 0
      TurnBias := bias_
      return

    ' Determine speed of inside wheel.

    inside_spd := (outside_spd * (100 - ||bias_)) / 100

    ' Set new wheel speeds.
                  
    if inside_wheel == RIGHT_WHEEL
      left_wheel_max_spd := outside_spd
      right_wheel_max_spd := inside_spd
    else
      left_wheel_max_spd := inside_spd
      right_wheel_max_spd := outside_spd

  ' Trigger the Wheel Controller Cog to set the new wheel speeds.
       
  req_flags[rw_setspd_req_] := 1
  req_flags[lw_setspd_req_] := 1

  ' Save turn state.

  TurnBias := bias_
  If (TurnBias <> 0) AND (TurnSpd == 0)
    TurnSpd := outside_spd 

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'' Throttle Method
''
'' Call this method to set the speed to a percentage of the maximum speed. This
'' method can be used when the speed is to be changed during a turn.  If there
'' is an active turn bias then the inside wheel speed will be set accordingly.
''  
'' This method will block if there is already a "set speed" command active. 
''
'' Inputs: speed -- 0 to 100 percent

PUB throttle(speed) | eu, bias_
                        
  ' Wait if there is an active speed change command.

  SpdChkWait

  ' Determine speed setting which is a percentage of MAX_SPEED.
     
  eu := ||speed
  if eu > 100
    eu := 100

  eu := MAX_SPEED - ((MAX_SPEED * (100 - eu)) / 100)

  ' Set the speed of both wheels.  If there is a turn bias active then the
  ' "turn" method is used to set the new speeds.

  right_wheel_max_spd := eu 
  left_wheel_max_spd := eu

  bias_ := TurnBias
                          
  if bias_ <> 0
    TurnBias := 0
    TurnSpd := 0
    turn(bias_)
  else     
    set_WheelSpeedUnits(ALL_WHEELS, eu)
                                                                                   

PRI SpdChkWait

  ' Wait while the wheel speeds are being changed.
   
  repeat
    if (req_flags[rw_setspd_req_] == 0) AND (req_flags[lw_setspd_req_] == 0)
      quit
    if AbortWait
      quit 

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'' Joy Stick Method
''
'' This method should be used when total remote control is desired.  The user
'' may use joy stick type inputs to control the wheels.  The 'X' value would be
'' for setting the speed and the 'Y' value for turning.  A positive value for
'' 'X' would be a forward speed, a negative value for reverse speed and zero
'' for stop.  When moving forward, a positive value for 'Y' would cause a right
'' turn, a negative value a left turn and zero would be for straight travel.
'' In reverse the turning action would be as expected. Think of it as behaving
'' like a steering wheel.
''
'' The speed and the turn bias parameters cannot go from negative to positive
'' without first going through zero.  If the user attempts to do so then this
'' method will force a zero value and the user must make another call with the
'' desired values.
''
'' Caution should be taken when going from a high speed to a low speed. For
'' example if the speed is changed from 100% to 5%, the wheels will stop
'' instantly.  This will be abrupt and undesirable.  Decreasing the speed
'' should be done in small steps.  Going from a high speed to zero speed is
'' not a problem.
''
'' The Joy Stick function uses the Auto-Travel mode to keep the wheels
'' moving.  The user never has to perform a travel command.  As a result, the
'' user can control the wheels with just this method.  No other methods need
'' to be used other than the Open and Start methods.
''
'' This method will block if there is an active set speed command.  It will
'' also block if called when the wheels are being stopped.
''
'' Inputs: jsspd -- speed (+/- 0..100 percent)
''         jstb  -- turn bias (+/- 0..100 percent)

PUB JoyStick(jsspd, jstb) | old_spd

  ' If the previous call resulted in the wheels being stopped then wait for
  ' the wheels to stop.  This is done to prevent abrupt stops.
  
  if JS_Clear <> 0  
    repeat while (right_wheel_spd + left_wheel_spd) > 4 
    req_flags[clear_req_] := 1
    JS_Clear := 0
    
  old_spd := JS_Spd
  
  ' If either of the input parameters is going from one side to the other
  ' then they are set to zero.  Values greater or less than 100 are
  ' truncated to +/- 100.

  if (jsspd <> JS_Spd) OR (jstb <> JS_Bias) 
          
    if ((JS_Spd < 0) AND (jsspd > 0)) OR ((JS_Spd > 0) AND (jsspd < 0))
      JS_Spd := 0
    else  
      JS_Spd := jsspd
 
    if ((JS_Bias < 0) AND (jstb > 0)) OR ((JS_Bias > 0) AND (jstb < 0))
      JS_Bias := 0
    else  
      JS_Bias := jstb     
     
    if JS_Spd > 100
      JS_Spd := 100
    elseif JS_Spd < -100
      JS_Spd := -100
  
    if JS_Bias > 100
      JS_Bias := 100
    elseif JS_Bias < -100
      JS_Bias := -100
                                     
    ' Set the Turn Bias and then call the Throttle method to set the wheel
    ' speeds.
    
    TurnBias := JS_Bias
    if JS_Spd <> 0
      Throttle(||JS_Spd)  

  ' If the speed has just been increased from zero then the wheels are
  ' commanded to travel.  Otherwise, they are commanded to stop.  The auto_trvl
  ' flag is used to trigger the Cog logic to automatically keep the wheels
  ' moving by advancing the wheel positions when they hit the threashold
  ' distance.
  
  if JS_Spd > 0
    if old_spd == 0 
      travel_units(TRVL_THRSH + 100, ALL_WHEELS)
      trvl_thrsh_rw := TRVL_THRSH
      trvl_thrsh_lw := TRVL_THRSH       ' Start forward travel
      req_flags[auto_trvl_] := 1
        
  elseif JS_Spd < 0
    if old_spd == 0 
      travel_units(-TRVL_THRSH - 100, ALL_WHEELS)
      trvl_thrsh_rw := -TRVL_THRSH
      trvl_thrsh_lw := -TRVL_THRSH      ' Start reverse travel
      req_flags[auto_trvl_] := 2
        
  else
    req_flags[auto_trvl_] := 0 
    travel_units(0, ALL_WHEELS)
    trvl_thrsh_rw := 0
    trvl_thrsh_lw := 0
    JS_Clear := 1                       ' Indicate wheels were stopped
                                                  
    
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'' Wait For Arrival Method
''
'' This method will block until the Position Controller Cog has detected arrival
'' or when the AbortWait flag has been set.  This method should not be used
'' unless the caller has nothing to do other than wait for the last Go Distance
'' or Spin Turn command to complete.

PUB arrival_wait

  waitcnt(clkfreq/2 + cnt)
  have_arrived := 0 
  repeat
    waitcnt(clkfreq/10 + cnt)
    if AbortWait OR have_arrived
      QUIT
      
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'' Check For Arrival Method
''
'' This method will return the "arrival" state.  This method should be used
'' when blocking is not desired.  Checking the "arrival" state is desirable
'' when the user is performing short Go Distance and Spin Turn commands. This
'' method can also be used to determine if all wheels have stopped.
''
'' Output: arrived -- TRUE or FALSE

PUB arrival_check : arrived

  arrived := have_arrived       ' Get current arrival status
 
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'' Set Wheel Speed Method
''
'' Call this method to set maximum wheel speed.  The caller provides the
'' speed in feet per minute which is converted to encoder positions per 1/2
'' second and sent to the Wheel Controller Cog to be passed on to the Position
'' Controllers.  Note that 88 feet per minute equates to one statute mile per
'' hour.  Note that the second method here, set_WheelSpdUnits, may be used to
'' set the speed in encoder units.  Be careful using it because it does not
'' check for maximum speed.
''  
'' Note that this method will block if there is already a "set speed" command
'' active. 
''
'' Inputs: wheel -- RIGHT_WHEEL, LEFT_WHEEL or ALL_WHEELS
''         speed -- feet per minute

PUB set_WheelSpeed(wheel, speed) | eu, rem

  ' Wait if there is an active speed change command.

  repeat while (req_flags[rw_setspd_req_]<>0) OR (req_flags[lw_setspd_req_]<>0)
  
  ' Compute encoder units per 1/2 second.
  
  eu := (speed * 12000) / UNIT_INCHES
  rem := eu // 120
  eu := eu / 120
  if rem > 60
    eu++

  ' If the maximum speed for the wheel kit has been exceded then the speed
  ' is backed off to prevent failure.

  if eu > MAX_SPEED
    eu := MAX_SPEED
    
  set_WheelSpeedUnits(wheel, eu)
 
PUB set_WheelSpeedUnits(wheel, eu)

  ' Pass new speed to Wheel Controller.
                                                
  if (wheel == RIGHT_WHEEL) OR (wheel == ALL_WHEELS)
    right_wheel_max_spd := eu
    req_flags[rw_setspd_req_] := 1
     
  if (wheel == LEFT_WHEEL) OR (wheel == ALL_WHEELS)
    left_wheel_max_spd := eu
    req_flags[lw_setspd_req_] := 1
         
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'' Get Speed Method
''
'' This method returns the current speed in feet per minute for a wheel or
'' ALL_WHEELS.  For ALL_WHEELS the average of both wheels is returned. The wheel
'' speed variables are updated by the Wheel Controller Cog on a periodic.  They
'' are the average speed over the last 1/2 second.
''
'' Input: wheel  -- RIGHT_WHEEL, LEFT_WHEEL or ALL_WHEELS
''
'' Output: speed -- feet per minute (negative if going backward), 88 equates to
''                  one mile per hour
  
PUB get_Speed(wheel) : speed | rem

  repeat until not lockset(mutex_id)
  
  speed := right_wheel_spd
  
  if wheel == ALL_WHEELS
    speed += left_wheel_spd
    if speed <> 0
      speed := speed / 2
    
  elseif wheel == LEFT_WHEEL
    speed := left_wheel_spd

  ' Compute feet per minute from encoder units per 1/2 second

  if speed <> 0 
    speed := ((speed * 120) * UNIT_INCHES) / 12  '(ft/min) * 1000
    rem := speed // 1000
    speed := speed / 1000
    if rem > 500
      speed++

  lockclr(mutex_id)

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'' Get Wheel Position Method
''
'' Call this method to get the position of a wheel.  The value returned is the
'' Position Controllers current position for the wheel.
''
'' Input: wheel      -- RIGHT_WHEEL or LEFT_WHEEL
''
'' Output: wheel_pos -- wheel position in encoder units
 
PUB get_Wheel_Position(wheel) : wheel_pos
 
  repeat until not lockset(mutex_id)
  
  if wheel == LEFT_WHEEL
    wheel_pos := left_wheel_pos
  elseif wheel == RIGHT_WHEEL
    wheel_pos := right_wheel_pos
  else
    wheel_pos := 0
 
  lockclr(mutex_id)
  
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'' Set Ramp Speed Method
''
'' Call this method to set the wheel ramp speed(s).  It is recommended that the
'' ramp speeds for both wheels be the same and they only be set during
'' initialization while both wheels are stopped.  The default value is 15.
''
'' Inputs: wheel -- RIGHT_WHEEL, LEFT_WHEEL or ALL_WHEELS
''         speed -- encoder positions per 1/2 second per 1/2 second 

PUB set_RampSpeed(wheel, speed)
                                      
  if wheel == RIGHT_WHEEL OR ALL_WHEELS
    right_wheel_rmp_spd := speed
    req_flags[rw_setrmp_req_] := 1
    
  if wheel == LEFT_WHEEL OR ALL_WHEELS
    left_wheel_rmp_spd := speed
    req_flags[lw_setrmp_req_] := 1 
                                                      
   
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'' Travel Units Method
''
'' This method is used to command a wheel to travel a specific number of encoder
'' units.
''
'' Inputs: distance -- number of units to travel (-32768 to +32768)
''         wheel    -- ALL_WHEELS, RIGHT_WHEEL or LEFT_WHEEL

PUB travel_units(distance, wheel)

  if wheel == ALL_WHEELS  
    trvl_rw := distance    
    trvl_lw := distance
    req_flags[go_req_] := 1
    
  elseif wheel == RIGHT_WHEEL
    trvl_rw := distance
    req_flags[rw_trvl_req_] := 1

  elseif wheel == LEFT_WHEEL
    trvl_lw := distance
    req_flags[lw_trvl_req_] := 1
    
                                
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'' Wheel Controller Interface Cog
''
'' The following code runs in its own cog.  It handles all direct communications
'' with the two wheel Position Controllers.  The Wheel Controller object will
'' interface with this cog's logic via global data structures (see the VAR and
'' CON code blocks). 
                                                          
DAT
                        org

' '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Entry point for Wheel Controller Cog Processing.

wc_entry                mov     r0,#0                   'Register for holding zero
                        mov     stat_ptr,par            'Get status pointer

                        mov     p1,par                  'Make I/O pin mask
                        add     p1,#io_pin_     
                        rdlong  r1,p1
                        mov     iomask,#1
                        shl     iomask,r1

                        mov     p1,par                  'Get bit ticks
                        add     p1,#bit_ticks_
                        rdlong  bitticks,p1                                                                                    
  
                        mov     p1,par                  'Get Req Flags ptr
                        add     p1,#req_flags_ptr_
                        rdlong  pReqFlags,p1
                           
                        mov     p1,par                  'Get Mutex Id
                        add     p1,#mutex_id_
                        rdlong  mutexid,p1
                        
                        mov     p1,par                  'Get periodic ticks
                        add     p1,#sec_ticks_          'and init periodic tm
                        rdlong  secticks,p1
                        mov     per_tm,secticks
                        shr     per_tm,#1
                        add     per_tm,cnt

                        cmp     r0,#1           wz      'Clear z bit    
                        muxz    outa,iomask             'Set I/O pin low (zero)         
                        muxz    dira,iomask             'Set I/O pin for input 

                        ' Wait here until the Start method has been called.
                        
:start_wait             rdlong  r1,stat_ptr
                        cmp     r1,#0           wz
              if_z      jmp     #:start_wait
               
                        mov     xmt_delay,cnt           'Init xmit delay              

                        ' We can now start communicating with the Position
                        ' Controllers.  First, the right wheel is reversed.
                                              
                        mov     txdata,#SREV
                        add     txdata,#RIGHT_WHEEL
                        call    #transmit

                        ' Set Position Controller Tx Delay 
 
                        mov     txdata,#STXD
                        call    #transmit
                        mov     txdata,#TX_DELAY
                        call    #transmit                        
                        
                        ' '''''''''''''''''''''''''''''''''''''''''''''''''''''
                        ' '''''''''''''''''''''''''''''''''''''''''''''''''''''
                        ' Begin loop to check request flags and perform
                        ' periodic processing.
                        
:loop                   mov     event,#0                'Clear event flag

                        ' '''''''''''''''''''''''''''''''''''''''''''''''''''''
                        ' Check for "clear" request.  This request will result
                        ' in three resets being sent to both wheels.  This will
                        ' stop both wheels and reset thier position parameters.
                        
                        mov     offset,#clear_req_
                        call    #check_flag
        if_z            jmp     #:loop1
                                                                    
                        mov     txdata,#CLRP|RIGHT_WHEEL
                        call    #transmit
                        mov     txdata,#CLRP|LEFT_WHEEL
                        call    #transmit             
                        mov     txdata,#CLRP|RIGHT_WHEEL
                        call    #transmit
                        mov     txdata,#CLRP|LEFT_WHEEL
                        call    #transmit
                        mov     txdata,#CLRP|RIGHT_WHEEL
                        call    #transmit             
                        mov     txdata,#CLRP|LEFT_WHEEL
                        call    #transmit

                        ' Give Position Controllers a little time to do their
                        ' thing.
                        
                        'mov     r1,secticks
                        'shr     r1,#1
                        'add     r1,cnt
                        'waitcnt r1,#0

                        call    #end_req
                                              
                        ' '''''''''''''''''''''''''''''''''''''''''''''''''''''
                        ' Check for "set speed" requests.
                        
:loop1                  mov     offset,#rw_setspd_req_
                        call    #check_flag
        if_z            jmp     #:loop2
        
                        mov     offset,#right_wheel_max_spd_
                        call    #read_wrd
                        mov     whl_type,#RIGHT_WHEEL
                        call    #set_spd              'Set right wheel max spd
                        call    #end_req
                          
:loop2                  mov     offset,#lw_setspd_req_
                        call    #check_flag
        if_z            jmp     #:loop3
        
                        mov     offset,#left_wheel_max_spd_
                        call    #read_wrd
                        mov     whl_type,#LEFT_WHEEL
                        call    #set_spd             'Set left wheel max spd
                        call    #end_req

                        ' '''''''''''''''''''''''''''''''''''''''''''''''''''''
                        ' Check for "set ramp speed" requests.
                        
:loop3                  mov     offset,#rw_setrmp_req_
                        call    #check_flag
        if_z            jmp     #:loop4               'Jump if no request
        
                        mov     offset,#right_wheel_rmp_spd_
                        call    #read_wrd
                        mov     whl_type,#RIGHT_WHEEL
                        call    #set_rmpspd           'Set right wheel ramp spd
                        call    #end_req
                        
:loop4                  mov     offset,#lw_setrmp_req_
                        call    #check_flag
        if_z            jmp     #:loop5
        
                        mov     offset,#left_wheel_rmp_spd_
                        call    #read_wrd
                        mov     whl_type,#LEFT_WHEEL
                        call    #set_rmpspd           'Set left wheel ramp spd
                        call    #end_req
                        
                        ' '''''''''''''''''''''''''''''''''''''''''''''''''''''
                        ' Check for "go distance" request.  This command will
                        ' cause both wheels to travel.  If the distances are
                        ' the same for both wheels then a ALL_WHEEL command is
                        ' used.  Otherwise, a separate command is sent for each
                        ' wheel.

:loop5                  mov     offset,#go_req_
                        call    #check_flag
        if_z            jmp     #:loop8            'Jump if no "go request"

                        mov     p1,par
                        add     p1,#have_arrived_  'Clear "have arrived" flag
                        wrlong  r0,p1
                        
                        mov     offset,#trvl_lw_
                        call    #read_wrd
                        mov     r2,dat_wrd         't2 = left wheel distance
                        mov     offset,#trvl_rw_
                        call    #read_wrd          'dat_wrd = right wheel dist   

                        cmp     r2,dat_wrd      wz 
        if_nz           jmp     #:loop6
                        mov     whl_type,#ALL_WHEELS
                        call    #travel                 'All wheel travel
                        jmp     #:loop7

:loop6                  mov     whl_type,#RIGHT_WHEEL
                        call    #travel                 'Right wheel travel
                        mov     dat_wrd,r2
                        mov     whl_type,#LEFT_WHEEL
                        call    #travel                 'Left wheel travel

:loop7                  call    #end_req

                        ' '''''''''''''''''''''''''''''''''''''''''''''''''''''
                        ' Check for "travel" requests.  These requests command
                        ' one wheel to travel.                                                

:loop8                  mov     offset,#rw_trvl_req_
                        call    #check_flag
        if_z            jmp     #:loop9                 'Jump if no request
                                      
                        mov     offset,#trvl_rw_
                        call    #read_wrd
                        mov     whl_type,#RIGHT_WHEEL
                        call    #travel                 'Right wheel travel
                        call    #end_req

:loop9                  mov     offset,#lw_trvl_req_
                        call    #check_flag
        if_z            jmp     #:loop10                'Jump if no request
                                      
                        mov     offset,#trvl_lw_
                        call    #read_wrd
                        mov     whl_type,#LEFT_WHEEL
                        call    #travel                 'Left wheel travel
                        call    #end_req

                        ' '''''''''''''''''''''''''''''''''''''''''''''''''''''
                        ' If a request has been processed then go back to top
                        ' of loop to check for more requests.  We want to make
                        ' sure all requests have been processed before any
                        ' periodics are performed.
                        
:loop10                 cmp     event,#0        wz
        if_nz           jmp     #:loop
                        
                        ' '''''''''''''''''''''''''''''''''''''''''''''''''''''
                        ' Perform periodic processing if it is time.
                                                                        
                        mov     r1,per_tm
                        sub     r1,cnt
                        cmps    r1,#0           wc
        if_nc           jmp     #:loop19                'Jump if not time
                        
                        ' Get arrival status.  Both wheels must have arrived
                        ' before arrival state is true.  If either wheel is
                        ' turning then the arrival state is set to false.

                        mov     p1,par
                        add     p1,#have_arrived_ 
                        mov     whl_type,#RIGHT_WHEEL
                        call    #get_arrival
                        mov     r2,rxdata
                        mov     whl_type,#LEFT_WHEEL
                        call    #get_arrival
                        and     rxdata,r2                             
                        wrlong  rxdata,p1       'Save arrival state
                                    
                        ' Get wheel speeds.
                                                  
                        mov     p1,par
                        add     p1,#right_wheel_spd_
                        mov     txdata,#QSPD|RIGHT_WHEEL
                        call    #transmit
                        call    #rcv_wrd
                        mov     r1,dat_wrd      'r1 = right wheel speed
                                             
                        mov     p2,par    
                        add     p2,#left_wheel_spd_  
                        mov     txdata,#QSPD|LEFT_WHEEL
                        call    #transmit
                        call    #rcv_wrd        'dat_wrd = left wheel speed

                        call    #store_data
                        
                        ' Get wheel positions.

                        mov     p1,par
                        add     p1,#right_wheel_pos_
                        mov     txdata,#QPOS|RIGHT_WHEEL
                        call    #transmit
                        call    #rcv_wrd
                        mov     r1,dat_wrd     'r1 = right wheel position    

                        mov     p2,par
                        add     p2,#left_wheel_pos_
                        mov     txdata,#QPOS|LEFT_WHEEL
                        call    #transmit
                        call    #rcv_wrd       'dat_wrd = left wheel position
                        call    #store_data
                        
                        mov     rwpos,r1       'Save current positions
                        mov     lwpos,dat_wrd             

                        ' If the auto_trvl flag is set then check the positions
                        ' of both wheels.  If a wheel is beyond the auto_trvl
                        ' threashold then its travel position is advanced.
                                             
                        mov     offset,#auto_trvl_
                        call    #check_flag
        if_z            jmp     #:loop11      'Jmp if auto travel mode inactive

                        mov     offset,#trvl_thrsh_rw_                          
                        mov     r2,rwpos
                        mov     whl_type,#RIGHT_WHEEL
                        call    #chk_trvl               'Check right wheel travel
                                                                          
                        mov     offset,#trvl_thrsh_lw_                          
                        mov     r2,lwpos
                        mov     whl_type,#LEFT_WHEEL
                        call    #chk_trvl               'Check left wheel travel
                                                  
                        ' Update status variable.

:loop11                 rdlong  r1,stat_ptr
                        add     r1,#1
                        wrlong  r1,stat_ptr
                        
                        ' Reset 1/4 second periodic time.
                        
                        mov     per_tm,secticks
                        shr     per_tm,#2
                        add     per_tm,cnt                        

                        ' '''''''''''''''''''''''''''''''''''''''''''''''''''''
                        ' Return to top of main processing loop.
                                                 
:loop19                 jmp     #:loop
                                                                                 
                                        
' '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Check flag Method -- This method checks the true/false state of a flag in
' main memory.
'
' Input: offset     -- request flags array offset for flag
'
' Output: zero bit  -- cleared if flag false (zero)
'         pFlag     -- pointer to flag, used to clear flag later (see end_req)
'         r3        -- flag value (sign extended)

check_flag              mov     pFlag,pReqFlags
                        add     pFlag,offset        
                        rdbyte  r3,pFlag        wz
check_flag_ret          ret
  
' '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' End Request Method -- This method terminates request processing by clearing
' the request flag and setting the event flag.  The check_flag method must
' have been called first.  It sets up the flag pointer in pFlag.
'
' Input: pFlag -- pointer to flag

end_req                 wrbyte  r0,pFlag
                        mov     event,#1
end_req_ret             ret

' '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Check Auto Travel Method -- This method is called when the auto travel mode
' is active.  If the designated wheel is beyond its travel threashold then it
' is commanded to travel.  This is done to prevent the wheel from stopping.
'
' Input: offset   -- offset for wheel travel threashold value
'        whl_type -- RIGHT_WHEEL or LEFT_WHEEL
'        r2       -- signed wheel position
'        r3       -- auto_trvl flag (1 for forward and 2 for reverse)

chk_trvl                mov     p1,par
                        add     p1,offset
                        rdlong  r1,p1                 'r1 = travel threashold                                                                                    
                        mov     dat_wrd,#TRVL_THRSH   'dat_wrd = travel units
                        
                        ' The wheel is within 100 encoder units of its end
                        ' position so we need to tell it to travel again.  When
                        ' in reverse the travel data word is negative. The
                        ' wheel's travel threashold is advanced for the next
                        ' check.                                                                                

                        cmps    r3,#2           wz
        if_z            jmp     #:chk_trvl1           'Jmp if reverse
                                                              
                        shl     r2,#16
                        shr     r2,#16
                        cmps    r2,r1           wc
        if_c            jmp     chk_trvl_ret          'Jmp if not travel time                                                             
                        call    #travel               'Travel forward
                        jmp     #:chk_trvl2

:chk_trvl1              cmps    r2,r1           wc
        if_nc           jmp     chk_trvl_ret          'Jmp if not travel time
                        neg     dat_wrd,dat_wrd                                                            
                        call    #travel               'Travel in reverse
                                                                                           
:chk_trvl2              add     r1,dat_wrd                        
                        wrlong  r1,p1                 'Save next threashold

                        mov     r1,#1
                        wrlong  r1,stat_ptr

chk_trvl_ret            ret

' '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Get Data Word Method -- This method will read a word of data from main
' memory.  Note that it is actually a long that is read.
'
' Input: offset   -- par offset for data word
'
' Output: dat_wrd -- data word
'         pData   -- pointer to data word

read_wrd                mov     pData,par
                        add     pData,offset
                        rdlong  dat_wrd,pData
read_wrd_ret            ret
                                                                                 
' '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Store Data Method -- This method will extend the sign of two 16 bit values
' and store them in global memory.  The writting of the data is mutexed.
'
' Inputs: r1 and dat_wrd -- two 16 bit signed numbers
'         p1 and p2      -- pointers to global memory

store_data              shl     r1,#16          'Extend sign bits
                        sar     r1,#16
                        shl     dat_wrd,#16
                        sar     dat_wrd,#16

:lock1                  lockset mutexid         wc
        if_c            jmp     #:lock1
                                                           
                        wrlong  r1,p1           'Store data 
                        wrlong  dat_wrd,p2   
                                
                        lockclr mutexid
                        
store_data_ret          ret

' '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Transmit Data Word Method -- This method will transmit a word to the
' Position Controllers.  As per protocol the upper byte is sent first.
'
' Input: dat_wrd -- 16 bit word to transmit

xmt_wrd                 mov     txdata,dat_wrd
                        shr     txdata,#8
                        call    #transmit              'Xmit upper byte
                        mov     txdata,dat_wrd
                        call    #transmit              'Xmit lower byte
xmt_wrd_ret             ret

' '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Receive Data Word Method -- This method will receive a word from the
' Position Controllers.  As per protocol the upper byte is received first.
'
' Output: dat_wrd -- 16 bit word

rcv_wrd                 mov     dat_wrd,#0
                        call    #receive                'Rcv upper
                        mov     dat_wrd,rxdata
                        call    #receive                'Rcv lower
                        shl     dat_wrd,#8
                        add     dat_wrd,rxdata          'Make data word 
rcv_wrd_ret             ret

' '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Get Arrival State Method -- This method will send a request for arrival state
' to a Position Controller.
'
' Input: whl_type -- RIGHT_WHEEL or LEFT_WHEEL
'
' Output: rxdata  -- Arrival state (0 = not arrived, -1 = have arrived)
                        
get_arrival             mov    txdata,whl_type
                        or     txdata,#CHFA
                        call   #transmit                'Xmit arrival request                                                                 
                        mov     txdata,#ARRIVAL_TOL
                        call    #transmit               'Xmit tolerance                        
                        call    #receive                'Receive state
get_arrival_ret         ret
                    
' '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Travel Method -- This method will send a travel command to the Position
' Controllers.
'
' Inputs: whl_type -- ALL_WHEELS, RIGHT_WHEEL or LEFT_WHEEL
'         dat_wrd  -- units to travel

travel                  mov     txdata,#TRVL
                        add     txdata,whl_type
                        call    #transmit               'Xmit travel command
                        call    #xmt_wrd                'Xmit distance word
travel_ret              ret

' ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Set Wheel Max Speed Method  -- This method will send a Max Speed command to
' the Postion Controllers.
'
' Inputs: whl_type -- ALL_WHEELS, RIGHT_WHEEL or LEFT_WHEEL
'         dat_wrd  -- wheel 16 bit max speed (positions per .5 sec)

set_spd                 mov     txdata,#SMAX
                        add     txdata,whl_type
                        call    #transmit               'Xmit max speed command
                        call    #xmt_wrd                'Xmit max speed word
set_spd_ret             ret

' ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Set Wheel Ramp Speed Method -- This method will send a Ramp Speed command to
' the Postion Controllers.
'
' Inputs: whl_type -- ALL_WHEELS, RIGHT_WHEEL or LEFT_WHEEL
'         dat_wrd  -- wheel 8 bit ramp speed (positions per .5 sec per .5 sec)

set_rmpspd              mov     txdata,#SSRR
                        add     txdata,whl_type
                        call    #transmit               'Xmit ramp spd command
                        mov     txdata,dat_wrd
                        call    #transmit               'Xmit ramp spd byte
set_rmpspd_ret          ret
                        
' '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Receive Method -- This method will input one byte of data from the Position
' Controller(s).  It will block until the byte has been received.
'
' Output: rxdata -- received data byte

receive                 ' Wait for start bit.

                        waitpeq r0,iomask
        
                        ' Initialize bit timer to middle of next bit.
                        
                        mov     iobits,#9                                            
                        mov     iocnt,bitticks
                        shr     iocnt,#1
                        add     iocnt,bitticks
                        add     iocnt,cnt                          

                        ' Loop until stop bit has been received.
                        
:receive2               waitcnt iocnt,bitticks          'Wait for next bit
                        test    iomask,ina      wc      'Get bit from input pin
                        rcr     rxdata,#1
                        djnz    iobits,#:receive2
                        
                        ' Adjust and extract received data byte.
                        
                        shr     rxdata,#23
                        and     rxdata,#$FF
                        mov     xmt_delay,cnt                                                                                          
receive_ret             ret                    'Return received byte in rxdata


' '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Transmit Method -- This method will transmit 1 byte of data to the Position
' Controllers.
'
' Input: txdata -- byte to be transmitted

transmit                or      dira,iomask             'Set direction for output

                        ' We delay here because the Position Controllers cannot
                        ' receive data as fast as we can send it.  The xmt_delay
                        ' register is set to 'cnt' at the end of each receive
                        ' or transmit.  If it has been longer than 1/2024 second
                        ' since the last receive or transmit then there will be
                        ' no delay.
                                                                                   
                        mov     iocnt,secticks
                        shr     iocnt,#11               '1/2024 sec delay          
                        add     xmt_delay,iocnt

:xmit1                  mov     iocnt,xmt_delay
                        sub     iocnt,cnt
                        cmps    iocnt,#0        wc
        if_nc           jmp     #:xmit1                 'Jmp if need to delay
                        
                        ' Add start and stop bits to byte.
                        
                        and     txdata,#$FF
                        or      txdata,#$100
                        shl     txdata,#2
                        or      txdata,#1
                                                                                                                        
                        ' Prepare bit xmit counters.
 
                        mov     iobits,#11                         
                        mov     iocnt,bitticks                        
                        add     iocnt,cnt

                        ' Transmit data byte.
                                                
:xmit2                  shr     txdata,#1       wc
                        muxc    outa,iomask
                        waitcnt iocnt,bitticks  
                        djnz    iobits,#:xmit2
                         
                        ' Byte has been transmited. 
                        
                        cmp     r0,#1           wz
                        muxz    dira,iomask             'Set direction for input
                        mov     xmt_delay,cnt
transmit_ret            ret
                                              
                        
' '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Wheel Controller data registers:

r0                      res     1               'Always contains zero
r1                      res     1               'General purpose registers
r2                      res     1
r3                      res     1

p1                      res     1               'General purpose pointers
p2                      res     1

xmt_delay               res     1               'Transmit delay counter
pReqFlags               res     1               'Request Flags arrary pointer
pData                   res     1               'Data pointer
pFlag                   res     1               'Flag pointer
mutexid                 res     1               'Mutex Id
offset                  res     1               'Data/Flag par offset
iomask                  res     1               'I/O pin mask
secticks                res     1               'Ticks per second
bitticks                res     1               'Ticks per I/O bit
rxdata                  res     1               'Receive data byte
txdata                  res     1               'Transmit data byte
iobits                  res     1               'I/O pin mask
iocnt                   res     1               'I/O time counter
whl_type                res     1               'Current wheel type
dat_wrd                 res     1               'Xmit/Rcv data word
per_tm                  res     1               'Periodic processing time
per_ticks               res     1               'Periodic ticks
event                   res     1               'Event flag
stat_ptr                res     1               'Pointer to status variable
rwpos                   res     1               'Right wheel position
lwpos                   res     1               'Left wheel position