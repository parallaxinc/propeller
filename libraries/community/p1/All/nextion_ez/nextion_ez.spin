'' =================================================================================================
''
''   File....... nextion_ez_p1.spin
''   Purpose.... Provide methods and protocol similar to the Easy Nextion Arduino library

''   Author..... Charles Current
''               -- based on the Easy Nextion Library for Arduino by Thanasis Seitanis

''   E-mail..... charles@charlescurrent.com
''   Started.... 16 JUN 2022
''   Updated.... 19 JUN 2022
''
'' =================================================================================================
{{
  NOTE: methods are similar to, but not identical to, those in the Arduino Easy Nextion Library
        The protocol is completely compatible with the Easy Nextion Library and will allow reuse
        of HMI code between Arduino and Propeller boards.

  NOTE: This Spin object requires the use of a custom version of FullDuplexSerial.spin called
        FullDuplexSerialAvail.spin that adds a method to return the number of bytes in
        the rx_buffer.

  Full documentation on the Arduino Easy Nextion Library and protocol, as well as examples,
        can be found at https://seithan.com/Easy-Nextion-Library/

  If you find this library useful, please consider supporting the author of the original
        Easy Nextion Library, Thanasis Seitanis at: [seithagta@gmail.com](https://paypal.me/seithan)

   Differences between the Arduino library and Spin object:
        1) The Arduino implementation automatically calls trigger functions, stored in a separate file,
           in response to Nextion commands.
                This object provides the methods cmdAvail(), getCmd(). and readByte()
                to retreave the command packets sent from the Nextion.

        2) The Arduino C++ library uses a single overloaded function writeStr() to send commands and
           update string values on the Nextion.
                This object uses separate methods sendCmd() and writeStr().

        3) A argument fifo has been added to allow a new method pushCmdArg() that can be used to
           provide a variable number of arguments to sendCmd().

        4) The the equivilent of the Arduino NextionListen() function has been named listen()
           in this implementation.

        5) This object adds a method called addWave() to create a quick and easy interface to the
           Nextion waveform add command.

        6) In this object the currentPageId and lastCurrentPageId variables can be accessed with the
           methods getCurrentPage() and getLastPage()

}}

CON
  SERIAL_MODE = %0000
  ERROR_NUM = 777777

VAR
  long  current_page_id
  long  last_current_page_id
  byte  cmd
  byte  cmd_len
  byte  cmd_avail
  long  cmd_fifo[16]
  byte  cmd_fifo_head
  byte  cmd_fifo_tail

OBJ
  _nextion      : "FullDuplexSerialAvail"               'a special version of FullDuplexSerial that provides an available method like Arduino and FullDuplexSerial

PUB start(rxPin, txPin, baud)                        'Must be run before using object
{{
  Must be run before using object
  Will start a new serial object in it's own cog using the pins and rate provided
}}
  _nextion.start(rxPin, txPin, SERIAL_MODE, baud)
  waitcnt(clkfreq / 100 + cnt)                          'wait for serial to init

PUB writeNum(ptr_component, num)                          'send a numeric value to nextion
{{
  send a numeric value to nextion
  ptr_component should be a pointer to a string that names the object and attribute to receive the new value
  _num is the value to assign to the object.attribute

  example: nextion.writeNum(STRING("j0.val"), number)
}}
  _nextion.str(ptr_component)
  _nextion.tx("=")
  _nextion.dec(num)
  repeat 3
    _nextion.tx($FF)


PUB writeStr(ptr_component, ptr_txt)                      'send a string value to nextion
{{
  send a string value to nextion
  ptr_component should be a pointer to a string that names the object and attribute to receive the new value
  ptr_txt should be a pointer to the string to pass to the object.attribute

  example: nextion.writeStr(STRING("t0.txt"), STRING("Text"))
}}
  _nextion.str(ptr_component)
  _nextion.tx("=")
  _nextion.tx($22)'double quote
  _nextion.str(ptr_txt)
  _nextion.tx($22)'double quote
  repeat 3
    _nextion.tx($FF)

PUB writeByte(val)                                        'send raw data byte (not ASCII formated) to Nextion
{{
  Main purpose and usage is for sending the raw data required by the addt command
  where we need to write raw bytes to serial

  example: nextion.writeByte(0)
 }}
  _nextion.tx(val)

PUB pushCmdArg(argument)                                'load the argument FIFO with numeric arguments that are to be sent with the command using sendCmd()
{{
  Used to load the argument FIFO with numeric arguments that are to be sent with the command using sendCmd()
  example:  to send the command "page 1" to the nextion
            nextion.pushCmdArg(1)
            nextion.sendCmd(STRING("page"))
}}
  cmd_fifo[cmd_fifo_head] := argument
  cmd_fifo_head++
  if cmd_fifo_head > 16
    cmd_fifo_head := 0

