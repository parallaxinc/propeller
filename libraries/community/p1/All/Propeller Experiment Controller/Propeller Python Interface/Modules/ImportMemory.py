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

#   Imports system variables. This is used to check version of python for compatibility issues.
import sys

##############################################################################################################################################################################################



##############################
##       Classes            ##      
##############################

##############################################################################################################################################################################################

class event():
#   The class "event" is able to read a memory file, store the data, process the data, then save it to a data file.
#   The class "event" has all the variables defined in __init__, and can use all the functions defined below.

    def __init__(self):
        #   Characteristics of each event.
        
        self.name=""
        self.ID=""
        self.onset=[]
        self.offset=[]
        self.duration=[]
        self.IEI=[]                 
        self.totaloccurrences=0
        self.totalduration=0
        self.memoryfile=""
        self.datafile=""
        self.debounce=0
        self.bounce=""
        self.rawdata=0


    def readmemory(self):
    #   Method for reading memory.
    #   Imported from Experimental_Functions.

        read=0
        data=""
        slot=""
        file=open(self.memoryfile,"r")

        while 1:                                                            # This loop continues until the end of the file.
            read=file.read(1)
            if read == "":
                break
            if read == self.ID:
                read=file.read(1)                                           # This is always a 1 or 3 to indicate an onset or offset.
                if ord(read) == 49:                                         # The next item is an onset. 
                    if slot == "onset":                                     # If the last item written was an onset, then no offset for the previous instance of behavior was written.
                        self.offset.append("")                              # Add a blank offset.
                    slot="onset"
                if ord(read) == 51:                                         # The next item is an offset. - Offset slot contains data values for raw data
                    if slot == "offset":                                    # If the last item written was an onset, then no onset for the previous instance of behavior was written.
                        self.onset.append("")                               # Add a blank onset.
                    slot="offset"  
                read=file.read(1)                                           # This character is always a comma.
                while 1:                                                    # This loop continues until data is written.
                    read=file.read(1)
                    if ord(read) == 44 or read == "\n":                     # If the character is a comma or the end of the line then a complete time has been read.
                        if slot == "onset":
                            if self.rawdata==0:                             # If it isn't raw data.
                                self.onset.append(int(data)/1000.0)         # If it is an onset, add it to the onset list.
                            else:                                           # If it is raw data.
                                self.onset.append(int(data))                # Add the data, but do not divide by 1000.   
                        elif slot == "offset":
                            if self.rawdata==0:                             # If it isn't raw data.
                                self.offset.append(int(data)/1000.0)        # If it is an offset, add it to the offset list.
                            else:                                           # If it is raw data.
                                self.offset.append(int(data))               # Add the data, but do not divide by 1000.
                        data=""
                        break
                    elif -1 < int(read) < 10:                               # If a comma or line break is located, add the preceding information to data.
                        data=data+read
        file.close()


    def processdata(self):   
    #   This method generates durations, inter-event intervals, total occurrances and total duration.
    
        self.totaloccurrences=len(self.onset)                               # Total occurrences is the number of onsets.
        if len(self.onset)>len(self.offset):                                # If there is one more onset than offset.
            self.offset.append("")                                          # Add an extra offset.    
        if self.rawdata==0:                                                 # If this event is not a rawdata type.
            self.duration=[]
            self.totalduration=0
            I=0
            while I < len(self.onset):                                      # Itterate through each onset to create durations.
                if self.onset[I] == "":                                     # If there was no onset, add a blank duration.
                    self.duration.append("")
                elif self.offset[I] == "":                                  # If there was no offset, add a blank duration.
                    self.duration.append("")
                else:                                                       # If onset and offset were present, generate duration and add it to total duration.
                    self.duration.append(self.offset[I]-self.onset[I])   
                    self.totalduration=self.totalduration+self.duration[I]
                I=I+1

        #   Generates inter-event intervals
        self.IEI=[]
        if len(self.onset)>0:                                               # If there are instances of the event.
            self.IEI.append(0)                                              # First add a zero, the first instance cannot have an IEI.
            count=1
            while count<len(self.onset):                                    # Iterate through remaining instances.
                if self.onset[count] == "":                                 # If there was no onset, add a blank IEI.
                    self.IEI.append("") 
                elif self.offset[count-1] == "":                            # If there was no offset, add a blank IEI.
                    self.duration.append("")
                else:                                                       # If an IEI can be calculated, save the IEI.
                    self.IEI.append(self.onset[count]-self.offset[count-1])
                count=count+1


    def debouncedata(self):    
    #   This method "debounces" existing data.
    #   It is a post-experiment software debounce that emulates the properties of debouncing code that runs during an experiment.
    #   This is an optional method. Use it if some faulty hardware caused rapid onsets and offsets of behavior.
    #   Optimally, this method should never due to the debouncing methods in Experimental_Event.
    #   The method is available to recover and process data collected in a worst case senario.
    #   Data from raw input, like temperature should not be debounced.


        if self.rawdata==1:
            print("The event "+self.name+" is raw data. It will not be debounced.\n")

        if self.rawdata==0:
            
            #   First, remove empty onsets.
            I=0
            lastvalidoffset=""
            while I < len(self.onset):                                                   
                while self.onset[I] == "":                                      # While the current onset slot is empty
                    if lastvalidoffset == "":                                   # If no last valid offset has been recorded
                        lastvalidoffset=self.offset[I-1]                        # The last valid offset is the last offset in the list
                    if self.offset[I]-lastvalidoffset<self.bounce:              # If the current offset minus the last recorded offset is less than bounce
                        self.onset.pop(I)                                       # Remove the empty onset
                        lastvalidoffset=self.offset.pop(I-1)                    # Remove the offset, note that it is now the last valid offset
                    else:                                                       # If nothing can be done, increment I and reset lastvalidoffset
                        I=I+1                                                   
                        lastvalidoffset=""
                I=I+1
                lastvalidoffset=""
                
            #   Second, remove empty offsets.
            I=0
            lastvalidonset=""
            while I < len(self.onset):                                                   
                while self.offset[I] == "" and I+1 < len(self.onset):           # While the current offset slot is empty and there are more instances of behavior
                    if lastvalidonset == "":                                    # If no last valid onset has been recorded
                        lastvalidonset=self.onset[I]                            # The last valid onset is the current onset in the list
                    if self.onset[I+1]-lastvalidonset<self.bounce:              # If the next onset minus the last valid onset is less than bounce
                        self.offset.pop(I)                                      # Remove the empty offset
                        lastvalidonset=self.onset.pop(I+1)                      # Remove the next onset, note that it is now the last valid onset
                    else:                                                       # If nothing can be done, increment I and reset lastvalidonset
                        I=I+1                                                   
                        lastvalidonset=""
                I=I+1
                lastvalidonset=""

            #   Third, remove instances with very low durations.
            I=0
            while I < len(self.onset):
                if self.onset[I] == "" or self.offset[I] == "":                 # If there is no onset or no offset, skip the instance
                    I=I+1
                elif self.offset[I]-self.onset[I]<self.bounce:                  # If the duration of the event is less than bounce              
                    self.onset.pop(I)                                           # Remove the onset                                           
                    self.offset.pop(I)                                          # Remove the offset
                else:                                                           # If no other conditions were met, then increment I
                    I=I+1                                               

            #   Finally, remove instances with very low inter-event times.
            I=0
            while I+1 < len(self.onset):
                if self.onset[I] == "" or self.offset[I] == "":                 # If there is no onset or no offset, skip the instance
                    I=I+1
                elif self.onset[I+1]-self.offset[I]<self.bounce:                # If the time between the next event and the current event is less than bounce              
                    self.onset.pop(I+1)                                         # Remove the next onset
                    self.offset.pop(I)
                else:
                    I=I+1
                    
            
    def printdata(self): 
    #   This method, like its Experimental_Functions counterpart prints the processed data to a data file.

        file=open(self.datafile,"a")
        I=0
        while I < len(self.onset):                                          # While 'I' is less than the number of instances of behavior:
            file.write(self.name)                                           # Write the event name.
            file.write(",")
            file.write(str(I+1))                                            # Write the event instance.
            file.write(",")
            if self.onset[I] != "":                                         # If the current onset is not empty,
                file.write("%.3f" % self.onset[I])                          # Then write the data. "%.3f" % indicates to only write three decimal places.
            else:
                file.write(self.onset[I])                                   # Otherwise, just write the empty slot.
            file.write(",")
            if self.offset[I] != "":                                        # Same as above, but with the offset.
                file.write("%.3f" % self.offset[I])
            else:
                file.write(self.offset[I])
            file.write(",")
            if self.duration[I] != "":                                      # Same as above, but with the duration.
                file.write("%.3f" % self.duration[I])
            else:
                file.write(self.duration[I])
            file.write(",")  
            if self.IEI[I] != "":                                           # Same as above, but with the IEI.
                file.write("%.3f" % self.IEI[I])
            else:
                file.write(self.IEI[I])
            file.write(",")
            file.write("%.3f" % self.totalduration)                         # Write the total duration.
            file.write(",")
            file.write(str(self.totaloccurrences))                          # Write the total occurrences.
            file.write("\n")                                                # Start a new line.
            I=I+1                                                           # Increase 'I'.
        file.close()


    def printrawdata(self): 
    #   This method, like its Experimental_Functions counterpart prints the processed data to a data file.
    
        file=open(self.datafile,"a")
        I=0
        while I < len(self.onset):                                          # While 'I' is less than the number of instances of behavior:
            file.write(self.name)                                           # Write the event name.
            file.write(",")
            file.write(str(I+1))                                            # Write the event instance.
            file.write(",")  
            file.write(str(self.onset[I]))                                  # Write the time measurement.
            file.write(",")
            file.write(str(self.offset[I]))                                 # Write the data value.
            file.write(",")
            file.write(str(self.IEI[I]))                                    # Write the inter-event interval.
            file.write(",")
            file.write(str(self.totaloccurrences))                          # Write the total occurrences.
            file.write("\n")                                                # Start a new line.
            I=I+1                                                           # Increase 'I'.
        file.close()


