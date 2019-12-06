# Add-on to ViewPort - expanded "watch"

By: Bob Anderson

Language: Spin, Assembly

Created: Dec 21, 2009

Modified: May 2, 2013

Use with ViewPort 4.2.5 (or higher)...

This program is an extension to the basic "watch shared variable" capabilities of ViewPort. It executes script statements that can deal with arrays and Spin floats and show variables in the following formats:

**int uint float binary hex bit**

There is a full expression evaluator that accepts the following operators:

**\* / div mod & | ^ >> << ~**

\======================================================================================

Script statements available for "watching" shared variables. These are normally placed in the "Main script" text panel.

*   showInt ( "<label>" , <expr> ) ; Show expr as signed 32 bit integer
*   showUint ( "<label>" , <expr> ) ; Show expr as unsigned 32 bit integer
*   showHex ( "<label>" , <expr> ) ; Show expr as $00fd\_0acb
*   showBinary( "<label>" , <expr> ) ; Show expr as %1010\_1000\_0000\_0000\_1100\_0011\_0000\_0001
*   showFloat ( "<label>" , <expr> ) ; Show expr as 3.81
*   showBit ( "<label>" , <expr> , <bit> ) ; Show value of bit <bit> in <expr>
*   showStr ( "<label>" ) ; Show <label>
*   :<name> = <expr> ; Set a local variable (this is "quiet" - no output)