PUB sendCmd(ptr_command) | count, x, argument                               'send a command to nextion
{{
  send a command to nextion
  ptr_command should be a pointer to a string containing the command to be sent

  example: nextion.sendCmd(STRING("page 0"))
}}
  if(cmd_fifo_head < cmd_fifo_tail)
    count := (cmd_fifo_head + 16) - cmd_fifo_tail
  else
    count := cmd_fifo_head - cmd_fifo_tail

  _nextion.str(ptr_command)

  if(count > 0)
    _nextion.tx(" ")
    x := 0
    repeat count
      if x > 0
        _nextion.tx(",")                                'only need commas between arguments, not between command and 1st argument
      argument := cmd_fifo[cmd_fifo_tail]
      _nextion.dec(argument)
      cmd_fifo_tail++
      if(cmd_fifo_tail > 15)
        cmd_fifo_tail := 0

  repeat 3
    _nextion.tx($FF)


PUB addWave(id, channel, val)                           'Add single value to a Nextion waveform channel
{{
  Add single value to a Nextion waveform channel
  id is the object id number of the waveform object, not the name
  channel is the waveform channel to add to
  val is the value to add to the channel (0-255)

  example: nextion.addWave(1, 0, 128)
}}
  _nextion.str(STRING("add "))
  _nextion.dec(id)
  _nextion.tx(",")
  _nextion.dec(channel)
  _nextion.tx(",")
  _nextion.dec(val)
  repeat 3
    _nextion.tx($FF)


PUB readStr(ptr_component, ptr_return) : status | _char, _pos, _time, _ms, _ffCount, _end  'Read a string value from nextion, will return a 1 if successful or -1 on error
{{
  Read a string value from nextion, will return a 1 if successful or -1 on error
  ptr_component should be a pointer to a string naming the object and string attribute to retrieve
  ptr_return should be a pointer to a string to recieve the string

  example: nextion.readStr(STRING("t0.txt"), @txt)

  Nextion data should have the following format:
  0x70 ... (each character of the String is represented in HEX) ... 0xFF 0xFF 0xFF

  Example: For the String ab123, we will receive: 0x70 0x61 0x62 0x31 0x32 0x33 0xFF 0xFF 0xFF
}}
  status := -1
  _char := 0
  if _nextion.available
    listen                                       'make sure the incoming buffer is empty

  _nextion.str(STRING("get "))                        'send the request
  _nextion.str(ptr_component)
  repeat 3
    _nextion.tx($FF)

  _time := cnt
  _ms := 400
  repeat while  _nextion.available < 4                  'wait for a response (valid response has min 4 chars)
    if(cnt - _time) / (clkfreq / 1000) > _ms                                    'but not forever
      return

    ' Wait for return data

  _char := _nextion.rx

  repeat while _char <> $70                         'look for the $70 signals the beginning of a valid response
    _char := _nextion.rxTime(100)
    if _char == -1                                     'if timeout (-1) return error (-1)
      return

  'must have a $70 reponse code now so we setup for receiving the command
  _pos := 0
  repeat strsize(ptr_return)                                   'clear the buffer
    byte[ptr_return + _pos] := 0
  _pos := 0
  _ffCount := 0
  _end := false
  _time := cnt
  _ms := 1000

  repeat until _end == true                          'start receiving the string
    _char := _nextion.rxTime(100)
    if _char == -1                                     'if timeout (-1) return error (-1)
      return
    if _char == $FF                                 'end char ($FF)?
      _ffCount++
      if _ffCount == 3
        _end := true                                'if 3 end chars in a row we're don
    else
      byte[ptr_return + _pos++] := _char
      'if _pos == strsize(ptr_return)                 'buffer full error
        'return
      _ffCount := 0
    if (cnt - _time) / (clkfreq / 1000) > _ms                                'time out if we don't see a end packet
      return

  return 1

