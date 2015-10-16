function [] = load_build_model (freq_find,freq_next)
#blabla
%  fid = fopen ("/home/vokris/Work/ARM_PowerModel/BuildModel/train_set.data", "r");
%  train_set = dlmread(fid,'\t',1,1);
%  fclose (fid);

  ###########################################################
  # Step 2: Invoke build_model on a and Y to calculate model
  # coefficients, model error and confidence intervals.
  # See the help of build_model for details
  ###########################################################

  
%  CPI_train=train_set(:,5)./train_set(:,9);
%  IPC_train=train_set(:,9)./train_set(:,5);
%  train_reg=[ones(size(train_set,1),1),IPC_train];

%  coeff_column=12;
%%  
%  train_reg=[ones(size(train_set,1),1),train_set(:,coeff_column)];
  
  
  #MYMODEL
%  train_reg=[ones(size(train_set,1),1),train_set(:,2),train_set(:,3),train_set(:,4)]; #justphysical
%  train_reg=[ones(size(train_set,1),1),train_set(:,5:9)]; #justevents
%  train_reg=[ones(size(train_set,1),1),train_set(:,10:15)]; #justCPUstate
  
%  train_reg=[ones(size(train_set,1),1),train_set(:,2),train_set(:,3),train_set(:,4),train_set(:,5:9)]; #physical + PMU events

