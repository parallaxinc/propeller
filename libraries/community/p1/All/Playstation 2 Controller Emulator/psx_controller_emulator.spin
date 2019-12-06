{{
  This object emulates a Playstation controller, with support
  for all known Dual Shock controller commands.

  This emulator is based on my own reverse engineering notes:
  http://docs.google.com/View?docid=ddbmmwds_5cw4pk3

  Each controller emulator can have several input/output
  buffers attached to it:

    - At most one actuator buffer, for force-feedback data received from the PSX

    - At most NUM_STATE_BUFFERS state buffers, holding controller states to
      read when we're polled by the PSX. If multiple buffers are attached, their 
      data is mixed. Button state is OR'ed, axes and pressure-sensitive buttons
      are summed and clamped.

  -- Micah Dowty <micah@navi.cx>
}}

CON

  ' Pin assignments, starting with base_pin. These
  ' are the same as the pin assignments on the Unicone2
  ' controller connectors from pin 1 to pin 5.

  PIN_DAT = 0
  PIN_CMD = 1
  PIN_SEL = 2
  PIN_CLK = 3
  PIN_ACK = 4

  STATE_BUFFER_LEN = 18
  NUM_STATE_BUFFERS = 4

  ACTUATOR_BUFFER_LEN = 2
  NUM_ACTUATOR_BUFFERS = 4

  ' ACK timings, based on values observed on a real Dual Shock controller
  ACK_DELAY_US = 8
  ACK_WIDTH_US = 3

  ' Log base 2 of LED fade rate (in steps per clock)
  LED_FADE_RATE = 6

  ' Startup/reset delay, in milliseconds
  STARTUP_DELAY_MS = 200

  PADDING_BYTE = $5A

  DIGITAL_MODE = $40
  ANALOG_MODE = $70
  ESCAPE_MODE = $F0
  MODE_MASK = $F0

  REPLY_LEN_ESCAPE = $3
  REPLY_LEN_DIGITAL = $1
  REPLY_LEN_ANALOG = $3

  RESULT_FORMAT_ESCAPE = $0000003F
  RESULT_FORMAT_DIGITAL = $00000003
  RESULT_FORMAT_ANALOG = $0000003F

  ' ext_status fields which seem to identify controller type or capabilities.
  ' Use these as arguments to start() or set_controller_type().

  CONTROLLER_ANALOG = $02000201            ' Required for Guitar Hero to detect a guitar controller
  CONTROLLER_DUAL_SHOCK = $02000203        ' Required for the PS2 to initialize pressure-sensitive buttons
  
  ' Offsets within the cog communication area
  _base_pin = 0
  _ack_delay_ticks = _base_pin + 4
  _ack_width_ticks = _ack_delay_ticks + 4
  _controller = _ack_width_ticks + 4
  _startup_cnt = _controller + 4
  _led_pin = _startup_cnt + 4
  _actuator_ptr_list = _led_pin + 4
  _state_ptr_list = _actuator_ptr_list + (4 * NUM_ACTUATOR_BUFFERS)


VAR

  long  cog

  ' Communication area between cog and object
  long  base_pin
  long  ack_delay_ticks
  long  ack_width_ticks
  long  controller
  long  startup_cnt
  long  led_pin
  long  actuator_ptr_list[NUM_ACTUATOR_BUFFERS]
  long  state_ptr_list[NUM_STATE_BUFFERS]
        

PUB start(basepin, ledpin, controller_type) : okay

  '' Start a cog running a new controller emulator.
  '' The emulator initially has no attached buffers.
  ''
  '' The controller must be connected via 5 pins starting at basepin.
  '' 'controller_type' tells us what kind of controller to emulate.
  '' It must be one of our CONTROLLER_* constants.
  ''
  '' The emulator supports an optional active-high status LED. The
  '' LED will glow when the emulator is actively being polled by
  '' a console. To disable LED support, pass in -1 for ledpin.

  base_pin := basepin
  controller := controller_type
  ack_delay_ticks := ACK_DELAY_US * (clkfreq / 1000000)
  ack_width_ticks := ACK_WIDTH_US * (clkfreq / 1000000)
  startup_cnt := cnt + STARTUP_DELAY_MS * (clkfreq / 1000)
  led_pin := ledpin
  
  longfill(@state_ptr_list, 0, NUM_STATE_BUFFERS)
  longfill(@actuator_ptr_list, 0, NUM_ACTUATOR_BUFFERS)

  okay := cog := cognew(@entry, @base_pin) + 1


