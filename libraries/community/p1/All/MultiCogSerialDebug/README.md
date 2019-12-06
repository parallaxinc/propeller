# MultiCogSerialDebug

By: Peter Verkaik

Language: Spin, Assembly

Created: Dec 17, 2007

Modified: May 2, 2013

Derived from SerialMirror V07.05.10  
 

All printing (also from multiple COGs) is done using cprintf. Each cprintf call is a message. The more parameter in cprintf lets you prohibit that the message is interleaved with text from another COG.  To keep output clear, end each (compound) message with a \\r or \\r\\n.  Receiving should be done by a single COG that can dispatch received messages.

  
See the test program for detailed usage.
