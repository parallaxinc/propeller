''***************************************************************************
''* TXX.SPIN
''*
''* Fast Serial Data Transmitter with Extended functionality
''* Copyright (C) 2018 Jac Goudsmit
''*
''* Based on tx.spin, (C) 2011 Barry Meaker
''* (See https://obex.parallax.com/object/619)
''*
''* TERMS OF USE: MIT License. See bottom of file.                                                            
''***************************************************************************
''
'' This module implements a fast serial transmitter (up to 8 megabits per
'' second when running at 80MHz). It cannot receive, and it doesn't implement
'' flow control.
''
'' All the formatting routines (e.g. for printing strings, decimal values,
'' hexadecimal values and binary values) were written in PASM, so this module
'' makes it easy to generate formatted output from another PASM cog.
'' Unfortunately this make the module rather big; however, if you're short
'' on space, it should be easy to prune away things you don't need, or
'' create your own module by extracting the code that you need.
''
'' A cog is dedicated to transmitting data on a single pin, based on commands
'' that are passed through a single longword. That way, the module can
'' easily be used from Spin as well as PASM. Please note: the code does not
'' protect against conflicts between multiple other cogs sending commands.
'' This race condition is easyis easy to mitigate by adding code that uses a
'' lock. 
''
'' The supported commands consist of an input mode, an output mode and some
'' parameters to the mode.
''
'' Input modes:
'' - in_BYTE: The cog reads values from the hub, one byte at a time.
'' - in_WORD: The cog reads values from the hub, one word at a time.
'' - in_LONG: The cog reads values from the hub, one long at a time.   
'' - in_SPEC: Special input mode: print strings / buffers or perform a reset. 
''
'' Output modes for BYTE, WORD and LONG input modes:
'' - out_DEC: The values are printed as unsigned decimal numbers.
'' - out_SGD: The values are printed as signed decimal numbers. 
'' - out_HEX: The values are printed as hexadecimal numbers.
'' - out_BIN: The values are printed as binary numbers.
''
'' Output modes for SPEC input mode:
'' - out_CHAR: Bytes from the hub are sent to the serial port directly.
'' - out_FILT: Same as CHAR but unprintable characters are replaced by "."
'' - out_DUMP: Generate a printable hex dump of hub memory.
'' - out_RSET: Reset the baud rate and pin number.     
''
'' Length parameter for DEC, SGD, HEX, BIN, CHAR, FILT and DUMP modes:
'' - 0=Read and send items to the output until an item with value 0 is
''   encountered. The item with value 0 is not printed.
'' - nonzero=Read and print the given number of items, regardless of
''   the values of the items.
''
'' Address parameter for DEC, SGD, HEX, BIN, CHAR, FILT and DUMP modes:
'' - Hub address of the (first) item to print.
''
'' Pin parameter for RSET mode:
'' - Output pin to use for serial data
''
'' Bittime parameter for RSET mode:
'' - Number of clock cycles per bit, i.e. (clkfreq / baudrate), min value=10  
''
'' This module only contains the "bare necessities" for Spin functions to use
'' the PASM code:
'' - Start and stop the cog
'' - Wait for the cog to finish sending data
'' - Wait for previous command to finish, and send the next command
'' The demo module contains further Spin functions that you might want to use
'' to make it easier to control the cog. 
''   
'' See the DAT section further down for more information.
''
''-----------------REVISION HISTORY-----------------
'' v1.0 - 2011-04-27 Original "tx.spin" by Barry Meaker
'' v2.0 - 2018-01-06 Various enhancements by Jac Goudsmit

CON

  ' These values are only used when running this module by itself (demo mode).
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000


CON

  ' Bits in the command word for non-reset commands
  #0
  
  sh_ADDR0                      '\
  sh_ADDR1                      '|
  sh_ADDR2                      '|
  sh_ADDR3                      '|
                                '|
  sh_ADDR4                      '|
  sh_ADDR5                      '|
  sh_ADDR6                      '|
  sh_ADDR7                      '|
                                '| Hub address for (first) item
  sh_ADDR8                      '|
  sh_ADDR9                      '|
  sh_ADDR10                     '|
  sh_ADDR11                     '|
                                '|
  sh_ADDR12                     '|
  sh_ADDR13                     '|
  sh_ADDR14                     '|
  sh_ADDRH                      '/

  sh_LEN0                       '\
  sh_LEN1                       '|
  sh_LEN2                       '|
  sh_LEN3                       '|
                                '|
  sh_LEN4                       '|
  sh_LEN5                       '| Number of items to process
  sh_LEN6                       '| (0=stop when there is an item with value 0
  sh_LEN7                       '|
                                '|
  sh_LEN8                       '|
  sh_LEN9                       '|
  sh_LEN10                      '|
  sh_LENH                       '/

  sh_OUT0                       '\
  sh_OUTH                       '/ Output format

  sh_IN0                        '\
  sh_INH                        '/ Input format


  ' Bits in the command word for the reset command
  #0
  
  sh_BITTIME0                   '\
  sh_BITTIME1                   '|
  sh_BITTIME2                   '|
  sh_BITTIME3                   '|
                                '|
  sh_BITTIME4                   '|
  sh_BITTIME5                   '|
  sh_BITTIME6                   '|
  sh_BITTIME7                   '|
                                '|
  sh_BITTIME8                   '|
  sh_BITTIME9                   '| Bit time in clock cycles
  sh_BITTIME10                  '|
  sh_BITTIME11                  '|
                                '|
  sh_BITTIME12                  '|
  sh_BITTIME13                  '|
  sh_BITTIME14                  '|
  sh_BITTIME15                  '|
                                '|
  sh_BITTIME16                  '|
  sh_BITTIME17                  '|
  sh_BITTIME18                  '|
  sh_BITTIMEH                   '/
  
  sh_RESERVED20                 '\
  sh_RESERVED21                 '| Reserved
  sh_RESERVED22                 '/

  sh_PIN0                       '\
  sh_PIN1                       '|
  sh_PIN2                       '| Pin number for TXD
  sh_PIN3                       '|
  sh_PINH                       '/

  sh_RESET28                    ' Always 1 for reset
  sh_RESET29                    ' Always 1 for reset                        
  sh_RESET30                    ' Always 0 for reset                        
  sh_RESET31                    ' Always 0 for reset
                                        
  ' Input modes (encoded as inmode << sh_IN0)
  #0
  in_SPEC                       ' Special: direct characters or reset
  in_BYTE                       ' Byte(s)
  in_WORD                       ' Word(s)
  in_LONG                       ' Long(s)

  ' Output modes (encoded as outmode << sh_OUT0)
  ' Only valid for inmodes BYTE, WORD or LONG
  #0
  out_DEC                       ' Unsigned Decimal
  out_SGD                       ' Signed Decimal
  out_HEX                       ' Hexadecimal
  out_BIN                       ' Binary

  ' Output modes (encoded as outmode << sh_OUT0)
  ' Only valid for in_SPEC
  #0
  out_CHAR                      ' Character(s)
  out_FILT                      ' Filtered char(s) (unprintables sent as '.')
  out_DUMP                      ' Generate hexdump of memory area                        
  out_RSET                      ' Reset baud rate and pin number

  ' Additional values for clarity in Spin code
  mask_ZEROTERM = (0 << sh_LEN0)  ' No length parameter=end at 0-item                        
  mask_SINGLE   = (1 << sh_LEN0)  ' Single item (character or longword)                            

  ' Bitmasks for easy command composing
  ' All masks marked *1 should be combined with an address, and a
  ' length shifted left by sh_LEN0.
  ' All masks marked *2 should be combined with a bit time in clock
  ' cycles, and a pin number shifted left by sh_PIN0
  ' If you don't use a mask and simply pass an address to the Str
  ' function, the value will be interpreted as a nul-terminated string.
  mask_BYTE_DEC = (in_BYTE << sh_IN0) | (out_DEC  << sh_OUT0) '\
  mask_BYTE_SGD = (in_BYTE << sh_IN0) | (out_SGD  << sh_OUT0) '|
  mask_BYTE_HEX = (in_BYTE << sh_IN0) | (out_HEX  << sh_OUT0) '|
  mask_BYTE_BIN = (in_BYTE << sh_IN0) | (out_BIN  << sh_OUT0) '|   
  mask_WORD_DEC = (in_WORD << sh_IN0) | (out_DEC  << sh_OUT0) '|
  mask_WORD_SGD = (in_WORD << sh_IN0) | (out_SGD  << sh_OUT0) '|
  mask_WORD_HEX = (in_WORD << sh_IN0) | (out_HEX  << sh_OUT0) '|
  mask_WORD_BIN = (in_WORD << sh_IN0) | (out_BIN  << sh_OUT0) '| *1
  mask_LONG_DEC = (in_LONG << sh_IN0) | (out_DEC  << sh_OUT0) '|
  mask_LONG_SGD = (in_LONG << sh_IN0) | (out_SGD  << sh_OUT0) '|
  mask_LONG_HEX = (in_LONG << sh_IN0) | (out_HEX  << sh_OUT0) '|
  mask_LONG_BIN = (in_LONG << sh_IN0) | (out_BIN  << sh_OUT0) '|
  mask_CHAR     = (in_SPEC << sh_IN0) | (out_CHAR << sh_OUT0) '|
  mask_FILT     = (in_SPEC << sh_IN0) | (out_FILT << sh_OUT0) '|
  mask_DUMP     = (in_SPEC << sh_IN0) | (out_DUMP << sh_OUT0) '/
  mask_RSET     = (in_SPEC << sh_IN0) | (out_RSET << sh_OUT0) '  *2  
  
  
VAR

  long  cog           ' Cog ID + 1

  ' Following are used by the PASM code
  long  cmd           ' Command
  long  benchmark     ' Number of cycles used by previous command

PUB Start(par_txpin, par_baudrate)
'' Starts serial transmitter in a new cog.
''
'' par_txpin      (long): Pin number (0..31)
'' par_baudrate   (long): Number of bits per second (clkfreq/10 .. clkfreq/$F_FFFF)
''
'' Returns (ptr to long): Address of command, or 0 on failure                  

  ' Stop the cog if it's running
  Stop

  ' Set the command to reset with the given pin number and baud rate
  cmd := mask_RSET | (par_txpin << sh_PIN0) | ((clkfreq / par_baudrate) << sh_BITTIME0)
  
  if (cog := cognew(@main, @cmd) + 1)
    result := @cmd

PUB Stop
'' Stop the txx cog, if any.

  if cog
    cogstop(cog - 1)

PUB Wait
'' Wait until previous command is done.
''
'' Returns (long) number of clock cycles that were needed to execute the
'' last command.
''
'' This can be used to ensure that buffers that are used in commands are not
'' overwritten while the cog is processing them.
''
'' The result value is the number of cycles that the command took to finish.

  repeat until cmd == 0

  result := benchmark  

PUB Str(par_cmd)
'' Send string or command
''
'' par_cmd (long)               : Command
'' 
'' The parameter can either be a 16-bit address of a nul-terminated string, or
'' a command composed in spin, as described in the documentation at the top of
'' this source file.                      

  ' Wait until any previous command has finished
  repeat until cmd == 0

  ' Set command for string
  cmd := par_cmd {implicit: constant((in_CHAR << sh_I0) | (out_CHAR << sh_Q0) | (0 << sh_LEN0)) | parm_cmd }

DAT
'' Each command to the PASM code is a single longword that has the following
'' format:
''
'' %II_QQ_LLLL_LLLL_LLLL_AAAA_AAAA_AAAA_AAAA
''  --                                       Input mode (see below)
''     --                                    Output mode (see below)
''        -------------                      Length (0=stop at value 0)
''                      -------------------  Hub addr for data (0=nop)
''
'' When resetting, the command is formatted as follows:
'' %0011_PPPPP_RRR_TTTT_TTTT_TTTT_TTTT_TTTT
''  ----                                     Always %0011 for reset
''       -----                               Pin number for TXD
''             ---                           Reserved
''                 ------------------------  Bit time in cycles
''
'' The input mode bits determine how the cog reads data from the hub.
'' It can read values in bytes, words or longs, or it can read bytes as
'' characters that are sent directly to the serial output.
''
'' II=%00 read chars (length is in bytes) or perform special function
''    %01 read bytes (length is in bytes)
''    %10 read words (length is in words)
''    %11 read longs (length is in longs)
''
'' The output mode bits determine how the cog formats the output. The meaning
'' of the bits depends on whether the input mode is set to %00 or to another
'' value. For non-character output, when printing multiple values,
'' values are separated by spaces.
''
'' For inmode==0:
'' QQ=%00 send characters directly to output
''    %01 send printable characters directly to output, replace others by '.'
''    %10 send hexdump of memory area
''    %11 reset cog
''          
'' For inmode<>0:
'' QQ=%00 send unsigned decimal 
''    %01 send signed decimal ('-' prefix for negative, no prefix otherwise)
''    %10 send hexadecimal padded with 0
''    %11 send binary padded with 0 
''
'' Examples:
'' - To print a nul-terminated string at address ABCD, use code $0000ABCD
'' - To print a $123 byte buffer at address ABCD, use code $0123ABCD
'' - To print a single character at address ABCD, use $0001ABCD
'' - To print a hexdump of a nul-terminated string at address ABCD: $6000ABCD
'' - To print a hexdump of a $3EF byte buffer at ABCD: $63EFABCD
'' - To print the unsigned decimal value of the longword at ABCD: $C001ABCD
''
'' All combinations of bits are valid in the command longword, but value
'' $0000_0000 is reserved to indicate that the cog has finished a command
'' and/or has nothing to do. That value corresponds to a command that would 
'' print a nul-terminated string starting at address $0000, and it's unlikely
'' that any application would be in a situation where it would need to do
'' that. If you application does need to do it, it can work around it as
'' follows:
'' 1. Test if the byte at location $0000 is zero. If it is, you're done.
'' 2. Otherwise: use command $0001_0000 to print the single character at
''    location $0000, then wait until the cog resets the command to 0.
'' 3. Then used the command $0000_0001 to print the zero-terminated string at
''    location $0001.
''
'' The Demo module generates some benchmarks using the built-in benchmarking
'' facility.


DAT
                        org  0


                        '======================================================================
                        ' Initialization
                        
main
                        ' Init benchmark pointer
                        mov     main_pbenchmark, PAR
                        add     main_pbenchmark, #4
                        
                        jmp     #main_loop_start


                        '======================================================================
                        ' Item loop
                        '                        
                        ' The following code processes items (bytes, words, longs) until the
                        ' command is done
                        ' The instructions are modified depending on input mode, output mode,
                        ' length parameter and runtime state.

item_loop_separator
                        ' When printing values (not characters), print a separator between
                        ' items.
                        mov     chr_char, #" "
                        call    #chr_send

main_end_outmode_init
                        ' Execution lands here after the output mode initializer is done
item_loop_no_separator
                        ' Execution lands here when printing strings or buffers (not values)

                        ' Load an item
                        ' This is changed to the appropriate RD... instruction
item_ins_load           rdbyte  (x), (item_address) wz

                        ' Take action if the item was zero
                        ' If count was initialized to nonzero, this is changed to a NOP  
item_ins_bail if_z      jmp     #(main_endcmd)

                        ' Process the item
                        ' This is replaced depending on the output format
item_ins_process        jmpret  (0), #(0)

                        ' Bump source address
                        add     item_address, item_numbytes
                        
                        ' Next item
                        ' If the length parameter was zero, the djnz is replaced by a jmp
item_ins_nextitem       djnz    (item_count), #(item_loop_separator)

                        ' Fall through to end the command


                        '======================================================================
                        ' Command finished
                        '
                        ' Execution lands here when a command is done
                        
main_endcmd
                        wrlong  zero, PAR               ' Clear command code

                        ' Update benchmark output in the hub
                        mov     x, CNT
                        sub     x, main_starttimestamp
                        wrlong  x, main_pbenchmark

                        ' This is where execution enters the main loop at initialization time.
                        ' The Spin code initializes the command to RSET before starting the
                        ' cog, so that's the first thing that gets done.
main_loop_start

                        '======================================================================
                        ' Get and process incoming command

main_readcmd
                        ' Read command, repeat until it's nonzero
                        rdlong  main_command, PAR wz
              if_z      jmp     #main_readcmd

                        ' Save start timestamp for benchmarking
                        mov     main_starttimestamp, CNT
                                                
                        ' Save address (invalid for out_RSET)
                        mov     item_address, main_command
                        'shr     item_address, #sh_ADDR0
                        and     item_address, mask_address

                        ' Save length (invalid for out_RSET)
                        mov     item_count, main_command
                        shr     item_count, #sh_LEN0
                        and     item_count, mask_count wz ' Z=1 to stop at a 0-item                                                

                        ' If count is zero, stop at a zero-item, and loop unconditionally
                        ' If count is nonzero, use a DJNZ to count down the items
              if_nz     mov     item_ins_bail, ins_nop
              if_nz     mov     item_ins_nextitem, ins_djnzitemloop
              if_z      mov     item_ins_bail, ins_ifjmpend
              if_z      mov     item_ins_nextitem, ins_jmpitemloop                                               

                        ' Save output mode
                        mov     main_outmode, main_command
                        shr     main_outmode, #sh_OUT0
                        and     main_outmode, mask_outmode                        
                        
                        ' Save input mode
                        mov     main_inmode, main_command
                        shr     main_inmode, #sh_IN0
                        and     main_inmode, mask_inmode wz ' Z=1 for character/reset mode

                        ' Select the output mode initializer jump table based on whether the
                        ' input mode is %00 (in_SPEC) or not.
              if_z      movs    main_ins_outmode_tab, #jmptab_outmode_spec ' Use special table
              if_nz     movs    main_ins_outmode_tab, #jmptab_outmode_b_w_l ' Byte/Word/Long

                        ' Execute input mode initializer based on jump table 
                        mov     x, main_inmode
                        add     x, #jmptab_inmode
                        jmp     x

                        ' All input mode initializers jump to this location.
                        ' The input mode initializers are written as subroutines but
                        ' because they are called from the jump tables, they can't be called
                        ' with a CALL (or JMPRET) instruction, because the address of the
                        ' return instruction isn't known when we jump into the table.
                        ' So this address is hard-coded in the input mode initializers'
                        ' return JMP instruction and the jump table uses JMP (not JMPRET)
                        ' to go to the selected input mode initializer.
main_end_inmode_init
                        
                        ' Execute output mode initializer based on jump table
                        ' The table that is used depends on whether the input mode is
                        ' %00 (in_SPEC) or not. It is initialized above.
                        mov     x, main_outmode
main_ins_outmode_tab    add     x, #(0)                 ' Modified depending on inmode 
                        jmp     x


                        '======================================================================
                        ' Input-mode initializers
                        '
                        ' These must run before the output initializers because they depend on
                        ' each other's data.

                        '----------------------------------------------------------------------                        
                        ' in_SPEC: Init for special operations (characters, hexdump, reset)
                        
init_inmode_spec
                        ' When in_SPEC is used to accomplish a reset, skip over the
                        ' following initialization code. This is technically not necessary
                        ' (the values aren't used during further processing) but it saves some
                        ' time. 
                        cmp     main_outmode, #out_RSET wz ' Z=1 when resetting
              if_z      jmp     init_inmode_spec_ret    ' NOTE: intentional indirect jump

                        ' Fall through to in_BYTE initializer

                        '----------------------------------------------------------------------
                        ' in_BYTE: Init for processing bytes