PUB readNum(ptr_component) : num | _time, _ms, _ffCount, _end, _char, _count, _numBuff[4]   'read a numeric value from nextion, returns number value or 777777 on error
{{
  Read a numeric value from nextion, returns number value or 777777 on error
  ptr_component should be a pointer to a string naming the component and attribute containing the number to receive

  example: nextion.readNum(STRING("x0.val"))

  Nextion data should have the following format:
 '0x71 0x01 0x02 0x03 0x04 0xFF 0xFF 0xFF
 '0x01 0x02 0x03 0x04 is 4 byte 32-bit value in little endian order
 }}
  num := ERROR_NUM

  if _nextion.available
    listen                                       'make sure the incoming buffer is empty

  _nextion.str(STRING("get "))                        'send the request
  _nextion.str(ptr_component)
  repeat 3
    _nextion.tx($FF)

   'And now we are waiting

  _time := cnt
  _ms := 400
  repeat while  _nextion.available < 8                  'wait for a response (valid response has min 4 chars)
    if(cnt - _time) / (clkfreq / 1000) > _ms                                    'but not forever
      return

  '_char := _nextion.rx

  repeat while _char <> $71                           'looking for start of valid response
    _char := _nextion.rxTime(100)
    if _char == -1                                     'if timeout (-1) return error (-1)
      return

  _count := 0

  repeat 4                                             'read the 4 bytes of the ASCII representation of our number
    _char := _nextion.rxTime(100)
    if _char == -1                                     'if timeout (-1) return error (-1)
      return
    _numBuff[_count] := _char
    _count++

  _ffCount := 0
  _end := false
  _time := cnt
  _ms := 400

  repeat while _end == false
    _char := _nextion.rxTime(100)
    if _char == -1                                     'if timeout (-1) return error (-1)
      return
    if _char == $FF
      _ffCount++
      if _ffCount == 3
        _end := true
    if(cnt - _time) / (clkfreq / 1000) > _ms                               'time out if we don't see a end packet
      return

  'convert ASCII to DEC
  num := _numBuff[3]
  num <<= 8
  num |= _numBuff[2]
  num <<= 8
  num |= _numBuff[1]
  num <<= 8
  num |= _numBuff[0]

  return

PUB readByte : _char                                    'read a byte from serial buffer (for use in custom commannds)
  _char := _nextion.rxTime(100)                         'if timeout (-1) return error (-1)
  return

PUB listen | _char, _time, _ms, _len, _cmdFound, _cmd      'check for incoming serial data from nextion, must be run frequently to respond to events
{{
  Check for incoming serial data from nextion, must be run frequently to respond to events

  example nextion.listen

  Uses the Easy Nextion protocol to identify commands from Nextion Events
  Advanced users can modify the custom protocol to add new group commands.
  More info on custom protocol: https://seithan.com/Easy-Nextion-Library/Custom-Protocol/ and on the documentation of the library

  ! WARNING: This method must be called repeatedly to response touch events from the Nextion.
  You can place it in the main loop of a Cog
}}
  cmd_avail := false

  if _nextion.available > 2                             'Read if more then 2 bytes come (we always send more than 2 <#> <len> <cmd> <id>
    _char := _nextion.rxTime(100)
    if _char == -1                                     'if timeout (-1) return error (-1)
      return

    _time := cnt
    _ms := 100

    repeat while _char <> "#"
      _char := _nextion.rxTime(100)
      if _char == -1                                     'if timeout (-1) return error (-1)
        return

      if(cnt - _time) / (clkfreq / 1000) > _ms                                'time out if we don't see a start char
        return

    if _char == "#"
      _len := _nextion.rxTime(100)
       if _char == -1                                     'if timeout (-1) return error (-1)
         return
    cmd_len := _len

      _cmdFound := true
      _time := cnt
      _ms := 100

      repeat while _nextion.available < _len
        if(cnt - _time) / (clkfreq / 1000) > _ms                                'time out if we don't see a full packet soon timeout
          return

    _cmd := _nextion.rx

      case _cmd
        "P" :                       'update the current and last page ID
          last_current_page_id := current_page_id
          current_page_id := _nextion.rx

        OTHER :                      'commands can be variable length, we pull just the first and leave the rest for main code to deal with
          cmd_avail := true
          cmd := _cmd
  return

PUB getCurrentPage : _page                              'returns the current page id
  return current_page_id

PUB setCurrentPage(_page)                               'sets the current page id
  current_page_id := _page

PUB getLastPage : _page                                 'returns the previous page id
  return last_current_page_id

PUB setLastPage(_page)                                  'sets the previous page id
  last_current_page_id := _page

PUB cmdAvail : _avail                                   'returns true if commands in the buffer
  _avail := cmd_avail
  cmd_avail := false
  return

PUB getCmd : _cmd                                       'returns the 1st command byte
  return cmd

PUB getCmdLen : _len                                  'returns the number of command bytes (for use in custom commands)
  return cmd_len

con { license }

{{

  Terms of Use: MIT License

  Permission is hereby granted, free of charge, to any person obtaining a copy of this
  software and associated documentation files (the "Software"), to deal in the Software
  without restriction, including without limitation the rights to use, copy, modify,
  merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
  permit persons to whom the Software is furnished to do so, subject to the following
  conditions:

  The above copyright notice and this permission notice shall be included in all copies
  or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
  PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
  CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
  OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

}}