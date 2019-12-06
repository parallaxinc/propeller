/**
 * @brief BME280 sensor library
 * @author Michael Burmeister
 * @date December 14, 2017
 * @version 1.1
 * 
*/

#include "simpletools.h"
#include "bme280.h"


#define BMESCL 7
#define BMESDA 6


int main()
{
  int i;
  int j;
  float f;
  
  i = BME280_open(BMESCL, BMESDA);
  
  print("should be hex (60):%x \n", i);
  
  BME280_reset();
  
  BME280_setHumidity(oversample_1);
  BME280_setTemp(oversample_1);
  BME280_setPressure(oversample_1);
  BME280_setStandbyRate(standby625);
  BME280_setMode(BME280_normal);
  
  i = BME280_getMode();
  print("Mode: %x \n", i);
  
  f = 0;
  
  while(1)
  {
    while (i != 0)
    {
      j = 1;
      print("<%b> ", i);
      pause(1000);
      i = BME280_getStatus();
    }
    
    if (j != 0)
    {
      j = 0;
      print("\n");
    }
          
    i = BME280_getTempF();
//    f = BME280_getTemperature();
//    printf("Temp: %d %2.2f ", i, f);
    print("Temp: %d ", i/100);
    
    i = BME280_getPressure();
//    f = BME280_getPressuref();
//    printf("Pressure: %d %2.2f ", i, f);
    print("Pressure: %d ", i);
    
    i = BME280_getHumidity();
//    f = BME280_getHumidityf();
//    printf("Humidity: %d %2.2f\n", i, f);
    print("Humidity: %d\% \n", i/100);
    
    i = BME280_getStatus();
  }  
}