init_inmode_byte
                        mov     item_numbytes, #1       ' Each iteration goes to next byte
                        mov     dec_numdigits, #3       ' "255" is worst case dec value
                        mov     item_unusedbits, #24    ' Each item starts with 24 unused bits
                        mov     item_ins_load, ins_rdbyte ' Load data as byte
init_inmode_spec_ret
init_inmode_byte_ret    jmp     #main_end_inmode_init

                        '----------------------------------------------------------------------                        
                        ' in_WORD: Init for processing words
init_inmode_word
                        mov     item_numbytes, #2       ' Each iteration goes to next word
                        mov     dec_numdigits, #5       ' "65535" is worst case dec value
                        mov     item_unusedbits, #16    ' Each item starts with 16 unused bits
                        mov     item_ins_load, ins_rdword ' Load data as word

init_inmode_word_ret    jmp     #main_end_inmode_init

                        '----------------------------------------------------------------------
                        ' in_LONG: Init for processing longs
init_inmode_long
                        mov     item_numbytes, #4       ' Each iteration goes to next long
                        mov     dec_numdigits, #10      ' "4294967295" is worst case dec value
                        mov     item_unusedbits, #0     ' Each item starts with 0 unused bits
                        mov     item_ins_load, ins_rdlong ' Load data as long

