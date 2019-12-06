CON
{
Pulse width modulated LED driver
24-channels, 8 bits per channel
Intended for use with 8 RBG LED modules

Version 1.0  2014-03-28
Copyright (c) 2014 Alexander Hajnal
See end of file for terms of use

Driver uses successive approximation to provide
256 brightness levels for each channel

Sample circuit using common-anode RBG modules:
(See "I2C PWM.spin" or "PWM demo.spin" for a more complete circuit)

      2x ULN2803A:
 ┌────────────────┐
 │  10kΩ  ┌─────┐ │        Propeller
 ┣──┤     ├─┘         ┌─────┐
     R0 ─┤     ├───────────┤•    ├─
      B0 ─┤     ├───────────┤     ├─
      G0 ─┤     ├───────────┤     ├─
      R1 ─┤     ├───────────┤     ├─
      B1 ─┤     ├───────────┤     ├─
      G1 ─┤     ├───────────┤     ├─
      R2 ─┤     ├───────────┤     ├─
      B2 ─┤    •├───────────┤     ├─
          └─────┘   Ground ─┤     ├─ 3.3V
 ┌────────────────┐ Ground ─┤     ├───┐5MHz
 │  10kΩ  ┌─────┐ │  Reset ─┤     ├────┘crystal  ULN2803A:
 ┣──┤     ├─┘   3.3V ─┤     ├─ Ground      ┌─────┐
     G2 ─┤     ├───────────┤     ├──────────────┤•    ├─ G7
      R3 ─┤     ├───────────┤     ├──────────────┤     ├─ B7
      B3 ─┤     ├───────────┤     ├──────────────┤     ├─ R7
      G3 ─┤     ├───────────┤     ├──────────────┤     ├─ G6
      R4 ─┤     ├───────────┤     ├──────────────┤     ├─ B6
      B4 ─┤     ├───────────┤     ├──────────────┤     ├─ R6
      G4 ─┤     ├───────────┤     ├──────────────┤     ├─ G5
      R5 ─┤    •├───────────┤     ├──────────────┤     ├─ B5
          └─────┘           └─────┘            ┌─┤     ├┐
                                               │ └─────┘ 10kΩ │
                                               └──────────────┫
                                                              
          12V
           │             Propeller  LED
 Common 0 ─╋─ Common 4   Ground     Ground         3.3V
 Common 1 ─╋─ Common 5     │          │     0.1µF   │
 Common 2 ─╋─ Common 6     └──────────╋────────────┘
 Common 3 ─┻─ Common 7                
                                    System
                                    ground

Ground lines for Propeller and LEDs should be tied together

Propeller runs at 3.3V
LEDs can run at any voltage that the ULN2803A's can handle (12V in this example)

Note that you may need to use multiple 12V power supplies depending on how much
current the LEDs need.  For example you might tie Common 0..3 to one supply's 12V
rail and Common 4..7 to a second supply's 12V rail (both supplies ground rails
need to be tied to the system ground).

The circuit was tested using Ikea Dioder lights which run at 12V and have resistors
built-in.  If you're using discrete LEDs you will probably want to add a current-
limiting resistor in series with each LED.  The lights that I have draw about 504mA
at 12V when all 24 channels are on (plus 24mA for the Propeller and the rest of the
circuitry).  The Ikea power supplies can only supply 430mA each so using a split
supply (1x 12V power supply for every 4 light strips) is recommended.

Cabling for Ikea Dioder RBG lights:

 Common (12V)
 Red
XXXXXX Blue
 Green

Duty cycles at 80MHz:
Channel = 0 ───────────── 0 cycles ────── 0.000% ── 0 s
Minimum on time (=1) ──── 900 cycles ──── 0.388% ── 11.25 µs (88890 Hz)
Maximum on time (=255) ── 230400 cycles ─ 99.346% ─ 2880  µs
Overhead ──────────────── 1516 cycles ─── 0.654% ── 18.95 µs
Total for one iteration ─ 231916 cycles ──────────── 2899  µs (345 Hz)