PUB stop

  '' Frees a cog.

  if cog
    cogstop(cog~ - 1)


PUB set_controller_type(controller_type)

  '' Change the emulator's controller type. This requires
  '' resetting the emulator completely. The emulator will be
  '' nonresponsive until its startup delay expires and the PS2
  '' completes its initialization sequence.
  ''
  '' This has no effect if controller_type is already current.

  if controller_type <> controller
    startup_cnt := cnt + STARTUP_DELAY_MS * (clkfreq / 1000)
    controller := controller_type

    cogstop(cog~ - 1)
    cog := cognew(@entry, @base_pin) + 1

    
PUB add_actuator_buffer(buffer) : okay | i

  '' Add an additional actuator buffer for this controller to write.
  '' 'buffer' must point to an area of at least ACTUATOR_BUFFER_LEN bytes.
  ''
  '' Returns TRUE on success, or FALSE if NUM_STATE_BUFFERS buffers
  '' are already attached.

  repeat i from 0 to NUM_ACTUATOR_BUFFERS - 1    
    if actuator_ptr_list[i] == 0
      actuator_ptr_list[i] := buffer
      okay := TRUE
      quit


PUB add_state_buffer(buffer) : okay | i

  '' Add an additional state buffer for this controller to read.
  '' 'buffer' must point to an area of at least STATE_BUFFER_LEN bytes.
  ''
  '' Returns TRUE on success, or FALSE if NUM_STATE_BUFFERS buffers
  '' are already attached.

  repeat i from 0 to NUM_STATE_BUFFERS - 1    
    if state_ptr_list[i] == 0
      state_ptr_list[i] := buffer
      okay := TRUE
      quit
  

PUB remove_actuator_buffer(buffer) : okay | i

  '' Remove an actuator buffer which was previously attached with
  '' add_actuator_buffer. Note that, since the controller emulator
  '' runs asynchronously, there is no guarantee that 'buffer'
  '' will not be accessed after this method returns.
  ''
  '' Returns TRUE on success, or FALSE if 'buffer' is not
  '' attached to the emulator.

  repeat i from 0 to NUM_ACTUATOR_BUFFERS - 1
    if actuator_ptr_list[i] == buffer
      actuator_ptr_list[i] := 0
      okay := TRUE
      quit


PUB remove_state_buffer(buffer) : okay | i

  '' Remove a state buffer which was previously attached with
  '' add_state_buffer. Note that, since the controller emulator
  '' runs asynchronously, there is no guarantee that 'buffer'
  '' will not be accessed after this method returns.
  ''
  '' Returns TRUE on success, or FALSE if 'buffer' is not
  '' attached to the emulator.

  repeat i from 0 to NUM_STATE_BUFFERS - 1
    if state_ptr_list[i] == buffer
      state_ptr_list[i] := 0
      okay := TRUE
      quit

  
DAT

                        org

        '------------------------------------------------------
        ' Entry point.

entry                   mov     t1, par                 ' Initialize all pin masks
                        add     t1, #_base_pin
                        rdlong  t2, t1
                        mov     dat_mask, #1
                        shl     dat_mask, t2

                        mov     cmd_mask, dat_mask
                        shl     cmd_mask, #1

                        mov     sel_mask, dat_mask
                        shl     sel_mask, #2

                        mov     clk_mask, dat_mask
                        shl     clk_mask, #3

                        mov     ack_mask, dat_mask
                        shl     ack_mask, #4

                        mov     clk_sel_mask, clk_mask
                        or      clk_sel_mask, sel_mask

                        call    #led_init

                        mov     t1, par                 ' Initialize ext_status according to controller type
                        add     t1, #_controller
                        rdlong  ext_status, t1

                        mov     t1, par                 ' Wait for startup_cnt
                        add     t1, #_startup_cnt
                        rdlong  t2, t1
                        waitcnt t2, #0


        '------------------------------------------------------
        ' Packet receive loop

