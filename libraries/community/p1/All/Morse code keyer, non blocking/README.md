# Morse code keyer, non blocking

By: Thierry Eggen, ON5TE

Language: Spin

Created: Jun 22, 2014

Modified: June 22, 2014

This CW keyer is currently in use in a Ham Radio UHF repeater.

 Being a non-blocking process, it requires one COG.

        When a message is received from the calling program, it is inserted into the TxBuffer and the control is sent back to the caller, provided there is enough space free

        in the buffer. The KeyerLoop then extracts the characters from the buffer one by one and sends them to tha keyer process, at the same time

        it frees the space in the buffer. Buffer management is done via a quasi circular buffer and two pointers NextToSend and NextToFill.

        The pin BusyPin may be used to indicaqte to any other COG that the keyer is busy transmitting or idle (its buffer is empty), for flow control

        purpose or anything ele you want.

        We have here a non blocking process, in our case, the repeater software doesn't need to wait until message has been sent to do something else.

        HOWEVER, if the buffer is full, then we operate as back pressure flow control and the calling program has to wait until his last message is completely in the buffer.

        In our case, a buffer of 20 is large enough.