##############################################################################################################################################################################################



##############################
##      Functions           ##      
##############################
        
##############################################################################################################################################################################################

def getinput(string,error,kind):
#   This method allows the user to input data from the terminal.
#   It uses a different version of the input code depending on the version of Python.
#   This is intended to make the code compatible with newer and older versions.
#   It also ensures the input is the correct type.

    x=False
    while x==False:
        if sys.hexversion > 0x03000000:
            response=input(string)
        else:
            response=raw_input(string)
        try:
            response=kind(response)
        except:
            print(error)
        x=isinstance(response,kind)
    return response


def newline():
#   This method prints a new line to the terminal.
#   It uses a different version of the input code depending on the version of Python.
#   This is intended to make the code compatible with newer and older versions.

    if sys.hexversion > 0x03000000:
        print()
    else:
        print("\n")


def empty(list):
#   This method allows a function to empty a list without confusing Python's variable scope.
#   If this method is not used, attempted to empty a list with list=[] causes Python to look for a non-existant local variable.
    while len(list)>0:
        list.pop(0)


def preparecustomdataoutput(datafile):
#   This method creates and prepares the data output file.
#   Note that it is not indented, and is not a function of the class "event."
#   Instead it is a general function.

    file=open(datafile,"w")
    file.write("Event,Instance,Onset,Offset,Duration,Inter-Event Interval,Total Duration,Total Occurrences,")
    file.write("\n")
    file.close()