init_inmode_long_ret    jmp     #main_end_inmode_init


                        '======================================================================
                        ' Output mode initializers for in_SPEC

                        '----------------------------------------------------------------------
                        ' in_SPEC and out_CHAR: Init for printing a string         
init_spec_string
                        movd    item_ins_load, #chr_char
                        mov     item_ins_process, ins_call_char
                        movs    item_ins_nextitem, #item_loop_no_separator ' Disable separators
                        
init_spec_string_ret    jmp     #main_end_outmode_init


                        '----------------------------------------------------------------------                        
                        ' in_SPEC and out_FILT: Init for printing a filtered string 
init_spec_filter
                        movd    item_ins_load, #chr_char       
                        mov     item_ins_process, ins_call_filter ' Filter byte, send to output
                        
init_spec_filter_ret    jmp     #main_end_outmode_init                                       


                        '----------------------------------------------------------------------                        
                        ' in_SPEC and out_DUMP: Init for generating a hexdump
                        '
                        ' In this mode, execution doesn't return to the main loop.
init_spec_hexdump
                        ' Set the start address of the first line to the requested address
                        ' modulo 16 so that hex dumps always start at a paragraph border
                        mov     hexdump_lineaddr, item_address
                        and     hexdump_lineaddr, vFFF0h

                        ' Calculate the end address so that irrelevant data can be skipped.
                        mov     hexdump_endaddr, item_address
                        add     hexdump_endaddr, item_count
                        sub     hexdump_endaddr, #1

                        ' Start the first line with the requested start address
                        mov     hex_value, item_address
                        jmp     #hexdump_lineloop_start
                         
