# Strings Library v2

![stringthumb_1.jpg](stringthumb_1.jpg)

By: Brandon Nimon

Language: Spin

Created: Nov 18, 2009

Modified: May 2, 2013

Strings Library v2:  
Contains 17 string-affecting methods. Methods include Capitalize, CharPos, CharRPos, Concatenate, Pad, Parse, StrCount, StrPos, StrRepeat, StrReplace, StrRev, StrStr, StrToLower, StrToUpper, SubStr, Trim, and WordWrap. Some are similar in functionality to PHP's string functions by the same name.

Version 2 and 1 are being kept separate because different precautions are needed for each. It is not to be used as a drop-in replacement. Be sure to read the documentation to understand the method differences.

A list of methods that may return a string that is longer than the original passed string, thus requiring special setup: StrReplace, Concatenate, Pad, StrRepeat, and WordWrap.

All methods in Version 2 are faster than version 1.X except StrPos which is the same, and StrRev which is 33% slower.