receive_packet
                        call    #led_update             ' Update the status LED while we wait.              
                        test    sel_mask, ina wc        ' Make sure SEL is high (previous packet is ended)
              if_nc     jmp     #receive_packet

                        mov     dira, led_mask          ' All PSX outputs high-Z while not selected
                        mov     outa, #0
                        mov     byte_index, #0          ' Reset beginning of packet

:wait_sel_neg                                           ' Wait for a falling edge on SEL
                        call    #led_update             ' Update the status LED while we wait.
                        test    sel_mask, ina wc
              if_c      jmp     #:wait_sel_neg        

                        jmp     #receive_packet
                        
                        call    #txrx_byte              ' Read the address byte
                        xor     rx_data, #$01 nr,wz     ' Is this packet for a controller on slot 1?
              if_nz     jmp     #receive_packet         ' If not, ignore the rest of the packet.
                        call    #send_ack               ' Acknowledge the address byte
                        or      dira, dat_mask          ' Enable output driver

                        mov     tx_data, mode_byte      ' Send current mode and reply length
                        call    #txrx_byte              ' Receive command byte

                        xor     rx_data, #$40           ' All commands have 4 as their high nybble
                        and     rx_data, #$F0 nr,wz
              if_nz     jmp     #receive_packet         ' Not between $40 and $4F? Don't respond.

                        add     rx_data, #:cmd_table    ' Jump via the cmd_table
                        jmp     rx_data

:cmd_table              jmp     #cmd_init_pressure                              ' $40
                        jmp     #cmd_get_available_poll_results                 ' $41
                        jmp     #cmd_poll                                       ' $42
                        jmp     #cmd_escape                                     ' $43
                        jmp     #cmd_set_major_mode                             ' $44
                        jmp     #cmd_read_ext_status_1                          ' $45
                        jmp     #cmd_read_const_1                               ' $46
                        jmp     #cmd_read_const_2                               ' $47
                        jmp     #receive_packet                                 ' $48 (invalid)
                        jmp     #receive_packet                                 ' $49 (invalid)
                        jmp     #receive_packet                                 ' $4a (invalid)
                        jmp     #receive_packet                                 ' $4b (invalid)
                        jmp     #cmd_read_const_3                               ' $4c
                        jmp     #cmd_set_poll_cmd_format                        ' $4d
                        jmp     #receive_packet                                 ' $4e (invalid)
                        jmp     #cmd_set_poll_result_format                     ' $4f
                        
        
        '------------------------------------------------------
        ' Byte receive/transmit subroutine
        '
        ' The Playstation bus is full-duplex. We always transmit
        ' a byte concurrently with receiving a byte. This routine
        ' sends 'tx_data' while receiving 'rx_byte'.
        '
        ' Multiple entry points exist for various data widths.
        '
        ' Note that this routine does not enable the output driver
        ' for DAT. The caller is responsible for doing so only when
        ' this device has been addressed. The original PSX shares
        ' the same physical bus for controller and memory card
        ' accesses, so we must be sure not to create bus contention
        ' with the memory card.
        '
        ' Bits are output on the falling edge of CLK, input on the
        ' rising edge of CLK. Each byte begins with a falling edge.
        '
        ' The last rising edge is timestamped, for send_ack.

txrx                    test    sel_mask, ina wc        ' Abort if SEL went high
              if_c      jmp     #receive_packet

                        mov     t1, #8