hexdump_lineloop                                    
                        ' At the start of the line, print the address as hex word

                        ' Set hex value to line address
                        mov     hex_value, hexdump_lineaddr

hexdump_lineloop_start
                        ' Execution enters here so that the first printed address is the
                        ' requested start address
                                                
                        ' Prepare for printing hex word
                        call    #init_inmode_word       ' Destroys return instruction
                        movs    init_inmode_word_ret, #main_end_inmode_init ' Recover
                        call    #init_outmode_hex       ' Destroys return instruction        
                        movs    init_outmode_hex_ret, #main_end_outmode_init ' Recover
                        call    #hex_send
                        
                        ' Separator after the address
                        mov     chr_char, #" "
                        call    #chr_send

                        ' Prepare for printing hex bytes
                        call    #init_inmode_byte       ' Destroys return instruction
                        movs    init_inmode_byte_ret, #main_end_inmode_init ' Recover
                        call    #init_outmode_hex       ' Destroys return instruction
                        movs    init_outmode_hex_ret, #main_end_outmode_init ' Recover
                        
                        ' Print 16 hex values
                        mov     hexdump_addr, hexdump_lineaddr
                        mov     hexdump_count, #16

hexdump_hexloop                         
                        ' Check if data is relevant
                        ' i.e. start =< current < end
                        cmp     hexdump_endaddr, hexdump_addr wc ' C=0 if current < end                      
              if_nc     cmp     hexdump_addr, item_address wc ' C=0 if start =< current =< end                       

                        ' Print characters for irrelevant values
              if_c      mov     chr_char, #" "
              if_c      call    #chr_send
              if_c      mov     chr_char, #" "
              if_c      call    #chr_send
              
                        ' Print hex value of byte
              if_nc     rdbyte  hex_value, hexdump_addr
              if_nc     call    #hex_send

                        ' Print separator after hex byte
                        cmp     hexdump_count, #8 wz    ' Z=1 if halfway across line
              if_z      mov     chr_char, #"-"
              if_nz     mov     chr_char, #" "
                        call    #chr_send

                        ' Bump address
                        add     hexdump_addr, #1

                        ' Repeat
                        djnz    hexdump_count, #hexdump_hexloop

                        ' Print separator
                        mov     chr_char, #" "
                        call    #chr_send
                        
                        ' Print 16 filtered characters
                        mov     hexdump_addr, hexdump_lineaddr
                        mov     hexdump_count, #16

