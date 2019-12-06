##############################################################################################################################################################################################
#
#   ┌────────────────────────┐
#   │ Experiment Memory Recovery v1.2          │
#   │ Author: Christopher A Varnon             │ 
#   │ Created: July 2012, Updated: 11-23-2012  │
#   │ All scripts created with Python 3.1.1    │
#   │ See end of file for terms of use.        │
#   └────────────────────────┘
#
#   This python script allows the user to read a memory file, process and manipulate the data, then save it to a data file.
#   The script allows the user to input each event by typing into the terminal, or by reading from a separate information file.
#
#   It uses the computer's memory and processing power, so it is able to handle over 1000 instances of behavior and process them very quickly.
#   Much of the code was taken directly from the spin methods in Experimental_Functions.
#   The code here will not be as heavily commented due to the similarity to methods in Experimental_Functions.
#
#   A future version will include storage for multiple groups, individuals, conditions, sessions, and events so that data can be analysed and exported in other forms.
#   Future format: group[n].individual[n].condition[n].session[n].event[n].name,onset[n],offset[n],duration[n],IEI[n],totaloccurrences,totalduration
#   I have found this format to be sucuessful with a data aquisition program I created to work with another experiment controller.

##############################################################################################################################################################################################
#
#   Imports system variables. This is used to check version of python for compatibility issues.
#   Also imports scripts from other modules.
#
from Modules.Instructions import *
from Modules.ImportMemory import *

print("Memory recovery program.\n")
print('Type "instructions()" for instructions or enter a command.\n')

##############################
##   Enter Commands Below   ##      
##############################
#
##############################################################################################################################################################################################























































##############################################################################################################################################################################################
#
#   ┌────────────────────────────────────────────────────────────────────────┐
#   │                                                   TERMS OF USE: MIT License                                                  │
#   ├────────────────────────────────────────────────────────────────────────┤
#   │Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation    │
#   │files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,    │
#   │modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software│
#   │is furnished to do so, subject to the following conditions:                                                                   │
#   │                                                                                                                              │
#   │The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.│
#   │                                                                                                                              │
#   │THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE          │
#   │WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR         │
#   │COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,   │
#   │ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                         │
#   └────────────────────────────────────────────────────────────────────────┘
#
##############################################################################################################################################################################################