:bit
                        test    tx_data, #1 wc
                        waitpne clk_mask, clk_sel_mask  ' Wait for CLK- or SEL+
                        muxc    outa, dat_mask          ' Write tx_data[0]
                        ror     tx_data, #1             ' Shift out tx_data[0]

                        test    sel_mask, ina wc        ' Abort if SEL goes high
              if_c      jmp     #receive_packet
                        
                        waitpne zero, clk_sel_mask      ' Wait for CLK+ or SEL+
                        test    cmd_mask, ina wc        ' Read CMD bit
                        mov     clk_posedge_cnt, cnt    ' Timestamp this rising edge                        
                        rcr     rx_data, #1             ' Shift into rx_data[31]

                        test    sel_mask, ina wc        ' Abort if SEL went high
              if_c      jmp     #receive_packet

                        djnz    t1, #:bit               ' Next bit...
txrx_ret                ret

txrx_byte               call    #txrx
                        rol     rx_data, #8             ' Right-justify and trim rx_byte               
                        and     rx_data, #$FF                          
txrx_byte_ret           ret

txrx_16                 call    #txrx
                        call    #send_ack
                        call    #txrx
                        rol     rx_data, #16                                                           
                        and     rx_data, mask_16bit
txrx_16_ret             ret

txrx_32                 call    #txrx                        
                        call    #send_ack
                        call    #txrx
                        call    #send_ack
                        call    #txrx
                        call    #send_ack
                        call    #txrx
txrx_32_ret             ret
                        

        '------------------------------------------------------
        ' send_ack subroutine.
        '
        ' This routine sends a timed ACK pulse based on ack_delay_ticks,
        ' ack_width_ticks, and the timestamp saved by the last txrx_byte.

send_ack
                        mov     t1, par
                        add     t1, #_ack_delay_ticks
                        rdlong  t2, t1                  ' Read ack_delay_ticks

                        mov     t1, par
                        add     t1, #_ack_width_ticks
                        rdlong  t3, t1                  ' Read ack_width_ticks

                        add     t2, clk_posedge_cnt     ' Add ack_delay_ticks to the +CLK timestamp

                        waitcnt t2, t3                  ' Wait for the ACK pulse to start, and update t2
                        or      dira, ack_mask          ' Pull ACK low

                        waitcnt t2, #0                  ' Wait for the ACK pulse to end
                        xor     dira, ack_mask          ' Float ACK

send_ack_ret            ret


        '------------------------------------------------------
        ' Command prologues
        '

        ' This is the prologue to normal non-escape commands.
        ' It acknowledges the command byte and sends a padding byte.
        ' The padding byte is NOT acknowledged.
begin_cmd
                        call    #send_ack
                        mov     tx_data, #PADDING_BYTE
                        call    #txrx_byte
begin_cmd_ret           ret

        ' Prologue for escape commands. If we're not in escape mode,
        ' reject this command. In this version, the padding byte is
        ' acknowledged.
begin_escape_cmd
                        mov     t1, mode_byte
                        and     t1, #MODE_MASK
                        xor     t1, #ESCAPE_MODE
              if_nz     jmp     #receive_packet

                        call    #begin_cmd
                        call    #send_ack
begin_escape_cmd_ret    ret


        '------------------------------------------------------
        ' Command: INIT_PRESSURE
        '
        ' This command performs unknown initialization for an individual
        ' pressure sensitive button.
        '
        ' Command data:
        '   0. Button number (0x00 - 0x0b, in the same order that
        '      the buttons are listed in the response packet)
        '   1. 0x02 (?)         
        '   2. 0x00 (?)
        '   3. 0x00 (?)
        '   4. 0x00 (?)
        '   5. 0x00 (?)
        '
        ' Response data
        '   0. 0x00 (?)
        '   1. 0x00 (?)
        '   2. 0x02 (?)
        '   3. 0x00 (?)
        '   4. 0x00 (?)
        '   5. 0x5a (Padding?)
          
cmd_init_pressure       call    #begin_escape_cmd

                        mov     tx_data, #0
                        call    #txrx_16
                        call    #send_ack

                        mov     tx_data, #2
                        call    #txrx_byte
                        call    #send_ack

                        mov     tx_data, #0
                        call    #txrx_16
                        call    #send_ack

                        mov     tx_data, #PADDING_BYTE
                        call    #txrx_byte

                        jmp     #receive_packet
          
          
        '------------------------------------------------------
        ' Command: GET_AVAILABLE_POLL_RESULTS
        ' 
        ' Returns:
        '    - 32-bit available_results flags (1 bit for each available byte of POLL data)
        '    - One more byte of flags, unused (0)
        '    - One padding byte

