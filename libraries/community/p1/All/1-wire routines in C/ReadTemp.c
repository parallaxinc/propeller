/*
ReadTemp.c
Read temperature from DS18B20 sensors 
*/
#include "simpletools.h"                      // Include simple tools
#include "ownet.h"
#define MAXDEVICES 20 //the maximum number of devices we expect to see on a 1-wire bus

void startConversion(uchar exPower, int portnum);

int main()                                    // Main function
{
  uchar SerialNum[MAXDEVICES][8]; //the 64-bit serial numbers of 1-wire devices
  int NumDevices=0; //the number of 1-wire devices found
  int portnum=23; //the I/O number used for one wire communication
  unsigned short int counter;
  short int temperature; //current temperature
  int devNum=0;
  unsigned char byte;
  uchar utilcrc8, tdata, exPower;

  do{
    // Find the temperature sensor(s). Only look for family 0x28 (DS18B20 temperature sensors)
    NumDevices = FindDevices(portnum, SerialNum, 0x28, MAXDEVICES);
    if (NumDevices==0) {
      putChar(0); //clear SimpleIDE terminal window
      print("No temperature sensors found\n");
    }      
  }while (NumDevices==0);  
  //display the serial numbers
  for (devNum=0;devNum<NumDevices;devNum++){
    print("Sensor %2d S/N ", devNum+1);
    for (byte=0;byte<sizeof(SerialNum[0]);byte++) print("%02x", SerialNum[devNum][byte]);
    print("\n");
  }
  //see if any devices are using parasite power
  owTouchReset(portnum);
  owWriteByte(portnum,0xcc); //address all one-wire devices
  owWriteByte(portnum,0xb4); //read power supply command
  exPower=owTouchBit(portnum, 1); //if any devices are parasite powered the line will be pulled low
  if (exPower) print("All devices are externally powered\n");
  else print("Parasite power is in use\n");
  startConversion(exPower, portnum); //start the temperature measurement
  while(1){
    if (owTouchBit(portnum, 1)) { 
      //the devices are all done converting the temperature
      for (devNum=0;devNum<NumDevices;devNum++){
        owSerialNum(portnum, SerialNum[devNum], 0); //put in the serial number of the sensor we want to read
        owAccess(portnum); //address the temperature sensor
        owWriteByte(portnum,0xbe); //tell sensor to send the temperature
        setcrc8(portnum, 0); //initialize the CRC to 0
        //read the scratchpad except for CRC
        for (byte=0; byte<8; byte++) {
          tdata=owReadByte(portnum);
          if (byte==0) temperature=tdata; //read temperature LSB
          if (byte==1) temperature|=(tdata<<8); //read temperature MSB
          utilcrc8=docrc8(portnum, tdata); //calculate CRC
        }
        tdata=owReadByte(portnum); //read the CRC from the scratchpad
        //use putchar calls to control the SimpleIDE terminal
        putChar(2); //x and y coordinates follow
        putChar(0); //far left
        putChar(devNum+NumDevices+1); //line number
        if (utilcrc8==tdata) {
          print("Temperature %2d %9.4fC %9.4fF", devNum+1, temperature/16.0, 32+(9*temperature)/80.0);
        } else {
          print("Error reading sensor %2d CRC %x %x", devNum, utilcrc8, tdata);
        }
        putChar(11); //clear to end of line
      }
      putChar(12); //clear lines below cursor
      startConversion(exPower, portnum); //restart the temperature measurement
    }
  }
  return 0;
}

void startConversion(uchar exPower, int portnum){
  owTouchReset(portnum); 
  owWriteByte(portnum,0xcc); //address all one-wire devices
  if (exPower){ //all devices are externally powered
    owWriteByte(portnum,0x44); //restart the temperature measurement
  }else{ //at least one device is parasite powered
    owWriteBytePower(portnum,0x44); //restart the temperature measurement
    sleep(1); //wait for temperature conversion to complete  
  }      
}  