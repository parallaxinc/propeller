''************************************************************************************
''*  Midi In Driver                                                                  *
''*                                                                                  *
''*  (C) 2007 Tom Dimock                                                             *
''*                                                                                  *
''*  V1.0 Initial release                                                            *
''*  V1.1 Fixes to two small bugs                                                    *
''*  V1.2 Fixes to three more bugs in controller code. Thanks to Olaf Schirm for     *
''*       finding and supplying fixes for these bugs!                                *
''*  V1.3 Adds MIT license to source code                                            *
''*  See end of file for terms of use.                                               *
''************************************************************************************


VAR

  long  cog                                                          ' Cog flag/id

  long  eventHead                                                    ' Event buffer structure
  long  eventTail                                                    '   for passing events
  long  eventBuffer[32]                                              '   to the caller

  byte  sysexBuffer[256]                                             ' Buffer for sysex data

PUB start(_midiPin, _eventEnable) : okay

'' Start MIDI in driver - starts a cog
'' returns false if no cog available

  stop
  midiPin      := _midiPin                                           ' Move the SPIN parameters to the DAT section
  eventEnable  := _eventEnable                                       '   where they will load at cog startup.
  event_head   := @eventHead                                         ' Initialize more cog variables
  event_tail   := @eventTail                                         '   the same way. This seems much easier
  event_buffer := @eventBuffer                                       '   to me than passing this stuff
  sysex_buffer := @sysexBuffer                                       '   as parameters in the cognew
  bitticks     := clkfreq / 31_250                                   '   command.
  halfticks    := bitticks / 2
  
  longfill(@eventHead,34,0)                                          ' Initialize the event buffer pointers
  
  okay := cog := cognew(@entry, 0) + 1                               ' Start a cog running our assembler code


PUB evtCheck : event

'' Check if event received (never waits)
'' returns -1 if no event received

  event := -1
  if eventTail <> eventHead
    event := eventBuffer[eventTail]
    eventTail := (eventTail + 1) & $0F
    
PUB evtTime(ms) : event | t

'' Wait ms milliseconds for an event to be received
'' returns -1 if no event received

  t := cnt
  repeat until (event := evtCheck) => 0 or (cnt - t) / (clkfreq / 1000) > ms
  

PUB evt : event

'' Receive event (may wait for event)
'' returns event

  repeat while (event := evtCheck) < 0


PUB stop

'' Stop MIDI driver - frees a cog

  if cog
    cogstop(cog~ - 1)


DAT

''************************************************
''* Assembly language MIDI serial driver/decoder *
''************************************************

                        org
''
'' Entry point for assembler code. 
''
entry                   mov     midiMask,#1                          ' Create a mask for the 
                        shl     midiMask,midiPin                     '   MIDI in pin

                        test    eventEnable,doNoteOn          wz     ' Set up to only pass     
              if_z      mov     ignoreNoteOn,#0                      '   events that the          
                        test    eventEnable,doNoteOff         wz     '   user is interested in.    
              if_z      mov     ignoreNoteOff,#0                     '          
                        test    eventEnable,doAftertouch      wz     ' This is accomplished
              if_z      mov     ignoreAftertouch,#0                  '   by overwriting the
                        test    eventEnable,doController      wz     '   instruction that
              if_z      mov     ignoreController,#0                  '   sets the event handler
                        test    eventEnable,doProgramChange   wz     '   with a no-op, leaving
              if_z      mov     ignoreProgramChange,#0               '   the default handler
                        test    eventEnable,doChannelPressure wz     '   in place, which just
              if_z      mov     ignoreChannelPressure,#0             '   goes on to the next
                        test    eventEnable,doSysex           wz     '   event.
              if_z      mov     ignoreSysex,#0
                        test    eventEnable,doMTC             wz
              if_z      mov     ignoreMtcQuarterFrame,#0
                        test    eventEnable,doSongPosPtr      wz
              if_z      mov     ignoreSongPosPtr,#0
                        test    eventEnable,doSongSelect      wz
              if_z      mov     ignoreSongSelect,#0
                        test    eventEnable,doTuneRequest     wz
              if_z      mov     ignoreTuneRequest,#0
                        test    eventEnable,doMidiClock       wz
              if_z      mov     ignoreMidiClock,#0
                        test    eventEnable,doMidiTick        wz
              if_z      mov     ignoreMidiTick,#0
                        test    eventEnable,doMidiStart       wz
              if_z      mov     ignoreMidiStart,#0
                        test    eventEnable,doMidiContinue    wz
              if_z      mov     ignoreMidiContinue,#0
                        test    eventEnable,doMidiStop        wz
              if_z      mov     ignoreMidiStop,#0
                        test    eventEnable,doActiveSense     wz
              if_z      mov     ignoreActiveSense,#0
                        test    eventEnable,doReset           wz
              if_z      mov     ignoreReset,#0

                        mov     nextDataHandler,#getMidiByte         ' Initialize handler address for non-command bytes
