{{
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// PROPELLER COMMAND SHELL - LED SHELL EXAMPLE "Machine 2 Machine"
//
// This example implements a more machine oriented protocol.
// It does not support the help command, and instead of printing
// readable error messages, error numbers are used.
//
// The protocol implementatin is as follows:
//
// set LED state: +s <led-nr:0..7> <led-state:1|0|t>
// get LED state: +g <led-nr:0..7>
//
// On error, an error message of the form:
//
// !ERR <err-nr:1..5>
//
// is returned.
//
// For the set command, on success nothing is returned.
// For the get command, on success the LED state is returned in the form:
//
// =<1|0>
//
// Example 1: set LED1 to on:
//
// +s 1 1
// <nothing returned>
//
// Example 2: toggel LED 1:
//
// +s 1 t
// <nothing returned>
//
// Example 3: invalid LED number given:
//
// +s 42 1
// !ERR 2
//
// Example 4: get state of LED 1:
//
// +g 1
// =0
//
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

  FIRST_LED_PIN = 16
  LAST_LED_PIN  = 23

OBJ

  ps	: "propshell"

VAR

  '' none

PUB main | i

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Main routine. Init the shell, prompt for commands, handle commands.
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  repeat i from FIRST_LED_PIN to LAST_LED_PIN
    dira[i] := 1
    outa[i] := 0

  ps.init(false, false, BAUD_RATE, RX_PIN, TX_PIN)

  repeat

    result := ps.prompt

    \cmdHandler(result)

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

  cmdSet(ps.commandDef(string("+s"), false , cmdLine))
  cmdGet(ps.commandDef(string("+g"), false , cmdLine))

  return true

PRI cmdSet(forMe) | ledNr, ledState

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Set the state of a given LED to ON or OFF
'' //
'' // @param                    forMe                   Ture if command should be handled, false otherwise
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  if not forMe
    return

  ps.parseAndCheck(1, string("!ERR 1"), true)
  ledNr := ps.currentParDec

  if ledNr > LAST_LED_PIN - FIRST_LED_PIN or ledNr < 0
    ps.puts(string("!ERR 2", ps#CR, ps#LF))
    abort

  ps.parseAndCheck(2, string("!ERR 3"), false)
  ledState := ps.currentPar

  if strcomp(ledState, string("1"))
    outa[FIRST_LED_PIN + ledNr] := 1
  elseif strcomp(ledState, string("0"))
    outa[FIRST_LED_PIN + ledNr] := 0
  elseif strcomp(ledState, string("t"))
    outa[FIRST_LED_PIN + ledNr] := not outa[FIRST_LED_PIN + ledNr]
  else
    ps.puts(string("!ERR 4", ps#CR, ps#LF))
    abort

  ps.commandHandled

PRI cmdGet(forMe) | ledNr

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Get the state of a given LED
'' //
'' // @param                    forMe                   Ture if command should be handled, false otherwise
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  if not forMe
    return

  ps.parseAndCheck(1, string("!ERR 1"), true)
  ledNr := ps.currentParDec

  if ledNr > LAST_LED_PIN - FIRST_LED_PIN or ledNr < 0
    ps.puts(string("!ERR 2", ps#CR, ps#LF))
    abort

  if outa[FIRST_LED_PIN + ledNr] == 1
    ps.puts(string("=1", ps#CR, ps#LF))
  else
    ps.puts(string("=0", ps#CR, ps#LF))

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
