load TC2/big/Run_1/TC2_big_octave_1.dat
load TC2/big/Run_2/TC2_big_octave_2.dat
load TC2/big/Run_3/TC2_big_octave_3.dat
load TC2/big/Run_4/TC2_big_octave_4.dat
load TC2/big/Run_5/TC2_big_octave_5.dat
load TC2/LITTLE/Run_1/TC2_LITTLE_octave_1.dat
load TC2/LITTLE/Run_2/TC2_LITTLE_octave_2.dat
load TC2/LITTLE/Run_3/TC2_LITTLE_octave_3.dat
load TC2/LITTLE/Run_4/TC2_LITTLE_octave_4.dat
load TC2/LITTLE/Run_5/TC2_LITTLE_octave_5.dat

load ODROID/Eric/Run_1/ODROID_big_octave_1.dat
load ODROID/Eric/Run_1/ODROID_big_octave_sensors_1.dat
load ODROID/Eric/Run_2/ODROID_big_octave_2.dat
load ODROID/Eric/Run_2/ODROID_big_octave_sensors_2.dat
load ODROID/Eric/Run_3/ODROID_big_octave_3.dat
load ODROID/Eric/Run_3/ODROID_big_octave_sensors_3.dat
load ODROID/Eric/Run_4/ODROID_big_octave_4.dat
load ODROID/Eric/Run_4/ODROID_big_octave_sensors_4.dat
load ODROID/Eric/Run_5/ODROID_big_octave_5.dat
load ODROID/Eric/Run_5/ODROID_big_octave_sensors_5.dat
load ODROID/Eric/Run_1/ODROID_LITTLE_octave_1.dat
load ODROID/Eric/Run_1/ODROID_LITTLE_octave_sensors_1.dat
load ODROID/Eric/Run_2/ODROID_LITTLE_octave_2.dat
load ODROID/Eric/Run_2/ODROID_LITTLE_octave_sensors_2.dat
load ODROID/Eric/Run_3/ODROID_LITTLE_octave_3.dat
load ODROID/Eric/Run_3/ODROID_LITTLE_octave_sensors_3.dat
load ODROID/Eric/Run_4/ODROID_LITTLE_octave_4.dat
load ODROID/Eric/Run_4/ODROID_LITTLE_octave_sensors_4.dat
load ODROID/Eric/Run_5/ODROID_LITTLE_octave_5.dat
load ODROID/Eric/Run_5/ODROID_LITTLE_octave_sensors_5.dat

ODROID_big_power_1 = zeros(30, 4);
ODROID_big_power_2 = zeros(30, 4);
ODROID_big_power_3 = zeros(30, 4);
ODROID_big_power_4 = zeros(30, 4);
ODROID_big_power_5 = zeros(30, 4);
ODROID_LITTLE_power_1 = zeros(30, 4);
ODROID_LITTLE_power_2 = zeros(30, 4);
ODROID_LITTLE_power_3 = zeros(30, 4);
ODROID_LITTLE_power_4 = zeros(30, 4);
ODROID_LITTLE_power_5 = zeros(30, 4);

