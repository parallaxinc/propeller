# Inline PAsm in Spin Demo

By: Parallax Inc

Language: Spin

Created: Jan 22, 2015

Modified: January 22, 2015

InLine Assembly? - debatable perhaps, however this allows you to call snippets of PAsm and run them as if they are a defined PUB or PRI subroutine without having to reload a new COG every time.

This program starts a single COG engine which is similar to 'other' dispatch type of PAsm programs such as 'graphics.spin'. What makes this different is that the PAsm that would normally be dispatched within the PAsm dispatcher program now resides in Spin and because of that can be more dynamic (customized) from within the Spin environment even making some LMM programming possible.
