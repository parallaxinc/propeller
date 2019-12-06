
CON
  MAX_EVENTS  = 99
  BUFFER_SIZE = 7 + 2*(MAX_EVENTS+1) + 1
  COG_RESTART_REQUEST = 27
  FINISH_CAPTURE_REQUEST = 22
    
VAR
  long ELogPtr
  long cog
    
PUB initialize( ELogStructAddress )
  ELogPtr := ELogStructAddress
  long[ELogPtr+0 ] := 0              'runState = 0  (idle -- parameters can be changed)
  long[ELogPtr+8 ] := MAX_EVENTS     'nEvents default
  long[ELogPtr+24] := 1              'nTrigs  default
  cog := cognew( @entry, ELogPtr ) + 1

PUB stop
  if cog
    cogstop( cog~ - 1 )

PUB restart
  if cog
    coginit(cog-1,@entry, ELogPtr)
      
PUB run
  long[ELogPtr+0]  := 1     'runState = 1 = waiting for trigger(s)
  
PUB setEventPinsMask( mask)
  long[ELogPtr+4]  := mask  'eMask     (event pins mask)

PUB setNevents( n )         'nEvents   (number of events)
  long[ELogPtr+8]  :=  1 #> n <# MAX_EVENTS

PUB setTriggerPinsMask( mask )
  long[ELogPtr+12] := mask  'tMask     (trigger pins mask)

PUB setTriggerState0( state )
  long[ELogPtr+16] := state 'tState0   (trigger state 0)

PUB setTriggerState1( state )
  long[ElogPtr+20] := state 'tState1   (trigger state 1)

PUB setNtriggers( n )
  long[ELogPtr+24] := n     'nTrigs    (num triggers to pass)   

 
DAT
                        org
                        
entry                   ' Wait for runState to change to "trigger wait"

                        add     endPtr,par      'set endPtr to point to "tail" of elog array in Hub
                        
idle                    rdlong  runState,par
                        cmp     runState,#1     wz   '1 is the command to start capture sequence 
              if_z      jmp     #setupAndRun

                        ' If elog[0] is $ff or smaller, we just copy it to "tail"  This gives users control
                        ' over the "head" and "tail" goalpost values that are used in packet consistency
                        ' tests.
                        
                        cmp     runState,#$ff   wz,wc
              if_be     wrlong  runState,endPtr                        
              if_be     jmp     #idle

                        ' If this point is reached, then elog[0] is a write word command.  This gives
                        ' the Event Logger client the ability to write to elog[n] even though the DDE
                        ' interface gives only the capability to "poke" into elog[0]
                        
                        mov     genPtr,runState
                        shr     genPtr,#16       'genPtr now contains the Hub byte offset
                        add     genPtr,par       'genPtr now points to a word in the elog[] array
                        wrword  runState,genPtr  'write the word data
                        mov     runState,#0      
                        wrlong  runState,par     'set elog[head] to 0
                        wrlong  runState,endPtr  'set elog[tail] to 0
                        jmp     #idle                                                                                                               

                        ' Grab the parameters for this capture sequence
setupAndRun             mov     parPtr,par
                        add     parPtr,#4
                        rdlong  eMask,parPtr
                        add     parPtr,#4
                        rdlong  nEvents,parPtr
                        add     parPtr,#4
                        rdlong  tMask,parPtr
                        add     parPtr,#4
                        rdlong  tState0,parPtr
                        add     parPtr,#4
                        rdlong  tState1,parPtr
                        add     parPtr,#4
                        rdlong  nTrigs,parPtr
                        add     parPtr,#4       'parPtr now points to where event data will be written (elog[7])

                        ' Fill the event capture buffer with the event capture instructions
                        mov     inst1mod,inst1ini
                        mov     inst2mod,inst2ini
                        mov     inst3mod,inst3ini
                        mov     inst4mod,inst4ini
                        mov     genPtr,#eBuff
                        mov     counter,nEvents

instFill                movd    aac1,genPtr
                        add     genPtr,#1
aac1                    mov     0-0,inst1mod
                        movd    aac2,genPtr
                        add     genPtr,#1
aac2                    mov     0-0, inst2mod
                        movd    aac3,genPtr
                        add     genPtr,#1
aac3                    mov     0-0,inst3mod
                        movd    aac4,genPtr
                        add     genPtr,#1
aac4                    mov     0-0,inst4mod
                        movd    aac5,genPtr

                        add     inst1mod,destPlus2  'add 2 to destination field
                        add     inst2mod,destPlus2
                        add     inst3mod,destPlus2
                        add     inst4mod,destPlus2

                        djnz    counter,#instFill

                        'make the last instruction in the capture sequence jump to the output routine
aac5                    mov     0-0,instFinal

                        'next, we indicate that we are waiting for the trigger conditions to be satisfied
                        add     runState,#1
                        wrlong  runState,par   'set runState to 2 (waiting for trigger)

                        'wait for trigger(s)

                        mov     counter,nTrigs
                        
trigWait                waitpeq tState0,tMask
                        waitpeq tState1,tMask
                        mov     inaVal,ina
                        mov     cntVal,cnt
                        and     inaVal,eMask
                        djnz    counter,#trigWait
                        
                        jmp     #eBuff          'go execute the event capture instructions

writeBuffToHub          mov     counter,nEvents
                        add     counter,#1      'account for event 0 that followed trigger
                        shl     counter,#1      'and we will be writing 2 values per event
                        mov     genPtr,#inaVal

writeNextEvent          movd    aac6,genPtr
                        add     genPtr,#1
aac6                    wrlong  0-0,parPtr
                        add     parPtr,#4

                        djnz    counter,#writeNextEvent  

                        add     runState,#2      'set runState to 4 (done all written)
                        wrlong  runState,par     ' head = runState
                        wrlong  runState,endPtr  ' tail = runState
                        jmp     #idle                                                
                        
runState                long    0   '0 = idle  1 = armed  2 = capturing  3 = done
parPtr                  long    0
eMask                   long    0   'indicates pins to monitor for events
nEvents                 long    0   'depth of event capture buffer (1..about 135 TBD)
tMask                   long    0   'indicates pins to monitor for trigger
tState0                 long    0   'pin values required to get past first  trigger condition
tState1                 long    0   'pin values required to get past second trigger condition
nTrigs                  long    0   'number of times triggers must be satisfied before capture starts
genPtr                  long    0   'used during "compose" event capture instruction sequence
destPlus2               long    %10_000_000_000  'used to add 2 to destination field of instruction
counter                 long    0   'general purpose iterator
endPtr                  long    (BUFFER_SIZE-1)*4


inst1ini                waitpne inaVal,eMask    'this instruction sequence writes over itself
inst2ini                mov     inaVal+2,ina
inst3ini                mov     cntVal+2,cnt
inst4ini                and     inaVal+2,eMask

instFinal               jmp     #writeBuffToHub

inst1mod                long    0
inst2mod                long    0
inst3mod                long    0
inst4mod                long    0

inaVal                  nop     'Beginning of event capture buffer
cntVal                  nop

eBuff                   res     4*(MAX_EVENTS-1)  '(4 * maxEvents) + 1 (for terminating jump instruction)

endOfCogMem             fit     $1F0


                                         