for i = 1:30,
	for j = 1:rows(ODROID_big_octave_sensors_1),
    		if ( ODROID_big_octave_sensors_1(j,1) <= ODROID_big_octave_1(i,2) && ODROID_big_octave_sensors_1(j,1) >= ODROID_big_octave_1(i,1) ) 
    			ODROID_big_power_1(i,1) += ODROID_big_octave_sensors_1(j,2);
    			ODROID_big_power_1(i,2) += ODROID_big_octave_sensors_1(j,3);
    			ODROID_big_power_1(i,3) += ODROID_big_octave_sensors_1(j,4);
    			ODROID_big_power_1(i,4) ++;
    		endif;
  	endfor;
	for j = 1:rows(ODROID_big_octave_sensors_2),
    		if ( ODROID_big_octave_sensors_2(j,1) <= ODROID_big_octave_2(i,2) && ODROID_big_octave_sensors_2(j,1) >= ODROID_big_octave_2(i,1) ) 
    			ODROID_big_power_2(i,1) += ODROID_big_octave_sensors_2(j,2);
    			ODROID_big_power_2(i,2) += ODROID_big_octave_sensors_2(j,3);
    			ODROID_big_power_2(i,3) += ODROID_big_octave_sensors_2(j,4);
    			ODROID_big_power_2(i,4) ++;
    		endif;
  	endfor;
 	for j = 1:rows(ODROID_big_octave_sensors_3),
    		if ( ODROID_big_octave_sensors_3(j,1) <= ODROID_big_octave_3(i,2) && ODROID_big_octave_sensors_3(j,1) >= ODROID_big_octave_3(i,1) ) 
    			ODROID_big_power_3(i,1) += ODROID_big_octave_sensors_3(j,2);
    			ODROID_big_power_3(i,2) += ODROID_big_octave_sensors_3(j,3);
    			ODROID_big_power_3(i,3) += ODROID_big_octave_sensors_3(j,4);
    			ODROID_big_power_3(i,4) ++;
    		endif;
  	endfor;
 	for j = 1:rows(ODROID_big_octave_sensors_4),
    		if ( ODROID_big_octave_sensors_4(j,1) <= ODROID_big_octave_4(i,2) && ODROID_big_octave_sensors_4(j,1) >= ODROID_big_octave_4(i,1) ) 
    			ODROID_big_power_4(i,1) += ODROID_big_octave_sensors_4(j,2);
    			ODROID_big_power_4(i,2) += ODROID_big_octave_sensors_4(j,3);
    			ODROID_big_power_4(i,3) += ODROID_big_octave_sensors_4(j,4);
    			ODROID_big_power_4(i,4) ++;
    		endif;
  	endfor;  	
 	for j = 1:rows(ODROID_big_octave_sensors_5),
    		if ( ODROID_big_octave_sensors_5(j,1) <= ODROID_big_octave_5(i,2) && ODROID_big_octave_sensors_5(j,1) >= ODROID_big_octave_5(i,1) ) 
    			ODROID_big_power_5(i,1) += ODROID_big_octave_sensors_5(j,2);
    			ODROID_big_power_5(i,2) += ODROID_big_octave_sensors_5(j,3);
    			ODROID_big_power_5(i,3) += ODROID_big_octave_sensors_5(j,4);
    			ODROID_big_power_5(i,4) ++;
    		endif;
  	endfor;
  	
 	for j = 1:rows(ODROID_LITTLE_octave_sensors_1),
    		if ( ODROID_LITTLE_octave_sensors_1(j,1) <= ODROID_LITTLE_octave_1(i,2) && ODROID_LITTLE_octave_sensors_1(j,1) >= ODROID_LITTLE_octave_1(i,1) ) 
    			ODROID_LITTLE_power_1(i,1) += ODROID_LITTLE_octave_sensors_1(j,2);
    			ODROID_LITTLE_power_1(i,2) += ODROID_LITTLE_octave_sensors_1(j,3);
    			ODROID_LITTLE_power_1(i,3) += ODROID_LITTLE_octave_sensors_1(j,4);
    			ODROID_LITTLE_power_1(i,4) ++;
    		endif;
  	endfor;
 	for j = 1:rows(ODROID_LITTLE_octave_sensors_2),
    		if ( ODROID_LITTLE_octave_sensors_2(j,1) <= ODROID_LITTLE_octave_2(i,2) && ODROID_LITTLE_octave_sensors_2(j,1) >= ODROID_LITTLE_octave_2(i,1) ) 
    			ODROID_LITTLE_power_2(i,1) += ODROID_LITTLE_octave_sensors_2(j,2);
    			ODROID_LITTLE_power_2(i,2) += ODROID_LITTLE_octave_sensors_2(j,3);
    			ODROID_LITTLE_power_2(i,3) += ODROID_LITTLE_octave_sensors_2(j,4);
    			ODROID_LITTLE_power_2(i,4) ++;
    		endif;
  	endfor;
   	for j = 1:rows(ODROID_LITTLE_octave_sensors_3),
    		if ( ODROID_LITTLE_octave_sensors_3(j,1) <= ODROID_LITTLE_octave_3(i,2) && ODROID_LITTLE_octave_sensors_3(j,1) >= ODROID_LITTLE_octave_3(i,1) ) 
    			ODROID_LITTLE_power_3(i,1) += ODROID_LITTLE_octave_sensors_3(j,2);
    			ODROID_LITTLE_power_3(i,2) += ODROID_LITTLE_octave_sensors_3(j,3);
    			ODROID_LITTLE_power_3(i,3) += ODROID_LITTLE_octave_sensors_3(j,4);
    			ODROID_LITTLE_power_3(i,4) ++;
    		endif;
  	endfor;
 	for j = 1:rows(ODROID_LITTLE_octave_sensors_4),
    		if ( ODROID_LITTLE_octave_sensors_4(j,1) <= ODROID_LITTLE_octave_4(i,2) && ODROID_LITTLE_octave_sensors_4(j,1) >= ODROID_LITTLE_octave_4(i,1) ) 
    			ODROID_LITTLE_power_4(i,1) += ODROID_LITTLE_octave_sensors_4(j,2);
    			ODROID_LITTLE_power_4(i,2) += ODROID_LITTLE_octave_sensors_4(j,3);
    			ODROID_LITTLE_power_4(i,3) += ODROID_LITTLE_octave_sensors_4(j,4);
    			ODROID_LITTLE_power_4(i,4) ++;
    		endif;
  	endfor;
 	for j = 1:rows(ODROID_LITTLE_octave_sensors_5),
    		if ( ODROID_LITTLE_octave_sensors_5(j,1) <= ODROID_LITTLE_octave_5(i,2) && ODROID_LITTLE_octave_sensors_5(j,1) >= ODROID_LITTLE_octave_5(i,1) ) 
    			ODROID_LITTLE_power_5(i,1) += ODROID_LITTLE_octave_sensors_5(j,2);
    			ODROID_LITTLE_power_5(i,2) += ODROID_LITTLE_octave_sensors_5(j,3);
    			ODROID_LITTLE_power_5(i,3) += ODROID_LITTLE_octave_sensors_5(j,4);
    			ODROID_LITTLE_power_5(i,4) ++;
    		endif;
  	endfor;  	  	
