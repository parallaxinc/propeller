Unzip the distribution to any convenient directory.

The .dll files and the .chm manual file must reside in the same directory as Event Logger Client.exe

Create a shortcut to Event Logger Client.exe and drag it to your desktop.

EventLogger.spin is the Spin/PASM object that gets loaded into a cog to provide the data (passed through by ViewPort) to be displayed by the Client.  Ideally, it should be placed in the Propeller "library" although it is acceptable to place in the same directory as your top level Spin program.

Note: the Propeller library directory is where PropTool is located.  That varies based on the version of PropTool that you are running.  PropTool is currently at version 1.2.6, so on my machine, the Propeller "library" is at

     C:\Program Files\Parallax Inc\Propeller Tool v1.2.6

EventLog Test.spin is a well commented test program that provides a working example and a template to be followed to incorporate EventLogger into your programs.