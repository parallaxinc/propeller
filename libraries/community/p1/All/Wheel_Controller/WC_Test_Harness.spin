'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'' WC_TestHarness.spin
''
'' This test harness is designed to exercise the Wheel Controller object.
''
'' The cart uses a Propeller Education Kit board with:
''
''      1. Push button on pin zero
''      2. Red LED on pin 2
''      3. Green LED on pin 3
''      2. Position Controllers on pin 27
''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

CON
   
  _clkmode = xtal1 + pll16x      ' Crystal feedback & PLL multiplier
  _xinfreq = 5_000_000           ' 5 MHz crystal

  START_BUTTON = 0
  RED_LED = 2
  GREEN_LED = 3

VAR

  ' Global Variables:

  long WC_Stat                  ' Wheel Controller Status
  word RobotSpeed
  long loop_cnt
  long FreezeCount
  long LastStatus 
  long Delta
  long Val
  
OBJ
                        
  WCtrl: "Wheel_Controller"

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'' Main Entry

PUB MAIN | success

  dira~
  outa~
  dira[RED_LED..GREEN_LED]~~    ' Set LED pins to output
                           
  FreezeCount := 0
  LastStatus := 0
                 
  waitcnt(clkfreq + cnt)
           
  success := WCtrl.open(27)     ' Initialize Wheel Controller
  if success == FALSE 
    repeat
      outa[RED_LED] := 1
      waitcnt(clkfreq/2 + cnt)
      outa[RED_LED] := 0
      waitcnt(clkfreq/2 + cnt)
                                                      
  waitcnt(clkfreq + cnt)  

  ' Loop forever.
    
  repeat

    ' Turn on the Red LED to indicate that we are stopped.
    
    outa[RED_LED] := 1
    outa[GREEN_LED] := 0 

    ' Wait for the Start Button to be pressed.
    
    repeat
      waitcnt(clkfreq/4 + cnt)
      if ina[START_BUTTON]
        if WC_Stat == 0

          ' This is the first time the Start Button has been pressed
          ' so the Wheel Controller is started.
          
          WCtrl.start    
          waitcnt(clkfreq + cnt)
          WC_Stat := WCtrl.get_Status
        QUIT
      Check_Status  

    ' Turn on Green LED to indicate we are moving.
                 
    outa[RED_LED] := 0                          
    outa[GREEN_LED] := 1
     
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''                                                           
'' The following test will command each wheel to go 200 encode units.
{   
    WCtrl.travel_units(200, WCtrl#RIGHT_WHEEL)
    WaitForArrival
     
    WCtrl.travel_units(200, WCtrl#LEFT_WHEEL)
    WaitForArrival
}    
                             
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''                                                           
'' The following test will travel in a five foot square with a 360 degree
'' right turn at the start and a 270 degree left turn at the end:
                                             
    WCtrl.set_WheelSpeed(WCtrl#ALL_WHEELS, 176) ' 2 mile/hour
            
    WCtrl.spin_turn(WCtrl#LEFT_TURN, 360)
    WaitForArrival
                                            
    WCtrl.go_Distance(60, WCtrl#FORWARD)
    WaitForArrival
                                                   
    WCtrl.spin_turn(WCtrl#RIGHT_TURN, 90)
    WaitForArrival
                                              
    WCtrl.go_Distance(60, WCtrl#FORWARD)
    WaitForArrival
                                                   
    WCtrl.spin_turn(WCtrl#RIGHT_TURN, 90)
    WaitForArrival
                                            
    WCtrl.go_Distance(60, WCtrl#FORWARD)
    WaitForArrival
                                                   
    WCtrl.spin_turn(WCtrl#RIGHT_TURN, 90)
    WaitForArrival
                                              
    WCtrl.go_Distance(60, WCtrl#FORWARD)
    WaitForArrival
                                                     
    WCtrl.spin_turn(WCtrl#LEFT_TURN, 270)
    WaitForArrival
  
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'' The following test will:
''
''    1. Set speed to 100 ft/min
''    2. Go forward
''    3. Turn to the right until the right wheel stops
''    4. Turn back to the left until the left wheel stops
''    5. Stop all wheels
''    6. Wait for all wheels to come to a complete stop
{      
    WCtrl.set_WheelSpeed(WCtrl#ALL_WHEELS, 100)  'Set speed to 100 ft/min
    Delta := 10 
    Val := 0      
    WCtrl.go_Distance(2000, WCtrl#FORWARD)  'Go forward for long distance
    
    repeat
      waitcnt(clkfreq/2 + cnt)
      Val += Delta 
      WCtrl.turn(Val)
      if Val => 100
        Delta := -10
      elseif Val =< -100
        quit
                              
    WCtrl.stop 
    WaitForArrival
}                                
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'' The following test will:
''    1. travel forward for 4 seconds
''    2. travel backward for 4 seconds
''    3. spin turn 360 degrees to the left
                                                         
    loop_cnt := 0       
    WCtrl.go_Distance(2000, WCtrl#FORWARD)
    repeat
      waitcnt(clkfreq + cnt)
      loop_cnt++
      if loop_cnt == 4
        quit
    WCtrl.stop 
    WaitForArrival
                                                           
    loop_cnt := 0       
    WCtrl.go_Distance(2000, WCtrl#REVERSE)
    repeat
      waitcnt(clkfreq + cnt)
      loop_cnt++
      if loop_cnt == 4
        quit
    WCtrl.stop 
    WaitForArrival
                                                         
    WCtrl.spin_turn(WCtrl#LEFT_TURN, 360) 
    WaitForArrival
   
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'' The following test will:
''     1. set speed to one mile per hour
''     2. start forward
''     3. at 2 seconds increase speed to two miles per hour
''     4. at 4 seconds increase speed to three miles per hour
''     5. at 6 seconds decrease speed to two miles per hour
''     6. at 8 seconds decrease speed to one mile per hour
''     3. at 10 seconds stop
{                                                             
    WCtrl.set_WheelSpeed(WCtrl#ALL_WHEELS, 88)
    
    loop_cnt := 0       
    WCtrl.go_Distance(2000, WCtrl#FORWARD)
    repeat
      waitcnt(clkfreq + cnt)
      loop_cnt++
      if loop_cnt == 2                                        
        WCtrl.set_WheelSpeed(WCtrl#ALL_WHEELS, 176)  
      elseif loop_cnt == 4                                    
        WCtrl.set_WheelSpeed(WCtrl#ALL_WHEELS, 264) 
      elseif loop_cnt == 6                                    
        WCtrl.set_WheelSpeed(WCtrl#ALL_WHEELS, 176) 
      elseif loop_cnt == 8                                    
        WCtrl.set_WheelSpeed(WCtrl#ALL_WHEELS, 88)
      elseif loop_cnt == 10
        quit
    WCtrl.stop 
    WaitForArrival                      
}                                                                                 

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'' The following test will move the cart in a arc to the right and then to
'' the left.
                                                                           
    WCtrl.set_WheelSpeed(WCtrl#ALL_WHEELS, 0)    
    WCtrl.turn(0)                                                                          
    WCtrl.set_WheelSpeed(WCtrl#ALL_WHEELS, 100) 
    WCtrl.turn(20)                               
    WCtrl.go_Distance(60, WCtrl#FORWARD)
    WaitForArrival
                                                  
    WCtrl.turn(-20)                              
    WCtrl.go_Distance(60, WCtrl#FORWARD)
    WaitForArrival
    WCtrl.turn(0)
                                     
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'' The following test will test the throttle during a straight run:
''
''    1. Set speed to zero
''    2. Go forward
''    3. Throttle up to 120 percent 
''    4. Stop all wheels
''    5. Wait for all wheels to come to a complete stop
              
 {
    WCtrl.set_WheelSpeed(WCtrl#ALL_WHEELS, 0)
    Delta := 5 
    Val := 0      
    WCtrl.go_Distance(2000, WCtrl#FORWARD)  'Go forward for long distance
    
    repeat
      waitcnt(clkfreq + cnt)
      Val += delta
      WCtrl.throttle(val)
      if Val => 120
        quit
                              
    WCtrl.stop 
    WaitForArrival 
}

''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'' The following test will test the throttle during a turn:
''
''    1. Set speed to zero
''    2. Set turn bias to 25 percent
''    2. Go forward
''    3. Throttle up to 120 percent 
''    4. Stop all wheels
''    5. Wait for all wheels to come to a complete stop
{              
    WCtrl.set_WheelSpeed(WCtrl#ALL_WHEELS, 0)
    Delta := 5 
    Val := 0 
    WCtrl.turn(25)      
    WCtrl.go_Distance(2000, WCtrl#FORWARD)  'Go forward for long distance
    
    repeat
      waitcnt(clkfreq + cnt)
      Val += Delta
      WCtrl.throttle(Val)
      if Val => 120
        quit
                              
    WCtrl.stop 
    WaitForArrival
}        
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'' This method will wait for the arrival flag to get set.  It will periodically
'' ckeck the Wheel Controller Cog to determine if it has failed.

PRI WaitForArrival

  repeat

    ' Wait or do other processing.   
         
    waitcnt(clkfreq/4 + cnt)
    
    if WCtrl.arrival_check <> 0
      quit
      
    Check_Status

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'' Check Status Method -- this method will determine if the Wheel Controller Cog
'' has stopped.  If it has stopped then the Red LED is flashed and any further
'' processing suspended.  This will most likely be caused by a low battery
'' condition.  A user may not want to stop here but instead go on to some sort of
'' recovery processing.
''
'' Note that calling the Wheel Controller 'start' method will reset it.

PRI Check_Status | r1

  r1 := WCtrl.get_Status
  if r1 == 0
    return                      ' Wheel Controller not started yet
  
  if r1 == LastStatus
    FreezeCount++
    if FreezeCount == 6  

    ' Wheel Controller Failure
      
      outa[RED_LED] := 1
      outa[GREEN_LED] := 0
      repeat
        outa[RED_LED] := 1
        waitcnt(clkfreq/2 + cnt)
        outa[RED_LED] := 0 
        waitcnt(clkfreq/2 + cnt)
  else                     
    FreezeCount := 0
             
  LastStatus := r1