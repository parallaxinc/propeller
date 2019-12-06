# 4D Systems GOLDELOX uLCD display support code

By: Mark Owen

Language: Spin

Created: Feb 14, 2015

Modified: October 13, 2015

This collection of source code provides a minimal set of text and graphic rendering operations on a 4D Systems GOLDELOX  uLCD display (eg: uLCD-144-G2, uOLED-128-G2 etc.)

Updated 2015-Oct-11 to incorporate minor changes as follows:

*     Device offline detection        
*     More LED Bulb/Bar options    
*     Support for switched ground power to display 
*     Single button simple text menus  
     

Files included in the attached zip file:

**File Name**

**Description/Purpose**

GOLDEtest.spin

tests of GOLDE\_UI.spin and associated code

GOLDE\_UI.spin

minimal set of text and graphic operations sent via serial communications to a 4D Systems uLCD display with a GOLDELOX processor

uLCDserialIO.spin

FullDuplexSerial wrappers/glue routines for serial transmissions to uLCDserialGOLDE.4dg

FullDuplexSerial-wCTS.spin

a slightly modified version of FullDuplexSerial incorporating a CTS pin  for flow control and 128 byte buffers

uLCDserialGOLDE.4dg

4DGL Source code for compilation/download via 4D Systems Workshop to implement the text and graphic operations on a GOLDELOX display

AButton.spin

A single button polling function used by GOLDEtest

Also required for operation:

        a 4D Systems GOLDELOX based display  (Parallax and Mouser sell them)

Operations implemented:

*   PUB Start(rx,tx,cts,reset)
*   PUB Stop
*   PUB PowerUp(gndGatePin,rx,tx,cts,reset)
*   PUB PowerDown(gndGatePin)
*   PUB IsOffline
*   PUB ShowVersion(y,md,hm,c,r)
*   PUB GetGeometry
*   PUB Xmax
*   PUB Ymax
*   PUB GetCharGeometry         
*   PUB Wchar
*   PUB Hchar
*   PUB ScreenMode(m)
*   PUB Clip(b)
*   PUB ClipWindow(a,b,c,d)
*   PUB Home
*   PUB Clear
*   PUB ClearHome
*   PUB FillMode(m)
*   PUB Color(c)
*   PUB ColorBG(c)
*   PUB BorderColor(c)
*   PUB TextColor(c)
*   PUB TextColorBG(c)
*   PUB TextAttributes(flags)
*   PUB TextOpacity(b)
*   PUB LinePattern(p)
*   PUB MoveTo(x,y)
*   PUB LineTo(x,y)
*   PUB Pixel(x,y,c)
*   PUB Rectangle(x,y)
*   PUB RectangleAt(x0,y0,x1,y1)
*   PUB Circle(r)
*   PUB CircleAt(r,x,y)
*   PUB EightLEDS(x,y,bits)
*   PUB OneLED(x,y,rgb)
*   PUB EightLEDSrgb(x,y,bits,rgbOn,rgbOff)
*   PUB LEDbar(x,y,n,bits,rgbOn,rgbOff)
*   PUB MoveToCR(x,y)
*   PUB Newline
*   PUB Textsize(n)
*   PUB SetStrAtIx(asz,ix)
*   PUB StrIx(ix)
*   PUB StrIxAt(ix,x,y)
*   PUB Str(asz)
*   PUB StrAt(asz,x,y)
*   PUB PrintDec(n,d)
*   PUB PrintDecAt(n,d,x,y)
*   PUB PrintInt(n)
*   PUB PrintIntAt(n,x,y)
*   PUB Hexadecimal(v)
*   PUB Hex4(v)
*   PUB Hex2(v)
*   PUB Hex1(v)
*   PUB HexadecimalAt(v,x,y)
*   PUB Hex4At(v,x,y)
*   PUB Hex2At(v,x,y)
*   PUB Hex1At(v,x,y)
*   PUB SetMenuItem(i,sz)
*   PUB SetMenuItems(asz,nsz)
*   PUB SetNMenuItems(n)
*   PUB SetMenuColors(fg,bg)
*   PUB ShowMenuItem(i)
*   PUB ShowMenu
*   PUB HighlightItem(i)
*   PUB UnhighlightItem(i)
*   PUB SetCurrentItem(i)
*   PUB GetCurrentItem
*   PUB HighlightNextItem
*   PUB CycleMenu(BTNpin)
*   PUB dec(value)
*   PUB decf(value, width)
*   PUB decx(value, digits)
*   PRI clrstr(strAddr, size)
*   PRI decstr(value)
*   PUB hex(value, digits)
*   PUB bin(value, digits)
*   PRI hexstr(value, digits)
*   PRI binstr(value, digits)
*   PUB strcat(dst, src)
*   PUB strcpy(dst, src)
*   PUB strncpy(dst, src, num)  
     
