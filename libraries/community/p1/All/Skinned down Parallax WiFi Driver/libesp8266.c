/**
 * @brief Connect to Parallax WX board
 * @author Michael Burmeister
 * @date April 4, 2019
 * @version 1.0
 * 
*/

#include "simpletools.h"
#include "esp8266.h"

void printb(char *, int);

int i;
int s;
int t;
char Buffer[5100];
fdserial *fd;
char url[] = "api.openweathermap.org";
char rqs[] = "GET /data/2.5/forecast?id=<city>&APPID=<your id>&units=imperial";
char rqs2[] = "GET /data/2.5/weather?id=<city>&APPID=<your id>&units=imperial";


int main()
{
  //simpleterm_close();
  
  fd = esp8266_open(3, 4); // 31 30
  
  print("Starting\n");
  
//  i = esp8266_set("wifi-mode", "STA");
//  print("WiFi: %d\n", i);
  pause(1000);
  printi("IP: %s\n", esp8266_check("station-ipaddr"));
  
//  i = esp8266_set("station-ipaddr", "101.1.1.42&101.1.1.4&255.255.255.0&101.1.1.1");
//  print("StationIP: %d\n", i);

//  i = esp8266_join("<your SSID>", "<your password>");
//  print("Join: %d\n", i);
  pause(1000);
  i = esp8266_connect(url, 80);
  if (i >= 0)
  {
    print("Sending request 2\n");
    s = esp8266_http(i, rqs2, 0);
    print("Request: %d \n", s);
    
    t = esp8266_recv(i, Buffer, 1024);
    print("Recv: %d \n", t);
    if (t > 0)
      printb(Buffer, 1024);
    esp8266_close(i);
  }
  else
  {
    print("Connect Failed: %d\n", i);
  }
  
  i = esp8266_connect(url, 80);
  if (i >= 0)
  {
    print("Sending request\n");
    s = esp8266_http(i, rqs, 0);
    print("Request: %d \n", s);

    t = esp8266_recv(i, Buffer, 1024);
    print("recv: %d\n", t);
    if (t == 1024)
    {
      t = esp8266_recv(i, &Buffer[1024], 1024);
      print("recv: %d\n", t);
    }
    if (t == 1024)
    {      
      t = esp8266_recv(i, &Buffer[2048], 1024);
      print("recv: %d\n", t);
    }
        
    printb(Buffer, sizeof(Buffer));
    esp8266_close(i);
  }
  else
  {
    print("Connect Failed: %d\n", i);
  }

  while(1)
  {
    pause(1000);
//    i = esp8266_poll(0);
//    print("Poll: %d\n", i);
  }  
}

void printb(char *data, int size)
{
  for(int n = 0; n < size; n++)
  {
    if(data[n] <= 128 && data[n] >= ' ')
    {
      putChar(data[n]);
    }      
    else if(data[n] == 0)
    {
      print("[%d]", n);
      break;
    }      
    else if(data[n] == '\n')
    {
      putChar('\n');
    }
    else
    {
      print("[%x]", data[n]);
    }      
  }  
}