def preparecustomdataoutputforrawdata(datafile):
#   Adds headings for raw data to the end of a previously prepared data file.

    try:
        file=open(datafile,"r")
        file.close()
        mode="a"
    except:
        mode="w"
    
    file=open(datafile,mode)                                                # Opens an existing file for writing. The next line writes the column headings.
    if mode=="a":
        file.write("\n")
    file.write("Event,Instance,Time,Data,Inter-Event Interval,Total Occurrences,")
    file.write("\n")
    file.close()


def prepareseparatecustomrawdataoutput(datafile):
#   Creates a separate file for raw data measurements.
#   Unused.

    file=open(datafile,"a")                                                 # Opens an existing file for writing. The next line writes the column headings.
    file.write("\n")
    file.write("Event,Instance,Time,Data,Total Occurrences,")
    file.write("\n")
    file.close()


def sorteventlist():
#   Sorts the eventlist so that any rawdata events are at the end of the list
    sortlist=[]
    for unit in eventlist:                                                  # Add stuff to the sortlist.
        sortlist.append(unit)
    while len(eventlist)>0:                                                 # Remove it from the eventlist.
        eventlist.pop(0)
    for unit in sortlist:                                                   # Add non-rawdata back to eventlist first.
        if unit.rawdata==0:
            eventlist.append(unit)
    for unit in sortlist:                                                   # Now add the raw data to the end of the list.
        if unit.rawdata==1:
            eventlist.append(unit)


