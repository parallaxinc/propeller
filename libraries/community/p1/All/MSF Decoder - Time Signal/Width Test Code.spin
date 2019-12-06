{MSF Off-Air Clock Data Decoder

 Richard G3CWI June 2012

Use with http://www.pvelectronics.co.uk/index.php?main_page=product_info&products_id=2}

CON
        _clkmode = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq = 5_000_000

        ThisYear = 2012 'Used for error checking
        MSF_In   = 14   'MSF Data input pin

VAR
  long  NegPulse
  Long  A[59], B[59]
  Long  Year, Month, Date, Day, Hour, Mn
  Long  MonthTxt, DayTxt, Error
   
OBJ
  DB      : "Debug_LCD03"
  
PUB Main | Start, Stop, Period, i, T1, T2, T3

DB.Start(15,9600,4)
DB.Backlight(true)
DB.cls
DB.cursor(0)
DB.str(string("Waiting for start..."))

  Repeat
  
          Repeat until NegPulse > 450 'Detect 500ms negative start pulse
            waitpeq(|< MSF_In, |<MSF_In, 0)
            Start := cnt
            waitpne(|< MSF_In, |<MSF_In, 0)
            Stop := cnt
            NegPulse := (Stop-Start) / (clkfreq/1_000)            

          If Date == 0 'only first time after start
            DB.cls
            DB.Str(string("Start detected."))
            DB.NL
            DB.Str(string("Gathering data.")) 
            
          NegPulse := 0 'reset start pulse detector
          
          wait(610) 'Wait until start of first databit + 10mS
       
          Repeat i from 1 to 59

            T1   := INA[MSF_In]   '2 tries
            wait(10)              'delay
            T2   := INA[MSF_In]
            
            A[i] := T1 * T2       '0 if not same
              
            Wait(90)              'wait for next data bit
            
            T1   := INA[MSF_In]   '2 tries
            wait(10)              'delay
            T2   := INA[MSF_In]
         
            B[i] :=  T1 * T2      '0 if not same 
                                
            If i <> 59   'stops loop missing start pulse at end of minute
              wait (890) '890 + 5 + 5 + 5 + 5  + 90 = total loop delay 1000ms

        ErrorCheck
           
        If Error == 0
          CalcYear
          CalcMonth
          CalcDate
          CalcDay
          CalcHour
          CalcMin
                    
        Else
          Wait (490)      
          Mn := Mn + 1          
           If Mn == 60
             Mn:= 0
             Hour:= Hour + 1 
       
        DB.cls
        DB.Str(MonthTxt)
        DB.Str(string(" "))

        If Date > 31
          DB.Str(string("??"))
          Error := 1 
        Else
          DB.Dec(Date)
          
        DB.Str(string(" "))
        If Year < ThisYear
          DB.Str(string("????"))
          Error := 1  
        Else
          DB.Dec(Year)
          
        DB.NL
        
        DB.Str(DayTxt)
        DB.Str(string(" "))

        If Hour > 23
          DB.Str(string("??"))
          Error := 1 
        Else
          DB.Dec(Hour)
          
        DB.Str(string(":"))

        If Mn > 59
          DB.Str(string("??"))
          Error := 1  
        Else
           IF Mn < 10 'add leading zero
             DB.Str(String("0"))
             DB.Dec(Mn)
           Else
             DB.Dec(Mn)
           
        If Error == 1
            DB.NL
            DB.Str(string("Data Error."))

PRI Wait(ms)

Waitcnt((clkfreq/1000)*ms + cnt)

Pri ErrorCheck | Parity

 Error := 0

 Parity := B[54] ^ A[17] ^ A[18] ^ A[19] ^ A[20] ^ A[21] ^ A[22] ^ A[23] ^ A[24]
 If Parity == 0
   Error:= 1
   Return
 
 Parity := B[55] ^ A[25] ^ A[26] ^ A[27] ^ A[28] ^ A[29] ^ A[30] ^ A[31] ^ A[32] ^ A[33] ^ A[34] ^ A[35] 
 If Parity == 0
   Error:= 1
   Return
 
 Parity := B[56] ^ A[36] ^ A[37] ^ A[38]
 If Parity == 0
   Error:= 1
   Return

 Parity := B[57] ^ A[39] ^ A[40] ^ A[41] ^ A[42] ^ A[43] ^ A[44] ^ A[45] ^ A[46] ^ A[47] ^ A[48] ^ A[49] ^ A[50] ^ A[51] 
 If Parity == 0
   Error:= 1
   Return

Pri CalcMonth

  Month := A[25]*10 + A[26]*8 + A[27]*4 + A[28]*2 + A[29]

  Case Month
   1 :   MonthTxt:= string("January")
   2 :   MonthTxt:= string("February")
   3 :   MonthTxt:= string("March")
   4 :   MonthTxt:= string("April")
   5 :   MonthTxt:= string("May")
   6 :   MonthTxt:= string("June")
   7 :   MonthTxt:= string("July")
   8 :   MonthTxt:= string("August")
   9 :   MonthTxt:= string("September")
   10:   MonthTxt:= string("October")
   11:   MonthTxt:= string("November")
   12:   MonthTxt:= string("December")
   Other:MonthTxt:= string("Error")
   
Pri CalcYear
  
  Year := A[17]*80 + A[18]*40 + A[19]*20 + A[20]*10 + A[21]*8 + A[22]*4 + A[23]*2 + A[24] + 2000 
   
Pri CalcDate
  
  Date := A[30]*20 + A[31]*10 + A[32]*8 + A[33]*4 + A[34]*2 + A[35]
   
Pri CalcDay
  
  Day := A[36]*4 + A[37]*2 +A[38]
 
  Case Day
    0     :DayTxt:= string("Sunday")
    1     :DayTxt:= string("Monday")
    2     :DayTxt:= string("Tuesday")
    3     :DayTxt:= string("Wednesday")
    4     :DayTxt:= string("Thursday")
    5     :DayTxt:= string("Friday")
    6     :DayTxt:= string("Saturday")   
    Other :DayTxt:= string("Error")
   
Pri CalcHour
  
  Hour := A[39]*20 + A[40]*10 + A[41]*8 + A[42]*4 + A[43]*2 + A[44]

   
Pri CalcMin
  
  Mn := A[45]*40 + A[46]*20 + A[47]*10 + A[48]*8 + A[49]*4 + A[50]*2 + A[51]
   