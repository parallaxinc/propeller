CC = iccprop
LIB = ilibw
CFLAGS =  -e -D__ICC_VERSION="7.05" -DFDS_DISABLE_OUTS -DP8X32A  -l -g 
ASFLAGS = $(CFLAGS) 
LFLAGS =  -g -ucrtprop.o -lmm:kernel.o -fhexbin -cf:PING.cmd
FILES = PingTest.o FdSerial.o ping.o ping_asm.o 

PING:	$(FILES)
	$(CC) -o PING $(LFLAGS) @PING.lk   -lcprop
PingTest.o: C:\iccv705prop\include\stdio.h C:\iccv705prop\include\stdarg.h C:\iccv705prop\include\_const.h C:\iccv705prop\include\propeller.h C:\iccv705prop\include\propclock.h .\..\..\..\..\..\..\DOCUME~1\Steve\MYDOCU~1\_Propeller_OBEX_\Ping\FdSerial.h .\..\..\..\..\..\..\DOCUME~1\Steve\MYDOCU~1\_Propeller_OBEX_\Ping\ping.h
PingTest.o:	..\..\..\..\..\..\DOCUME~1\Steve\MYDOCU~1\_Propeller_OBEX_\Ping\PingTest.c
	$(CC) -c $(CFLAGS) ..\..\..\..\..\..\DOCUME~1\Steve\MYDOCU~1\_Propeller_OBEX_\Ping\PingTest.c
FdSerial.o: C:\iccv705prop\include\stdio.h C:\iccv705prop\include\stdarg.h C:\iccv705prop\include\_const.h C:\iccv705prop\include\stdlib.h C:\iccv705prop\include\limits.h C:\iccv705prop\include\string.h C:\iccv705prop\include\propeller.h C:\iccv705prop\include\propclock.h .\..\..\..\..\..\..\DOCUME~1\Steve\MYDOCU~1\_Propeller_OBEX_\Ping\FdSerial.h .\..\..\..\..\..\..\DOCUME~1\Steve\MYDOCU~1\_Propeller_OBEX_\Ping\FdSerial_Array.h
FdSerial.o:	..\..\..\..\..\..\DOCUME~1\Steve\MYDOCU~1\_Propeller_OBEX_\Ping\FdSerial.c
	$(CC) -c $(CFLAGS) ..\..\..\..\..\..\DOCUME~1\Steve\MYDOCU~1\_Propeller_OBEX_\Ping\FdSerial.c
ping.o: C:\iccv705prop\include\propeller.h C:\iccv705prop\include\propclock.h .\..\..\..\..\..\..\DOCUME~1\Steve\MYDOCU~1\_Propeller_OBEX_\Ping\ping.h
ping.o:	..\..\..\..\..\..\DOCUME~1\Steve\MYDOCU~1\_Propeller_OBEX_\Ping\ping.c
	$(CC) -c $(CFLAGS) ..\..\..\..\..\..\DOCUME~1\Steve\MYDOCU~1\_Propeller_OBEX_\Ping\ping.c
ping_asm.o:	..\..\..\..\..\..\DOCUME~1\Steve\MYDOCU~1\_Propeller_OBEX_\Ping\ping_asm.s
	$(CC) -c $(ASFLAGS) ..\..\..\..\..\..\DOCUME~1\Steve\MYDOCU~1\_Propeller_OBEX_\Ping\ping_asm.s
