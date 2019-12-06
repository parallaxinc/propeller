CON

        _wchunk         = 512      'size of write buffer
        _wextra         = 32
        
        
VAR

        long    wbufptr          'pointer to wbuf
        byte    wbuf[_wchunk+_wextra]
        

PUB manageWB(mode) | rc, n
{{

  (copy this method to the module that
   will call memStick.spin)
   
  use this with format_memory to achieve
  much higher write speed

  set _wchunk to some large size say
  a sector size 512 bytes
  
  set _wextra to the length of the longest
  line to be output via calls that put
  data into wbuf using wbufptr as the pointer

  call open in memStick.spin
  call init  (mode == 0)
  
  (repeat these two as needed)
  call format_memory to build a line
              or part of a line using
              wbufptr as the pointer
  call check (2)
  ....
  call flush (1) to get anything leftover
  call close in memStick.spin

  returns 0 if ok else negative error codes
  listed in the header comment

  see demo in memStick_demo.spin

  adjust fs.write to your object name.write
  
}}
  case mode
    0 :                         'init
      wbufptr := @wbuf
      return 0
    1 :                         'flush
      n := wbufptr-@wbuf
      if n
        rc := fs.write(@wbuf,n)
        wbufptr := @wbuf
        return rc
    2 :                         'check/write if needed
      n := wbufptr-@wbuf
      if n > _wchunk
        rc := fs.write(@wbuf,_wchunk)
        if rc
          return rc             'some error
        n -= _wchunk            'leftover
        bytemove(@wbuf,@wbuf+_wchunk,n)
        wbufptr -= _wchunk
      return 0
      
        

