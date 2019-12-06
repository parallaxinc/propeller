# Real Time Clock

By: Mathew Brown

Language: Spin

Created: Jul 6, 2008

Modified: May 20, 2013

Starts R.T.C. in a new cog. 

Tracks both time, and date, with days in month/leap year day correction.

(Rev 1.01 ... Added weekday data. Automatically generated, based on the date)

Time/date can be set using the following...

1.  Via direct writes to timekeeping registers
2.  Via time & date setting methods
3.  Via loading with a 32 bit packed Microsoft format time

Time/date can be read using the following...

1.  Via direct reads from timekeeping registers
2.  Via return as strings representing time, date, or day of the week.
3.  Via return of a 32 bit packed Microsoft format time.