''
'' Get the next byte from the MIDI in stream
''
getMidiByte             waitpne midiMask,midiMask                    ' Wait for a start bit.

                        mov     midiBits,#9                          ' Set the number of bits
                        mov     bitClk,cnt                           '   and initialize
                        add     bitClk,halfticks                     '   the clock to the          
                        add     bitClk,bitticks                      '   middle of the first bit
                         
:midiBit                waitcnt bitClk,bitticks                      ' Wait until the bit is there

                        test    midiMask,ina            wc           ' Receive bit on the MIDI in pin,
                        rcr     midiByte,#1                          '   rotate it into our MIDI byte
                        djnz    midiBits,#:midiBit                   '   and go get the next bit

                        shr     midiByte,#32-9                       ' Justify and trim the received 
                        and     midiByte,#$FF                        '   MIDI byte
''
'' A byte of MIDI data has been received. Classify it as a command (high order bit is one) or as a
'' data byte (high order bit is zero).
''
                        test    midiByte,#$80           wz           ' If the new byte is not a command,
              if_z      jmp     nextDataHandler                      '   go to the correct handler for it.
                        
''
'' We have a command byte. Check to see if it is a real-time command ($F8-$FF). These can show up at any time,
'' including right in the middle of a normal event, so we don't want to mess with the event handler for normal
'' events when we get a real-time event.
''
                        mov     t1,midiByte                          ' Check to see if
                        and     t1,#$F8                              '   we have a
                        cmp     t1,#$F8                 wz           '   real-time command.
              if_z      jmp     #:realTime
                        mov     eventHandler,#ignoreEvt              ' Default the normal event handler to ignore
                        jmp     #:notRealTime
:realTime               mov     rtEventHandler,#ignoreEvt            ' Default the real-time event handler to ignore
                        jmp     #sysCommand
''
'' Separate the command byte into its command and channel components, and then use jump
'' tables to go to the approptiate command byte handler.
''
:notRealTime            mov     command,midiByte                     ' Get the command nibble
                        shr     command,#4
                        mov     channel,midiByte                     ' Save the channel
                        and     channel,#$0F                         '   for this command
                        shl     channel,#16                          '   shifting for insertion into event
                        mov     t1,command                           ' Calculate the offset
                        and     t1,#$07                              '   into the command 
                        add     t1,#:cmdTable                        '   jump table
                        jmp     t1                                   '   and go for it
                        
:cmdTable               jmp     #noteOffCmd                          ' Note off
                        jmp     #noteOnCmd                           ' Note on
                        jmp     #aftertouchCmd                       ' Aftertouch
                        jmp     #controllerCmd                       ' Controller
                        jmp     #programChangeCmd                    ' Program change
                        jmp     #channelPressureCmd                  ' Channel pressure
                        jmp     #pitchWheelCmd                       ' Pitch wheel
                        jmp     #sysCommand                          ' System command
''
'' Decode the system commands
''
sysCommand              mov     t1,midiByte                          ' The "channel" in a system command 
                        and     t1,#$0F                               '   defines the type of command - 
                        add     t1,#:sysCmdTable                     '   use it as an offset into 
                        jmp     t1                                   '   the system command jump table