Release notes and errata:

• I am not an electrical engineer.
  Use this circuit at your own risk!

• Do NOT connect the 12V rail to any of the Propeller's pins.
  If you do so you will immediately and permanently destroy
  the Propeller chip.  The only connections should be through
  the ULN2803A's.

• The driver takes a buffer address as its start parameter,
  This buffer should be an array of 24 bytes.  To set an RBG
  channel's brightness simply write a value between 0 (fully
  off) and 255 (fully on) to the appropriate element of the
  array.  The array elements are as follows:

  array[0] ── Channel 0 red
  array[1] ── Channel 0 blue
  array[2] ── Channel 0 green
  ...
  array[21] ─ Channel 7 red
  array[22] ─ Channel 7 blue
  array[23] ─ Channel 7 green

• Could eliminate 24 instructions (96 clocks) of overhead
  by combining move_loop and zero_loop.  This would reduce
  the overhead from 1516 cycles to 1420 cycles.
  Additional speed improvements could be made by unrolling
  the innermost loop.

• Driver is hard-coded for 24 channels on pins 0 through 23

• There is no synchronization for the inputs.
  If the input values change while the driver is reading
  them then the output RGB values may be incorrect for that
  iteration.

• The driver could be adapted for use with an SPI or I²C GPIO
  chip (e.g. the Microchip MCP23S17) by modifying the inner
  loop of the driver.  Doing so would probably only reduce
  performance by a couple of percent.

• See "PWM demo.spin" and "I2C PWM.spin" for usage demos.

• The pulse width modulation code uses successive approximation
  to generate smooth 24-bit RBG output.  The pseudocode algorithm
  for a single channel is as follows:

  channel_value := BYTE ' The input value, 0..255
  target_intensity := 0
  current_intensity := 0
  repeat intensity from 0 to 255
        target_intensity += channel_value
        if ( target_intensity > current_intensity )
                current_intensity += 255
                led_output := ON
        else
                led_output := OFF
}

VAR
byte cog    ' Cog running the ASM LED driver

PUB start(input_buffer_address) : okay
  ' input_buffer_address contains is the address of the 24 byte RBG buffer
  stop
  okay := cog := cognew(@display_entry, @input_buffer_address) + 1

PUB stop
  if cog
    cogstop(cog~ - 1)

DAT
PasmCode      org       $000

display_entry
              ' Get the I2C buffer address
              mov       rbg_address,par                 ' PAR contains the I2C buffer address
              rdlong    rbg_address,rbg_address         ' Read the I2C buffer address

              ' Set pins 0,,23 to output
              and       dira, bits_mask2
              or        dira, bits_mask
'----------------------------------------------------------------------------------------------------------------------
:loop   ' Start of main loop

              ' Read 8 RBG values from HUB
              movd      :move_loop, #rbg                ' Set copy instruction destination to head of cog RBG buffer
              mov       cur_address, rbg_address        ' Set current hub address to start of hub RBG buffer
              mov       count, #(8*3)                   ' Set number of bytes to copy from hub to cog
:move_loop    rdbyte    0-0, cur_address                ' Read a byte (destination is current position in cog RBG buffer)
              add       :move_loop, incr_d              ' Point to next long in cog RBG buffer
              add       cur_address, #1                 ' Point to next byte in hub RBG buffer
              djnz      count,#:move_loop               ' Loop if there are more bytes to copy

              ' Zero out the PWM registers
              movs      :clear_t, #target               ' Set source...
              movd      :clear_t, #target               ' ...and destination of "target" clear instruction to head of hub's "target" buffer
              movs      :clear_c, #current              ' Set source...
              movd      :clear_c, #current              ' ...and destination of "current" clear instruction to head of hub's "current" buffer
              mov       count, #(8*3)                   ' Need to clear 24 longs in each buffer
