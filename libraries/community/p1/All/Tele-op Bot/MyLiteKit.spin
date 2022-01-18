{
  Project: EE-9 Practical 1
  Platform: Parallax Project USB Board
  Revision: 1.1
  Author: Muhammad Syamim
  Date: 14th Nov 2021
  Log:
    Date: Desc
    v1
    14/11/21:   Added Cog bootstrapping & stop flag

    v1.1
    16/11/21:   Offloaded conditional checks and direction control to cog 0
                for futureproof modularity
    v1.2
    17/11/21:   Added delay for bootstrapping
                Added ZigBee driver
    v1.3
    23/11/21:   Streamlined operation directive & conditional checks
                Stop flag to array to accomodate directional stop
    v1.4
    24/11/21:   Adjusted Ultrasonic Sensor range to account for echo loss
    v1.5
    26/11/21:   Added Speed setting
    ===========================================================         |            Delays to note:
    |   Cog 0   |  Cog 1  |  Cog 2  |  Cog 3  |     Cog 4     |         |            Motor Driver Boot time: 2s
    | Behaviour | Sensor  |  Motor  | Op-code |  ZigBee UART  |         |            Communication Driver Boot time: 1s
    |  Control  | Polling | Control |  Sync   | Communication |         |            Ultrasonic Sensor Poll rate: 40ms / Sensor
    |           |         |         |         |               |         |
    ===========================================================         |
}
CON
        _clkmode = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq = 5_000_000
        _ConClkFreq = ((_clkmode - xtal1) >> 6) * _xinfreq
        _Ms_001 = _ConClkFreq / 1_000

        ToFStop = 230

VAR

  long  MCID, SCID, CCID                                                        'cogID for tracking
  BYTE  RDY, Dir, FSpd, RSpd                                                    'Ready, Direction, Forward & Reverse speed flag
  long  F_Ult, R_Ult, F_ToF, R_ToF                                              'Storage for sensor values
  BYTE  Stop[3]                                                                 'Stop byte array | 0 = EStop, 1 = Front Stop, 2 = Rear Stop

OBJ

  'Term          : "FullDuplexSerial.spin"                                       'UART communication
  Sensor        : "SensorControl.spin"                                          'Ultrasonic and ToF Sensors
  Motor         : "MotorControl.spin"                                           'RoboClaw Motor Driver
  Comm          : "CommControl.spin"                                            'ZigBee Driver

PUB Main                                                                        'Lite Kit Semi-Autonomous Land based Tele-operated Vehicle
  'Initilisation
  SCID := Sensor.Init(@F_Ult, @R_Ult, @F_ToF, @R_ToF, @RDY, _Ms_001)            'Initialise Sensor Driver
  MCID := Motor.Init(@Stop, @Dir, @FSpd, @RSpd, @RDY, _Ms_001)                  'Initialise Motor Driver
  CCID := Comm.Init(@Dir, @RDY, _Ms_001)                                        'Initialise Control Driver
  repeat while RDY < 3                                                          'Wait for bootstrapping
  Pause(100)                                                                    'Account for intital sensor poll
  FSpd := 30
  RSpd := 30
  repeat until Stop[0]                                                          'Update instructions | 100ms polling time
    'EStop                                                                       'Emergency Condition
    ObjDetect                                                                   'Obstacle condition
    'SetSpd                                                                      'Update Speed Setting
  MCID := Motor.StopCore                                                        'Disengage Motor cog
  Motor.StopAllMotors                                                           'Ensure all motor stopped

  repeat                                                                        'Suspend cog 0

PRI SetSpd                                                                      'Speed Control

  if F_Ult > 1500 OR F_Ult == 0                                                 'Check special case (debouncing yet to be implemented)
    FSpd := 75                                                                  'Double instance of 0, > 2m & Exact 0m
  elseif F_Ult > 1000
    FSpd := 50
  else
    FSpd := 25
  if R_Ult > 1500 OR R_Ult == 0                                                 'Check special case (debouncing yet to be implemented)
    RSpd := 75                                                                  'Double instance of 0, > 2m & Exact 0m
  elseif R_Ult > 1000
    RSpd := 50
  else
    RSpd := 25

  return

PRI ObjDetect                                                                   'Object Detection

  if (F_Ult > 0 AND F_Ult < 300) OR F_ToF > ToFStop                             'Front Object and Ditch condition
    Stop[1] := TRUE
  else
    Stop[1] := FALSE

  if (R_Ult > 0 AND R_Ult < 300) OR R_ToF > ToFStop                             'Rear Object and Ditch condition
    Stop[2] := TRUE
  else
    Stop[2] := FALSE

  return

PRI EStop                                                                       'Emergency stop condition check (Not in use)
  if F_Ult < 200 OR R_Ult < 200' OR F_ToF > 250 OR R_ToF > 250
    Stop[0] := TRUE

  return

PRI Pause(ms) | t
  t := cnt - 1088
  repeat (ms #> 0)
    waitcnt(t += _Ms_001)

  return