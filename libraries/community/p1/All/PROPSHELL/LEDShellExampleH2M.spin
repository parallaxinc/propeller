{{
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// PROPELLER COMMAND SHELL - LED SHELL EXAMPLE "Human 2 Machine"
//
// This example implements a more human oriented protocol.
// It supports the help command (?), and prints human
// readable error messages.
//
// The protocol implementatin is as follows:
//
// set LED state: set <led-nr:0..7> <led-state:on|off|tog>
// get LED state: get <led-nr:0..7>
//
// Example 1: set LED1 to on:
//
// set 1 on
// <nothing returned>
//
// Example 2: toggel LED 1:
//
// set 1 tog
// <nothing returned>
//
// Example 3: invalid LED number given:
//
// set 42 on
// led-nr out of bounds (0..7)
//
// Example 4: get state of LED 1:
//
// get 1
// off
//
// Note: enable local echo on the terminal used to communicate with the shell.
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

  ps.init(string("LED# "), string("?"), BAUD_RATE, RX_PIN, TX_PIN)

  ps.puts(string(ps#CR, ps#LF, "*** LED SHELL EXAMPLE (use ? for help) ***", ps#CR, ps#LF))

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

  cmdSet(ps.commandDef(string("set"), string("Set the state of a given LED" , ps#CR, ps#LF, "usage: set <led-nr:0..7> <led-state:on|off|tog>") , cmdLine))
  cmdGet(ps.commandDef(string("get"), string("Get the state of a given LED" , ps#CR, ps#LF, "usage: get <led-nr:0..7>") , cmdLine))

  return true

PRI cmdSet(forMe) | ledNr, ledState

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Set the state of a given LED to ON or OFF
'' //
'' // @param                    forMe                   Ture if command should be handled, false otherwise
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  if not forMe
    return

  ps.parseAndCheck(1, string("Missing or non int parameter: led-nr"), true)
  ledNr := ps.currentParDec

  if ledNr > LAST_LED_PIN - FIRST_LED_PIN or ledNr < 0
    ps.puts(string("led-nr out of bounds (0..7)", ps#CR, ps#LF))
    abort

  ps.parseAndCheck(2, string("Missing parameter: led-state"), false)
  ledState := ps.currentPar

  if strcomp(ledState, string("on"))
    outa[FIRST_LED_PIN + ledNr] := 1
  elseif strcomp(ledState, string("off"))
    outa[FIRST_LED_PIN + ledNr] := 0
  elseif strcomp(ledState, string("tog"))
    outa[FIRST_LED_PIN + ledNr] := not outa[FIRST_LED_PIN + ledNr]
  else
    ps.puts(string("led-state must be 'on' or 'off'", ps#CR, ps#LF))
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

  ps.parseAndCheck(1, string("Missing or non int parameter: led-nr"), true)
  ledNr := ps.currentParDec

  if ledNr > LAST_LED_PIN - FIRST_LED_PIN or ledNr < 0
    ps.puts(string("led-nr out of bounds (0..7)", ps#CR, ps#LF))
    abort

  if outa[FIRST_LED_PIN + ledNr] == 1
    ps.puts(string("on", ps#CR, ps#LF))
  else
    ps.puts(string("off", ps#CR, ps#LF))

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