def manualinput():
#   This function gets all the needed information directly from the user at the terminal.

    print("Memory recovery: User input mode.\n")
    print("What is the name of the memory file?")
    print("Make sure the file is in the same folder as the python script.")
    memoryfound=0
    while memoryfound==0:
        mastermemoryfile=getinput("Memory file: ","",str)
        try:
            file=open(mastermemoryfile,"r")
            memoryfound=1
            file.close()
        except:
            print("Memory file not found.")
    newline()
    
    print("How many events do you want to save?")
    numberofevents=getinput("Number of events: ","Please enter a number.",int)
    newline()

    if numberofevents>1:
        print("Do you want to save all the events in one common data file?")
        usemasterdata=getinput("Please type 'yes' or 'no': ","",str).lower()
        newline()
        if usemasterdata=="yes":
            print("What datafile do you want to use to save all the events?")
            print("The datafile will be created in the same folder as the python script.")
            print("Save the file as ___.csv to easily read the data in Excel.")
            masterdatafile=getinput("Data file: ","",str)
            newline()
    else:
        print("What datafile do you want to use to save the event?")
        print("The datafile will be created in the same folder as the python script.")
        print("Save the file as ___.csv to easily read the data in Excel.")
        masterdatafile=getinput("Data file: ","",str)
        usemasterdata="yes"
        newline()
             
    while numberofevents > 0:
        eventlist.append(event())
        numberofevents=numberofevents-1

    print("Please provide information for each event.")
    for unit in eventlist:
        unit.memoryfile=mastermemoryfile

        numberofevents=numberofevents+1
        print("Event "+(str(numberofevents)))
        newline()

        unit.name=getinput("Event name: ","",str)
        newline()

        if usemasterdata=="no":
            print("What datafile do you want to use to save the event?")
            print("Save the file as ___.csv to easily read the data in Excel.")
            unit.datafile=getinput("Data file: ","",str)
            newline()
        else:
            unit.datafile=masterdatafile

        print("In what order was the event originally saved in the experimental program?")
        print("Please provide a number such as 1 or 2.")
        order=getinput("Event order: ","Please enter a number.",int)
        unit.ID=chr(IDcode[order-1])
        newline()

        print("Was this event raw data?")
        if getinput("Please type 'yes' or 'no': ","",str).lower()=="yes":
            unit.rawdata=1
        else:
            unit.rawdata=0

        unit.readmemory()
        unit.processdata()

        if unit.rawdata==0:
            print("\nDo you want to debounce the data before saving?")
            usedebounce=getinput("Please type 'yes' or 'no': ","",str).lower()
            newline()
            if usedebounce == "yes":
                unit.debounce=1
                print("What time interval, in milliseconds, do you want to used to debounce the data?")
                print("The default value is 25 milliseconds")
                unit.bounce=getinput("Debounce interval: ","Please enter a number.",float)
                unit.bounce=unit.bounce/1000.0
                newline()
                unit.debouncedata()
                unit.processdata()
                print("Data reduced to "+str(unit.totaloccurrences)+" occurrences of "+unit.name+" with a total duration of "+str(unit.totalduration)+".")
            newline()

    print("All information collected.")
    newline()
    savedata()
    empty(eventlist)


def fileinput():
    #   Allows the use of an input settings file to quickly process multiple files.
    
    print("Memory recovery: File input mode.\n")
    print("What is the name of the input settings file?")
    print("Make sure the file is in the same folder as the python script.")
    
    settingsfound=0
    while settingsfound==0:
        settingsfile=getinput("Settings file: ","",str)
        try:
            readsettings(settingsfile)
            settingsfound=1
        except:
            print("Settings file not found.")
    
    memoryfile=0
    datafile=0
    morefiles="yes"
    
    while morefiles=="yes":
        print("What is the name of the memory file?")
        memoryfound=0
        while memoryfound==0:
            memoryfile=getinput("Memory file: ","",str)
            try:
                file=open(memoryfile,"r")
                memoryfound=1
                file.close()
            except:
                print("Memory file not found.")
        newline()
        print("What datafile do you want to use to save the event?")
        print("Save the file as ___.csv to easily read the data in Excel.")
        datafile=getinput("Data file: ","",str)
        newline()
        
        for unit in eventlist:
            unit.memoryfile=memoryfile
            unit.datafile=datafile
            unit.readmemory()
            unit.processdata()
            if unit.debounce==1:
                unit.debouncedata()
                unit.processdata()
        savedata()
        
        print("Do you want to recover more memory files with these settings?")
        morefiles=getinput("Please type 'yes' or 'no': ","",str)
        morefiles=morefiles.lower()
        newline()
        empty(eventlist)
        
    print("Complete.\n")


