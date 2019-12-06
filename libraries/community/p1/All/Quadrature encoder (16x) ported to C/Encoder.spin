{{*************************
* Derived from:           *
* Quadrature Encoder v1.0 *
* Author: Jeff Martin     *
* (C) 2005 Parallax, Inc. *
***************************
}}
PUB WhatEver 'start(StartPin)
 
{{****************************************************
'* Encoder Reading Assembly Routine                  *
'* Modified  by HJK Opteq mechatronics Febr 2015     *
'* for use with C                                    *
'*****************************************************

Changes Febr 2015:
- Life counter added and time measurement added. Both can be commented to save a little execution time
  But the life counter is requred to make robot applications safe to be sure that the encoder cog runs.
- Mailbox structure to interface with C

Some performance indications:
- 1 encoder  uses 148 clocks with counter and time measurement on
- 4 encoders uses 292 clocks
- 8 encoders uses 484 clocks
-16 encoders uses 868 clocks

Example: at 80 MHz, clock time is 12,5 ns. If we use a safety margin of 2 for edge detection
And assume that we run a motor with encoder with 1000 counts per rev, 
what is then the max speed of the motor?

Max counts per second:
- 1 encoder  -> 270,000 counts/s -> 16000 rpm
- 4 encoders -> 137,000 counts/s ->  8000 rpm
- 8 encoders ->  82,000 counts/s ->  4900 rpm
-16 encoders ->  46,000 counts/s ->  2750 rpm

The counter is not only for safety, bt can be used as well for a simpel and robust 
speed calculation in the calling C-routine

Read all encoders and update encoder positions in main memory.
'See "Theory of Operation," below, for operational explanation.
'Cycle Calculation Equation:
'  Terms:     SU = :Sample to :Update.  UTI = :UpdatePos through :IPos.  MMW = Main Memory Write.
'             AMMN = After MMW to :Next.  NU = :Next to :UpdatePos.  SH = Resync to Hub.  NS = :Next to :Sample.
'  Equation:  SU + UTI + MMW + (AMMN + NU + UTI + SH + MMW) * (TotEnc-1) + AMMN + NS
'             = 92 + 16  +  8  + ( 16  + 4  + 16  + 6  +  8 ) * (TotEnc-1) +  16  + 12
'             = 144 + 50*(TotEnc-1)

Mailbox structure in C

typedef struct encoder_s     // Encoder structure

  int PosPointer;            // Pointer to the first address of the position counter to PASM code via PAR register
  int Pin;                   // The first encoder pin
  int Totenc;                // Total number of encoders  
  int pasm_cntr;             // Life counter
  int EncTime;               // Clock cycles for encoder time
  int POS[4];                // Actual position counters updated by encoder cog
  encoder_t;                 // Encoder type for declaring

int MaxPOS = 4;              // Value must be the same as the size of POS


}}

DAT
                org     0