hexdump_charloop
                        ' Check if data is relevant                        
                        ' i.e. start =< current < end
                        cmp     hexdump_endaddr, hexdump_addr wc ' C=0 if current < end                      
              if_nc     cmp     hexdump_addr, item_address wc ' C=0 if start =< current =< end                       

                        ' Print a space for irrelevant bytes
              if_c      mov     chr_char, #" "
              if_nc     rdbyte  chr_char, hexdump_addr
                        call    #chr_filter

                        ' Bump address
                        add     hexdump_addr, #1

                        ' Repeat
                        djnz    hexdump_count, #hexdump_charloop

                        ' Print end of line
                        mov     chr_char, #13
                        call    #chr_send

                        ' If we're still inside the requested address range, print the
                        ' next line.
                        cmp     hexdump_endaddr, hexdump_addr wc ' C=0 if current < end
              if_nc     add     hexdump_lineaddr, #16
              if_nc     jmp     #hexdump_lineloop

                        ' All done here.
                        jmp     #main_endcmd                                                                            
                                                      
                               
                        '----------------------------------------------------------------------                        
                        ' in_SPEC and out_RSET: Init bit rate and pin number
                        '
                        ' In this mode, execution doesn't return to the main loop.
                        '
                        ' Also, the item address and item count are invalid (and irrelevant)
                        ' because this uses a different bit mask for the command. 
init_spec_reset
                        ' Save requested number of Propeller cycles per bit on the serial port
                        mov     x, main_command
                        shr     x, #sh_BITTIME0
                        and     x, mask_bittime
                        mov     chr_bittime, x 

                        ' Save the pin number from the command
                        mov     x, main_command
                        shr     x, #sh_PIN0
                        and     x, mask_pinnum

                        ' At this point, x contains the bit number that we use for TxD output.

                        ' Store the bit number into the lowest bits of CTRA for now.
                        ' The timer stays off because the CTRMODE fields remains 0.
                        ' We do this to save a register (this way we can use x to calculate
                        ' the bitmask).
                        mov     CTRA, x

                        ' Make sure PHSA never changes by itself.
                        mov     FRQA, #0

                        ' In NCO mode, PHSA[31] is what controls the output pin, so initialize
                        ' it to $8000_0000.                        
                        mov     PHSA, v8000_0000h

                        ' Calculate the bitmask for DIRA in x. 
                        mov     x, #1
                        shl     x, CTRA

                        ' Activate the timer before setting DIRA
                        or      CTRA, ctra_NCO

                        ' Enable the output pin.
                        ' NOTE: when used with pin 30, a pullup resistor (on the Prop Plug)
                        ' has been pulling our TxD pin high. By putting the above instructions
                        ' in this order, the pin is never low until data is generated.
                        ' NOTE: OUTA is assumed to be 0.                        
                        mov     DIRA, x

                        ' All done here                        
init_spec_reset_ret     jmp     #main_endcmd


                        '======================================================================
                        ' Output mode initializers for input modes other than in_SPEC
                        '
                        ' These must be run after the input mode initializers because they
                        ' depend on variables being initialized there.
                        
                        '----------------------------------------------------------------------                                                                                           
                        ' out_DEC (and not in_SPEC): Init for generating decimal
init_outmode_dec
                        movd    item_ins_load, #dec_value
                        mov     item_ins_process, ins_call_dec ' Generate decimal number
                        mov     dec_numbits, item_numbytes
                        shl     dec_numbits, #3         ' Dec loop counts bits: 8 per byte
                        mov     dec_unusedbits, item_unusedbits
                               
init_outmode_dec_ret    jmp     #main_end_outmode_init
                        

                        '----------------------------------------------------------------------                                                                                           
                        ' out_SGD (and not in_SPEC): Init for generating signed decimal
init_outmode_sgd
                        movd    item_ins_load, #dec_value
                        mov     item_ins_process, ins_call_sgd ' Generate decimal number
                        mov     dec_numbits, item_numbytes
                        shl     dec_numbits, #3         ' Dec loop counts bits: 8 per byte       
                        mov     dec_unusedbits, item_unusedbits
                               
init_outmode_sgd_ret    jmp     #main_end_outmode_init


                        '----------------------------------------------------------------------                                                                                           
                        ' out_HEX (and not in_SPEC): Init for generating hexadecimal
init_outmode_hex
                        movd    item_ins_load, #hex_value
                        mov     item_ins_process, ins_call_hex ' Generate hexadecimal
                        mov     hex_numdigits, item_numbytes
                        shl     hex_numdigits, #1       ' 2 digits per byte 
                        mov     hex_unusedbits, item_unusedbits
                               
init_outmode_hex_ret    jmp     #main_end_outmode_init


                        '----------------------------------------------------------------------                                                                                           
                        ' out_HEX (and not in_SPEC): Init for generating binary
