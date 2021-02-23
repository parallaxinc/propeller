# Stepper Motor Driver Ver 2

## Author
Bill Tuss (forum: btuss)

## Language
Spin2, PASM2

## Created:
February 9, 2021

## Category
Motor control

## Description
This object implements a step motor driver. 
The trajectory is sinusoidal, ramp up, a period at constant speed, ramp down. 
A STOP input is monitored that will decelerate the motor to a stop in a controlled fashion. 
There are two versions. One for drivers that use step and direction inputs and one for drivers with cw and ccw inputs. 
A demo program in spin2 is included. 

## License
MIT (see end of source code)
