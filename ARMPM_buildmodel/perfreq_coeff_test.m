function [] = perfreq_coeff_test (coeff_column)
  fid = fopen ("/home/vokris/Work/ARM_PowerModel/BuildModel/Full_Freq_Results/LITTLE_perfreq_modelcoeff.data", "r");
  train_set = dlmread(fid,'\t',1,0);
  fclose (fid);

  [m, Err, CLow, CHigh] = build_model([ones(size(train_set,1),1),train_set(:,1)],train_set(:,coeff_column));

  format

  disp("###########################################################");
  disp("Model coefficients:");    # Print model coefficients
  disp("###########################################################");
  disp(num2str(m));

  meas_coeff=train_set(:,coeff_column);
  pred_coeff=[ones(size(train_set,1),1),train_set(:,1)]*m;

  error=(abs(pred_coeff-meas_coeff))./abs(meas_coeff);

  disp("");
  disp (num2str(error*100));
