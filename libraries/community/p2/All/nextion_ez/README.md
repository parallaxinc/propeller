  

# nextion_ez 

## Description

A simple object for interfacing with Nextion HMI displays that is compatible with the protocol and HMI code used by the Arduino Easy Nextion Library. 

The Arduino library was developled by Thanasis Seitanis.  It uses a custom protocol that is simple to use and can be easily modified to meet one’s needs.
It was designed to provide a simple method to use Nextion displays for beginners and at the same time satisfying the needs of the more advanced programmers.

Full documentation on the Arduino Easy Nextion Library and protocol, as well as examples, can be found at https://seithan.com/Easy-Nextion-Library/

If you find this library useful, please consider supporting the author of the original Easy Nextion Library, Thanasis Seitanis at: [seithagta@gmail.com](https://paypal.me/seithan)

Differences between the Arduino library and this library

1. The original Easy Nextion library automatically calls trigger functions, stored in a separate file,
    in response to Nextion commands.
        This object provides the methods `cmdAvail()`, `getCmd()`, and `readByte()`
        to retreave the command packets sent from the Nextion.

2. The original library uses a single overloaded function `writeStr()` to send commands and
    update string values on the Nextion.
        This object uses separate methods `sendCmd()` and `writeStr()`.

3. An argument fifo has been added to allow a new method `pushCmdArg()` that can be used to
    provide a variable number of arguments to `sendCmd()`.

4. The the original library's `NextionListen()` function has been named `listen()`
    in this implementation.

5. This object adds a method called `addWave()` to create a quick and easy interface to the
    Nextion waveform add command.

6. In this object the currentPageId and lastCurrentPageId variables can be accessed with the
    functions `getCurrentPage()`, `getLastPage()`, `setCurrentPage()` and `setLastPage()`

**NOTE**: `.HMI` files for Nextion Editor are also included in the demo folder.

## The public methods
- `start()`
- `writeNum()`
- `writeStr()`
- `writeByte()`
- `pushCmdArg()`
- `sendCmd()`
- `addWave()`
- `readNum()`
- `readStr()` 
- `readByte()`
- `cmdAvail()`
- `getCmd()`
- `getCmdLen()`
- `getCurrentPage()`
- `getLastPage()`
- `setCurrentPage()`
- `setLastPage()`

In order for the object to update the Id of the current page, you must write the Preinitialize Event of every page: `printh 23 02 50 XX` , where `XX` the id of the page in HEX.
Your code can then read the current page and previous page using the `getCurrentPage()` and `getLastPage()` methods.

Standard Easy Nextion Library commands are sent from the Nextion display with `printh 23 02 54 XX` , where `XX` is the id for the command in HEX.  
Your code should call the `listen()` method frequently to check for new commands from the display.  You can then use the `getAvail`, `getCmd()` and `getSubCmd` methods to parse any commands.

example:
```spin2
PUB main()
    nextion.listen()                        ' need to run this to check for incoming data from the Nextion
    if nextion.cmdAvail() > 0               ' has the nextion sent a command?
      callCommand(nextion.getCmd())         ' get the command byte and see parse it         

PRI callCommand(_cmd)                       ' parse the 1st command byte and decide how to proceed
  case _cmd
    "T" :                                   ' standard Easy Nextion Library commands start with "T"
      callTrigger(readByte())               ' so we need the second byte to know what function to call

PRI callTrigger(_triggerId)                 ' use the 2nd command byte from nextion and call associated method
  case _triggerId
    $00 :
      trigger00()                           ' the orginal Arduino library uses numbered trigger functions
    $01 :
      trigger01()
    $02 :
      runCount()                            ' but since we are parsing ourselves, we can call any method we want
    $03 :
      trigger03()
    $04 :
      trigger04()
```

##  Usefull Tips

**Manage Variables**
You can read/write the variables as any other component.

Use `readNum()` to read the value of a numeric variable.  
Example: `nextion.readNum(STRING("va0.val"))`  
Example: `nextion.readNum(STRING("sys0"))`

Use `writeNum()` to change the value of a numeric variable.  
Example: `nextion.writeNum(STRING("va0.val"), 255)`  
Example: `nextion.readNumber(STRING("sys0"), 375)`

Use `readStr()` to read the text of a String variable.  
Example: `nextion.readStr(STRING("va0.txt"))`

Use `writeStr()` to change the text of a String variable.  
Example: `nextion.writeStr(STRING("va0.txt"), STRING("Hello World"))`

For this to happen, the variables you want to read/write must be at the page you are currently on.  
Otherwise, if the variables are of **global** scope, you will need to use a prefix with the page name that the variables are at.  
Example: `nextion.readNumber(STRING("page0.va0.val"))`   'If the variable is at page0  
The same goes for the other methods as well.

**NOTE**: (from the Nextion Editor Guide)
> In an HMI project a page is a localized unit. When changing pages, the existing page is removed from memory and the > > requested page is then loaded into memory. As such components with a variable scope of _**local**_ are only accessible while the page they are in is currently loaded. Components within a page that have a variable scope of _**global**_ are accessible by prefixing the page name to the global component .objname.
As an Example:
 A global Number component n0 on page1 is accessed by **page1.n0** . 
A local Number component n0 on page1 can be accessed by page1.n0 or n0, but there is little sense to try access a local component if the page is not loaded. Only the component attributes of a global component are kept in memory. Event code is never global in nature.

## Compatibility
* Propeller     (https://github.com/parallaxinc/propeller spin version in P1 folder)
* Propeller2    (https://github.com/parallaxinc/propeller spin2 version in P2 folder)
* Arduino       (https://github.com/currentc57/nextion_ez)


## Licence 

  Terms of Use: MIT License

  Permission is hereby granted, free of charge, to any person obtaining a copy of this
  software and associated documentation files (the "Software"), to deal in the Software
  without restriction, including without limitation the rights to use, copy, modify,
  merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
  permit persons to whom the Software is furnished to do so, subject to the following
  conditions:

  The above copyright notice and this permission notice shall be included in all copies
  or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
  PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
  CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
  OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