:sysCmdTable            jmp     #beginSysexCmd                       ' F0 - Begin Sysex
                        jmp     #mtcQuarterFrameCmd                  ' F1 - Midi Time Code quarter frame
                        jmp     #songPosPtrCmd                       ' F2 - Song position pointer
                        jmp     #songSelectCmd                       ' F3 - Song select
                        jmp     #unused4Cmd                          ' F4 - Unused
                        jmp     #unused5Cmd                          ' F5 - Unused
                        jmp     #tuneRequestCmd                      ' F6 - Tune request
                        jmp     #endSysexCmd                         ' F7 - End Sysex
                        jmp     #midiClockCmd                        ' F8 - MIDI clock
                        jmp     #midiTickCmd                         ' F9 - MIDI tick
                        jmp     #midiStartCmd                        ' FA - MIDI start
                        jmp     #midiContinueCmd                     ' FB - MIDI continue
                        jmp     #midiStopCmd                         ' FC - MIDI stop
                        jmp     #unusedDCmd                          ' FD - Unused
                        jmp     #activeSenseCmd                      ' FE - Active sense
                        jmp     #resetCmd                            ' FF - Reset
''
'' Channel command byte handlers. Each sets the handler for the first data byte (if there is one), and
'' the handler for the completed event, once all data bytes have been dealt with. The event handler
'' setup may be overwritten with a no-op during cog setup if the user is not interested in this
'' event type.
''
noteOnCmd               mov     nextDataHandler,#note                ' Next non-cmd byte should be a note
ignoreNoteOn            mov     eventHandler,#noteOn
                        jmp     #getMidiByte 

noteOffCmd              mov     nextDataHandler,#note                ' Next non-cmd byte should be a note
ignoreNoteOff           mov     eventHandler,#noteOff
                        jmp     #getMidiByte 

aftertouchCmd           mov     nextDataHandler,#note                ' Next non-cmd byte should be a note
ignoreAftertouch        mov     eventHandler,#aftertouch
                        jmp     #getMidiByte 

controllerCmd           mov     nextDataHandler,#cont_num            ' Next non-cmd byte should be controller number
ignoreController        mov     eventHandler,#controller
                        jmp     #getMidiByte 

programChangeCmd        mov     nextDataHandler,#program_num         ' Next non-cmd byte should be a program number
ignoreProgramChange     mov     eventHandler,#programChange
                        jmp     #getMidiByte

channelPressureCmd      mov     nextDataHandler,#channel_pressure    ' Next non-cmd byte should be channel pressure 
ignoreChannelPressure   mov     eventHandler,#channelPressure
                        jmp     #getMidiByte

pitchWheelCmd           mov     nextDataHandler,#pitch_wheel_lo      ' Next non-cmd byte should be low order seven
ignorePitchWheel        mov     eventHandler,#pitchWheel             '   bits of the pitch wheel value
                        jmp     #getMidiByte
''
'' System command byte handlers
''
beginSysexCmd           mov     nextDataHandler,#sysex_byte          ' Next non-cmd byte should be a sysex byte
ignoreSysex             mov     eventHandler,#sysex
                        mov     sysex_cursor,sysex_buffer
                        jmp     #getMidiByte
                        
mtcQuarterFrameCmd      mov     nextDataHandler,#quarter_frame       ' Next non-cmd byte should be an MTC value
ignoreMtcQuarterFrame   mov     eventHandler,#quarterFrame
                        jmp     #getMidiByte
                        
songPosPtrCmd           mov     nextDataHandler,#song_pos_ptr_lo     ' Next non-cmd byte should be low order seven
ignoreSongPosPtr        mov     eventHandler,#songPosPtr             '   bits of the song position pointer
                        jmp     #getMidiByte
                        
songSelectCmd           mov     nextDataHandler,#song_num            ' Next non-cmd byte should be a song number 
ignoreSongSelect        mov     eventHandler,#songSelect
                        jmp     #getMidiByte
                        
unused4Cmd              jmp     #getMidiByte                         ' $F4 command is undefined

unused5Cmd              jmp     #getMidiByte                         ' $F5 command is undefined
                        
tuneRequestCmd          
ignoreTuneRequest       mov     eventHandler,#tuneRequest            ' Tune request has no data. Go immediately
                        jmp     eventHandler                         '   to its event handler.
                        
endSysexCmd             jmp     eventHandler                         ' End sysex frame. Go handle it
''
'' MIDI real time messages - since these can show up in the middle of normal commands, we need to use a separate
'' event handler pointer for them
''                                                              
midiClockCmd                                                         ' MIDI clock real time command    - $F8
ignoreMidiClock         mov     rtEventHandler,#midiClock            '   It has no data. Go immediately
                        jmp     rtEventHandler                       '   to its event handler.  
                        
midiTickCmd                                                          ' MIDI tick real time command     - $F9
ignoreMidiTick          mov     rtEventHandler,#midiTick             '   It has no data. Go immediately
                        jmp     rtEventHandler                       '   to its event handler.
                        
