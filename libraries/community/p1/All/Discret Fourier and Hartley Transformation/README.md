# Discret Fourier and Hartley Transformation

By: G. Pillmann

Language: Spin, Assembly

Created: Sep 20, 2013

Modified: September 20, 2013

Abstract for the Spin object "Hartley.Spin" in category Signal Keywords: Discret Fourier Transformation DFT, Discrete Hartley Transformation DHT, Fast Fourier Transformation FFT The object realizes a Discret Fourier Transformation (DFT) based on the Hartley transformation with the following properties: Transformation with 8, 16, 32 .. 2048 .. points Assignable to 1, 2 or 4 Cogs Input data up to 15 bits plus sign or 16-bit unsigned Output data 31 bits plus sign Fourier spectrum for 1024 points with 80 MHz processor clock and 4 cogs in 7.5 ms Mathematical foundations for the Propeller object are: Fast Discrete Hartley Transform (DHT) for calculating the discrete Fourier transform (DFT) by means of recursion and parallelization CORDIC technique for sine, cosine, multiplication, magnitude, phase In the demo programs the Triggerpin is on port 27 and the PAL TV pins are on ports 23..20. These assignments can be changed in the Demo and Display objects themselves. It is important to read the documentation file "Hartley\_Documentation.pdf" before! Otherwise it could be difficult to understand the theory, the code, and the in- and output of the Hartley.Spin object! The documentation is in German and partially translated to English if necessary. 9/20/2013
