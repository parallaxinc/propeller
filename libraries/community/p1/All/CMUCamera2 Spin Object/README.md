# CMUCamera2 Spin Object

By: Joe Lucia

Language: Spin

Created: May 4, 2014

Modified: May 4, 2014

Functions to get and set just about all of the CMUCam2 features.  Object manages Color Tracking, Frame Differencing, and Statistics (don't have histograms decoding yet), as well as the ability to capture a Frame Dump to a propeller buffer for processing and/or forwarding to external app.  Get started tracking colors and objects with just a few lines.  Uses two cogs, one for FullDuplexSerial to talk to the camera at 38400 and a one to manage the camera data.
