{{
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// TB6612FNG MOTOR DRIVER
//
//
// Author: Stefan Wendler
// Updated: 2013-11-28
// Designed For: P8X32A
// Version: 1.0
//
// Copyright (c) 2013 Stefan Wendler
// See end of file for terms of use.
//
// Update History:
//
// v1.0 - Initial release       - 2013-11-28
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Circuit Diagram:
//
// PIN AO1       --- AO1,  Motor A out 1
// PIN AO2       --- AO2,  Motor A out 2
// PIN PWMA      --- PWMA, Motor A PWM (for speed control)
// PIN BO1       --- BO1,  Motor B out 1
// PIN BO2       --- BO2,  Motor B out 2
// PIN PWMB      --- PWMB, Motor B PWM (for speed control)
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Brief Description:
//
// Dirve two motors through the TB6612FNG dual motor dirver. Optionally adjust the speed for each motor in %.
// Speed adjustment is done through the TB6612FNG PWM input. For each motor PWM speedcontrol is used, a Cog is
// reserved to generate the PWM.
// The driver offers methods to operate each motor individually or both motors together (by sending the same command
// to each, or sending a different command to each).
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Detailed Description:
//
// For detailed usage, see the example.
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}}

CON

  PWM_FREQ_HZ   = 18_000        ' Freq. for PWM
  INITIAL_DC_PC = 100           ' Initial duty-cycle for PWM

  MOT_A       = 1               ' Address motor A
  MOT_B       = 2               ' Address motor B

  CMD_CW      = 1               ' Drive motor clock wise
  CMD_CCW     = 2               ' Drive motor counter clock wise
  CMD_STOP    = 3               ' Stop (break) motor

VAR

  byte pinAO1
  byte pinAO2
  byte pinBO1
  byte pinBO2

OBJ

  pwma	: "pwm"
  pwmb	: "pwm"

PUB init(aPinAO1, aPinAO2, aPinPWMA, aPinBO1, aPinBO2, aPinPWMB)

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Initialize the TB6612FNG motor driver
'' //
'' // @param                    aPinAO1                 Motor A output pin for motor operation 1
'' // @param                    aPinAO2                 Motor A output pin for motor operation 2
'' // @param                    aPinPWMA                Motor A output pin for motor PWM, or false if NC
'' // @param                    aPinBO1                 Motor B output pin for motor operation 1
'' // @param                    aPinBO2                 Motor B output pin for motor operation 2
'' // @param                    aPinPWMB                Motor B output pin for motor PWM, or false if NC
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  pinAO1 := aPinAO1
  pinAO2 := aPinAO2
  pinBO1 := aPinBO1
  pinBO2 := aPinBO2

  if aPinPWMA
    pwma.start(aPinPWMA, PWM_FREQ_HZ, INITIAL_DC_PC)

  if aPinPWMB
    pwmb.start(aPinPWMB, PWM_FREQ_HZ, INITIAL_DC_PC)

  dira[pinAO1] := 1
  dira[pinAO2] := 1
  dira[pinBO1] := 1
  dira[pinBO2] := 1

  operateSync(CMD_STOP)

PUB operate(motor, command) | o1, o2, f1, f2

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Operate a single motor (MOT_A or MOT_B)
'' //
'' // @param                    motor                   Motor to operate (MOT_A or MOT_B)
'' // @param                    command                 Command to send (CMD_CW, CMD_CCW or CMD_STOP)
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  if motor == MOT_A
    o1 := pinAO1
    o2 := pinAO2
  else
    o1 := pinBO1
    o2 := pinBO2

  if command == CMD_CW
    f1 := 0
    f2 := 1
  elseif command == CMD_CCW
    f1 := 1
    f2 := 0
  else
    f1 := 1
    f2 := 1

  outa[o1] := f1
  outa[o2] := f2

PUB operateAsync(commandA, commandB)

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Operate both motors asynchron (send individual command to each)
'' //
'' // @param                    commandA                 Command to send to motor A (CMD_CW, CMD_CCW or CMD_STOP)
'' // @param                    commandB                 Command to send to motor B (CMD_CW, CMD_CCW or CMD_STOP)
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  operate(MOT_A, commandA)
  operate(MOT_B, commandB)

PUB operateSync(command)

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Operate both motors synchron (send same command to both)
'' //
'' // @param                    command                  Command to send to motor A+B (CMD_CW, CMD_CCW or CMD_STOP)
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  operateAsync(command, command)

PUB setSpeed(motor, speed)

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Set the speed (PWM duty cycle in %) for a single motor (MOT_A or MOT_B)
'' //
'' // @param                    motor                   Motor for which to set speed (MOT_A or MOT_B)
'' // @param                    speed                   Speed as PWM dutycycle in % (0=stop, 100=full)
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  if motor == MOT_A
    pwma.setDc(speed)
  else
    pwmb.setDc(speed)

PUB setSpeedAsync(speedA, speedB)

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Set the speed (PWM duty cycle in %) asynchron (individual for each motor)
'' //
'' // @param                    speedA                  Speed as PWM dutycycle in % (0=stop, 100=full) for motor A
'' // @param                    speedB                  Speed as PWM dutycycle in % (0=stop, 100=full) for motor B
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  setSpeed(MOT_A, speedA)
  setSpeed(MOT_B, speedB)

PUB setSpeedSync(speed)

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Set the speed (PWM duty cycle in %) synchron (same for each motor)
'' //
'' // @param                    speed                   Speed as PWM dutycycle in % (0=stop, 100=full) for motor A + B
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  setSpeedAsync(speed, speed)

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
