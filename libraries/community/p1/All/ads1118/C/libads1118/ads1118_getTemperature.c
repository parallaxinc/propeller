/*
 * @file ads1118_getTempurature.c
 *
 * @author Greg LaPolla
 *
 * @version 0.1
 *
 * @copyright Copyright (C) 2020.  See end of file for
 * terms of use (MIT License).
 *
 * @brief This is a driver that allows the Propeller Multicore Microcontroller to 
 * commnicate with the TI ADS1118 16 bit ADC with compensatin temperature sensor
 *
 */

#include "simpletools.h"
#include "ads1118.h"

uint8_t lastSensorMode;

double ads1118_getTemperature() {
  
  const uint8_t  CONV_TIME[8] = {125, 63, 32, 16, 8, 4, 3, 2}; 	
  uint16_t convRegister;
  uint8_t dataMSB, dataLSB, configMSB, configLSB, count=0;
  
  if(lastSensorMode == TEMP_MODE) {
    count=1;
  } else {
	  ads1118_setTEMPMode(); 
    lastSensorMode=TEMP_MODE;
  }
      
  do{
      low(_cs);
      shift_out(_din,_sclk,MSBFIRST,8,configRegister.byte.msb);
      shift_out(_din,_sclk,MSBFIRST,8,configRegister.byte.lsb);
      high(_cs);

      usleep(100);

      low(_cs);
      dataMSB = shift_in(_dout,_sclk,MSBPOST,8);
      dataLSB = shift_in(_dout,_sclk,MSBPOST,8);
      configMSB = shift_in(_dout,_sclk,MSBPOST,8);
      configLSB = shift_in(_dout,_sclk,MSBPOST,8);
      high(_cs);

      for(int i=0;i<CONV_TIME[configRegister.bits.rate];i++) 
        usleep(1000);
      count++;
    } while (count<=1);

    convRegister = ((dataMSB << 8) | (dataLSB))>>2;
    if((convRegister<<2) >= 0x8000){
      convRegister=((~convRegister)>>2)+1;
      return (double)(convRegister*0.03125*-1);
    }
      
    return (double)convRegister*0.03125;
}

/**
 * TERMS OF USE: MIT License
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 */