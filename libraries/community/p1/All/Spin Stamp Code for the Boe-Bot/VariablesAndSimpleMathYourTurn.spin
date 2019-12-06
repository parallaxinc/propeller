''Robotics with the Boe-Bot - VariablesAndSimpleMathYourTurn.spin
''Declare variables and use them to solve a few arithmetic problems.

CON
   
  _clkmode = xtal1 + pll8x
  _xinfreq = 10_000_000
  CR = 13

VAR

  long value, anotherValue                         ' Declare variables
  
OBJ
   
  Debug: "FullDuplexSerialPlus"
   
   
PUB VariablesAndSimpleMathYourTurn
 
  Debug.start(31, 30, 0, 9600)

  value := 500                                     ' Initialize variables
  anotherValue := 2000

  Debug.str(string("value = "))                    ' Display values 
  Debug.dec(value)
  Debug.str(string(CR, "anotherValue = "))
  Debug.dec(anotherValue)

  value := value - anotherValue                    ' Answer = -1500

  Debug.str(string(CR, "value = "))                ' Display values again 
  Debug.dec(value)
  Debug.str(string(CR, "anotherValue = "))
  Debug.dec(anotherValue)
  
'********************************************************************************************  

' Robotics with the Boe-Bot - VariablesAndSimpleMathYourTurn.bs2
' Declare variables and use them to solve a few arithmetic problems.

' {$STAMP BS2}
' {$PBASIC 2.5}

'value         VAR Word                            ' Declare variables
'anotherValue  VAR Word

'value = 500                                       ' Initialize variables
'anotherValue = 2000

'DEBUG ? value                                     ' Display values
'DEBUG ? anotherValue

'value = value - anotherValue                      ' Answer = -1500

'DEBUG "value = ", SDEC value, CR                  ' Display values again
'DEBUG ? anotherValue

'END