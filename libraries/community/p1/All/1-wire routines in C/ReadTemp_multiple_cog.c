/*
ReadTemp_multiple_cog.c
Read temperature from DS18B20 sensors using mutiple 1-wire ports and cogs 
*/
#include "simpletools.h"                      // Include simple tools
#include "limits.h"
//#define STACKTEST
#ifdef STACKTEST
  #include "stacktest.h"
#endif                  
#include "ownet.h"
#define MAXDEVICES 20 //the maximum number of devices we expect to see on a 1-wire bus
#define ONE_WIRE_BUSES 3 //the number of 1-wire buses we are using

struct {
  uchar SerialNum[MAXDEVICES][8]; //the compiler puts up a warning that it discards the volatile qualifier (why?) 
  short int temperature[MAXDEVICES];  //temperature reading from the sensors
  int NoDevices; //the number of temperature sensors found on the 1-wire bus
  int port; //the I/O number used for one wire communication
  int cognum; //the cog number that this index of the structure matches
} volatile tSense[ONE_WIRE_BUSES];

void ReadTemp(); //runs in other cogs

int main() {                                   // Main function
  int *cog[ONE_WIRE_BUSES];                   // Cog process ID variable
  int portnum[ONE_WIRE_BUSES]={22,23,24}; //the I/O ports used for 1-wire communication
  int port;
  int devNum;
  unsigned char byte;
  
#ifdef STACKTEST
  while (1){
    cog[0] = cog_runStackTest(ReadTemp, 512);        // Run the cog test
    tSense[0].cognum=cog_num(cog[0]);
    tSense[0].port=portnum[0];
    print("Please wait 5 seconds...\n");       // User prompt
    sleep(5);                               // Give time to put cog to work
    int stacksize = cog_endStackTest(cog[0]);     // Get the result
    print("Stack int usage = %d.\n",           // Display result
          stacksize);
    sleep(5);
  }
#endif
  putChar(0); //clear SimpleIDE terminal window
  for (port=0;port<ONE_WIRE_BUSES;port++){
    cog[port] = cog_run(ReadTemp, 33);        // Start reading the temperature in another cog
    tSense[port].cognum=cog_num(cog[port]);
    tSense[port].port=portnum[port];
    print("1-wire bus I/O port %d controlled by cog %d\n", tSense[port].port, tSense[port].cognum);
  }
  print("Looking for temperature sensors\n");
  //display the serial numbers
  while (1) {
    putChar(2); //position cursor.  x and y coordinates follow
    putChar(0); //far left
    putChar(ONE_WIRE_BUSES+2); //line number
    for (port=0;port<ONE_WIRE_BUSES;port++){
      for (devNum=0;devNum<tSense[port].NoDevices;devNum++){
        print("Port %2d Sensor %02d S/N ", tSense[port].port, devNum+1);
        for (byte=0;byte<sizeof(tSense[port].SerialNum[0]);byte++) print("%02x", tSense[port].SerialNum[devNum][byte]);
        print("\n");
      }
    }  
    for (port=0;port<ONE_WIRE_BUSES;port++){
      for (devNum=0;devNum<tSense[port].NoDevices;devNum++){
        //use putchar calls to control the SimpleIDE terminal
        if (tSense[port].temperature[devNum]!=SHRT_MAX){
          print("Port %2d-%02d %9.4fC %9.4fF", tSense[port].port, devNum+1, 
            tSense[port].temperature[devNum]/16.0, 32+(9*tSense[port].temperature[devNum])/80.0);
        } else {
          print("Port %2d-%02d Error", tSense[port].port, devNum+1); 
        }
        putChar(11); //clear to end of line
        print("\n");
      }
    }  
    putChar(12); //clear lines below cursor
    pause(750);
  }    
}


void startConversion(uchar exPower, int portnum){
  owTouchReset(portnum); //may not be necessary, but doesn't hurt
  owWriteByte(portnum,0xcc); //address all one-wire devices
  if (exPower){ //all devices are externally powered
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
  int portnum;
  int index; //the index of the structure array this function is using
  
  //find out which I/O port and which index of the structure we are to use
  do{
    usleep(100);
    for (index=0;(index<ONE_WIRE_BUSES) && (cogid()!=tSense[index].cognum);index++);
  }while (cogid()!=tSense[index].cognum);         
  portnum=tSense[index].port; //no changes to port number after this function starts
 
  for (devNum=0;devNum<MAXDEVICES;devNum++){
    tSense[index].temperature[devNum]=SHRT_MAX; //initialize temperature to error value
  }    
  do{
    // Find the temperature sensor(s). Only look for family 0x28 (DS18B20 temperature sensors)
    NumDevices = FindDevices(portnum, tSense[index].SerialNum, 0x28, MAXDEVICES);
  }while (NumDevices==0);
  tSense[index].NoDevices=NumDevices;  
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
        owSerialNum(portnum, tSense[index].SerialNum[devNum], 0); //put in the serial number of the sensor we want to read
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
          tSense[index].temperature[devNum]=temp;
        } else {
          tSense[index].temperature[devNum]=SHRT_MAX; //CRC doesn't match. Indicates an error
        }
      }
      startConversion(exPower, portnum); //restart the temperature measurement
    }
  }
  return;
}