pasm                                                                                                
                mov     mailbox_start,par         ' save the pointer to the mailbox memory area for later use
                mov     mailbox_ptr, mailbox_start  'init maibox pointer
                                                           '
                rdlong  Pos, mailbox_ptr          ' read the first position address from HUB as defined in the mailbox by C
  
                add     mailbox_ptr, #4           ' point to the next LONG in HUB 
                rdlong  Pin, mailbox_ptr          ' read start pin from mailbox
     
                add     mailbox_ptr, #4           ' point to the next LONG in mailbox 
                rdlong  TotEnc, mailbox_ptr       'read number of encoders from mailbox
      
      '          add     mailbox_ptr, #4           ' point to the next LONG in mailbox
            '    mov     pasm_cntr_addr, mailbox_ptr   ' Save process counter address
          
                mov     tEncCntr, #0              'Init life counter
                mov     Tt2, #0                   'Init time measurement
                                                  '             
{{:again 'test cycle
                mov     Tt1, CNT                  'Set Time reference for time measurement
        
                mov     mailbox_ptr, mailbox_start  'init mailbox pointer
'                mov     mailbox_ptr, par          'init mailbox pointer
                add     mailbox_ptr, #0           'offset for pasm_cntr
                mov     testvar, #11
                wrlong  testvar, mailbox_ptr     'write counter to mailbox var pasm_cntr
           
                add     mailbox_ptr, #4          'offset for process timer EncTime
                mov     testvar, #22
                wrlong  testvar, mailbox_ptr      'write time to mailbox var 

                add     mailbox_ptr, #4           'offset for pasm_cntr
                mov     testvar, #33
                wrlong  testvar, mailbox_ptr     'write counter to mailbox var pasm_cntr

                mov     testvar, tEncCntr                               
                add     mailbox_ptr, #4            
                mov     testvar, #44
                wrlong  testvar, mailbox_ptr         
                mov     testvar, tEncCntr                               
   
                add     mailbox_ptr, #4            
                mov     testvar, #55
                wrlong  testvar, mailbox_ptr         
   
                add     tEncCntr, #1              'increment counter
          
                mov     MPosAddr, Pos             'prepare index in POS counters
                mov     testvar, tEncCntr              'test  var
                wrlong  testvar, MPosAddr         'write  POS
   
                mov     testvar, TotEnc                               
                add     MPosAddr, #4              'Next POS
                wrlong  testvar, MPosAddr         'write  POS
      
                mov     testvar, Pin                               
                add     MPosAddr, #4              'Next POS
                wrlong  testvar, MPosAddr         'write  POS
                                                    
                mov     testvar, Tt2                               
                add     MPosAddr, #4              'Next POS
                wrlong  testvar, MPosAddr         'write  POS
                                                                                                    '
                mov     Tt2, CNT                  'Next time ref
                sub     Tt2, Tt1                  'Calculate loop time in clock cycles
}}
                                                                           '
                                                                '
                        test    Pin, #$20               wc      'Test for upper or lower port
                        muxc    :PinSrc, #%1                    'Adjust :PinSrc instruction for proper port
                        mov     IPosAddr, #IntPos               'Clear all internal encoder position values
                        movd    :IClear, IPosAddr               '  set starting internal pointer
                        mov     Idx, TotEnc                     '  for all encoders...  
:IClear                 mov     0, #0                           '  clear internal memory
                        add     IPosAddr, #1                    '  increment pointer
                        movd    :IClear, IPosAddr               
                        djnz    Idx, #:IClear                   '  loop for each encoder
                                                                
                        mov     St2, ina                        'Take first sample of encoder pins
                        shr     St2, Pin                

:Sample                 mov     Tt1, CNT                  'Set Time reference for time measurement
                        add     tEncCntr, #1              'increment counter

                        mov     IPosAddr, #IntPos               'Reset encoder position buffer addresses
                        movd    :IPos+0, IPosAddr                               
                        movd    :IPos+1, IPosAddr
'                        mov     MPosAddr, PAR                           
                        mov     MPosAddr, Pos                           
                        mov     St1, St2                        'Calc 2-bit signed offsets (St1 = B1:A1)
                        mov     T1,  St2                        '                           T1  = B1:A1 
                        shl     T1, #1                          '                           T1  = A1:x 
        :PinSrc         mov     St2, inb                        '  Sample encoders         (St2 = B2:A2 left shifted by first encoder offset)
                        shr     St2, Pin                        '  Adj for first encoder   (St2 = B2:A2)
                        xor     St1, St2                        '          St1  =              B1^B2:A1^A2
                        xor     T1, St2                         '          T1   =              A1^B2:x
                        and     T1, BMask                       '          T1   =              A1^B2:0
                        or      T1, AMask                       '          T1   =              A1^B2:1
                        mov     T2, St1                         '          T2   =              B1^B2:A1^A2
                        and     T2, AMask                       '          T2   =                  0:A1^A2
                        and     St1, BMask                      '          St1  =              B1^B2:0
                        shr     St1, #1                         '          St1  =                  0:B1^B2
                        xor     T2, St1                         '          T2   =                  0:A1^A2^B1^B2
                        mov     St1, T2                         '          St1  =                  0:A1^B2^B1^A2
                        shl     St1, #1                         '          St1  =        A1^B2^B1^A2:0
                        or      St1, T2                         '          St1  =        A1^B2^B1^A2:A1^B2^B1^A2
                        and     St1, T1                         '          St1  =  A1^B2^B1^A2&A1^B2:A1^B2^B1^A2
                        mov     Idx, TotEnc                     'For all encoders...
