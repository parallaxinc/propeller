/*
 * @file ads1118_decodeConfigRegister.c
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


double volts;
double temp;
uint16_t adc;
  

int main()                                    // Main function
{
 
  ads1118_init(22,23,20,21);
  
  ads1118_enableNOP();  
  ads1118_enablePullup();
  ads1118_setSamplingRate(RATE_128SPS);
  ads1118_setSingleShotMode();
  ads1118_setFullScaleRange(FSR_0256);
  ads1118_enableSingleStart();
  
  
  while(1)
  {
    adc = ads1118_getADCValue(DIFF_0_1);
    print("\n%cadc 1 reading = %d%c\n\n", HOME, adc, CLREOL);                // Display adc reading
    
    ads1118_decodeconfigRegister(configRegister);
    
    adc = ads1118_getADCValue(DIFF_2_3);
    print("\nadc 2 reading = %d%c\n\n",adc, CLREOL);                           // Display adc reading
    
    ads1118_decodeconfigRegister(configRegister);
    
    volts = ads1118_getMilliVolts(DIFF_0_1);
    print("\nMillivolts 1 = %f%c\n\n",volts,CLREOL);                         // Display milivolts
     
    ads1118_decodeconfigRegister(configRegister);
    
    volts = ads1118_getMilliVolts(DIFF_2_3);
    print("\nMillivolts 2 = %f%c\n\n",volts,CLREOL);                         // Display milivolts
    
    ads1118_decodeconfigRegister(configRegister);
     
    temp = (ads1118_getTemperature() * 9 / 5) + 32;   
    print("\nTemperature = %f%c\n",temp,CLREOL);                         // Display milivolts
    
    pause(1000);
  }
} 