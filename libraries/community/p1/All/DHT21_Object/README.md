# DHT21_Object

![1348204046_177.png](1348204046_177.png)

By: Prophead100

Language: Spin, C

Created: Apr 4, 2013

Modified: April 5, 2013

The object reads the temperature and humidity from an AM3201/DHT21 Sensor using a unique 1-wire serial protocol with 5 byte packets where 0s are 26uS long and 1s are 70uS. The object launches another cog and automatically returns the temperature and humidity to variables in memory every few seconds as degrees F and relative percent respectively. It also returns an error byte where true means the data received had correct parity.

Note: For C++ programmers, related MIT licensed C code is included in the documentation.