%  train_reg=[ones(size(train_set,1),1),train_set(:,[2,3,4,5:9,10:15]); #final

  #CSR MODEL
%  int_train_reg=train_set(:,7)./train_set(:,6);
%  vfp_train_reg=train_set(:,8)./train_set(:,6);
%  l1d_acc_train_reg=train_set(:,9)./train_set(:,6);
%  l2_acc_train_reg=train_set(:,10)./train_set(:,6);
%  l2_ref_train_reg=train_set(:,11)./train_set(:,6);
%  IPC_train_reg=train_set(:,6)./train_set(:,5);
%%
%%%  train_reg=[ones(size(train_set,1),1),int_train_reg,vfp_train_reg,IPC_train_reg,l1d_acc_train_reg,l2_acc_train_reg,l2_ref_train_reg]; #CSR model
%%%%%%%%%    
%%  train_reg=[ones(size(train_set,1),1),train_set(:,2),train_set(:,3),train_set(:,4),int_train_reg,vfp_train_reg,IPC_train_reg,l1d_acc_train_reg,l2_acc_train_reg,l2_ref_train_reg,train_set(:,12:17)]; #Improved CSR
%  
%  train_reg=[ones(size(train_set,1),1),train_set(:,2),train_set(:,3),train_set(:,4),int_train_reg,vfp_train_reg,IPC_train_reg,l1d_acc_train_reg,l2_acc_train_reg,l2_ref_train_reg]; #CSR + Physical


  #IDLE MODEL
%
%  train_reg=[ones(size(train_set,1),1),train_set(:,12),(train_set(:,12).^2)]; #standart south
%%%
%  train_reg=[ones(size(train_set,1),1),train_set(:,3),train_set(:,12),(train_set(:,3).*train_set(:,12)),(train_set(:,12).^2),((train_set(:,12).^2).*train_set(:,3))]; #full south
  
  #FREQUENCY MODEL
%  train_reg=[ones(size(train_set,1),1),train_set(:,3),train_set(:,3).^2];
%


%  [m, Err, CLow, CHigh] = build_model(train_reg,train_set(:,1));

  ###########################################################
  # Step 3: Inspect and evaluata model quality
  ###########################################################

%  format
%
%  disp("###########################################################");
%  disp("Model coefficients:");    # Print model coefficients
%  disp(["Coeff: " num2str(m')]);

  %disp("Model quality measures:");

%  mean_Error  = mean(Err);
  %disp("  Average model error [%]:");     # Print average model error
  %disp(["    "  num2str(mean_Error*100)]); # This should be very close to 0
  %disp("");

%  std_Error   = std(Err);
  %disp("  Standard deviation of model error [%]:");   # Print std of model error
  %disp(["    "  num2str(std_Error*100)]);              # The lower the beter
  %disp("");

  %disp("  Width of confidence intervals [% of model coefficient]");
  %disp(["    "  num2str(((CHigh-CLow)./m*100)')]);    # The lower the beter
  %disp("");                                           # Good if all numbers are the same order
  %
  %if (any((CHigh-CLow)./m > 0.05))
  %    disp("Warning: Confidence itnerval wider than 5%");
  %endif




%  skew_Error = skewness(Err);
  %disp("  Skewness:");                        # Skweness = 0 means symmetric distribution
  %disp(["    "  num2str(skew_Error)]);    #
  %disp("");

  %if (abs(skew_Error) > 0.4)
  %    disp("Warning: Error distribution seems to be skewed");
  %endif

%  kurt_Error = kurtosis(Err);
  %disp("  Kurtosis:");                        # Kurtosis = 0 for normal distributin, >0 for more "pointy"/"peaked" distributions
  %disp(["    "  num2str(kurt_Error)]);    # and < 0 for more "short"/"wide" distributions (compared to normal distribution)
  %disp("");

  %if (kurt_Error < -0.1)
  %    disp("Warning: Error distribution seems to have negative kurtosis. You should verify normality and acceptability of model error");
  %endif

  ############################################
  # Smexy Graphs
  ###########################################
  %[histogram, bins] = hist(Err,50);
  %
  %figure(1)
  %bar(bins*100,histogram);
  %ylabel("Sample count");
  %xlabel("Model Error [%]");
  %
  %bindiff  = diff(bins)(1);
  %
  %errorpdf = histogram/sum(histogram)/bindiff;
  %
  %
  %right_bins  = bins(1):bindiff:max((mean_Error+4*std_Error),bins(end)+bindiff/10);
  %left_bins   = bins(1):-bindiff:min((mean_Error-4*std_Error),bins(1)-bindiff/10);
  %
  %new_bins    = [left_bins(end:-1:2) right_bins];
  %new_errorpdf= [zeros(1,length(left_bins(end:-1:2))) errorpdf zeros(1,length(right_bins)-length(errorpdf))];
  %
  %normalpdf   = normpdf(new_bins,mean_Error,std_Error);
  %
  %figure(2)
  %plot(new_bins,new_errorpdf);
  %hold on
  %plot(new_bins,normalpdf,"r");
  %hold off


  #ylabel("Probability density");
  #xlabel("Error [%]");
  #legend("Model","Normal distribution");

  #figure(3);
  #eh = (CHigh./m)-1;
  #el = 1-(CLow./m);
  #errorbar(1:3,ones(1,3),el,eh)
  #axis([1 3 0.9 1.1])

  ###########################################################
  # Step 3: Additional validity for test set
  ###########################################################

  fid = fopen ("/home/vokris/Work/ARMPM/ARMPM_buildmodel/test_set.data", "r");
  test_set = dlmread(fid,'\t',1,3);
  fclose (fid);

  #Coefficient computation
  for  idx = 1:size(test_set,1)
    if test_set(idx,1) == freq_find
      break;
    endif
  endfor
  st=idx;

  for  idx = st:size(test_set,1)
    if test_set(idx,1) == freq_next
      break;
    endif
  endfor
  nd=idx-1;

  
%  test_reg=[ones(size(test_set,1),1),test_set(:,coeff_column)];
  
%  CPI_test=test_set(:,5)./test_set(:,9);
%  IPC_test=test_set(:,9)./test_set(:,5);
%%  
%  test_reg=[ones(size(test_set,1),1),IPC_test];

  #MYMODEL
%  test_reg=[ones(size(test_set,1),1),test_set(:,2),test_set(:,3),test_set(:,4)]; #JUSTPHYSICAL
%  test_reg=[ones(size(test_set,1),1),test_set(:,5:9)]; #JUSTEVENTS
%  test_reg=[ones(size(test_set,1),1),test_set(:,10:15)]; #JUSTCPUSTATE
  
%  test_reg=[ones(size(test_set,1),1),test_set(:,2),test_set(:,3),test_set(:,4),test_set(:,5:9)]; #physical + PMU
%
%  test_reg=[ones(size(test_set,1),1),test_set(:,4:7)]; #full
    
  
  #CSR MODEL
%  int_test_reg=test_set(:,7)./test_set(:,6);
%  vfp_test_reg=test_set(:,8)./test_set(:,6);
%  l1d_acc_test_reg=test_set(:,9)./test_set(:,6);
%  l2_acc_test_reg=test_set(:,10)./test_set(:,6);
%  l2_ref_test_reg=test_set(:,11)./test_set(:,6);
%  IPC_test_reg=test_set(:,6)./test_set(:,5);
%%  
%%%  test_reg=[ones(size(test_set,1),1),int_test_reg,vfp_test_reg,IPC_test_reg,l1d_acc_test_reg,l2_acc_test_reg,l2_ref_test_reg]; #CSR model
%%  
%  test_reg=[ones(size(test_set,1),1),test_set(:,2),test_set(:,3),test_set(:,4),int_test_reg,vfp_test_reg,IPC_test_reg,l1d_acc_test_reg,l2_acc_test_reg,l2_ref_test_reg,test_set(:,12:17)]; #UPDATED CSR
%
%  test_reg=[ones(size(test_set,1),1),test_set(:,2),test_set(:,3),test_set(:,4),int_test_reg,vfp_test_reg,IPC_test_reg,l1d_acc_test_reg,l2_acc_test_reg,l2_ref_test_reg]; #Updated CSR + P

  #IDLE MODEL
%  test_reg=[ones(size(test_set,1),1),test_set(:,12),(test_set(:,12).^2)]; #south idle
%%
%  test_reg=[ones(size(test_set,1),1),test_set(:,3),test_set(:,12),(test_set(:,3).*test_set(:,12)),(test_set(:,12).^2),((test_set(:,12).^2).*test_set(:,3))]; #south full

  #FREQUENCY MODEL
%  test_reg=[ones(size(test_set,1),1),test_set(:,3),test_set(:,3).^2];
%  
  
  #mean(train_set(:,coeff_column))
  #mean(test_set(:,coeff_column))

  test_power=test_set(st:nd,5);
%  pred_power=test_reg(st:nd,:)*m;
  
  maxMP=max(test_power)
  minMP=min(test_power)
  
%  maxMT=max(test_set(st:nd,4));
%  minMT=min(test_set(st:nd,4));
  
%  maxPP=max(pred_power);
%  minPP=min(pred_power);
  
%  error=(abs(pred_power-test_power))./abs(test_power);
%  average_err=mean(error);
%  std_dev_err=std(error);
  
%  ms_err=mean((pred_power-test_power).^2);
%  rms_err=sqrt(ms_err);
%  norm_rms_err=rms_err/mean(test_power);

  disp("###########################################################");
  disp("Model validation against test set");
  disp("###########################################################");

  disp(["Measured Power Range [%]: " num2str(100*(abs(maxMP-minMP)/abs(minMP)))]);  # Print Test Set power range
%  disp(["Predicted Power Range [%]: " num2str(100*(abs(maxPP-minPP)/abs(minPP)))]);  # Print predicted power range. Should be close to measured power range

  disp(["Average Power [W]: " num2str(mean(test_power))]);  # Print test Set average power
  disp(["Average Temperature [C]: " num2str(mean(test_set(st:nd,2)))]);  # Print Test Set power range
  disp(["Average Current [A]: " num2str(mean(test_set(st:nd,4)))]);  # Print Test Set power range
  disp(["Voltage Level [A]: " num2str(mean(test_set(st:nd,3)))]);  # Print Test Set power range
  disp(["Average Ev1 [#]: " num2str(mean(test_set(st:nd,7)))]);  # Print Test Set power range
  disp(["Average Ev2 [#]: " num2str(mean(test_set(st:nd,8)))]);  # Print Test Set power range
  disp(["Average Ev3 [#]: " num2str(mean(test_set(st:nd,9)))]);  # Print Test Set power range
  disp(["Average Ev4 [#]: " num2str(mean(test_set(st:nd,10)))]);  # Print Test Set power range
  disp(["Average Ev5 [#]: " num2str(mean(test_set(st:nd,11)))]);  # Print Test Set power range
  
%  disp(["Average Error [%]: " num2str(average_err*100)]);  # Print average model error. Should be close to 0.
%  disp(["Standart Deviation Error [%]: " num2str(std_dev_err*100)]);  # Print standart deviation of model error. The lower the better.
%  disp(["Normalised RMS Error [%]: " num2str(norm_rms_err*100)]);  # Print average model RMS error
  
%  disp("###########################################################");
%  disp("One line");
%  disp("###########################################################");
%  disp([num2str(100*(abs(maxMP-minMP)/abs(minMP))) " " num2str(100*(abs(maxPP-minPP)/abs(minPP))) " " num2str(average_err*100) " " num2str(std_dev_err*100) " " num2str(norm_rms_err*100)]);
  
  #Extra stuff
%  disp("###########################################################");
%  disp("Display values\n");
%  disp("###########################################################");
%  disp([repmat("Frequency: " , [size(test_set(st:nd,3),1),1]) num2str(test_set(st:nd,3))]);
%  disp([repmat("Measured: " , [size(test_set(st:nd,3),1),1]) num2str(test_power(st:nd,:))]);
%  disp([repmat("Predicted: " , [size(test_set(st:nd,3),1),1]) num2str(pred_power(st:nd,:))]);