cmd_get_available_poll_results
                        call    #begin_escape_cmd

                        mov     tx_data, available_results
                        call    #txrx_32
                        call    #send_ack

                        mov     tx_data, #0
                        call    #txrx_byte
                        call    #send_ack

                        mov     tx_data, #PADDING_BYTE
                        call    #txrx_byte
                        call    #send_ack

                        jmp     #receive_packet


        '------------------------------------------------------
        ' Command: POLL/ESCAPE
        '
        ' The POLL and ESCAPE commands are substantially the same.
        ' This routine implements them both, by swapping in different
        ' rx_data handlers.
        '
        ' Arguments:
        '    - For ESCAPE, the first command-specific argument selects
        '      whether we're entering or exiting escape mode.
        '
        '    - For POLL, each argument may be mapped to an
        '      actuator by SET_POLL_CMD_FORMAT
        '
        ' Results:
        '    - For each bit set in result_format, returns one byte of data
        '      aggregated from all state buffers present in state_ptr_list.

cmd_escape              movs    poll_rx_callback, #pollcb_escape
                        jmp     #cmd_poll_or_escape                        
cmd_poll                movs    poll_rx_callback, #pollcb_poll
cmd_poll_or_escape      call    #begin_cmd

                        call    #led_bright

                        mov     byte_index, #0          ' Iterate over result bytes
                        mov     result_iter, result_format
poll_byte_loop          test    result_iter, #1 wc      ' C = 1, output this byte
              if_nc     jmp     #poll_skip_byte
              
                        ' Perform poll result mixing in various ways, depending on
                        ' what type of byte this is. The first two are buttons, the
                        ' next four are analog axes, and the rest are pressure sensors.

                        sub     byte_index, #2 nr,wc
              if_c      jmp     #mix_button_byte
                        sub     byte_index, #6 nr,wc
              if_c      jmp     #mix_axis_byte
                        jmp     #mix_pressure_byte
mix_ret

                        ' Note that we are acking the previous byte here. This lets us
                        ' perform result mixing and store actuator data while we wait for
                        ' the ACK delay. The extra time we save this way is critical to
                        ' support the 500 kbps mode used by some PS2 games.

                        call    #send_ack
                        call    #txrx_byte

                        ' Act on the received data via a callback that changes
                        ' depending on whether this is POLL or ESCAPE.

poll_rx_callback        jmp     #0
poll_rx_callback_ret

poll_skip_byte          add     byte_index, #1          ' Next byte...
                        shr     result_iter, #1 wz      ' Z = 1, this was the last byte
              if_nz     jmp     #poll_byte_loop
              
                        jmp     #receive_packet


                        '--------------------------------------
                        ' Poll RX callback: POLL command
                        '
                        ' This callback is responsible for storing rx_byte
                        ' in any applicable actuator buffers.
                        '
                        ' This also unconditionally kicks us out of
                        ' escape mode, if we were in it.

pollcb_poll
                        mov     mode_byte, preescape_mode_byte
                        mov     result_format, preescape_result_format

                        ' Determine which actuator this byte represents

                        sub     byte_index, #4 nr,wc    ' We only support the first 4 cmd bytes
              if_nc     jmp     #poll_rx_callback_ret

                        mov     t1, byte_index          ' Convert byte_index to a bit offset...
                        shl     t1, #3                  ' ... within cmd_format
                        mov     actuator_num, cmd_format 
                        shr     actuator_num, t1
                        and     actuator_num, #$FF      ' And extract the actuator_num for this byte_index.
                        
                        sub     actuator_num, #ACTUATOR_BUFFER_LEN nr,wc
              if_nc     jmp     #poll_rx_callback_ret   ' Ignore disabled or out-of-range actuators                        

                        ' Write this actuator value to all attached actuator buffers
              
                        mov     t2, par                 ' Point at the first actuator buffer
                        add     t2, #_actuator_ptr_list
                        mov     t3, #NUM_ACTUATOR_BUFFERS ' Count the remaining actuator buffers