midiStartCmd                                                         ' MIDI start real time command    - $FA
ignoreMidiStart         mov     rtEventHandler,#midiStart            '   It has no data. Go immediately
                        jmp     rtEventHandler                       '   to its event handler. 
                        
midiContinueCmd                                                      ' MIDI continue real time command - $FB
ignoreMidiContinue      mov     rtEventHandler,#midiContinue         '   It has no data. Go immediately
                        jmp     rtEventHandler                       '   to its event handler. 
                        
midiStopCmd                                                          ' MIDI stop real time command     - $FC
ignoreMidiStop          mov     rtEventHandler,#midiStop             '   It has no data. Go immediately
                        jmp     rtEventHandler                       '   to its event handler. 
                         
unusedDCmd              jmp     #getMidiByte                         ' $FD command is undefined

activeSenseCmd                                                       ' Active sense real time command  - $FE
ignoreActiveSense       mov     rtEventHandler,#activeSense          '   It has no data. Go immediately
                        jmp     rtEventHandler                       '   to its event handler. 
                        
resetCmd                                                             ' Reset real time command         - $FF
ignoreReset             mov     rtEventHandler,#reset                '   It has no data. Go immediately
                        jmp     rtEventHandler                       '   to its event handler. 
''
'' Non command byte handlers
''
note                    mov     noteValue,midiByte                   ' Save the note value,
                        shl     noteValue,#8                         '   shifting for insertion into event;
                        mov     nextDataHandler,#velocity            '   next byte should be velocity
                        jmp     #getMidiByte 
'
velocity                mov     velocityValue,midiByte               ' Save the velocity value,
                        mov     nextDataHandler,#note                '   next byte should be a note, if running status
                        jmp     eventHandler                         ' Event is complete, go handle it

cont_num                mov     controllerNumber,midiByte            ' Save the controller number, 
                        shl     controllerNumber,#8                  '   shifting for insertion into event;
                        mov     nextDataHandler,#cont_val            '   next byte should be a controller value
                        jmp     #getMidiByte              

cont_val                mov     controllerValue,midiByte             ' Save the controller value, 
                        mov     nextDataHandler,#cont_num            '   next is controller number, if running status
                        jmp     eventHandler                         ' Event is complete, go handle it

program_num             mov     programValue,midiByte                ' Save the program number value
                        jmp     eventHandler                         ' Event is complete, go handle it

channel_pressure        mov     channelPressureValue,midiByte        ' Save the channel pressure value
                        jmp     eventHandler                         ' Event is complete, go handle it

pitch_wheel_lo          mov     pitchWheelLoValue,midiByte           ' Save the low pitch wheel byte,
                        mov     nextDataHandler,#pitch_wheel_hi      '   next will be the high byte
                        jmp     #getMidiByte

pitch_wheel_hi          mov     pitchWheelHiValue,midiByte           ' Save the high pitch wheel byte,
                        shl     pitchWheelHiValue,#7                 '   shifting for insertion into event;
                        mov     nextDataHandler,#pitch_wheel_lo      '   next will be a low byte, if running status
                        jmp     eventHandler                         ' Event is complete, go handle it

song_pos_ptr_lo         mov     songPosPtrLoValue,midiByte           ' Save the low song position byte,
                        mov     nextDataHandler,#song_pos_ptr_hi     '   next will be the high byte
                        jmp     #getMidiByte

song_pos_ptr_hi         mov     songPosPtrHiValue,midiByte           ' Save the high song position byte,
                        shl     songPosPtrHiValue,#7                 '   shifting for insertion into event;
                        mov     nextDataHandler,#song_pos_ptr_lo     '   next will be a low byte, if running status  
                        jmp     eventHandler                         ' Event is complete, go handle it

song_num                mov     songSelectValue,midiByte             ' Save the song number
                        jmp     eventHandler                         ' Event is complete, go handle it

quarter_frame           mov     quarterFrameValue,midiByte           ' Save the MTC quarter frame value
                        jmp     eventHandler                         ' Event is complete, go handle it

sysex_byte              wrbyte  midiByte,sysex_cursor                ' Write the sysex byte into the sysex
                        add     sysex_cursor,#1                      '   buffer and increment the cursor
                        and     sysex_cursor,#$FF                    ' Wrap the buffer - this is very bad, but
                        jmp     #getMidiByte                         '   that's life.
                        