init_outmode_bin
                        movd    item_ins_load, #bin_value
                        mov     item_ins_process, ins_call_bin ' Generate binary
                        mov     bin_numdigits, item_numbytes
                        shl     bin_numdigits, #3       ' 8 digits per byte
                        mov     bin_unusedbits, item_unusedbits
                               
init_outmode_bin_ret    jmp     #main_end_outmode_init


                        '======================================================================
                        ' Send a filtered character to the serial port 
                        '
                        ' If the input character is non-printable, it's replaced by a period
                        ' character '.'. This is useful e.g. in hexdumps
                        '
                        ' Input:
                        ' chr_char              Character to print (destroyed)
                        ' chr_bittime           Number of clock cycles per bit (preserved)
                        ' chr_bitmask           Output pin(s) bitmask (preserved)
                        '
                        ' Const:
                        ' v126                  Value 126 (highest printable number) 
                        '
                        ' Local:
                        ' chr_count             Number of bits remaining
                        ' chr_time              Keeps track of time
                                                
chr_filter
                        cmp     chr_char, #$20 wc       ' If value is below space
              if_nc     cmp     v126, chr_char wc       ' ... or value is above 126
              if_c      mov     chr_char, #"."          ' ... Change value to period '.'
              
                        ' Fall through to chr_send routine

              
                        '======================================================================
                        ' Send a character to the serial port
                        '
                        ' This sends the character in chr_char directly to the serial pin.
                        ' Other processing functions also call this to print characters.
                        '
                        ' The code uses timer A in NCO mode with FRQA set to 0 so the PHSA
                        ' 
                        '
                        ' Input:
                        ' chr_char              Character to print (0..255) (destroyed)
                        ' chr_bittime           Number of clock cycles per bit (preserved)
                        ' PHSA                  $8000_0000 (destroyed)
                        '
                        ' Const:
                        ' CTRA                  %00100 << 26 | transmit_pin (preserved)
                        ' FRQA                  0 (preserved)
                        ' DIRA                  1 << transmit_pin                                                              
                        '
                        ' Local:
                        ' chr_time              Keeps track of time
               
chr_send
                        or      chr_char, #$100         ' Add in a stop bit

                        mov     chr_time, CNT           ' Read the current count
                        add     chr_time, #9            ' Value 9 ends next waitcnt immediately

                        waitcnt chr_time, chr_bittime   ' Never waits
                        mov     PHSA, chr_char          ' Bit 31 is 0: start bit
                        waitcnt chr_time, chr_bittime   ' Wait for next bit
                        ror     PHSA, #1                ' Output original bit 0
                        waitcnt chr_time, chr_bittime   ' Wait for next bit
                        ror     PHSA, #1                ' Output original bit 1
                        waitcnt chr_time, chr_bittime   ' Wait for next bit
                        ror     PHSA, #1                ' Output original bit 2
                        waitcnt chr_time, chr_bittime   ' Wait for next bit
                        ror     PHSA, #1                ' Output original bit 3
                        waitcnt chr_time, chr_bittime   ' Wait for next bit
                        ror     PHSA, #1                ' Output original bit 4
                        waitcnt chr_time, chr_bittime   ' Wait for next bit
                        ror     PHSA, #1                ' Output original bit 5
                        waitcnt chr_time, chr_bittime   ' Wait for next bit
                        ror     PHSA, #1                ' Output original bit 6
                        waitcnt chr_time, chr_bittime   ' Wait for next bit
                        ror     PHSA, #1                ' Output original bit 7
                        waitcnt chr_time, chr_bittime   ' Wait for next bit
                        ror     PHSA, #1                ' Output original bit 8: stop bit
                        waitcnt chr_time, chr_bittime   ' Ensure stop bit at least 1 bit time

chr_send_ret
chr_filter_ret
                        ret


                        '======================================================================
                        ' Send a signed decimal number to the serial port
                        '
                        ' If the value in dec_value is negative, send a '-' and negate the
                        ' value.
                        '
                        ' Then print the resulting unsigned value.
                        '
                        ' Input:
                        ' dec_value             Value to print (destroyed)
                        ' dec_numbits           Number bits in value (preserved)
                        ' dec_numdigits         Max expected output digits (preserved)
                        ' dec_unusedbits        Number of unused bits in value (preserved)         
                        '
                        ' Const:
                        ' v8000_0000h           Value $8000_0000
                        '
                        ' Local:
                        ' dec_bitcount          Remaining number of bits to process
                        ' dec_digitcount        Remaining BCD digits to process
                        ' dec_digits[10]        Array holding BCD digits            
                        '
                        ' Calls:
                        ' dec_send              Print decimal value
                        ' chr_send              Print characters        
                        '

dec_send_signed
                        ' Shift the value to the left to eliminate unused bits
                        shl     dec_value, dec_unusedbits
                                                
                        ' Check if item is negative, if so print '-' prefix and negate item
                        
                        test    dec_value, v8000_0000h wz ' Z=1 if positive
              if_nz     mov     chr_char, #"-"          ' If negative, print "-"
              if_nz     call    #chr_send
              if_nz     neg     dec_value, dec_value    ' Negate value

                        ' Continue with signed decimal
                        jmp     #dec_send_no_unused


                        '======================================================================
                        ' Send a decimal value to the serial port
                        '
                        ' This converts the number in dec_value to BCD using the "double
                        ' dabble" algorithm, then it prints each of the significant digits.
                        '
                        ' The "double dabble" algorithm is roughly as follows:
                        ' 1. Initialize the BCD digits buffer to zeroes.
                        ' 2. Repeat the following steps (bytesperitem * 8) times:
                        '    2.1 Check each BCD digit from left (msd) to right (lsd), If the
                        '        digit is 5 or higher, add 3 to the digit (without carry)
                        '    2.2 Rotate the msb of the binary bits into the lsb of the BCD
                        '        digits, and rotate each BCD digit to the next one.
                        '
                        ' Input:
                        ' dec_value             Value to print (destroyed)
                        ' dec_numbits           Number bits in value (preserved)
                        ' dec_numdigits         Max expected output digits (preserved)         
                        ' dec_unusedbits        Number of unused bits in value (preserved)         
                        '
                        ' Const:
                        ' v8000_0000h           Value $8000_0000
                        '
                        ' Local:
                        ' dec_bitcount          Remaining number of bits to process
                        ' dec_digitcount        Remaining BCD digits to process
                        ' dec_digits[10]        Array holding BCD digits            
                        '
                        ' Calls:
                        ' chr_send              Print characters
                        
