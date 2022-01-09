load train;
load dit_fd;
mini = table2array(train(:,[14,15,27,21,28]));

%% 选取指定小区编号，指定时间段的数据
cellID = 60564;
start_time = datenum({'2012-09-12 18:00:00'});
end_time = datenum({'2012-10-20 24:00:00'});

base_locat = dit_fd((dit_fd(:,1)==cellID),2:3);  % 假设的基站坐标
minidata = mini(mini(:,4)==cellID & mini(:,5)<end_time & mini(:,5)>=start_time ,:);
latti = [minidata(:,1);base_locat(1);];
longi = [minidata(:,2);base_locat(2);];
rssi_value = [minidata(:,3);-50;];
TT = table(latti,longi,rssi_value);
Traintable = groupsummary(TT,{'latti','longi'},"mean","rssi_value");  % 利用table来平均同一个地理位置的rssi强度

%% 计算每个点与基站的距离与差值，计算损耗系数alpha
minidata = table2array(Traintable(:,[1,2,4]));
[n,~] = size(minidata);
mini_por = zeros(n-1,4);
k = 0;
for i=1:n
    k = k + 1;
    if minidata(i,1:2)~=base_locat
        mini_por(k,1:2)=minidata(i,1:2)-base_locat;
        mini_por(k,4)= -50 - minidata(i,3);
    else
        k = k - 1;
    end
end
mini_por(:,3) = lat2dis(mini_por(:,1:2));   % 经纬度差值转换为距离
alpha = mean(mini_por(:,4) ./ (10*log10(mini_por(:,3))));

%% 计算损耗模型下各点信号强度
LDPL_value = zeros(n,3);
k = 0;
for i=1:n
    k = k + 1;
    LDPL_value(i,1:2)=minidata(i,1:2);
    if minidata(i,1:2)~=base_locat
        LDPL_value(i,3)= -50 - 10*alpha*log10(mini_por(k,3));
    else
        k = k - 1;
        LDPL_value(i,3)=-50;
    end
end

%% 计算均方误差
difference = LDPL_value(:,3) - minidata(:,3);
mse = mean(difference.^2);