def directfileinput(settingsfile,memoryfile,datafile):
    #   Allows the use of an input settings file to quickly process multiple files.
    #   Information is entered as a parameter instead of intered in the python shell.
     
    readsettings(settingsfile)

    for unit in eventlist:
        unit.memoryfile=memoryfile
        unit.datafile=datafile
        unit.readmemory()
        unit.processdata()
        if unit.debounce==1:
            unit.debouncedata()
            unit.processdata()
    savedata()
    empty(eventlist)

    print("Complete.\n")

def readsettings(settingsfile):
    file=open(settingsfile,"r")
    file.readline()
    file.readline()
    file.readline()
    file.readline()
    file.readline()
    
    read=file.readline()                                                    # Number of events
    read=int(read[0:-1])
    while read > 0:
        eventlist.append(event())
        read=read-1
    file.readline()
    for unit in eventlist:                                                  # Event Names
        read=file.readline()
        unit.name=read[0:-1]
    file.readline()
    for unit in eventlist:                                                  # Event IDs
        read=file.readline()
        read=int(read[0:-1])
        unit.ID=chr(IDcode[read-1])
    file.readline()
    for unit in eventlist:                                                  # Raw data
        read=file.readline()
        read=(read[0:-1]).lower()
        if read=='yes':
            unit.rawdata=1
    file.readline()
    for unit in eventlist:                                                  # Debounce
        read=file.readline()
        read=(read[0:-1]).lower()
        if read=='yes':
            unit.debounce=1
    file.readline()                                                         # Debounce interval
    for unit in eventlist:
        if unit.debounce==1:
            read=file.readline()
            unit.bounce=float(read[0:-1])
            unit.bounce=unit.bounce/1000.0
    file.close()
    print("Settings imported.\n")


def savedata():
#   This function saves each event to the datafile.
    sorteventlist()
    rawdataprepared=0
    
    for unit in eventlist:
        if unit == eventlist[0]:
            if unit.rawdata==1:
                preparecustomdataoutputforrawdata(unit.datafile)
            else:
                preparecustomdataoutput(unit.datafile)  
        else:
            try:
                file=open(unit.datafile,"r")
                file.close()
            except:
                preparecustomdataoutput(unit.datafile)
        if unit.rawdata==1:
            if rawdataprepared==0:
                preparecustomdataoutputforrawdata(unit.datafile)
                rawdataprepared=1
            unit.printrawdata()
        else:
            unit.printdata()
        print(unit.name+" data saved.")
        newline()
    print("All data saved.")


###########################################################################################################################



##############################
##        Variables         ##      
##############################

###########################################################################################################################


#   This list will hold as many events as needed.
#   It is used to hold all the events together in a group so that they can be processed quickly in sequence.
#   It is also used to create events without explicitly giving them a name.

eventlist=[]


#   These IDcodes are assigned to each event on creation, and used to quickly write information to the memory file.
#   Later they are used to quickly sort through the memory file to read and process each event.

IDcode=[33, 34, 35, 36, 37, 38, 39, 42, 43, 45, 47, 58, 59, 60, 61, 62, 63, 64, 65, 66,
        67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86,
        87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99,100,101,102,103,104,105,106,
        107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,
        128,129,120,131,132,133,134,135,136,137,138,140,141,142,143,144,145,146,147,148,
        149,150,151,152,153,154,155,156,157,158,159,160,161,162,163,164,165,166,167,168,
        169,170,171,172,173,174,175,176,177,178,179,180,181,182,183,184,185,186,187,188,
        189,190,191,192,193,194,195,196,197,198,199,200,201,203,204,205,206,207,208,209,
        210,211,212,213,214,215,216,217,218,219,220,221,222,223,224,225,228,229,230,231,
        232,233,234,235,236,237,238,239,240,241,242,243,244,245,246,247,248,249,250,251,
        252,253,254]



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
