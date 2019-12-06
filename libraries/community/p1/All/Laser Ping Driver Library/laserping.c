/**
 * @file laserping.c
 * @brief Laser Ping Driver to determine distance
 * @author Michael Burmeister
 * @date March 30, 2019
 * @version 1.0
 * 
*/

#include "simpletools.h"
#include "laserping.h"


void laserping_run(void *par);
void laserping_runp(void *par);


char _Pin;
int _Average[10];
char _Buffer[25];
serial *_S;
int _RS;

void laserping_start(char mode, char pin)
{
  _Pin = pin;

  if (mode == 'S')
    cog_run(&laserping_run, 50);
  else
    cog_run(&laserping_runp, 50);
}
  
void laserping_run(void *par)
{
  char c;
  int p;
  int i;
  int t;
  
  low(_Pin);
  pause(250);

  _S = serial_open(_Pin, _Pin, 0, 9600);
  
  serial_txChar(_S, 'I');
  serial_txChar(_S, 'I');

  p = 0;
  t = 0;
  _RS = 1;
  while (_RS)
  {
    c = serial_rxChar(_S);
    if (c == 13)
    {
      _Buffer[p] = 0;
      i = atoi(_Buffer);
      _Average[t++] = i;
      if (t > 9)
        t = 0;
      p = 0;
    }
    else
      _Buffer[p++] = c;

    if (p > 10)
      p = 0;
  }
  serial_close(_S);
  cogstop(cogid());
}

void laserping_runp(void *par)
{
  int i;
  int t;
  
  low(_Pin);
  
  t = 0;
  _RS = 1;
  while (_RS)
  {
    pause(70);
    low(_Pin);
    pulse_out(_Pin, 5);
    i = pulse_in(_Pin, 1);
    _Average[t++] = i * 1740 / 10000;
    if (t > 9)
      t = 0;
  }
}
  
int laserping_distance(void)
{
  int d = 0;
  
  for (int i=0;i<10;i++)
    d = d + _Average[i];
  
  return d / 10;
}

void laserping_stop(void)
{
  _RS = 0;
}
  