/**
 * @file esp8266.c
 * @brief Connect to Parallax WX board
 * @author Michael Burmeister
 * @date April 4, 2019
 * @version 1.0
 * 
*/

#include "simpletools.h"
#include "esp8266.h"

int Recv(void);
void Results(void);

// WiFi Commands
#define CONNECT 0xE4
#define CLOSE   0xE8
#define LISTEN  0xE7
#define REPLY   0xE5
#define POLL    0xEC
#define RECV    0xE9
#define SEND    0xEA
#define SET     0xED
#define CMD     0xFE


int _RX;
int _TX;
fdserial *_esp;
char _Buffer[2048];
char _Work[16];
char _URL[64];
char _Status;
int _SValue;
unsigned long _PCNTX;


fdserial *esp8266_open(int rx, int tx)
{
  _RX = rx;
  _TX = tx;
  
  // put esp8266 unit in command mode
  low(_TX);
  pause(1);
  input(_TX);
  pause(1);
  
  _esp = fdserial_open(_RX, _TX, FDSERIAL_MODE_NONE, 115200);
  return _esp;
}

int esp8266_connect(char *url, char port)
{
  int i, t;
  
  strcpy(_URL, url);
  i = Recv();
  t = 0;
  dprint(_esp, "%c%c%s,%d\r", CMD, CONNECT, url, port);
  do
  {
    if (t++ > 30)
      break;
    i = Recv();
  } while (i == 0);
  
  if (i == 0)
    return -1;
  
  Results();
  
  if (_Status == 'S')
    return _SValue;
  
  return -_SValue;
}

int esp8266_send(char handle, char *request, short opt)
{
  int i, t, j;
  
  strcpy(_Buffer, request);
  strcat(_Buffer, " HTTP/1.1\r\nHost: ");
  strcat(_Buffer, _URL);
  strcat(_Buffer, "\r\nConnection: ");
  if (opt == 1)
    strcat(_Buffer, "close");
  else
    strcat(_Buffer, "keep-alive");
  strcat(_Buffer, "\r\nAccept: */\*\r\n\r\n");

  t = strlen(_Buffer);
  
  dprint(_esp, "%c%c%d,%d\r", CMD, SEND, handle, t);
  for (j=0;j<t;j+=32)
  {
    i = t - j;
    if (i > 32)
      i = 32;
    
    for (int k=0;k<i;k++)
      fdserial_txChar(_esp, _Buffer[j+k]);
    pause(1);
  }
  i = Recv();
  Results();
  return _SValue;
}

int esp8266_recv(char handle, char *data)
{
  int i, t;
  char *r;

  dprint(_esp, "%c%c%d,%d\r", CMD, RECV, handle, 2040);
  t = 0;
  do
  {
    if (t++ > 30)
      break;
    i = Recv();
  } while (i == 0);
  
  if (i == 0)
    return -1;
  Results();
  r = memchr(_Buffer, 0x0d, 15);
  if (r == NULL)
    return -1;
  t = r - _Buffer;
  memcpy(data, &r[1], i-t);
  i = Recv();
  if (i > 0)
    strcat(data, _Buffer);
  return _SValue;
}
  
void esp8266_close(char handle)
{
  dprint(_esp, "%c%c%d\r", CMD, CLOSE, handle);
  Recv();
}
  
int Recv()
{
  int i, j;
  int t;
  
  millis(&_PCNTX);
  t = 0;
  i = 0;
  while (t < 500)
  {
    if (fdserial_rxReady(_esp) != 0)
    {
      j = fdserial_rxCount(_esp);
      for (int k=0;k<j;k++)
        _Buffer[i++] = fdserial_rxChar(_esp);
      _Buffer[i] = 0;
    }
    pause(1);
    t += millis(&_PCNTX);
    if (i > sizeof(_Buffer))
      break;
  }
  
  return i;
}

int esp8266_results()
{
  return _SValue;
}

void esp8266_print(char *data)
{
  for(int n = 0; n < 2048; n++)
  {
    if(data[n] <= 128 && data[n] >= ' ')
    {
      dprint(_esp, "%c", data[n]);
    }      
    else if(data[n] == 0)
    {
      dprint(_esp, "[%x]", data[n]);
      break;
    }      
    else if(data[n] == '\n')
    {
      dprint(_esp, "%c", '\n');
    }
    else
    {
      dprint(_esp, "[%x]", data[n]);
    }      
  }  
}

void Results()
{
  _Status = ' ';
  _SValue = 0;
  if (_Buffer[0] != 0xfe)
    return;
  _Status = _Buffer[2];
  _SValue = atoi(&_Buffer[4]);
}
