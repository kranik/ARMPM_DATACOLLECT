fid = fopen ("/home/vokris/Work/ARMPowerModel/BuildModel/model_input.dat", "r");
model_input = dlmread(fid);
fclose (fid);

###########################################################
# Step 2: Invoke build_model on a and Y to calculate model
# coefficients, model error and confidence intervals.
# See the help of build_model for details
###########################################################

[m, Err, CLow, CHigh] = build_model([ones(size(model_input,1),1),model_input(:,2:4)],model_input(:,1));

###########################################################
# Step 3: Inspect and evaluata model quality
###########################################################

disp("###########################################################");
disp("Model coefficients:");    # Print model coefficients
disp([m']);
disp("");

disp("Model quality measures:");

mean_Error  = mean(Err);
disp("  Average model error [%]:");     # Print average model error
disp(["    "  num2str(mean_Error*100)]); # This should be very close to 0
disp("");

std_Error   = std(Err);
disp("  Standard deviation of model error [%]:");   # Print std of model error
disp(["    "  num2str(std_Error*100)]);              # The lower the beter
disp("");

disp("  Width of confidence intervals [% of model coefficient]");
disp(["    "  num2str(((CHigh-CLow)./m*100)')]);    # The lower the beter
disp("");                                           # Good if all numbers are the same order

if (any((CHigh-CLow)./m > 0.05))
    disp("Warning: Confidence itnerval wider than 5%");
endif




skew_Error = skewness(Err);
disp("  Skewness:");                        # Skweness = 0 means symmetric distribution
disp(["    "  num2str(skew_Error)]);    #
disp("");

if (abs(skew_Error) > 0.4)
    disp("Warning: Error distribution seems to be skewed");
endif

kurt_Error = kurtosis(Err);
disp("  Kurtosis:");                        # Kurtosis = 0 for normal distributin, >0 for more "pointy"/"peaked" distributions
disp(["    "  num2str(kurt_Error)]);    # and < 0 for more "short"/"wide" distributions (compared to normal distribution)
disp("");

if (kurt_Error < -0.1)
    disp("Warning: Error distribution seems to have negative kurtosis. You should verify normality and acceptability of model error");
endif


[histogram, bins] = hist(Err,50);

figure(1)
bar(bins*100,histogram);
ylabel("Sample count");
xlabel("Model Error [%]");

bindiff  = diff(bins)(1);

errorpdf = histogram/sum(histogram)/bindiff;


right_bins  = bins(1):bindiff:max((mean_Error+4*std_Error),bins(end)+bindiff/10);
left_bins   = bins(1):-bindiff:min((mean_Error-4*std_Error),bins(1)-bindiff/10);

new_bins    = [left_bins(end:-1:2) right_bins];
new_errorpdf= [zeros(1,length(left_bins(end:-1:2))) errorpdf zeros(1,length(right_bins)-length(errorpdf))];

normalpdf   = normpdf(new_bins,mean_Error,std_Error);

figure(2)
plot(new_bins,new_errorpdf);
hold on
plot(new_bins,normalpdf,"r");
hold off

ylabel("Probability density");
xlabel("Error [%]");
legend("Model","Normal distribution");

figure(3);
eh = (CHigh./m)-1;
el = 1-(CLow./m);
errorbar(1:3,ones(1,3),el,eh)
axis([1 3 0.9 1.1])
