/**
 * @brief Connect to Parallax WX board
 * @author Michael Burmeister
 * @date April 4, 2019
 * @version 1.0
 * 
*/

#include "simpletools.h"
#include "esp8266.h"

void doPrint(char *);

int i;
int s;
char Buffer[2048];
fdserial *fd;


int main()
{
  simpleterm_close();
  
  fd = esp8266_open(31, 30); // 31 30
  
  i = esp8266_connect("api.openweathermap.org", 80);
  if (i > 0)
  {
    s = esp8266_send(i, "GET /data/2.5/weather?id=<your city state and ID>&units=imperial", 1);
    s = esp8266_send(i, "GET /", 1);
    s = esp8266_recv(i, Buffer);
    esp8266_close(i);
  }
  else
  {
    dprint(fd, "value: %d\n", i);
  }

  doPrint(Buffer);
    
  while(1)
  {
    pause(1000);
    
  }  
}

void doPrint(char *data)
{
  for(int n = 0; n < 2048; n++)
  {
    if(data[n] <= 128 && data[n] >= ' ')
    {
      dprint(fd, "%c", data[n]);
    }      
    else if(data[n] == 0)
    {
      dprint(fd, "[%x]", data[n]);
      break;
    }
    else if(data[n] == '\n')
    {
      dprint(fd, "%c", '\n');
    }
    else
    {
      dprint(fd, "[%x]", data[n]);
    }
  }  
}