endfor;

ODROID_big_energy_1 = zeros(30, 3);
ODROID_big_energy_2 = zeros(30, 3);
ODROID_big_energy_3 = zeros(30, 3);
ODROID_big_energy_4 = zeros(30, 3);
ODROID_big_energy_5 = zeros(30, 3);

ODROID_LITTLE_energy_1 = zeros(30, 3);
ODROID_LITTLE_energy_2 = zeros(30, 3);
ODROID_LITTLE_energy_3 = zeros(30, 3);
ODROID_LITTLE_energy_4 = zeros(30, 3);
ODROID_LITTLE_energy_5 = zeros(30, 3);

for j = 1:3,
	ODROID_big_energy_1(:,j) = ( ODROID_big_power_1(:,j) ./ ODROID_big_power_1(:,4) ) .* ( (ODROID_big_octave_1(:,2) - ODROID_big_octave_1(:,1))/1000000000 ) ;
	ODROID_big_energy_2(:,j) = ( ODROID_big_power_2(:,j) ./ ODROID_big_power_2(:,4) ) .* ( (ODROID_big_octave_2(:,2) - ODROID_big_octave_2(:,1))/1000000000 ) ;
	ODROID_big_energy_3(:,j) = ( ODROID_big_power_3(:,j) ./ ODROID_big_power_3(:,4) ) .* ( (ODROID_big_octave_3(:,2) - ODROID_big_octave_3(:,1))/1000000000 ) ;
	ODROID_big_energy_4(:,j) = ( ODROID_big_power_4(:,j) ./ ODROID_big_power_4(:,4) ) .* ( (ODROID_big_octave_4(:,2) - ODROID_big_octave_4(:,1))/1000000000 ) ;
	ODROID_big_energy_5(:,j) = ( ODROID_big_power_5(:,j) ./ ODROID_big_power_5(:,4) ) .* ( (ODROID_big_octave_5(:,2) - ODROID_big_octave_5(:,1))/1000000000 ) ;
	
	ODROID_LITTLE_energy_1(:,j) = ( ODROID_LITTLE_power_1(:,j) ./ ODROID_LITTLE_power_1(:,4) ) .* ( (ODROID_LITTLE_octave_1(:,2) - ODROID_LITTLE_octave_1(:,1))/1000000000 ) ;
	ODROID_LITTLE_energy_2(:,j) = ( ODROID_LITTLE_power_2(:,j) ./ ODROID_LITTLE_power_2(:,4) ) .* ( (ODROID_LITTLE_octave_2(:,2) - ODROID_LITTLE_octave_2(:,1))/1000000000 ) ;
	ODROID_LITTLE_energy_3(:,j) = ( ODROID_LITTLE_power_3(:,j) ./ ODROID_LITTLE_power_3(:,4) ) .* ( (ODROID_LITTLE_octave_3(:,2) - ODROID_LITTLE_octave_3(:,1))/1000000000 ) ;
	ODROID_LITTLE_energy_4(:,j) = ( ODROID_LITTLE_power_4(:,j) ./ ODROID_LITTLE_power_4(:,4) ) .* ( (ODROID_LITTLE_octave_4(:,2) - ODROID_LITTLE_octave_4(:,1))/1000000000 ) ;
	ODROID_LITTLE_energy_5(:,j) = ( ODROID_LITTLE_power_5(:,j) ./ ODROID_LITTLE_power_5(:,4) ) .* ( (ODROID_LITTLE_octave_5(:,2) - ODROID_LITTLE_octave_5(:,1))/1000000000 ) ;
endfor;

