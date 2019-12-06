# CANbus objects

By: Chris Gadd

Language: Spin, Assembly

Created: Jun 13, 2014

Modified: March 28, 2015

  Supports standard, extended, and remote frames.
  Includes:
   A stand-alone writer, requiring one cog
   A stand-alone reader that reads up to 1Mbps but requires two cogs
   A stand-alone reader that reads up to 500Kbps but only requires one cog
   A combined reader/writer that operates at 500Kbps, requires one cog but works haltingly on high-traffic busses
   And a demonstration showing how everything works together

These objects only produce a logic-level output, in order to connect to a CANbus, a line driver such as the MCP2551 is required.