:UpdatePos              ror     St1, #2                         'Rotate current bit pair into 31:30
                        mov     Diff, St1                       'Convert 2-bit signed to 32-bit signed Diff
                        sar     Diff, #30
        :IPos           add     0, Diff                         'Add to encoder position value
                        wrlong  0, MPosAddr                     'Write new position to main memory
                        add     IPosAddr, #1                    'Increment encoder position addresses
                        movd    :IPos+0, IPosAddr
                        movd    :IPos+1, IPosAddr
                        add     MPosAddr, #4                            
:Next                   djnz    Idx, #:UpdatePos                'Loop for each encoder
              
                        mov     Tt2, CNT                        'Next time ref
                        sub     Tt2, Tt1                        'Calculate loop time in clock cycles
               
                        mov     mailbox_ptr, mailbox_start      'init mailbox pointer
                        add     mailbox_ptr, #12                 'offset for pasm_cntr
                        wrlong  tEncCntr, mailbox_ptr            'write time to mailbox var 

                        add     mailbox_ptr, #4                 'offset for EncTime
                        wrlong  Tt2, mailbox_ptr            'write counter to mailbox var EncTime              
                      
                        jmp     #:Sample                        'Loop forever

'Define Encoder Reading Cog's constants/variables

mailbox_ptr             long    0                               ' working ptr into the HUB area - reload from PAR if needed
mailbox_start           long    0
AMask                   long    $55555555                       'A bit mask
BMask                   long    $AAAAAAAA                       'B bit mask
MSB                     long    $80000000                       'MSB mask for current bit pair

Pin                     long    0                               'First pin connected to first encoder
TotEnc                  long    0                               'Total number of encoders

Pos                     long    0                               'Address pointer to Positions in HUB memory. Set by C-code
'pasm_cntr_addr          long    0                               'Counter address of life counter in HUB mem
EncTimeAddr             long    0                
tEncCntr                long    0
testvar                 long    0                               'test variable

Tt1                     long    0                               'Buffers for loop time measurement
Tt2                     long    0
                                                                '
Idx                     res     1                               'Encoder index
St1                     res     1                               'Previous state
St2                     res     1                               'Current state
T1                      res     1                               'Temp 1
T2                      res     1                               'Temp 2
Diff                    res     1                               'Difference, ie: -1, 0 or +1
IPosAddr                res     1                               'Address of current encoder position counter (Internal Memory)
MPosAddr                res     1                               'Address of current encoder position counter (Main Memory)
IntPos                  res     16                              'Internal encoder position counter buffer

                        fit     496             