'
'Handlers for completed events
'
ignoreEvt               jmp     #getMidiByte                         ' Handler for ignored events

noteOn                  mov     event_data,noteOnEvt                 ' Build a note on event and
                        or      event_data,channel                   '   write it to the event buffer
                        or      event_data,noteValue                
                        or      event_data,velocityValue
                        call    #writeEvent                
                        jmp     #getMidiByte
                                                            
noteOff                 mov     event_data,noteOffEvt                ' Build a note off event and
                        or      event_data,channel                   '   write it to the event buffer
                        or      event_data,noteValue                
                        or      event_data,velocityValue
                        call    #writeEvent                
                        jmp     #getMidiByte
                        
aftertouch              mov     event_data,aftertouchEvt             ' Build an aftertouch event and
                        or      event_data,channel                   '   write it to the event buffer
                        or      event_data,noteValue                
                        or      event_data,velocityValue
                        call    #writeEvent                
                        jmp     #getMidiByte
                                 
controller              mov     event_data,controllerEvt             ' Build a controller event and
                        or      event_data,channel                   '   write it to the event buffer
                        or      event_data,controllerNumber                
                        or      event_data,controllerValue
                        call    #writeEvent                
                        jmp     #getMidiByte
                                          
programChange           mov     event_data,programChangeEvt          ' Build a program change event and
                        or      event_data,channel                   '   write it to the event buffer
                        or      event_data,programValue
                        call    #writeEvent                
                        jmp     #getMidiByte
                        
channelPressure         mov     event_data,channelPressureEvt        ' Build a channel pressure event and   
                        or      event_data,channel                   '   write it to the event buffer
                        or      event_data,channelPressureValue
                        call    #writeEvent                
                        jmp     #getMidiByte
                        
pitchWheel              mov     event_data,pitchWheelEvt             ' Build a pitch wheel event and   
                        or      event_data,channel                   '   write it to the event buffer   
                        or      event_data,pitchWheelHiValue                
                        or      event_data,pitchWheelLoValue
                        call    #writeEvent                
                        jmp     #getMidiByte
                                           
quarterFrame            mov     event_data,mtcEvt                    ' Build a MIDI Time Code event and   
                        or      event_data,quarterFrameValue         '   write it to the event buffer
                        call    #writeEvent                
                        jmp     #getMidiByte
                        
songPosPtr              mov     event_data,songPosPtrEvt             ' Build a song position pointer event and   
                        or      event_data,songPosPtrHiValue         '   write it to the event buffer            
                        or      event_data,songPosPtrLoValue
                        call    #writeEvent                
                        jmp     #getMidiByte
                        
songSelect              mov     event_data,songSelectEvt             ' Build a song select event and   
                        or      event_data,songSelectValue           '   write it to the event buffer
                        call    #writeEvent                
                        jmp     #getMidiByte
                        
tuneRequest             mov     event_data,tuneRequestEvt            ' Build a tune request event and   
                        call    #writeEvent                          '   write it to the event buffer
                        jmp     #getMidiByte
                        
sysex                   mov     event_data,sysexEvt                  ' Build a Sysex event
                        mov     t1,sysex_cursor
                        sub     t1,sysex_buffer
                        shl     t1,#16
                        or      event_data,t1
                        or      event_data,sysex_buffer
                        call    #writeEvent                          '   write it to the event buffer
                        jmp     #getMidiByte
                        
midiClock               mov     event_data,midiClockEvt              ' Build a MIDI clock event and
                        call    #writeEvent                          '   write it to the event buffer
                        jmp     #getMidiByte
                        
midiTick                mov     event_data,midiTickEvt               ' Build a MIDI tick event and 
                        call    #writeEvent                          '   write it to the event buffer
                        jmp     #getMidiByte
                        
midiStart               mov     event_data,midiStartEvt              ' Build a MIDI start event and 
                        call    #writeEvent                          '   write it to the event buffer
                        jmp     #getMidiByte
                        
midiContinue            mov     event_data,midiContinueEvt           ' Build a MIDI continue event and 
                        call    #writeEvent                          '   write it to the event buffer
                        jmp     #getMidiByte
                        
