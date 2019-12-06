100 UOLED SETUP               
110 UOLED ERASE               
115 GOSUB 1400              
120 UOLED PIXEL 0,0,255,255,255                               
130 PAUSE 1000              
140 UOLED PIXEL 95,0,255,0,0                            
150 PAUSE 1000              
160 UOLED PIXEL 0,63,0,255,0                            
170 PAUSE 1000              
180 UOLED PIXEL 95,63,0,0,255                             
190 PAUSE 1000              
200 FOR t = 0 TO 47                   
210 UOLED LINE t,0,47,31,255,255,255                                    
220 PAUSE 20            
230 IF t = 47 THEN GOTO 250                           
240 UOLED LINE t,0,47,31,0,0,0                              
250 NEXT t          
260 PAUSE 1000              
300 FOR t = 0 TO 31                   
310 UOLED LINE 95,t,47,31,255,0,0                                 
320 PAUSE 20            
330 IF t = 31 THEN GOTO 350                           
340 UOLED LINE 95,t,47,31,0,0,0                               
350 NEXT t          
360 PAUSE 1000              
400 FOR t = 63 TO 31 STEP -1                            
410 UOLED LINE 0,t,47,31,0,255,0                                
420 PAUSE 20            
430 IF t = 31 THEN GOTO 450                           
440 UOLED LINE 0,t,47,31,0,0,0                              
450 NEXT t          
460 PAUSE 1000              
500 FOR t = 95 TO 47 STEP -1                            
510 UOLED LINE t,63,47,31,0,0,255                                 
520 PAUSE 20            
530 IF t = 47 THEN GOTO 550                           
540 UOLED LINE t,63,47,31,0,0,0                               
550 NEXT t          
560 PAUSE 1000              
600 UOLED ERASE               
610 PAUSE 1000              
700 FOR t = 0 TO 47                   
710 UOLED LINE t,0,47,31,255,255,255                                    
720 PAUSE 20            
730 NEXT t          
740 PAUSE 1000              
750 FOR t = 0 TO 31                   
760 UOLED LINE 95,t,47,31,255,0,0                                 
770 PAUSE 20            
780 NEXT t          
790 PAUSE 1000              
800 FOR t = 63 TO 31 STEP -1                            
810 UOLED LINE 0,t,47,31,0,255,0                                
820 PAUSE 20            
830 NEXT t          
840 PAUSE 1000              
850 FOR t = 95 TO 47 STEP -1                            
860 UOLED LINE t,63,47,31,0,0,255                                 
870 PAUSE 20            
880 NEXT t          
890 PAUSE 1000              
900 UOLED ERASE               
910 PAUSE 1000              
920 UOLED RECT 0,0,31,63,1,255,0,0                                  
930 PAUSE 1000              
940 UOLED RECT 32,0,63,63,1,0,255,0                                   
950 PAUSE 1000              
960 UOLED RECT 64,0,95,63,1,0,0,255                                   
970 PAUSE 1000              
980 UOLED ERASE               
990 PAUSE 1000              
1000 FOR t = 1 TO 30                    
1010 UOLED ERASE                
1020 UOLED RECT t,t,t*2,t*2,1,255,0,0                                     
1030 PAUSE 50             
1040 NEXT t           
1050 PAUSE 1000               
1060 UOLED ERASE                
1070 FOR i = 20 TO 0 STEP -10                             
1080 FOR t = 0 TO 63                    
1090 UOLED LINE 0,t,95,t,0,0,255                                
1100 PAUSE i            
1110 UOLED LINE 0,t,95,t,0,0,0                              
1120 NEXT t           
1130 FOR t = 63 TO 0 STEP -1                            
1140 UOLED LINE 0,t,95,t,255,0,0                                
1150 PAUSE i            
1160 UOLED LINE 0,t,95,t,0,0,0                              
1170 NEXT t           
1180 FOR t = 0 TO 63                    
1190 UOLED LINE 0,t,95,t,0,255,0                                
1200 PAUSE i            
1210 UOLED LINE 0,t,95,t,0,0,0                              
1220 NEXT t
1230 FOR t = 63 TO 0 STEP -1
1240 UOLED LINE 0,t,95,t,255,255,0
1250 PAUSE i
1260 UOLED LINE 0,t,95,t,0,0,0
1270 NEXT t
1280 NEXT i
1290 PAUSE 2000
1300 GOTO 110
1400 UOLED TEXT 0,0,64,64,64,"uOLED Test"
1410 UOLED TEXT 0,1,64,64,64,"Version 3"
1420 UOLED TEXT 0,2,64,64,64,"uOLED Basic"
1430 UOLED TEXT 0,3,64,64,64,"V 1.008"
1440 PAUSE 3000
1450 UOLED ERASE
1451 FOR i=1 TO 15
1452 UOLED CIRCLE 48,32,16-i,64,64,64
1453 PAUSE 100
1454 NEXT i
1455 PAUSE 3000
1456 UOLED ERASE
1460 RETURN