''
''
''**************************
''* FUNCTIONAL DESCRIPTION *
''**************************
''
''Reads 1 to 16 two-bit gray-code quadrature encoders and provides 32-bit absolute position values for each and optionally provides delta position support
''(value since last read) for up to 16 encoders.  See "Required Cycles and Maximum RPM" below for speed boundary calculations.
''
''Connect each encoder to two contiguous I/O pins (multiple encoders must be connected to a contiguous block of pins).  If delta position support is
''required, those encoders must be at the start of the group, followed by any encoders not requiring delta position support.
''
''To use this object: 
''  1) Create a position buffer (array of longs).  The position buffer MUST contain NumEnc + NumDelta longs.  The first NumEnc longs of the position buffer
''     will always contain read-only, absolute positions for the respective encoders.  The remaining NumDelta longs of the position buffer will be "last
''     absolute read" storage for providing delta position support (if used) and should be ignored (use ReadDelta() method instead).
''  2) Call Start() passing in the starting pin number, number of encoders, number needing delta support and the address of the position buffer.  Start() will
''     configure and start an encoder reader in a separate cog; which runs continuously until Stop is called.
''  3) Read position buffer (first NumEnc values) to obtain an absolute 32-bit position value for each encoder.  Each long (32-bit position counter) within
''     the position buffer is updated automatically by the encoder reader cog.
''  4) For any encoders requiring delta position support, call ReadDelta(); you must have first sized the position buffer and configured Start() appropriately
''     for this feature.
''
''Example Code:
''           
''OBJ
''  Encoder : "Quadrature Encoder"
''
''VAR
''  long Pos[3]                            'Create buffer for two encoders (plus room for delta position support of 1st encoder)
''
''PUB Init
''  Encoder.Start(8, 2, 1, @Pos)           'Start continuous two-encoder reader (encoders connected to pins 8 - 11)
''
''PUB Main 
''  repeat
''    <read Pos[0] or Pos[1] here>         'Read each encoder's absolute position
''    <variable> := Encoder.ReadDelta(0)   'Read 1st encoder's delta position (value since last read)
''
''________________________________
''REQUIRED CYCLES AND MAXIMUM RPM:
''
''Encoder Reading Cog requires 144 + 50*(TotEnc-1) cycles per sample.  That is: 144 for 1 encoder, 194 for 2 encoders, 894 for 16 encoders.
''
''Conservative Maximum RPM of Highest Resolution Encoder = XINFreq * PLLMultiplier / EncReaderCogCycles / 2 / MaxEncPulsesPerRevolution * 60
''
''Example 1: Using a 4 MHz crystal, 8x internal multiplier, 16 encoders where the highest resolution encoders is 1024 pulses per revolution:
''           Max RPM = 4,000,000 * 8 / 894 / 2 / 1024 * 60 = 1,048 RPM
''
''Example 2: Using same example above, but with only 2 encoders of 128 pulses per revolution:
''           Max RPM = 4,000,000 * 8 / 194 / 2 / 128 * 60 = 38,659 RPM

'____________________
'THEORY OF OPERATION:
'Column 1 of the following truth table illustrates 2-bit, gray code quadrature encoder output (encoder pins A and B) and their possible transitions (assuming
'we're sampling fast enough).  A1 is the previous value of pin A, A2 is the current value of pin A, etc.  '->' means 'transition to'.  The four double-step
'transition possibilities are not shown here because we won't ever see them if we're sampling fast enough and, secondly, it is impossible to tell direction
'if a transition is missed anyway.
'
'Column 2 shows each of the 2-bit results of cross XOR'ing the bits in the previous and current values.  Because of the encoder's gray code output, when
'there is an actual transition, A1^B2 (msb of column 2) yields the direction (0 = clockwise, 1 = counter-clockwise).  When A1^B2 is paired with B1^A2, the
'resulting 2-bit value gives more transition detail (00 or 11 if no transition, 01 if clockwise, 10 if counter-clockwise).
'
'Columns 3 and 4 show the results of further XORs and one AND operation.  The result is a convenient set of 2-bit signed values: 0 if no transition, +1 if
'clockwise, and -1 and if counter-clockwise.
'
'This object's Update routine performs the sampling (column 1) and logical operations (colum 3) of up to 16 2-bit pairs in one operation, then adds the 
'resulting offset (-1, 0 or +1) to each position counter, iteratively.
'
'      1      |      2      |          3           |       4        |     5
'-------------|-------------|----------------------|----------------|-----------
'             |             | A1^B2^B1^A2&(A1^B2): |   2-bit sign   |
'B1A1 -> B2A2 | A1^B2:B1^A2 |     A1^B2^B1^A2      | extended value | Diagnosis
'-------------|-------------|----------------------|----------------|-----------
' 00  ->  00  |     00      |          00          |      +0        |    No
' 01  ->  01  |     11      |          00          |      +0        | Movement
' 11  ->  11  |     00      |          00          |      +0        |
' 10  ->  10  |     11      |          00          |      +0        |
'-------------|-------------|----------------------|----------------|-----------
' 00  ->  01  |     01      |          01          |      +1        | Clockwise
' 01  ->  11  |     01      |          01          |      +1        |
' 11  ->  10  |     01      |          01          |      +1        |
' 10  ->  00  |     01      |          01          |      +1        |
'-------------|-------------|----------------------|----------------|-----------
' 00  ->  10  |     10      |          11          |      -1        | Counter-
' 10  ->  11  |     10      |          11          |      -1        | Clockwise
' 11  ->  01  |     10      |          11          |      -1        |
' 01  ->  00  |     10      |          11          |      -1        |