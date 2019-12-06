{{
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// PROPELLER COMMAND SHELL - TEST
//
// Simple shell example showig the basic usage of the "propshell". In the command line
// type "?" to get help.
//
// Note: enable local echo on the terminal used to communicate with the shell.
//
// Author: Stefan Wendler
// Updated: 2013-10-14
// Designed For: P8X32A
// Version: 1.0
//
// Copyright (c) 2013 Stefan Wendler
// See end of file for terms of use.
//
// Update History:
//
// v1.0 - Initial release       - 2013-10-14
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}}

CON

  '' Clock settings
  '' _clkmode = rcfast                                  ' Internal clock at 12MHz

  _CLKMODE = XTAL1 + PLL16X                             ' External clock at 80MHz
  _XINFREQ = 5_000_000

  '' Serial port settings for shell
  '' BAUD_RATE 	= 8_761                                ' Turns out to be about 9600 with rcfast on my board
  BAUD_RATE     = 115_200

  RX_PIN 	= 1
  TX_PIN 	= 0

  ''RX_PIN 		= 31
  ''TX_PIN 		= 30

OBJ

  ps	: "propshell"

VAR

  '' none

PUB main

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Main routine. Init the shell, prompt for commands, handle commands.
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  '' init shell with help available
  ps.init(string("ps# "), string("?"), BAUD_RATE, RX_PIN, TX_PIN)

  '' init shell without promt and no help available
  'ps.init(false, false, BAUD_RATE, RX_PIN, TX_PIN)

  ps.puts(string(ps#CR, ps#LF, "*** SIMPLE EXAMPLE (use ? for help) ***", ps#CR, ps#LF))

  '' main loop for handling commands
  repeat

    result := ps.prompt

    if \cmdHandler(result) and not ps.isEmptyCmd(result)
      ps.puts(string("Unknown kommand. Use ? for help.", ps#CR, ps#LF))

PRI cmdHandler(cmdLine)

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Command handler. All shell commands are defined here.
'' //
'' // @param                    cmdLine                 Input to parse (from promt)
'' // @return                                           ture if cmdLine was NOT handled
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  '' Each command needs to have a single parameter: the result of ps.commandDef.
  '' Each ps.commandDef takes three parameters:
  '' - 1  name of command
  '' - 2  help/descriptoin for command (or false if no help)
  '' - 3  command line to check command against

  cmd1(ps.commandDef(string("cmd1"), string("This is the first command" , ps#CR, ps#LF, "usage: cmd1") , cmdLine))
  cmd2(ps.commandDef(string("cmd2"), string("This is the second command", ps#CR, ps#LF, "usage: cmd2 <par1:str>"), cmdLine))
  cmd3(ps.commandDef(string("cmd3"), string("This is the third command" , ps#CR, ps#LF, "usage: cmd3 <par1:str> <par2:int>") , cmdLine))
  cmd4(ps.commandDef(string("cmd4"), false , cmdLine))

  return true

PRI cmd1(forMe)

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Sample command 1
'' //
'' // @param                    forMe                   Ture if command should be handled, false otherwise
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  '' only if forMe is true, this command must be handled
  if not forMe
    return

  ps.puts(string("CMD 1", ps#CR, ps#LF))

  '' signal that command handling is done
  '' if ps.commandHandled is NOT called, command handling will proceed with next command
  ps.commandHandled

PRI cmd2(forMe)

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Sample command 2
'' //
'' // @param                    forMe                   Ture if command should be handled, false otherwise
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  '' only if forMe is true, this command must be handled
  if not forMe
    return

  ps.puts(string("CMD 2", ps#CR, ps#LF))

  '' see if at least one param was given
  '' if check fails, command handling is aborted
  ps.parseAndCheck(1, string("Missing parameter: par1:str"), false)

  ps.puts(string("par1="))
  ps.puts(ps.currentPar)                                '' ps.currentPar points to param at pos1 (last one parsed)
  ps.puts(string(ps#CR, ps#LF))

  '' signal that command handling is done
  '' if ps.commandHandled is NOT called, command handling will proceed with next command
  ps.commandHandled

PRI cmd3(forMe)

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Sample command 3
'' //
'' // @param                    forMe                   Ture if command should be handled, false otherwise
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  '' only if forMe is true, this command must be handled
  if not forMe
    return

  ps.puts(string("CMD 3", ps#CR, ps#LF))

  '' see if first param is given
  '' if check fails, command handling is aborted
  ps.parseAndCheck(1, string("Missing parameter: par1:str"), false)

  ps.puts(string("par1="))
  ps.puts(ps.currentPar)
  ps.puts(string(ps#CR, ps#LF))

  '' see if second param is given, and if it is a decimal
  '' if check fails, command handling is aborted
  ps.parseAndCheck(2, string("Missing or invalid parameter: par2:int"), true)

  ps.puts(string("par2="))
  ps.putd(ps.currentParDec)                             '' get current param as a decimal
  ps.puts(string(ps#CR, ps#LF))

  '' signal that command handling is done
  '' if ps.commandHandled is NOT called, command handling will proceed with next command
  ps.commandHandled

PRI cmd4(forMe)

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Sample command 4
'' //
'' // @param                    forMe                   Ture if command should be handled, false otherwise
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  '' only if forMe is true, this command must be handled
  if not forMe
    return

  ps.puts(string("CMD 4", ps#CR, ps#LF))

  '' signal that command handling is done
  '' if ps.commandHandled is NOT called, command handling will proceed with next command
  ps.commandHandled

DAT

{{
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                  TERMS OF USE: MIT License
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,
// modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the
// Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
// WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
// ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}}
