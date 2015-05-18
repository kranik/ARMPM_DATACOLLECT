function [] = full_power_range(freq_find,freq_next)
#blabla
  fid = fopen ("/home/vokris/Work/ARM_PowerModel/BuildModel/power_high.data", "r");
  high = dlmread(fid,'\t',1,1);
  fclose (fid);
  
  for  idx = 1:size(high,1)
    if high(idx,2) == freq_find
      break;
    endif
  endfor
  st=idx;

  for  idx = st:size(high,1)
    if high(idx,2) == freq_next
      break;
    endif
  endfor
  nd=idx-1;
  
  high_power=high(st:nd,4);
  out=outlier(high_power,0,1);
  high_power(find(out))=[];
  av_high=mean(high_power);
  
  
  fid = fopen ("/home/vokris/Work/ARM_PowerModel/BuildModel/power_low.data", "r");
  low = dlmread(fid,'\t',1,1);
  fclose (fid);

  for  idx = 1:size(low,1)
    if low(idx,2) == freq_find
      break;
    endif
  endfor
  st=idx;

  for  idx = st:size(low,1)
    if low(idx,2) == freq_next
      break;
    endif
  endfor
  nd=idx-1;
  
  low_power=low(st:nd,4);
  out=outlier(low_power,0,1);
  low_power(find(out))=[];
  av_low=mean(low_power);


  disp("###########################################################");
  disp("Model validation against test set");
  disp("###########################################################");

  disp(["Measured Power Range [%]: " num2str(100*(abs(av_high-av_low)/abs(av_low)))]);  # Print Test Set power range