:buffer                 rdlong  t4, t2 wz               ' Read the current buffer pointer
                        
                        add     t4, actuator_num        ' Offset by the actuator number
                        add     t2, #4                  ' Next buffer...
                        
              if_nz     wrbyte  rx_data, t4             ' Write the actuator data

                        djnz    t3, #:buffer
                        jmp     #poll_rx_callback_ret


                        '--------------------------------------
                        ' Poll RX callback: ESCAPE command
                        '
                        ' This callback switches into or out of escape mode,
                        ' depending on the value of the byte at byte_index 0.

pollcb_escape
                        xor     byte_index, #0 nr,wz
              if_nz     jmp     #poll_rx_callback_ret   ' Not byte_index 0, ignore it

                        xor     rx_data, #0 nr,wz

                        ' Exiting escape mode
              if_z      mov     mode_byte, preescape_mode_byte
              if_z      mov     result_format, preescape_result_format
              
                        ' Entering escape mode
              if_nz     mov     mode_byte, #(ESCAPE_MODE | REPLY_LEN_ESCAPE)                  
              if_nz     mov     result_format, #RESULT_FORMAT_ESCAPE
              
                        jmp     #poll_rx_callback_ret              
              

                        '--------------------------------------
                        ' Poll result mixer: Buttons.
                        '
mix_button_byte
                        mov     tx_data, #$FF           ' Default value, all buttons released
                        movs    mixer_callback, #button_mix_callback
                        jmp     #mixer

button_mix_callback     and     tx_data, t1             ' Logically OR the inverted buttons
                        jmp     #mixer_callback_ret


                        '--------------------------------------
                        ' Poll result mixer: Axes.
                        '
mix_axis_byte
                        mov     tx_data, #$80           ' Default value, centered
                        movs    mixer_callback, #axis_mix_callback
                        jmp     #mixer

axis_mix_callback       add     tx_data, t1             ' Add axes
                        sub     tx_data, #$80           ' Subtract the duplicate offset
                        maxs    tx_data, #$FF           ' Clamp
                        mins    tx_data, #$00
                        jmp     #mixer_callback_ret


                        '--------------------------------------
                        ' Poll result mixer: Pressure sensors.
                        '
mix_pressure_byte
                        mov     tx_data, #$00           ' Default value, no pressure
                        movs    mixer_callback, #pressure_mix_callback
                        jmp     #mixer

pressure_mix_callback   add     tx_data, t1             ' Combine pressure
                        maxs    tx_data, #$FF           ' Clamp
                        jmp     #mixer_callback_ret


                        '--------------------------------------
                        ' Generic poll result mixer. Expects the
                        ' default value to be set already. This
                        ' iterates t1 over each value to be mixed,
                        ' using a mixer callback routine pointed to
                        ' by the jmp instruction at mixer_callback.
                        '

mixer                   mov     t2, par                 ' Point at the first state buffer
                        add     t2, #_state_ptr_list
                        mov     t3, #NUM_STATE_BUFFERS  ' Count the remaining state buffers

mixer_buffer_loop       rdlong  t4, t2 wz               ' Read the state buffer pointer
                        
                        add     t4, byte_index          ' Offset by the current byte index
              if_nz     rdbyte  t1, t4                  ' Get the current byte at this buffer

mixer_callback
              if_nz     jmp #0                          ' Allow the callback to operate on this byte
mixer_callback_ret

                        add     t2, #4                  ' Next state buffer...
                        djnz    t3, #mixer_buffer_loop
                        jmp     #mix_ret


        '------------------------------------------------------
        ' Command: SET_MAJOR_MODE
        '
        ' Sets analog mode if the first byte is nonzero, digital mode
        ' otherwise. All reply bytes are zero. This command also resets
        ' various controller state, such as the actuator and reply byte
        ' mappings.

