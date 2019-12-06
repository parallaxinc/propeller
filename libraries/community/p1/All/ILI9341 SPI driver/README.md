# ILI9341 SPI driver

By: MarkT

Language: Spin, Assembly

Created: Nov 16, 2013

Modified: November 16, 2013

724:"
This is a simple little method that returns the lowest common multiple of two numbers. For example, if I were to pass it the parameters (12,15), it would return 60. I use it as part of a CNC controller. It can only handle positive numbers. 

PUB Get\_LCM (m,n) : result | a,b 'Returns lowest common multiple of two numbers

  a := m

  b := n

  repeat while a <> b

    if a < b

      a := (a+m)

    else

      b := (b+n)

result := a
