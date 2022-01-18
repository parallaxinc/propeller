{
  Project: EE-8 Practical 1
  Platform: Parallax Project USB Board
  Revision: 1
  Author: Muhammad Syamim
  Date: 17th Nov 2021
  Log:
    Date: Desc
    v1
    17/11/21:   Added UART Communication OBJ using zigBee pins and baudrate
    v1.1
    22/11/21:   Synced Milliseconds within OBJs
    v1.2
    24/11/21:   Delegated new cog for op-code processing
}
CON
        _clkmode = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq = 5_000_000

        comRx = 20
        comTx = 21
        comBaud = 9600

        comStart = $7A
        comForward = $01
        comReverse = $02
        comTurnLeft = $03
        comTurnRight = $04
        comStopAll = $AA

VAR
  long _Ms_001
  long CommCogID, CommCogStack[64]

OBJ
  Comm  : "FullDuplexSerial.spin"                                               'UART Communication for control

PUB Init(DirPtr , RDYPtr, MsVal)                                                'Initialise Core for Communications

  _Ms_001 := MsVal                                                              'Sync time delays
  StopCore                                                                      'Prevent stacking drivers
  CommCogID := cognew(Start(DirPtr, RDYPtr), @CommCogStack)                     'Initialise new cog with Start method

  return CommCogID

PUB Start(DirPtr, RDYPtr) | rxVal                                               'Looping code for Op-Code update

  Comm.Start(comRx, comTx, 0, comBaud)                                          'Start new cog for UART Communication with ZigBee
  BYTE[RDYPtr]++                                                                'Update Ready Byte

  repeat
    rxVal := Comm.rx                                                            'Wait until incomming BYTE
    if rxVal == comStart                                                        'Protocol starts with start BYTE
      comm.dec(rxval)
      rxVal := Comm.rx                                                          'Retrieve direction BYTE
      case rxVal                                                                'Update direction using Op-Code
        comForward:
          BYTE[DirPtr] := 1
        comReverse:
          BYTE[DirPtr] := 2
        comTurnRight:
          BYTE[DirPtr] := 3
        comTurnLeft:
          BYTE[DirPtr] := 4
        comStopAll:
          BYTE[DirPtr] := 0

PUB StopCore                                                                    'Stop active cog
  if CommCogID                                                                  'Check for active cog
    cogStop(CommCogID~)                                                         'Stop the cog and zero out ID
  return CommCogID

PRI Pause(ms) | t
  t := cnt - 1088
  repeat (ms #> 0)
    waitcnt(t += _Ms_001)
  return