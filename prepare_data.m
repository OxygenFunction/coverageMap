testtable = readtable('6056x_alldata.csv');     % load data set
rssi = table2array(testtable(:,8:12));          % rssi
avg = mean(rssi,2);                             % average rssi
date = table2array(testtable(:,1));             % time
time = datenum(date);
DateVector = datevec(date);                     
month = DateVector(:,2);                        
day = DateVector(:,3);                          
hour = DateVector(:,4);                         
minute = DateVector(:,5);                       

testtable.avg = avg;                            % 加入table
testtable.time = time;
testtable.month = month;
testtable.day = day;
testtable.hour = hour;
testtable.minute = minute;
train = testtable(1:100:end,:);                 % select training datas