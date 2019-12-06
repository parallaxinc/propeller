{{
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// PROPELLER COMMAND SHELL
//
// See included examples for usage.
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

  CR     	= 13            ' Code of character to send for CR
  LF 		= 10            ' Code of character to send for LF

  MAX_BUF       = 256           ' Max. lenght of command line and parameters
  MAX_PROMPT    = 8             ' Max. length of command prompt
  MAX_HELPCMD   = 8             ' Max. length of help command

OBJ

  fdc	: "Full-Duplex_COMEngine"

VAR

  byte shellPrompt[MAX_PROMPT]  ' Hold the shell prompt
  byte helpCmd[MAX_HELPCMD]     ' Hold the help command
  byte cmdBuf[MAX_BUF]          ' Buffer to hold the commad line
  byte parBuf[MAX_BUF]          ' Buffer to hold a single parameter of the command line
  byte enableHelp               ' Determines if help is available
  byte enablePrompt             ' Determines if prompt is printed

PUB init(aShellPrompt, aHelpCmd, baudRate, rxPin, txPin)

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Initialize the shell
'' //
'' // @param                    aShellPromt             String to use as shell prompt or false for no shell prompt
'' // @param                    aHelpCmd                String which defines the help command or false for no help command
'' // @param                    baudRate                Serial baudrate to use
'' // @param                    rxPin                   Pin to use for serial RX
'' // @param                    txPin                   Pin to use for serial TX
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  shellPrompt := aShellPrompt
  helpCmd     := aHelpCmd

  fdc.COMEngineStart(rxPin, txPin, baudRate)

  if not aHelpCmd
    enableHelp  := false
  else
    enableHelp  := true

  if not aShellPrompt
    enablePrompt  := false
  else
    enablePrompt  := true

PUB commandDef(cmd, cmdDesc, cmdLine)

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Define a command
'' //
'' // @param                    cmd                     String which defines the command
'' // @param                    cmdDesc                 Description of the command (used for help), or false if no description
'' // @param                    cmdLine                 Command line to parse
'' // @return                                           true if cmdLine matches cmd, false otherwise
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  if subMatches(helpCmd, cmdLine) and enableHelp
    '' write out command help
    fdc.writeString(string(CR, LF))
    fdc.writeString(cmd)
    fdc.writeString(string(": "))
    fdc.writeString(cmdDesc)
    fdc.writeString(string(CR, LF))
    return false
  elseif not subMatches(cmd, cmdLine)
    return false

  return true

PUB prompt

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Show promt (if defined), await input
'' //
'' // @return                                           input read from serial line
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  if enablePrompt
    fdc.writeString(shellPrompt)

  result := fdc.readString(@cmdBuf, MAX_BUF)
  fdc.writeString(string(CR))

PUB commandHandled

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Signal that command was handled
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  abort

PUB puts(str)

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Write out string
'' //
'' // @param                    str                     String to write to serial line
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  fdc.writeString(str)

PUB putd(value) | i

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Write out decimal
'' //
'' // @param                    value                   Decimal value to write to serial line
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	i := 1_000_000_000

	repeat 10
		if value => i
			fdc.writeByte(value / i + "0")
			value //= i
			result~~

		elseif result or i == 1
			fdc.writeByte("0")

		i /= 10

PUB currentPar

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Get last param parsed (as raw string)
'' //
'' // @return                                           Last parameter parsed as raw string value
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  return @parBuf

PUB currentParDec

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Get last param parsed (as converted to decimal)
'' //
'' // @return                                           Last parameter parsed as decimal value
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  return strToDec(@parBuf)

PUB isEmptyCmd(cmdLine)

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Check if received command line was empty.
'' //
'' // @param                    cmdLine                 Command line read (e.g. by promt method)
'' // @return                                           True ic cmdLine is emtpy, false otherwise
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  if strsize(cmdLine) == 1 or subMatches(helpCmd, cmdLine) or not enableHelp
    return true

  return false

PUB parse(pos) | i, done, inputPtr, foundPos, curPos

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Parse param from last command line read at given pos.
'' //
'' // @param                    pos                     pos (0..m) of parameter to parse
'' // @return                                           True if parameter was fond at pos, false otherwise
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

        inputPtr := @cmdBuf

        foundPos := false
        done     := false
        curPos   := 0
        i        := 0

        bytefill(@parBuf, 0, 8)

	repeat until byte[inputPtr] == 0 or done == true

		if byte[inputPtr] == 32 and not foundPos

                   if ++curPos == pos
                        foundPos := true
                   else
                        inputPtr++

		elseif foundPos

                   if byte[inputPtr] <> 32 and byte[inputPtr] <> CR and byte[inputPtr] <> LF and byte[inputPtr] <> 0
			parBuf[i++] := byte[inputPtr]
                   else
                        done := true

                inputPtr++

        return done

PUB parseAndCheck(pos, errMsg, checkDec)

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Parse param at given pos and check if it is valid. If check fails, abort is issued.
'' //
'' // @param                    pos                     pos (0..m) of parameter to parse
'' // @param                    errMsg                  Message to write out if param check failed (not found, or not decimal)
'' // @param                    checkDec                If set to true,check if param is valid deciamal value
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  if not parse(pos)
    fdc.writeString(errMsg)
    fdc.writeString(string(CR, LF))
    abort

  if checkDec and strToDec(@parBuf) == $FFFFFFFF
    fdc.writeString(errMsg)
    fdc.writeString(string(CR, LF))
    abort

PRI subMatches(cmdPtr, inputPtr) | i, lenCmdPtr

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Match a substring. Used to see if a command line starts with a given command.
'' //
'' // @param                    cmdPtr                  Pointer to command definition
'' // @param                    inputPtr                Pointer to whole command line
'' // @return                                           True if inputPtr (command line) starts with command (cmdPtr), flase
'' //                                                   otherwise
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

        lenCmdPtr := strsize(cmdPtr)

	if lenCmdPtr > strsize(inputPtr)
		return false

	repeat i from 0 to lenCmdPtr - 1
	  if byte[cmdPtr++] <> byte[inputPtr++]
	     return false

	if byte[inputPtr] <> 32 and byte[inputPtr] <> CR and byte[inputPtr] <> LF
		return false

	return true

PRI strToDec(strPtr) : decVal | valid, char, index, multiply

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Convert string to decimal.
'' //
'' // @param                    strPtr                  Pointer to string which should be converted to decimal
'' // @return                                           Decimal value for strPtr
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

        valid   := false
	decVal := index := 0

	repeat until ((char := byte[strPtr][index++]) == 0)
		if char => "0" and char =< "9"
			decVal := decVal * 10 + (char - "0")
                        valid := true
		if byte[strPtr] == "-"
			decVal := -decVal

        if not valid
          decVal := $FFFFFFFF

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