dec_send
                        ' Shift the value to the left to eliminate unused bits
                        shl     dec_value, dec_unusedbits

                        ' This is where execution enters when printing a signed decimal
dec_send_no_unused

                        ' Clear the BCD digits
                        movd    dec_ins_cleardec, #dec_digitarray
                        
                        mov     dec_digitcount, dec_numdigits

dec_clearloop
dec_ins_cleardec        mov     dec_digitarray, #0                        
                        add     dec_ins_cleardec, d1
                        djnz    dec_digitcount, #dec_clearloop                        

                        ' Init bit counter from number of significant bits
                        mov     dec_bitcount, dec_numbits

dec_shiftloop
                        ' Add 3 to all digits that are 5 or higher

                        ' Init pointers                         
                        movd    dec_ins_cmp, #dec_digitarray
                        movd    dec_ins_add, #dec_digitarray

                        mov     dec_digitcount, dec_numdigits

dec_add3loop
dec_ins_cmp             cmp     dec_digitarray, #5 wc
dec_ins_add   if_nc     add     dec_digitarray, #3

                        add     dec_ins_cmp, d1
                        add     dec_ins_add, d1

                        djnz    dec_digitcount, #dec_add3loop                             

                        test    dec_value, v8000_0000h wc ' C=1 if bit=1

                        ' Rotate bit into the decimal digits

                        ' Init pointers
                        movd    dec_ins_rcl, #dec_digitarray
                        movd    dec_ins_cmpsub, #dec_digitarray

                        mov     dec_digitcount, dec_numdigits
                        
dec_rotateloop                                                
dec_ins_rcl             rcl     dec_digitarray, #1      ' Rotate C into digit
dec_ins_cmpsub          cmpsub  dec_digitarray, #$10 wc ' C = bit 4 (old bit 3), bit 4 cleared
                        add     dec_ins_rcl, d1         ' Bump pointer for rcl instruction
                        add     dec_ins_cmpsub, d1      ' Bump pointer for cmpsub instruction

                        djnz    dec_digitcount, #dec_rotateloop

                        ' Next bit
                        shl     dec_value, #1
                        djnz    dec_bitcount, #dec_shiftloop

                        ' At this point, the decimal digits contain a BCD representation of the
                        ' original item value, padded with zeroes
                        ' Find the first significant digit first, then print the digits

                        ' Init pointers
                        mov     x, #(dec_digitarray - 1)
                        add     x, dec_numdigits
                        movd    dec_ins_test, x
                        movs    dec_ins_mov, x

                        ' Init count
                        mov     dec_digitcount, dec_numdigits
                        sub     dec_digitcount, #1      ' Keep at least one digit

                        ' Find the most significant digit
dec_trimloop
dec_ins_test            test    dec_digitarray, #$F wz  ' Z=1 if digit is zero
              if_z      sub     dec_ins_test, d1        ' Trim one digit
              if_z      sub     dec_ins_mov, #1         ' Skip printing it
              if_z      djnz    dec_digitcount, #dec_trimloop

                        add     dec_digitcount, #1      ' Get remaining digits to print 

                        ' Print rest of the digits
dec_printloop
dec_ins_mov             mov     chr_char, dec_digitarray ' Get digit
                        add     chr_char, #"0"          ' Make ASCII
                        call    #chr_send               ' Print it
                        
                        sub     dec_ins_mov, #1         ' Next digit
                        djnz    dec_digitcount, #dec_printloop                        

                        ' All done
dec_send_signed_ret
dec_send_ret            ret


                        '======================================================================
                        ' Send a hexadecimal value
                        '
                        ' Iterate the value in hex_value, converting each group of 4 bits into
                        ' a hexadecimal digit, and print each digit, msd first.
                        '
                        ' Input:
                        ' hex_value             Value to print (destroyed)
                        ' hex_numdigits         Number of expected output digits (preserved)         
                        ' hex_unusedbits        Number of unused bits in value (preserved)         
                        '
                        ' Local:
                        ' hex_count             Remaining number of digits to print
                        '
                        ' Calls:
                        ' chr_send              Print characters        
                        '
                        
hex_send
                        ' Shift the value to the left to eliminate unused bits
                        shl     hex_value, hex_unusedbits

                        ' Init digit counter
                        mov     hex_count, hex_numdigits

hex_loop                        
                        ' Get a hex digit
                        mov     chr_char, hex_value
                        shr     chr_char, #28           ' Reduce to last 4 bits
                        cmpsub  chr_char, #10 wc        ' C=0 for "0-9", 1 for "A-F"
              if_nc     add     chr_char, #"0"
              if_c      add     chr_char, #"A"

                        ' Print the digit
                        call    #chr_send

                        ' Repeat for all digits
                        shl     hex_value, #4
                        djnz    hex_count, #hex_loop    
                         
hex_send_ret            ret


                        '======================================================================
                        ' Send a binary value
                        '
                        ' Iterate the value in bin_value, converting each bit into a binary
                        ' digit, and print each digit, msd first.
                        '
                        ' Input:
                        ' bin_value             Value to print (destroyed)
                        ' bin_numdigits         Number of expected output digits (preserved)         
                        ' bin_unusedbits        Number of unused bits in value (preserved)         
                        '
                        ' Const:
                        ' v8000_0000h           Value $8000_0000
                        '
                        ' Local:
                        ' bin_count             Remaining number of digits to print
                        '
                        ' Calls:
                        ' chr_send              Print characters        
                        
bin_send
                        ' Shift the value to the left to eliminate unused bits
                        shl     bin_value, bin_unusedbits

                        ' Init digit counter
                        mov     bin_count, bin_numdigits