cmd_set_major_mode      call    #begin_escape_cmd

                        mov     tx_data, #0
                        call    #txrx_byte
                        call    #send_ack

                        xor     rx_data, #0 nr,wz

                        ' Digital mode
              if_z      mov     preescape_mode_byte, #(DIGITAL_MODE | REPLY_LEN_DIGITAL)
              if_z      mov     preescape_result_format, #RESULT_FORMAT_DIGITAL

                        ' Analog mode
              if_nz     mov     preescape_mode_byte, #(ANALOG_MODE | REPLY_LEN_ANALOG)
              if_nz     mov     preescape_result_format, #RESULT_FORMAT_ANALOG
                        muxnz   ext_status, extstatus_analog

                        call    #txrx_byte      ' Send 5 more zeroes
                        call    #send_ack
                        call    #txrx_32

                        jmp     #receive_packet


        '------------------------------------------------------
        ' Command: READ_EXT_STATUS_1
        '
        ' Response data:
        '   - 0x03 (?) on Dual Shock controller, 0x01 (?) for Guitar Hero controller
        '   - 0x02 (?)
        '   - 0x01 if the "Analog" light is on, 0x00 if it's off.
        '   - 0x02 (?)
        '   - 0x01 (?)
        '   - 0x00 (?)

cmd_read_ext_status_1   call    #begin_escape_cmd

                        mov     tx_data, ext_status
                        call    #txrx_32
                        call    #send_ack

                        mov     tx_data, #$0001
                        call    #txrx_16         

                        jmp     #receive_packet


        '------------------------------------------------------
        ' Command: READ_CONST_1/2/3
        '
        ' These commands returns unknown constant data. The
        ' first command byte is always an address offset. The
        ' first two response bytes are always zero.

cmd_read_const_1        movs    const_ptr, #constdata_1
                        jmp     #cmd_read_const
cmd_read_const_2        movs    const_ptr, #constdata_2
                        jmp     #cmd_read_const
cmd_read_const_3        movs    const_ptr, #constdata_3
cmd_read_const          call    #begin_escape_cmd

                        mov     tx_data, #0             ' First byte is const address
                        call    #txrx_byte
const_ptr               add     rx_data, #0             ' This is filled in with a constdata_* address
                        movs    :indirect, rx_data

                        call    #send_ack               ' Unused (zero) byte
                        call    #txrx_byte
                        call    #send_ack
 
:indirect               mov     tx_data, 0              ' Load tx_data from the computed pointer
                        call    #txrx_32                ' .. and send the constant word.

                        jmp     #receive_packet

                        
        '------------------------------------------------------
        ' Command: SET_POLL_CMD_FORMAT
        '
        ' Sets cmd_format, the mapping from poll bytes to actuator indices.
        ' Our return value is the previous cmd_format.
        '
        ' We only use the first 32 bits. The last two actuator bytes are ignored.

cmd_set_poll_cmd_format call    #begin_escape_cmd

                        mov     tx_data, cmd_format
                        call    #txrx_32
                        call    #send_ack
                        mov     cmd_format, rx_data

                        mov     tx_data, mask_16bit
                        call    #txrx_16

                        jmp     #receive_packet

                        
        '------------------------------------------------------
        ' Command: SET_POLL_RESULT_FORMAT
        '
        ' Sets result_format, the bitmask of poll result bytes that the
        ' console wishes to receive. This command is typically used to
        ' enable and disable pressure-sensitive buttons.
        '
        ' Note that the new result length doesn't take effect until we leave
        ' escape mode. (Escape mode has a fixed result format, in order to
        ' match the fixed reply length.)

cmd_set_poll_result_format
                        call    #begin_escape_cmd

                        mov     tx_data, #0             ' Always 00 00 00 00
                        call    #txrx_32
                        call    #send_ack
                        mov     preescape_result_format, rx_data

                        mov     tx_data, #0             ' Always 00
                        call    #txrx_byte
                        call    #send_ack

                        mov     tx_data, #PADDING_BYTE
                        call    #txrx_byte

                        ' Count the number of one bits in preescape_result_format,
                        ' and use it to set the length portion of preescape_result_format.

                        mov     t1, #0
                        mov     t2, preescape_result_format