midiStop                mov     event_data,midiStopEvt               ' Build a MIDI stop event and 
                        call    #writeEvent                          '   write it to the event buffer
                        jmp     #getMidiByte
                        
activeSense             mov     event_data,activeSenseEvt            ' Build an active sense event and 
                        call    #writeEvent                          '   write it to the event buffer
                        jmp     #getMidiByte
                        
reset                   mov     event_data,resetEvt                  ' Build a reset event and 
                        call    #writeEvent                          '   write it to the event buffer
                        jmp     #getMidiByte
'
' Routine to write an event to the event buffer
'
writeEvent              rdlong  t1,event_head                        ' Write an event into
                        mov     event_offset,t1                      '   the event buffer.
                        shl     event_offset,#2                      ' Note that we don't check
                        add     event_offset,event_buffer            '   for buffer overruns, as
                        wrlong  event_data,event_offset              '   waiting here could really
                        add     t1,#1                                '   screw up reading the 
                        and     t1,#$0F                              '   MIDI stream
                        wrlong  t1,event_head
writeEvent_ret          ret
'
' Constant data
'
doNoteOn                long    $00000001                            ' Bit flags used by the caller
doNoteOff               long    $00000002                            '   to indicate what MIDI events
doAftertouch            long    $00000004                            '   they want to see.
doController            long    $00000008
doProgramChange         long    $00000010
doChannelPressure       long    $00000020
doPitchWheel            long    $00000040
doSysex                 long    $00000100
doMTC                   long    $00000200
doSongPosPtr            long    $00000400
doSongSelect            long    $00000800
doTuneRequest           long    $00001000
doMidiClock             long    $00002000
doMidiTick              long    $00004000
doMidiStart             long    $00008000
doMidiContinue          long    $00010000
doMidiStop              long    $00020000
doActiveSense           long    $00040000
doReset                 long    $00080000

noteOnEvt               long    $00000000                            ' Event codes used in constructing
noteOffEvt              long    $01000000                            '   our events for passing to the caller
aftertouchEvt           long    $02000000
controllerEvt           long    $03000000
programChangeEvt        long    $04000000
channelPressureEvt      long    $05000000
pitchWheelEvt           long    $06000000
sysexEvt                long    $07000000
mtcEvt                  long    $08000000
songPosPtrEvt           long    $09000000
songSelectEvt           long    $0A000000
tuneRequestEvt          long    $0B000000
MidiClockEvt            long    $0C000000
MidiTickEvt             long    $0D000000
MidiStartEvt            long    $0E000000
MidiContinueEvt         long    $0F000000
MidiStopEvt             long    $10000000
activeSenseEvt          long    $11000000
resetEvt                long    $12000000

' Values initialized by the SPIN code before loading the cog
                       
bitticks                long    0-0                                  ' One bit width = clkfreq / 31,250
halfticks               long    0-0                                  ' Half of that

midiPin                 long    0-0                                  ' MIDI in pin 
eventEnable             long    0-0                                  ' Bit flags enabling events

event_head              long    0-0                                  ' Addresses of the event buffer
event_tail              long    0-0                                  '   head and tail pointers and
event_buffer            long    0-0                                  '   the buffer itself

sysex_buffer            long    0-0                                  ' Sysex buffer and

' Short term variables

t1                      res     1
event_offset            res     1
event_data              res     1
sysex_cursor            res     1  

' Variables for bit bashed I/O

midiMask                res     1
midiBits                res     1
bitClk                  res     1
midiByte                res     1

' Navigation variables used for controlling the flow of code

nextDataHandler         res     1
eventHandler            res     1
rtEventHandler          res     1

' Variables to hold parsed MIDI data

command                 res     1
channel                 res     1
noteValue               res     1
velocityValue           res     1
controllerNumber        res     1
controllerValue         res     1
programValue            res     1
channelPressureValue    res     1
pitchWheelLoValue       res     1
pitchWheelHiValue       res     1
songPosPtrLoValue       res     1
songPosPtrHiValue       res     1
songSelectValue         res     1
quarterFrameValue       res     1
                        fit
{{
┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                   TERMS OF USE: MIT License                                                  │                                                            
├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation    │ 
│files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,    │
│modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software│
│is furnished to do so, subject to the following conditions:                                                                   │
│                                                                                                                              │
│The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.│
│                                                                                                                              │
│THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE          │
│WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR         │
│COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,   │
│ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                         │
└──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
}}          