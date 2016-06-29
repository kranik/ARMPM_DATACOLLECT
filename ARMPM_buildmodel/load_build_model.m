function [] = load_build_model (train_set,test_set,start_row,start_col,regressand_col,events_col)

%Open train set file
fid = fopen (train_set, "r");
train_set = dlmread(fid,'\t',start_row,start_col);
fclose (fid);
%Extract train data from the file train clomuns specified. 
%The ones in front are for the constant coefficiant for linear regression
train_reg=[ones(size(train_set,1),1),train_set(:,str2num(events_col).-start_col)];
%Compute model
[m, Err, CLow, CHigh] = build_model(train_reg,train_set(:,regressand_col.-start_col));

%Open test set file
fid = fopen (test_set, "r");
test_set = dlmread(fid,'\t',start_row,start_col);
fclose (fid);
%Again extract test data from specified file.
%Events columns are same as train file
test_reg=[ones(size(test_set,1),1),test_set(:,str2num(events_col).-start_col)];

%Extract measured power and range from test data
test_power=test_set(:,regressand_col.-start_col);
%Compute predicted power using model and events
pred_power=(test_reg(:,:)*m);

%Compute absolute model errors
err=(test_power-pred_power);
abs_err=abs(err);
avg_abs_err=mean(abs_err);
std_dev_err=std(abs_err,1);
%compute realtive model errors and deviation
rel_abs_err=abs(err./test_power)*100;
rel_avg_abs_err=mean(rel_abs_err);
rel_err_std_dev=std(rel_abs_err,1);

disp("###########################################################");
disp("Model validation against test set");
disp("###########################################################");
disp(["Average Power [W]: " num2str(mean(test_power),"%.5f")]); 
disp(["Measured Power Range [%]: " num2str((range(test_power)./min(test_power))*100,"%.2f")]);
disp("###########################################################"); 
disp(["Average Predicted Power [W]: " num2str(mean(pred_power),"%.5f")]);  
disp(["Predicted Power Range [%]: " num2str((range(pred_power)./min(pred_power))*100,"%.2f")]);
disp("###########################################################"); 
disp(["Average Absolute Error [W]: " num2str(avg_abs_err,"%.5f")]);
disp(["Absolute Error Standart Deviation [W]: " num2str(std_dev_err,"%.5f")]);
disp("###########################################################");
disp(["Average Relative Error [%]: " num2str(rel_avg_abs_err,"%.2f")]);
disp(["Relative Error Standart Deviation [%]: " num2str(rel_err_std_dev,"%.2f")]);
disp("###########################################################");
disp(["Model coefficients: " num2str(m',"%G\t")]);
disp("###########################################################");