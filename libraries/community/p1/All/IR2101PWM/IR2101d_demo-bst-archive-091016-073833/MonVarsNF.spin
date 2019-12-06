'' MonitorVars, program to show variables on video screen, leaving main program free to run fast
'' three per line, seperated with commas by groups of three
' Eric Ratliff, 2008_3_x to 2008_4_2
' Eric Ratliff, 2008.6.7 eliminating flicker by using modified version of TV_Termainal
OBJ
  Num   :       "Numbers"       ' string manipulations
  TV    :       "TV_terminalHoming"   ' video display

VAR
  long IncTime_C
  byte RunningCogID   ' ID of started cog, -1 code shows failure to start
  long Stack[100]     ' space for new cog, no idea how much to allocate
  byte EverRun        ' flag to show object has been used at least once
  byte VarIndex       ' offset of long variable we are currently painting

PUB Start(pMem,Quantity): NewCogID                      '' start a monitor cog
  Stop                        ' stop any cog that may already be running
  ' start a mew cog and retain it's ID or failure code
  RunningCogID := cognew(Run(pMem,Quantity),@Stack)
  NewCogID := RunningCogID      ' report the results to calling object

PUB Stop                        '' to stop any possible running monitor cog
  if EverRun
    if RunningCogID => 0        ' is there a cog already running?
      cogstop(RunningCogID)     ' place running cog in dormant state
  RunningCogID := -1            ' place code like that returned when a cog fails to start
  EverRun := TRUE

PRI Run(pMemBegin,QtyToShow)    ' routine that formats and outputs the numbers to the screen until stopped externally
  Num.Init                      ' start the string manupulation object
  TV.Start(12)                  ' start TV video object with specified base pin.  Pin 12 is the base pin in the dev board

  'IncTime_C := 500000
  IncTime_C := clkfreq/20

  ' three times 14 just happens to be number of characters on a line, no LF needed, no counting of variables on line needed
  repeat
    VarIndex := 0
    TV.home                                           ' return to top left
    repeat
      TV.Str(Num.ToStr(LONG[pMemBegin + VarIndex << 2], Num#DSDEC14)) ' show result of the arithmatic, delimited decimal, groups 1000's with commas
      VarIndex++
    while VarIndex < QtyToShow
    waitcnt(IncTime_C + cnt) 'wait a little while before next update

  