:zero_loop
:clear_t      xor       0-0, 0-0                        ' Clear entry in "target" buffer
:clear_c      xor       0-0, 0-0                        ' Clear entry in "current" buffer
              add       :clear_t, incr_s_and_d          ' Point to next entry in "target" buffer
              add       :clear_c, incr_s_and_d          ' Point to next entry in "current" buffer
              djnz      count,#:zero_loop               ' Loop if there are more entries to clear

              ' Initialize display loop
              mov       display_count, #256             ' 256 intensity levels are supported (0..255)

:display_loop ' Start of display loop

              ' Zero the output bitfield
              xor       bits, bits                      ' zero == all channels off

              ' Point to start of target and current buffers
              movs      :tr_add, #rbg                   ' Set source of "target" addition to head of "RBG" buffer
              movd      :tr_add, #target                ' Set destination of "target" addition to head of "target" buffer
              movd      :c_add, #current                ' Set destination of "current" addition to head of "current" buffer
              movd      :tc_cmp, #current               ' Set source of target/current comparison to head of "current" buffer
              movs      :tc_cmp, #target                ' Set destination of target/current comparison to head of "target" buffer

              mov       field_count, #24                ' Need to process 24 channels per PWM step

:field_loop   ' Start of logic for a single output bit
:tr_add       add       0-0, 0-0                        ' Add the current RBG value to the current target value
              shr       bits, #1                        ' Shift bitfield to next channel
:tc_cmp       cmp       0-0, 0-0 wc                     ' Compare field's desired value to the value currently output   ( c := ( target < current ) )
                                                        ' If desired value is greater than or equal to the currently output value...
:c_add  if_c  add       0-0, #255                       ' ...add a full step (256) to the currently output value
        if_c  or        bits, high_bit                  ' ...and set the current pin to on

              ' Point to next entries in the "current", "target", and "rbg" buffers
              add       :tc_cmp, incr_s_and_d           ' Set the "target/current" comparison addresses to the next entries in the "target" and "current" buffers
              add       :tr_add, incr_s_and_d           ' Set the "target" and "rbg" addresses for the "target" addition statement to the next entries in the "target" and "rbg" buffers
              add       :c_add, incr_d                  ' Set the "current" address for "current" addition statement to the next entry in the "current" buffer

              ' End of logic for a single output bit
              djnz      field_count,#:field_loop        ' Loop if there are more pins to process

              mov       outa, bits                      ' Update LEDs
              djnz      display_count,#:display_loop    ' Loop if there are more PWM levels to process

              ' Pause then turn off all LEDs
              mov       count, #222                     ' This is equal to ( 9 * 24 ) + 8 - 2
                                                        ' i.e. ( field loop * channels ) - these 2 instructions
:pause_loop   djnz      count,#:pause_loop              ' Delay
              and       outa, bits_mask2                ' Turn off all output pins

              jmp       #:loop                          ' Jump back to start of main loop

'----------------------------------------------------------------------------------------------------------------------

incr_s_and_d  long      $00000201  ' Used to increment an instruction's source and destination fields by 1
incr_d        long      $00000200  ' Used to increment an instruction's destination field by 1
bits_mask     long      $00ffffff  ' Bitmask: all LED pins set
bits_mask2    long      $ff000000  ' Bitmask: all non-LED pins set
high_bit      long      $00800000  ' Output bit set in "bits" by a single iteration of the loop
                                   ' This gets shifted right 23 times for a final "bits" value between $00000000 and $00ffffff

rbg_address   res       1          ' Address of hub's RBG buffer
cur_address   res       1          ' Address of current location within hub's RBG buffer
rbg           res       (8*3)      ' 8-bit RBG values for each of 8 channels (each stored in a long, so 8 x 3 longs total)
bits          res       1          ' State of LEDs for a single iteration of the PWM loop
target        res       (8*3)      ' Desired values for each channel as of the current iteration the PWM loop
current       res       (8*3)      ' Actual (output) values for each channel as of the current iteration the PWM loop

count         res       1          ' General-purpose counter variable
display_count res       1          ' Current iteration of the PWM loop (256..0)
field_count   res       1          ' Current channel within the PWM loop (24..0)

              fit       $1f0

DAT
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
