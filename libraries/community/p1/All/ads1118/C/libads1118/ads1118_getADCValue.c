/*
 * @file ads1118_getADCValue.c
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

#include "ads1118.h"


uint8_t lastSensorMode;

uint16_t ads1118_getADCValue(uint8_t inputs) {
  
  const uint8_t  CONV_TIME[8] = {125, 63, 32, 16, 8, 4, 3, 2}; 	    
  uint16_t value;
  byte dataMSB, dataLSB, configMSB, configLSB, count=0;
    
  if(lastSensorMode == ADC_MODE) { 
	  count=1;
  } else {
    ads1118_setADCMode();
    lastSensorMode = ADC_MODE;
  }       
    
    ads1118_setMuxInput(inputs);
    
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
      
	    for(int i=0;i<CONV_TIME[configRegister.bits.rate];i++) //Lets wait the conversion time
        usleep(1000);
      count++;
	  } while (count<=1);
    
    value = (dataMSB << 8) | (dataLSB);
    return value;
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