:bit                    test    t2, #1 wc
              if_c      add     t1, #1
                        shr     t2, #1 wz
              if_nz     jmp     #:bit

                        and     preescape_mode_byte, #$F0
                        shr     t1, #1
                        add     preescape_mode_byte, t1

                        jmp     #receive_packet


        '------------------------------------------------------
        ' LED Driver.
        '
        ' We use Counter 1 to drive the LED with PWM. It hops to full brightness
        ' when 'led_bright' is called, and gradually fades thereafter.

                        ' Initialize the LED
led_init                mov     t1, par
                        add     t1, #_led_pin
                        rdlong  t2, t1                  ' Read led_pin
                        and     t2, #$3F
                        xor     t2, #$3F nr,wz          ' Was this -1?

              if_nz     movs    ctra, t2                ' Set CTRA pin number
              if_nz     movi    ctra, #%00110_000       ' Set CTRA to single-ended DUTY mode
              if_z      movi    ctra, #0                ' Disable CTRA if led_pin == -1

              if_nz     mov     led_mask, #1            ' If LED is enabled, set led_mask correctly
              if_nz     shl     led_mask, t2
              if_z      mov     led_mask, #0            ' Zero the led_mask if led_pin == -1
                        mov     dira, led_mask
              
                        call    #led_bright             ' Start out with a bright pulse (lamp test)
led_init_ret            ret


                        ' Hop to full brightness (Reset the fade)
led_bright              mov     led_timestamp, cnt
                        mov     frqa, max_int
                        mov     led_fade_active, #1
led_bright_ret          ret


                        ' Update the LED's fade progress
led_update              
                        test    led_fade_active, #1 wc
              if_nc     jmp     #:done

                        mov t1, cnt
                        sub     t1, led_timestamp       ' How long since the last led_bright?

                        shl     t1, #LED_FADE_RATE-1    ' Multiply by fade rate, while extracting the
                        shl     t1, #1 wc               '   bit to the left of the multiplied MSB.
                                                        '   If C=1, we're done fading to zero and we
                                                        '   need to clamp in order to avoid wraparound.

              if_c      mov     frqa, #0
              if_c      mov     led_fade_active, #0
                        
              if_nc     mov     t2, max_int             ' Subtract from max brightness
              if_nc     sub     t2, t1 wc
              if_nc     mov     frqa, t2

:done
led_update_ret          ret


        '------------------------------------------------------
        ' Constant data.

zero                    long    0
mask_16bit              long    $FFFF
max_int                 long    $FFFFFFFF

available_results       long    $0003FFFF
extstatus_analog        long    $00010000

constdata_1             long    $0a000201
                        long    $14010101
constdata_2             long    $00010002
constdata_3             long    $00000400
                        long    $00000700


        '------------------------------------------------------
        ' Initialized data.

mode_byte               long    DIGITAL_MODE | REPLY_LEN_DIGITAL
preescape_mode_byte     long    DIGITAL_MODE | REPLY_LEN_DIGITAL
result_format           long    RESULT_FORMAT_DIGITAL
preescape_result_format long    RESULT_FORMAT_DIGITAL
cmd_format              long    $00000000

        '------------------------------------------------------
        ' Uninitialized data.

ext_status              res     1               ' "Extended status" bits. Mostly controller capabilities?

t1                      res     1
t2                      res     1
t3                      res     1
t4                      res     1

tx_data                 res     1
rx_data                 res     1
clk_posedge_cnt         res     1
byte_index              res     1
result_iter             res     1
actuator_num            res     1

led_timestamp           res     1
led_fade_active         res     1

dat_mask                res     1               ' Output, high-z when not addressed
cmd_mask                res     1               ' Input
clk_mask                res     1               ' Input
sel_mask                res     1               ' Input
ack_mask                res     1               ' Output, open-collector
clk_sel_mask            res     1
led_mask                res     1

                        fit
                        