
OBJ   
  EL  : "EventLogger"
  vp  : "Conduit"

CON
  ' Set clock to 80Mhz
  _CLKMODE      = XTAL1 + PLL16X
  _XINFREQ      = 5_000_000        ' 5MHz Crystal

                  
VAR
  long  reDo
  long  E0
  long  E1
  long  E2
  long  E3
  long  E4
  long  E5
  long  E6
  long  Etail
  
  long  elog[EL#BUFFER_SIZE]

  
PUB Main | i

'' Begin ViewPort configuration...

  ' Name the "channel" that is about to be created and shared with ViewPort
  vp.config(string("var:elog"))       ' This exact name (including case) is required.
  ' Create an array type 5 "channel" -- share elog[] with ViewPort
  vp.array( @elog, EL#BUFFER_SIZE, 5) ' elog[] must have this exact size! (and the 5 is reqd).

  ' The Event Logger client recieves this array via DDE from ViewPort by name. That is why
  ' you must adhere to the elog name.  The client also validates the connection by checking
  ' the size of the elog array, hence the requirement for an exact size.
  
{{  
   Any other Viewport config strings would go here.
}}
  
  ' Name the variable "channels" that are about to be shared with ViewPort.
  vp.config(string("var:reDo,E0,E1,E2,E3,E4,E5,E6,Etail")) 
  ' Create the variables "channels" and share them with ViewPort -- THIS STATEMENT MUST BE LAST !!
  vp.share( @reDo,@Etail)

'' End ViewPort configuration

'' Begin EventLogger initialization and configuration

  EL.initialize( @elog )  ' Starts the EventLogger in a cog  and defaults Nevents to 99 and Ntrigs to 1 

  ' The parameters that control the capture sequence can be modified from the Event Logger Client,
  ' but it is best to put a basic set directly in the code.  There is a configuration wizard in
  ' Client to help with configuration changes (there is a copy to clipboard function -- then paste here)
 
  EL.setEventPinsMask  ( $C000_0000 )  ' Monitor P31 (rx) and P30 (tx)  
  EL.setTriggerPinsMask( $4000_0000 )  ' P30 (tx) supplies the trigger
  EL.setTriggerState0  ( $0000_0000 )  ' Set trigger event to be a rising edge on P30
  EL.setTriggerState1  ( $4000_0000 )

'' End EventLogger configuration

'' Your code starts here, but note the accomodation for cog restart and capture finish.  You
'' may or may not need either one, but if you have a convenient place for them, it is
'' recommended that you do so.
                                                           
repeat

  ' If the event logger cog gets hungup waiting for a trigger event that may never occur,
  ' the user can request a cog restart from the GUI.  Then he can reconfigure the
  ' trigger setup.
  if elog[0] == EL#COG_RESTART_REQUEST
    EL.restart

  ' Sometimes one may be looking to capture n events, and n events don't occur.  In this
  ' case, the user can request that artificial events be created by toggling a free pin
  ' that normally doesn't change state but IS included in the event mask.  You have to
  ' plan ahead to use this capability.  Here I allocated P2 to escape an event-starved
  ' capture sequence
  if elog[0] == EL#FINISH_CAPTURE_REQUEST
    Repeat 99 ' Create 99 artificial events to force capture sequence to complete
      Outa[2] := 0
      Outa[2] := 1

  ' Copy elog header info to where we can watch them with ViewPort
  
  E0 := elog[0]  ' runState   (cog control word)
  E1 := elog[1]  ' eMask      (event pin selections)
  E2 := elog[2]  ' nEvents    (number of events to capture 1..99)
  E3 := elog[3]  ' tMask      (trigger pin selection)
  E4 := elog[4]  ' tState0    (trigger state 0)
  E5 := elog[5]  ' tState1    (trigger state 1)
  E6 := elog[6]  ' nTrigs     (number of triggers before capture start)
  Etail := elog[EL#BUFFER_SIZE-1]
  
  
      
      