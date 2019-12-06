/*
ReadTemp_cog.c
Read temperature from DS18B20 sensors using another cog 
*/
#include "simpletools.h"                      // Include simple tools
#include "limits.h"
//#define STACKTEST
#ifdef STACKTEST
  #include "stacktest.h"
#endif                  
#include "ownet.h"
#define MAXDEVICES 20 //the maximum number of devices we expect to see on a 1-wire bus

uchar SerialNum[MAXDEVICES][8]; //the compiler puts up a warning if this is volatile 
volatile short int temperature[MAXDEVICES];
volatile int NoDevices=-1;
volatile int portNumber=23; //the I/O number used for one wire communication

void ReadTemp(); //runs in other cog

int main() {                                   // Main function
  int *cog;                                    // Cog process ID variable
  int devNum;
  unsigned char byte;
  
#ifdef STACKTEST
  while (1){
    cog = cog_runStackTest(ReadTemp, 512);        // Run the cog test
    print("Please wait 5 seconds...\n");       // User prompt
    sleep(5);                               // Give time to put cog to work
    int stacksize = cog_endStackTest(cog);     // Get the result
    print("Stack int usage = %d.\n",           // Display result
          stacksize);
    sleep(5);
  }
#endif
  cog = cog_run(ReadTemp, 36);        // Start reading the temperature in another cog
  putChar(0); //clear SimpleIDE terminal window
  print("Main running on cog %d. ReadTemp on cog %d\n", cogid(), cog_num(cog));
  while (NoDevices<0){
    print("Looking for temperature sensors\n");
    sleep(1);
  }    
  if (NoDevices==0) {
    print("No temperature sensors found\n");
    while (NoDevices==0){
      sleep(1);
    }      
  }      
  print("\n");
  //display the serial numbers
  for (devNum=0;devNum<NoDevices;devNum++){
    print("Sensor %2d S/N ", devNum+1);
    for (byte=0;byte<sizeof(SerialNum[0]);byte++) print("%02x", SerialNum[devNum][byte]);
    print("\n");
  }
  while (1) {
    putChar(2); //x and y coordinates follow
    putChar(0); //far left
    putChar(NoDevices+3); //line number
    for (devNum=0;devNum<NoDevices;devNum++){
      //use putchar calls to control the SimpleIDE terminal
      if (temperature[devNum]!=SHRT_MAX){
        print("Temperature %2d %9.4fC %9.4fF", devNum+1, 
          temperature[devNum]/16.0, 32+(9*temperature[devNum])/80.0);
      } else {
        print("Temperature %2d Error", devNum+1); 
      }
      putChar(11); //clear to end of line
      print("\n");
    }
    putChar(12); //clear lines below cursor
    pause(750);
  }    
}


void startConversion(uchar exPower, int portnum){
  owTouchReset(portnum); //may not be necessary, but doesn't hurt
  owWriteByte(portnum,0xcc); //address all one-wire devices
  if (exPower){
    owWriteByte(portnum,0x44); //restart the temperature measurement
  }else{ //at least one device is parasite powered
    owWriteBytePower(portnum,0x44); //restart the temperature measurement
    sleep(1); //wait for temperature conversion to complete  
  }      
}  

void ReadTemp()         //function runs in other cog
{
  unsigned short int counter;
  short int temp;
  int devNum=0;
  unsigned char byte, tSensor[MAXDEVICES]={0};
  uchar utilcrc8, tdata, exPower;
  int NumDevices;
  int portnum=portNumber; //no changes to port number after this function starts
 
  for (devNum=0;devNum<MAXDEVICES;devNum++){
    temperature[devNum]=SHRT_MAX; //initialize temperature to error value
  }    
  do{
    // Find the temperature sensor(s). Only look for family 0x28 (DS18B20 temperature sensors)
    NumDevices = FindDevices(portnum, SerialNum, 0x28, MAXDEVICES);
  }while (NumDevices==0);
  NoDevices=NumDevices;  
  //see if any devices are using parasite power
  owTouchReset(portnum);
  owWriteByte(portnum,0xcc); //address all one-wire devices
  owWriteByte(portnum,0xb4); //read power supply command
  exPower=owTouchBit(portnum, 1); //if any devices are parasite powered the line will be pulled low
//  if (exPower) print("All devices are externally powered\n");
//  else print("Parasite power is in use\n");
  startConversion(exPower, portnum); //start the temperature measurement
  while(1){
    if (owTouchBit(portnum, 1)) { 
      //the devices are all done converting the temperature
      for (devNum=0;devNum<NumDevices;devNum++){
        owSerialNum(portnum, SerialNum[devNum], 0); //put in the serial number of the sensor we want to read
        tSensor[devNum] = owAccess(portnum); //address the temperature sensor
        owWriteByte(portnum,0xbe); //tell sensor to send the temperature
        setcrc8(portnum, 0); //initialize the CRC to 0
        //read the scratchpad except for CRC
        for (byte=0; byte<8; byte++) {
          tdata=owReadByte(portnum);
          if (byte==0) temp=tdata; //read temperature LSB
          if (byte==1) temp|=(tdata<<8); //read temperature MSB
          utilcrc8=docrc8(portnum, tdata); //calculate CRC
        }
        tdata=owReadByte(portnum); //read the CRC from the scratchpad
        if (utilcrc8==tdata) {
          temperature[devNum]=temp;
        } else {
          temperature[devNum]=SHRT_MAX; //CRC doesn't match. Indicates an error
        }
      }
      startConversion(exPower, portnum); //restart the temperature measurement
    }
  }
  return;
}
