/**
 * @file esp8266.c
 * @brief Connect to Parallax WX board
 * @author Michael Burmeister
 * @date April 4, 2019
 * @version 1.1
 * 
*/

#include "simpletools.h"
#include "esp8266.h"

int doWait(void);
int Recv(void);
void Results(void);
int millis(void);

// WiFi Commands

#define JOIN    0xEF
#define CONNECT 0xE4
#define CLOSE   0xE8
#define LISTEN  0xE7
#define REPLY   0xE5
#define POLL    0xEC
#define RECV    0xE9
#define SEND    0xEA
#define CHECK   0xEE
#define SET     0xED
#define CMD     0xFE
#define UDP     0xDE
#define SLEEP   0xF1
#define DROP    0xDC

int _RX;
int _TX;
fdserial *_esp;
char _Buffer[1050];
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
  dprint(_esp,"\r");
  return _esp;
}

int esp8266_connect(char *url, short port)
{
  int i;
  
  strcpy(_URL, url);
  i = Recv();
  dprint(_esp, "%c%c%s,%d\r", CMD, CONNECT, url, port);
  if (doWait() <= 0)
    return -1;
  if (_Status == 'S')
    return _SValue;
  return -_SValue;
}

int esp8266_send(char handle, char *request)
{
  int i;
  
  i = strlen(request);
  return esp8266_sendbin(handle, request, i);
}

int esp8266_http(char handle, char *request, short opt)
{
  int i;
  
  strcpy(_Buffer, request);
  strcat(_Buffer, " HTTP/1.1\r\nHost: ");
  strcat(_Buffer, _URL);
  strcat(_Buffer, "\r\nConnection: ");
  if (opt == 0)
    strcat(_Buffer, "close");
  else
    strcat(_Buffer, "keep-alive");
  strcat(_Buffer, "\r\nAccept: */\*\r\n\r\n");

  i = strlen(_Buffer);
  
  return esp8266_sendbin(handle, _Buffer, i);
}

int esp8266_sendbin(char handle, unsigned char *data, short size)
{
  int i, j;
  
  dprint(_esp, "%c%c%d,%d\r", CMD, SEND, handle, size);
  for (j=0;j<size;j+=32)
  {
    i = size - j;
    if (i > 32)
      i = 32;
    
    for (int k=0;k<i;k++)
      fdserial_txChar(_esp, data[j+k]);
    pause(1);
  }
  i = doWait();
  
  if (i <= 0)
    return i;

  if (_Status == 'S')
    return _SValue;

  return -_SValue;
}

int esp8266_recv(char handle, char *data, int size)
{
  int i, s;
  char *r;

  if (size > 1024)
    size = 1024;
  
  dprint(_esp, "%c%c%d,%d\r", CMD, RECV, handle, size);
  i = doWait();

  if (i <= 0)
    return i;

  r = memchr(_Buffer, '\r', 15);
  if (r == NULL)
    return -1;
  
  s = i - (r - _Buffer);
  memcpy(data, &r[1], s);
  data[s] = 0;
  
  i = Recv();
  if (i > 0)
  {
    strcat(data, _Buffer);
  }    

  return _SValue;
}

int esp8266_udp(char *url, short port)
{
  int i;
  
  i = Recv();
  dprint(_esp, "%c%c%s,%d\r", CMD, UDP, url, port);
  if (doWait() <= 0)
    return -1;
  if (_Status == 'S')
    return _SValue;
  return -_SValue;
}
  
void esp8266_close(char handle)
{
  dprint(_esp, "%c%c%d\r", CMD, CLOSE, handle);
  doWait();
}

int esp8266_join(char *ssd, char *pwd)
{
  int i;
  dprint(_esp, "%c%c%s,%s\r", CMD, JOIN, ssd, pwd);
  if (doWait() <= 0)
    return -1;
  if (_Status == 'S')
    return _SValue;
  return -_SValue;
}

int esp8266_set(char *env, char *value)
{
  int i;
  dprint(_esp, "%c%c%s,%s\r", CMD, SET, env, value);
  if (doWait() <= 0)
    return -1;
  if (_Status == 'S')
    return _SValue;
  return -_SValue;
}

char *esp8266_check(char *env)
{
  int i;
  dprint(_esp, "%c%c%s\r", CMD, CHECK, env);
  i = doWait();

  if (i <= 0)
    return NULL;

  if (_Status == 'S')
    return &_Buffer[4];
  
  return NULL;
}

int esp8266_poll(char handle)
{
  int i;
  i = 1 << handle;
  dprint(_esp, "%c%c%d\r", CMD, POLL, i);
  i = doWait();
  if (i == 0)
    return i;
  
  i = atoi(&_Buffer[6]);

  return i;
}

int esp8266_listen(char protocol, char *uri)
{
  int i;
  
  dprint(_esp, "%c%c%c%s\r", CMD, LISTEN, protocol, uri);
  if (doWait() <= 0)
    return -1;
  if (_Status == 'S')
    return _SValue;
  return -_SValue;
}

int esp8266_sleep(char type, int microsec)
{
  dprint(_esp, "%c%c%c,%d\r", CMD, SLEEP, type, microsec);
  if (doWait() <= 0)
    return -1;
  if (_Status == 'S')
    return _SValue;
  return -_SValue;
}

int esp8266_drop(void)
{
  dprint(_esp, "%c%c\r", CMD, DROP);
  if (doWait() <= 0)
    return -1;
  if (_Status == 'S')
    return _SValue;
  return -_SValue;
}

int esp8266_results()
{
  return _SValue;
}

int doWait()
{
  int i, t;
  
  t = 0;
  do
  {
    if (t++ > 30)
      return -1;
    i = Recv();
  } while (i == 0);
  
  Results();

  return i;
}

int Recv()
{
  int i, j;
  int t;
  
  millis();
  t = 0;
  i = 0;
  while (t < 500)
  {
    if (fdserial_rxReady(_esp) != 0)
    {
      j = fdserial_rxCount(_esp);
      if ((j+i) >= 1023)
        j = 1023 - i;
      for (int k=0; k<j; k++)
        _Buffer[i++] = fdserial_rxChar(_esp);

      _Buffer[i] = 0;
    }
    pause(1);
    t += millis();
  }
  
  return i;
}

void esp8266_print(char *data, int size)
{
  for(int n = 0; n < size; n++)
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
  if (_Buffer[0] != CMD)
    return;
  _Status = _Buffer[2];
  _SValue = atoi(&_Buffer[4]);
}

int millis()
{
  long t;
  
  t = CNT - _PCNTX;
  _PCNTX = CNT;
  if (t < 0)
    t = UINT32_MAX + t;

  _PCNTX = _PCNTX - t % ms;
  t = t/ms;
  return t;
}
