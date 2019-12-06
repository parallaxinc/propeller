{{
''***********************************************
''*  Program simple_multicore_demo3c.spin
''*  Author: Jon Titus 09-23-2015 Rev. 
''*  Copyright 2015
''*  Released under Apache 2 license
''*  Program demonstrates use of locks by two
''*  cogs that each run through a loop to display
''*  counter values. Runs of Propeller QuickStart
''*  board, P8X32A.
''*  Based on program simple_multicore_demo2.spin.
''*  See Parallax Application Note AN011.
''*  Ensure Propeller Terminal set for 115,200 bits/sec.
''***********************************************
}}

CON
    _clkmode = xtal1 + pll16x       'Set up the clock mode
    _xinfreq = 5_000_000            '8- MHz system-clock frequency

VAR     'Global variables declared here  
    long cogStack[100]              'Stack space for 2 cogs
    long routine1_cog, routine2_cog 'Storage for two cog numbers, cog IDs
    long LockID                     'Storage for ID of lock checked out
  
OBJ     'Objects identified and names here
  pst   :   "Parallax Serial Terminal"

PUB Main 'Public method that runs in Cog 0

  pst.Start(115_200)            'Starts the Parallax Serial Terminal object at 115,200 bits/sec.
  waitcnt(cnt + (clkfreq * 12)) 'Wait for 12 seconds before starting other routines. Leaves
  pst.Clear                     'time to switch to Parallax Terminal (press F12). Adjust delay
                                'as you see fit. Not a critical time.

  if(LockID := locknew) == -1               'Check out a lock, if available
     pst.Str(string("No lock available."))  'If no lock available, print this message
  else
     pst.Str(string("Lock checked out: "))  'If we checked out a lock, save ID number in LockID
     pst.Dec(LockID)                        'Display lock-ID number
     pst.NewLine                            'Display a new line
     lockset(LockID)                        'Close the lock--no cog can use the resource
     
       'Test for available cogs. If available, start Multicore_Routine2 in a new cog
  repeat until (routine2_cog := cognew(Multicore_Routine_2, @cogStack[0])) > -1

       'Test for available cogs. If available, start Multicore_Routine1 in a new cog
  repeat until (routine1_cog := cognew(Multicore_Routine_1, @cogStack[50])) > -1

  lockclr(LockID)                           'OK, open the the lock on the resource so cogs
                                            'can access the resource
                                            
        'Test for running cogs and display messages
  if (routine1_cog > -1)                                      
    pst.Str(string("Multicore_Routine_1 started."))
    pst.NewLine
  else
    pst.Str(string("Multicore_Routine_1 cog FAILED!"))
    pst.NewLine

  if (routine2_cog > -1)
    pst.Str(string("Multicore_Routine_2 started."))
    pst.NewLine
  else
    pst.Str(string("Multicore_Routine_2 cog FAILED start!"))
    pst.NewLine

  pst.Str(string("========================="))
  pst.NewLine
  pst.NewLine
  
        'wait in this repeat loop until both cogs complete their tasks.
  repeat until routine1_cog == -1 AND routine2_cog == -1

        'Both cogs have stopped, so report their state
  pst.Str(string("==========================================="))
  pst.NewLine
  pst.Str(string("Multicore_Routine_1 and Multicore_Routine_2 have shut down."))
  pst.NewLine
  lockret(LockID)
  pst.Str(string("Returned Lock "))
  pst.Dec(LockID)
  pst.NewLine
  pst.Str(string("Shutting down cog "))
  pst.Dec(cogid)                            'Print ID of cog still running this code.
  pst.NewLine
  pst.Str(string("End"))
  
  'No more code, so Cog 0 stops
  '====================================================================================
PUB Multicore_Routine_1 | counter1          'Start next available cog, declare local counter1 variable
  waitcnt(cnt + clkfreq)                    'Short delay here
  counter1 := 200                           'Preset counter1 = 200 to start

  repeat until lockset(LockID) == False     'Wait in this loop for lock to open
  
  repeat 10                                 'Start loop, runs 10 times
    'flag := true
    pst.Str(string("Multicore_Routine_1, running in cog "))
    pst.Dec(cogid)                          'Display the cog ID number
    pst.Str(string(".  Counter = "))        'Display this string
    pst.Dec(counter1)                       'Display counter1 value
    pst.NewLine                             'Display a new line
    counter1++                              'Increment counter1 by 1
    
    'End of loop, so display these messages
  pst.Str(string("Multicore_Routine_1 finished executing, cog "))
  pst.Dec(cogid)                            'Display cog number
  pst.Str(string(" shutting down."))
  pst.NewLine
  pst.NewLine
  
  lockclr(LockID)                           'Open the lock

  routine1_cog := -1                        'Indicate this cog completed its task
                                            'and change the global variable to -1
  'This cog shuts down
'====================================================================================
PUB Multicore_Routine_2 | counter2          'Start next available cog, declare local counter2 variable
  waitcnt(cnt + clkfreq)                    'Short delay here
  counter2 := 0                             'Preset counter2 = 0 to start

  repeat until lockset(LockID) == False     'Wait for lock to open
  
  repeat 10                                 'Start loop, loops 10 times
    pst.Str(string("Multicore_Routine_2, running in cog "))
    pst.Dec(cogid)                          'Display the cog ID number
    pst.Str(string(".  Counter = "))        'Display this string
    pst.Dec(counter2)                       'Display counter2 value
    pst.NewLine                             'Display a new line
    counter2++                              'Increment counter2 by 1

    'End of loop, so display these messages
  pst.Str(string("Multicore_Routine_2 finished executing, cog "))
  pst.Dec(cogid)                            'Display cog number
  pst.Str(string(" shutting down."))
  pst.NewLine
  pst.NewLine

  lockclr(LockID)                            'Open the lock
  routine2_cog := -1                         'Indicate this cog completed its task
                                             'and change the global variable to -1
    
  'This cog shuts down
  
  '====================================================================================
  '-----  End of Program: simple_multicore_demo3c.spin -----