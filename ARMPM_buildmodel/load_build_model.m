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
maxMP=max(test_power);
minMP=min(test_power);

%Compute predicted power using model and events
pred_power=(test_reg(:,:)*m);
maxPP=max(pred_power);
minPP=min(pred_power);

%Compute absolute model errors
err=(pred_power-test_power);
abs_err=abs(err);
avg_abs_err=mean(abs_err);
std_dev_err=std(abs_err,1);
%compute normalised model errors
norm_avg_abs_err=mean((abs_err./abs(test_power))*100);
rel_std_dev=(std_dev_err/avg_abs_err)*100;

disp("###########################################################");
disp("Model validation against test set");
disp("###########################################################");
disp(["Average Power [W]: " num2str(mean(test_power),"%.5f")]); 
disp(["Measured Power Range [%]: " num2str(100*(abs(maxMP-minMP)/abs(minMP)),"%.2f")]);
disp("###########################################################"); 
disp(["Average Predicted Power [W]: " num2str(mean(pred_power),"%.5f")]);  
disp(["Predicted Power Range [%]: " num2str(100*(abs(maxPP-minPP)/abs(minPP)),"%.2f")]);
disp("###########################################################"); 
disp(["Average Absolute Error: " num2str(avg_abs_err,"%.10f")]);
disp(["Absolute Error Standart Deviation: " num2str(std_dev_err,"%.10f")]);
disp("###########################################################");
disp(["Normalised Average Absolute Error [%]: " num2str(norm_avg_abs_err,"%.2f")]);
disp(["Relative Standart Deviation [%]: " num2str(rel_std_dev,"%.2f")]);
disp("###########################################################");
disp(["Model coefficients: " num2str(m',"%G\t")]);
disp("###########################################################");