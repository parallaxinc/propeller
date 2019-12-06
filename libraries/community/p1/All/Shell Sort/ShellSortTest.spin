'' ShellSortTest.spin
''
'' Copyright (c) 2008 Andrew Walton
'' See end of file for terms of use.
''
'' This file tests the ShellSort object.  It uses a contrived example to
'' create rows of data that are sorted.  The data is printed before and
'' after it is sorted and the sort order is checked.
''
'' This program requires no connections to the propeller other than the
'' prop plug or prop clip.  The output from the program can be viewed
'' using the basic stamp debug console.  Make sure the debug console is
'' set to serial port "none" when you program the propeller.  Then set the
'' debug window to whatever serial port is being emulated by the prop plug.
''
'' The example:
''
''      This test program simulates a range-finding sensor that can turn.
''      For every measurement, the range-finder captures a distance and a
''      direction.  The Shell sort is used to sort the distances in
''      ascending order.  Since the point of this program is to test the
''      sort, it uses random numbers instead of a real sensor.
''
'' The black box test: (http://en.wikipedia.org/wiki/Black_box_testing)
''
''      Since we want to test the ShellSort object, we do not need real sensor
''      data.  Instead, the test will use random numbers and will run in an
''      infinite loop to achieve good test coverage.
''
''      Since the user will not want to watch this run for a long time, the
''      test program keeps a running count of errors that have been seen.  You
''      will need to log the output to a file to get the details of any errors
''      that are discovered.
'' 

con
  ' Clock configuration
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000
  
  maxDirections = 128

  CR = 13  ' constant for carriage return

var
  long pass
  long SensorDir[maxDirections]
  long SensorDist[maxDirections]
  long Seed

OBJ 
''
'' Objects Used
'' -------------------
'' FullDuplexSerialPlus is used to output to Basic Stamp Debug window.   
  Debug: "FullDuplexSerialPlus"

'' ShellSort is the sorting object under test.  
  Sort:  "ShellSort"

pub TestShellSort | directions, dir, errors, randDir, randDist, randIdx, randRowMatch, numbersSorted
  ''
  '' Start Serial Port Cog using pins and baud rate for BS Debug window 
  Debug.start(31, 30, 0, 38400)

  '' Initialize variables  
  pass := 1
  errors := 0
  numbersSorted := 0
  Seed := 53281          ' Pseudo random generator seed - I adore my C64!

  
  '' Generate sensor data (random directions and distances) and print it to
  '' the Debug window
  repeat
    randRowMatch := false
    Debug.str(string("Shell Sort Test -- Pass "))
    Debug.dec(pass)
    Debug.str(string(CR, "---------------------------------------", CR))
    directions := ||Seed?//maxDirections
    '' Check that directions != 0
    if directions == 0
      directions := 1
    Debug.str(string("Number of directions this pass is: "))
    Debug.dec(directions)
    Debug.str(string(CR, "Filling arrays . . . ", CR))
    repeat dir from 0 to (directions - 1)
      SensorDir[dir] := ||Seed?//359
      ''Debug.str(string("Index: "))
      ''Debug.dec(dir) 
      ''Debug.str(string(" Direction: "))
      ''Debug.dec(SensorDir[dir]) 
      SensorDist[dir] := ||Seed?
      ''Debug.str(string(" Distance: "))
      ''Debug.dec(SensorDist[dir])
      ''Debug.str(string(CR))
      
      '' Remember a random row of the table to make sure the distance column
      '' was moved with the direction column.
      randIdx  := ||Seed?//(directions - 1)
      randDir  := SensorDir[randIdx]
      randDist := SensorDist[randIdx]

    '' Sort the data from smallest distance to largest 
    Debug.str(string("Sorting arrays . . . ", CR))
    Sort.Sort(@SensorDist, @SensorDir, directions)

    '' Print the sorted data
    repeat dir from 0 to (directions - 1)
      {Debug.str(string("Index: "))
      Debug.dec(dir) 
      Debug.str(string(" Direction: "))
      Debug.dec(SensorDir[dir]) 
      Debug.str(string(" Distance: "))                             
      Debug.dec(SensorDist[dir])
      Debug.str(string(CR))}
      
      '' Check that list was sorted correctly
      if dir > 0   ' don't check element 0 since there is no element -1
        if SensorDist[dir - 1] > SensorDist[dir]
          Debug.str(string("*******************************", CR))
          Debug.str(string("***** ERROR in sort order *****", CR))
          Debug.str(string("*******************************", CR))
          errors++
          
      '' Check random row to see if direction column got moved with its
      '' corresponding distance
      if SensorDist[dir] == randDist AND SensorDir[dir] == randDir
        randRowMatch := true
    if randRowMatch == false
      Debug.str(string("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@", CR))
      Debug.str(string("@@@@@@@@ ERROR in sort @@@@@@@@", CR))
      Debug.str(string("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@", CR))
      Debug.str(string("Could not find the following row in the sorted data:", CR))
      Debug.str(string("Direction: "))
      Debug.dec(randDir) 
      Debug.str(string(" Distance: "))
      Debug.dec(randDist)
      Debug.str(string(" Index: "))
      Debug.dec(randIdx)
      Debug.str(string(" randRowMatch: "))
      Debug.dec(randRowMatch)
      Debug.str(string(CR))      
      errors++

    '' Add cumulative count of numbers sorted without error
    if errors == 0
      numbersSorted := numbersSorted + directions

    '' Print cumulative count of numbers sorted without error
    Debug.str(string("Count of numbers sorted without error: "))
    Debug.dec(numbersSorted)
    Debug.str(string(CR))                
      
    '' Print running count of errors  
    Debug.str(string("Total errors so far: "))
    Debug.dec(errors)
    Debug.str(string(CR))                
    Debug.str(string(CR))
    pass++
    
  

{{

                            TERMS OF USE: MIT License                                                           

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
}}