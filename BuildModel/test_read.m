#TODO:
#average data for TC2 (this should be obsolete in future versions of this script so make it easily removable) calculate standart deviation for the different runs
#average data for ODROID (this should be obsolete in future versions so make it modular) and calculate std deviation between runs
#calculate the percentage difference between the averaged TC2 and ODROID
#wrap this as a function with inputs num_events and scan_string
#after I update the std_dev runs then wrap this as a function with inputs num_events, scan_string and the file to be scanned (might also add data start line and matrix label line) 
ODROID=1;
num_events = 5;
if(ODROID)
  scan_string = "%s %*d %f %f %f %*d %f";
else
  scan_string = "%s %f %f %f %f %f %f";
endif
scan_events = repmat(' %f' , [1,num_events]);
scan_string = cstrcat(scan_string,scan_events);
head_string = strrep (scan_string, "f", "s");
head_string = strrep (head_string, "d", "s");


#Assign arrays
for i = 1:10
  
%  if i == 5
%    continue;
%  endif
  filename = [ "/home/vokris/Work/ARMPowerModel/Results/ODROID/Kris/Run_" , num2str(i) ,"/LITTLE_SYS_RAW.data" ];
  fid = fopen (filename, "r");
  var = genvarname( ["next", num2str(i)] );
  
  
    
  if (i == 1)
    data_head=textscan(fid,head_string,1,"delimiter","\t","headerlines",1);
    assignin("base",var,textscan (fid,scan_string,"delimiter","\t"));
    
  else
    assignin("base",var,textscan (fid,scan_string,"delimiter","\t","headerlines",2));
    
  endif;
  
  fclose (fid);
  
  
  data_temp = eval ([ var ]);
    
%    #initialise data_mean to be single column
%  data_mean = cell(1,size(data_temp,2));
%    
%   for j = 2:size(data_mean,2)
%      data_mean{j} = mean(data_temp{j}(:,1),1);
%    endfor;
%  data_mean{1} = data_temp{1}(1);
%  return;
    
  if (i == 1)
    data_store = data_temp;
    data_all = data_temp;    
  else
    data_all{1} = [ data_all{1} ;  data_temp{1} ];
    for j = 2:size(data_temp,2)
      data_store{j} = [data_store{j} , data_temp{j}];
      data_all{j} = [ data_all{j} ;  data_temp{j} ];
    endfor;
  endif
endfor;

#initialise data_mean to be single column
data_mean = cell(1,size(data_temp,2));
for i = 2:size(data_mean,2)
  data_mean{i} = zeros(size(data_temp{size(data_temp,2)},1),1);
endfor; 
  
for i = 1:size(data_mean{size(data_mean,2)},1)
  for j = 2:size(data_mean,2)
    data_mean{j}(i) = mean(data_store{j}(i,:),2);
  endfor;
endfor;
data_mean{1} = data_store{1};
  

#compute standart deviation
%std_dev=TC2_big;
%for i = 2:size(TC2_big,2)
%  std_dev{i} = (std([next1{i},next2{i},next3{i},next4{i},next5{i}],0,2)./TC2_big{j})*100;
%  mean_std_dev(i-1) = mean(std_dev{i});
%endfor;
%mean_std_dev