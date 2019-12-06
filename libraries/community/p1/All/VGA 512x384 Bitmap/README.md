# VGA 512x384 Bitmap

![logo_icon.gif](logo_icon.gif)

By: Chip Gracey (Parallax)

Language: Spin, Assembly

Created: Apr 17, 2013

Modified: April 17, 2013

This object generates a 512x384 pixel bitmap, signaled as 1024x768 VGA. Each pixel is one bit, so the entire bitmap requires 512 x 384 / 32 longs, or 6,144 longs (24KB). Color words comprised of two byte fields provide unique colors for every 32x32 pixel group. These color words require 512/32 \* 384/32 words, or 192 words. Pixel memory and color memory are arranged left-to-right then top-to-bottom.
