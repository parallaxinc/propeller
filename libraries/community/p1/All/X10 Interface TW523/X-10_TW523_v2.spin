''************************************
''*  X-10 TW523 Interface Controller *
''*  (C) 2008 Sal Mustafa            *
''************************************

{{

This routine will return raw X-10 codes as seen by the TW523.

With the exception of the start code (1110), all other bits are transmitted along with their inverse in two-bit pairs.

For example, 

House O / Code 8
0 1 0 0 / 1 1 0 1 0

becomes

House O     / Code 8
01 10 01 01 / 10 10 01 10 01

And with the start code, will look like

1110 01 10 01 01 10 10 01 10 01

You can implement your own routine to detect transmission errors (ie where a pair is either 00 or 11).

Some sample codes for House Code O:

All Lights off
11100110010101010101100000000000

All Lights on
11100110010101010110100000000000

}}


CON
  X10_START     = %1110
  X10_BUFLEN    = 50                                    'store this many x10 codes
    

VAR

  long cog
  long X10code[X10_BUFLEN]
  long bufptr
  

PUB start(rxpin, txpin, zxpin) : okay

  _usec := clkfreq / 1_000_000 * 500                    'TWC requires read after 500usec
  
  bufptr := 0                                           'move to beginning of x10code buffer                        
  _rxpin := rxpin
  _txpin := txpin
  _zxpin := zxpin
  okay := cog := cognew(@TW523, @X10code) + 1 


PUB stop

  if cog
    cogstop(cog~ - 1)


PUB rxcheck : code 

  if X10code[bufptr] <> 0 
    code := X10code[bufptr]                             'return bufptr
    X10code[bufptr] := 0                                'destroy value
    bufptr++                                            'increment bufptr ...                                                                      
    bufptr //= X10_BUFLEN                               '... but not past buflen
'    bufptr := 0
'    code += bufptr + 1
  else
    code := 0                                           'otherwise return nothing

'  X10code := 0
      

DAT
                        org
TW523
                        mov     _rxmask,#1              'prep with a '1'
                        shl     _rxmask,_rxpin          'shift into place as mask

                        mov     _txmask,#1              'prep with a '1'
                        shl     _txmask,_txpin          'convert to mask

                        mov     _zxmask,#1              'prep with a '1'
                        shl     _zxmask,_zxpin          'convert to mask

                        mov     _ptr1,par               'set buffer head
                        mov     _ptr2,#X10_BUFLEN       'get number of longs
                        shl     _ptr2,#2                'multiply by 4 to convert to bytes
                        add     _ptr2,par               'get end-address of buffer
                                                                                                        
:start
                        waitpeq _zxmask,_zxmask         'then wait for zero-crossing to reach one

                        waitpeq _zero,_zxmask           'wait for zero-crossing to reach zero

                        mov     _phase,#0               'reset phase counter
                        mov     _x10code,#0             'reset code
                        mov     _t1,#28                 'reset loop counter to 32 - 4 start bits
:loop1
                        cmp     _phase,#0       wz      'is this positive cycle?
              if_z      waitpeq _zxmask,_zxmask         'then wait for zero-crossing to reach one
              if_z      mov     _phase,#1               'set for negative cycle
              if_nz     waitpeq _zero,_zxmask           'otherwise wait for zero-crossing to reach zero
              if_nz     mov     _phase,#0               'reset to positive cycle

                        mov     _time,cnt               'get time
                        add     _time,_usec             'add 500usec
                        waitcnt _time,_usec             'wait for it, with automatic delta

                        test    _rxmask,ina     wz      'ina AND _rxmask

                        shl     _x10code,#1             'shift left with a zero into lsb
              if_z      or      _x10code,#1             'put a one into lsb - rx is inverted

                        and     _x10code,#%1111         'mask off lsb nibble                                       
                        cmp     _x10code,#%1110 wz      'is it X10 start code?
              if_nz     jmp     #:loop1                 'if not, keep looking


:loop2
                        cmp     _phase,#0       wz      'is this positive cycle?
              if_z      waitpeq _zxmask,_zxmask         'then wait for zero-crossing to reach one
              if_z      mov     _phase,#1               'set for negative cycle
              if_nz     waitpeq _zero,_zxmask           'otherwise wait for zero-crossing to reach zero
              if_nz     mov     _phase,#0               'reset to positive cycle


                        mov     _time,cnt               'get time
                        add     _time,_usec             'add 500usec
                        waitcnt _time,_usec             'wait for it, with automatic delta

                        test    _rxmask,ina     wz      'ina AND _rxmask
:loop3
                        shl     _x10code,#1             'shift left with a zero into lsb
              if_z      or      _x10code,#1             'put a one into lsb - rx is inverted


                        waitpeq _zero,_zxmask           'otherwise wait for zero-crossing to reach zero
                        djnz    _t1,#:loop2             'keep going until code retrieved
                                                        'otherwise write code to memory and exit      
:write
                        cmp     _ptr2,_ptr1     wz      'is ptr1 at end of array?
              if_z      mov     _ptr1,par               'if so, start at beginning 
                        wrlong  _x10code,_ptr1          'write value to memory in array
                        add     _ptr1,#4                'move to next array element

                        mov     _time,_usec
                        shl     _time,#4
                        add     _time,cnt
                        waitcnt _time,_usec
                        
                        jmp     #:start                 '



_rxpin                  long    0
_txpin                  long    0
_zxpin                  long    0
_usec                   long    0
_zero                   long    0
_one                    long    1
_x10code                res     1
_t1                     res     1
_t2                     res     1
_ptr1                   res     1
_ptr2                   res     1
_rxmask                 res     1
_txmask                 res     1
_zxmask                 res     1
_phase                  res     1
_time                   res     1





