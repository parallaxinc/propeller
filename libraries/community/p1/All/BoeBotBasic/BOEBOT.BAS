100 REM PINGing around with a Propeller BOE-BOT
110 REM Ping servo (R) 550 to (L) 2300, (C) 1425
120 REM Left servo (F) > 1700, (C) 1488, (R) < 1300
130 REM Right servo (F) < 1300, (C) 1500, (R) > 1700
140 SRVPING [50] = 1425 : REM Initialize
150 PAUSE 500
160 GOSUB 1000 : REM Look around with PING and IR
170 h = 0 : REM See if a close IR response
180 IF w > 5 THEN h = w
190 IF x > 5 THEN h = x
200 IF y > 5 THEN h = y
210 PRINT "Left ";y;" Center ";x;" Right ";w
220 IF h > 0 THEN GOTO 900
230 f = 0 : g = 300 : REM Which direction has longer path
240 IF a > f THEN f = a : g = 400
250 IF b > f THEN f = b : g = 500
260 IF c > f THEN f = c : g = 600
270 IF d > f THEN f = d : g = 700
280 IF e > f THEN f = e : g = 800
285 PRINT "Longest distance ";f
290 GOTO g
300 REM No responses in any direction
305 PRINT "No response, go forward"
310 GOSUB 1500 : REM Go forward
320 GOSUB 1500
330 GOTO 160
400 REM Turn right 90 degrees and go forward
405 PRINT "Turn right 90 degrees, go forward"
410 GOSUB 1300
420 GOSUB 1300
430 GOSUB 1500
440 GOTO 160
500 REM Turn right 45 degrees and go forward
505 PRINT "Turn right 45 degrees, go forward"
510 GOSUB 1300
520 GOSUB 1500
530 GOTO 160
600 REM Go forward
605 PRINT "Go forward"
610 GOSUB 1500
620 GOSUB 1500
630 GOTO 160
700 REM Turn left 45 degrees and go forward
705 PRINT "Turn left 45 degrees, go forward"
710 GOSUB 1400
720 GOSUB 1500
730 GOTO 160
800 REM Turn left 90 degrees and go forward
805 PRINT "Turn left 45 degrees, go forward"
810 GOSUB 1400
820 GOSUB 1400
830 GOSUB 1500
840 GOTO 160
900 REM Back up and check environment again
905 PRINT "Backup and reevaluate"
910 GOSUB 1600
920 GOSUB 1600
930 GOTO 160
1000 REM Starting at the PING servo center position,
1010 REM check first at 45 degrees, then 90 degrees
1020 REM to the right, then the left for PING distance
1030 REM and IR distance zone using variables A-E for
1040 REM PING and V-Z for IR.
1050 SRVPING [50] = 550 : REM Start on the right side
1060 PAUSE 500 : PING : REM Wait for movement, then PING
1070 a = PING : v = IRZONE [38000,10,500]
1080 SRVPING [50] = 986 : REM Mid-right position
1090 PAUSE 500 : PING : REM Wait for movement, then PING
1100 b = PING : w = IRZONE [38000,10,500]
1110 SRVPING [50] = 1425 : REM Straight ahead
1120 PAUSE 500 : PING : REM Wait for movement, then PING
1130 c = PING : x = IRZONE [38000,10,500]
1140 SRVPING [50] = 1964 : REM Mid-left position
1150 PAUSE 500 : PING : REM Wait for movement, then PING
1160 d = PING : y = IRZONE [38000,10,500]
1170 SRVPING [50] = 2300 : REM Finish on the left side
1180 PAUSE 500 : PING : REM Wait for movement, then PING
1190 e = PING : z = IRZONE [38000,10,500]
1200 SRVPING [50] = 1425 : REM Center servo
1210 RETURN
1300 REM Turn to the right about 45 degrees
1310 SRVLEFT [40]=1688
1320 SRVRIGHT [40]=1700
1330 PAUSE 500
1340 RETURN
1400 REM Turn to the left about 45 degrees
1410 SRVLEFT [40]=1288
1420 SRVRIGHT [40]=1300
1430 PAUSE 500
1440 RETURN
1500 REM Go forward for about a second
1510 SRVLEFT [50]=1688
1520 SRVRIGHT [50]=1300
1530 PAUSE 1000
1540 RETURN
1600 REM Go backwards for about a second
1610 SRVLEFT [50]=1288
1620 SRVRIGHT [50]=1700
1630 PAUSE 1000
1640 RETURN