bin_loop                        
                        ' Get a bit
                        test    bin_value, v8000_0000h wc ' C=1 if bit is 1
              if_nc     mov     chr_char, #"0"
              if_c      mov     chr_char, #"1"

                        ' Print the digit
                        call    #chr_send

                        ' Repeat for all digits
                        shl     bin_value, #1
                        djnz    bin_count, #bin_loop    
                         
bin_send_ret            ret                                                                                                                        


                        '======================================================================
                        ' Data

' Constants for various purposes
zero                    long    0
d1                      long    (|< 9)            
v126                    long    126
vFFF0h                  long    $FFF0
v8000_0000h             long    $8000_0000
ctra_NCO                long    (%00100 << 26)    


' Constants for extracting bit fields from the command
mask_address            long    (|< (1 + sh_ADDRH    - sh_ADDR0))    - 1
mask_count              long    (|< (1 + sh_LENH     - sh_LEN0))     - 1
mask_bittime            long    (|< (1 + sh_BITTIMEH - sh_BITTIME0)) - 1
mask_pinnum             long    (|< (1 + sh_PINH     - sh_PIN0))     - 1
mask_inmode             long    (|< (1 + sh_INH      - sh_IN0))      - 1
mask_outmode            long    (|< (1 + sh_OUTH     - sh_OUT0))     - 1

' Constants coded as instructions
ins_rdbyte              rdbyte  x, item_address wz
ins_rdword              rdword  x, item_address wz
ins_rdlong              rdlong  x, item_address wz
ins_nop                 nop
ins_ifjmpend  if_z      jmp     #main_endcmd
ins_djnzitemloop        djnz    item_count, #item_loop_separator
ins_jmpitemloop         jmp     #item_loop_separator
ins_call_char           call    #chr_send
ins_call_filter         call    #chr_filter
ins_call_dec            call    #dec_send
ins_call_sgd            call    #dec_send_signed
ins_call_hex            call    #hex_send
ins_call_bin            call    #bin_send

' Jump table for input mode initializers
jmptab_inmode           jmp     #init_inmode_spec       ' in_SPEC: Chars, hexdump or reset
                        jmp     #init_inmode_byte       ' in_BYTE: Byte values
                        jmp     #init_inmode_word       ' in_WORD: Word values
                        jmp     #init_inmode_long       ' in_LONG: Long values

' Jump table for output mode initializers, valid for in_SPEC only
jmptab_outmode_spec     jmp     #init_spec_string       ' out_CHAR: Send data directly
                        jmp     #init_spec_filter       ' out_FILT: Send printable chars
                        jmp     #init_spec_hexdump      ' out_DUMP: Hexdump
                        jmp     #init_spec_reset        ' out_RSET: Reset tx pin, baud rate
                         
' Jump table for output mode initializers, valid for input modes other than in_SPEC                        
jmptab_outmode_b_w_l    jmp     #init_outmode_dec       ' out_DEC: Decimal
                        jmp     #init_outmode_sgd       ' out_SGD: Signed decimal
                        jmp     #init_outmode_hex       ' out_HEX: Hexadecimal
                        jmp     #init_outmode_bin       ' out_BIN: Binary                                 

' Uninitialized data, global
x                       res     1                       ' Multi-use variable
                        
' Uninitialized data for main loop
main_starttimestamp     res     1                       ' Value of CNT at start of operation
main_pbenchmark         res     1                       ' Pointer to benchmark in hub
main_command            res     1                       ' Current command
main_inmode             res     1                       ' Input mode from command
main_outmode            res     1                       ' Output mode from command                                

' Uninitialized data for item loop
item_count              res     1                       ' Number of remaining items
item_numbytes           res     1                       ' Number of bytes per items 
item_unusedbits         res     1                       ' Unused bits near msb of each item
item_address            res     1                       ' Address of current item
        
' Uninitialized data for sending characters                         
chr_char                res     1                       ' Character to print
chr_bittime             res     1                       ' Time per serial bit, in clock cycles
chr_time                res     1                       ' Time keeper

' Uninitialized data for sending decimal values
dec_value               res     1                       ' Value to print
dec_unusedbits          res     1                       ' Unused bits near msb of value        
dec_numbits             res     1                       ' Number of significant bits in value
dec_numdigits           res     1                       ' Max number of expected output digits 
dec_bitcount            res     1                       ' Bit counter
dec_digitcount          res     1                       ' Output digit counter
dec_digitarray          res     10                      ' Buffer for BCD digits

' Uninitialized data for sending hexadecimal values
hex_value               res     1                       ' Value to print 
hex_unusedbits          res     1                       ' Unused bits near msb of value        
hex_numdigits           res     1                       ' Number of digits to print 
hex_count               res     1                       ' Digit counter

' Uninitialized data for sending binary values
bin_value               res     1                       ' Value to print
bin_unusedbits          res     1                       ' Unused bits near msb of value        
bin_numdigits           res     1                       ' Number of digits to print
bin_count               res     1                       ' Digit counter 

' Uninitialized data for sending hexdumps
hexdump_lineaddr        res     1                       ' Address at start of line
hexdump_endaddr         res     1                       ' End address for printing
hexdump_addr            res     1                       ' Current address        
hexdump_count           res     1                       ' Remaining bytes to print
                        
                        fit


CON
''***************************************************************************
''* MIT LICENSE
''*
''* Permission is hereby granted, free of charge, to any person obtaining a
''* copy of this software and associated documentation files (the
''* "Software"), to deal in the Software without restriction, including
''* without limitation the rights to use, copy, modify, merge, publish,
''* distribute, sublicense, and/or sell copies of the Software, and to permit
''* persons to whom the Software is furnished to do so, subject to the
''* following conditions:
''*
''* The above copyright notice and this permission notice shall be included
''* in all copies or substantial portions of the Software.
''*
''* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
''* OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
''* MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
''* IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
''* CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT
''* OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR
''* THE USE OR OTHER DEALINGS IN THE SOFTWARE.
''***************************************************************************