TC2_big_avg = ([((TC2_big_octave_1(:,2).-TC2_big_octave_1(:,1))/1000000000),TC2_big_octave_1(:,3:9)] + [((TC2_big_octave_2(:,2).-TC2_big_octave_2(:,1))/1000000000),TC2_big_octave_2(:,3:9)] + [((TC2_big_octave_3(:,2).-TC2_big_octave_3(:,1))/1000000000),TC2_big_octave_3(:,3:9)] + [((TC2_big_octave_4(:,2).-TC2_big_octave_4(:,1))/1000000000),TC2_big_octave_4(:,3:9)] + [((TC2_big_octave_5(:,2).-TC2_big_octave_5(:,1))/1000000000),TC2_big_octave_5(:,3:9)]) ./ 5 ;

TC2_LITTLE_avg = ([((TC2_LITTLE_octave_1(:,2)-TC2_LITTLE_octave_1(:,1))/1000000000),TC2_LITTLE_octave_1(:,3:9)] + [((TC2_LITTLE_octave_2(:,2)-TC2_LITTLE_octave_2(:,1))/1000000000),TC2_LITTLE_octave_2(:,3:9)] + [((TC2_LITTLE_octave_3(:,2)-TC2_LITTLE_octave_3(:,1))/1000000000),TC2_LITTLE_octave_3(:,3:9)] + [((TC2_LITTLE_octave_4(:,2)-TC2_LITTLE_octave_4(:,1))/1000000000),TC2_LITTLE_octave_4(:,3:9)] + [((TC2_LITTLE_octave_5(:,2)-TC2_LITTLE_octave_5(:,1))/1000000000),TC2_LITTLE_octave_5(:,3:9)]) ./ 5 ;

ODROID_big_avg = ( [((ODROID_big_octave_1(:,2)-ODROID_big_octave_1(:,1))/1000000000),ODROID_big_energy_1,ODROID_big_octave_1(:,3:7)] + [((ODROID_big_octave_2(:,2)-ODROID_big_octave_2(:,1))/1000000000),ODROID_big_energy_2,ODROID_big_octave_2(:,3:7)] + [((ODROID_big_octave_3(:,2)-ODROID_big_octave_3(:,1))/1000000000),ODROID_big_energy_3,ODROID_big_octave_3(:,3:7)] + [((ODROID_big_octave_4(:,2)-ODROID_big_octave_4(:,1))/1000000000),ODROID_big_energy_4,ODROID_big_octave_4(:,3:7)] + [((ODROID_big_octave_5(:,2)-ODROID_big_octave_5(:,1))/1000000000),ODROID_big_energy_5,ODROID_big_octave_5(:,3:7)]) ./ 5 ;

ODROID_LITTLE_avg = ( [((ODROID_LITTLE_octave_1(:,2)-ODROID_LITTLE_octave_1(:,1))/1000000000) ,ODROID_LITTLE_energy_1,ODROID_LITTLE_octave_1(:,3:7)] + [((ODROID_LITTLE_octave_2(:,2)-ODROID_LITTLE_octave_2(:,1))/1000000000) ,ODROID_LITTLE_energy_2,ODROID_LITTLE_octave_2(:,3:7)] + [((ODROID_LITTLE_octave_3(:,2)-ODROID_LITTLE_octave_3(:,1))/1000000000) ,ODROID_LITTLE_energy_3,ODROID_LITTLE_octave_3(:,3:7)] +[((ODROID_LITTLE_octave_4(:,2)-ODROID_LITTLE_octave_4(:,1))/1000000000) ,ODROID_LITTLE_energy_4,ODROID_LITTLE_octave_4(:,3:7)] + [((ODROID_LITTLE_octave_5(:,2)-ODROID_LITTLE_octave_5(:,1))/1000000000) ,ODROID_LITTLE_energy_5,ODROID_LITTLE_octave_5(:,3:7)]) ./ 5 ; 

TC2_ODROID_LITTLE_events = abs( (ODROID_LITTLE_avg (:,5:9)  - TC2_LITTLE_avg (:,4:8) ) ./ ( (ODROID_LITTLE_avg (:,5:9)   + TC2_LITTLE_avg (:,4:8) )/2 ) ) * 100 ;
TC2_ODROID_big_events = abs( (ODROID_big_avg (:,5:9)  - TC2_big_avg (:,4:8) ) ./ ( (ODROID_big_avg (:,5:9)   + TC2_big_avg (:,4:8) )/2 ) ) * 100 ;

TC2_ODROID_LITTLE_events_mean = mean(TC2_ODROID_LITTLE_events)
TC2_ODROID_big_events_mean = mean(TC2_ODROID_big_events)