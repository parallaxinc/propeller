##############################################################################################################################################################################################
#
#   ┌────────────────────────┐
#   │ Experiment Memory Recovery v1.2          │
#   │ Author: Christopher A Varnon             │ 
#   │ Created: July 2012, Updated: 11-23-2012  │
#   │ File created with Python 3.1.1           │
#   │ See end of file for terms of use.        │
#   └────────────────────────┘
#
##############################################################################################################################################################################################

def instructions():

    print("This program can recover data from a memory file in three ways.\n")
    
    print("1) The user can specify the values of a file through prompts")
    print("   in the terminal.")
    print('   Type "manualinput()" to enter information manually.\n')
    
    print("2) The user can also provide an input settings file to process")
    print("   several memory files quickly.")
    print('   Type "fileinput()" to use an input settings file.')
    print('   See the "InputSettingsFileTemplate.txt" file for')
    print("   an example and instructions on using an input settings file.")
    print("   The user will be prompted to provide information about the")
    print("   settings, memory and data files.\n")

    print("3) The user can also use an input settings while specifying")
    print("   the files directly without the use of prompts.")
    print('   Type "directfileinput(settingsfile,memoryfile,datafile)"')
    print("   to use an input settings file while simultaneously providing")
    print("   information about the files.")
    print('   In place of the parameters "settingsfile, memoryfile,"')
    print("   and datafile, enter the file names in quotes.")
    print('   Example: directfileinput("settings.txt","memory.txt","data.csv")\n')
    
    print("\n")



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


