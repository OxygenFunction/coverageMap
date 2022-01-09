testtable_all = readtable('6056x_alldata.csv');     % 读取数据集
test_size = 445420;                               % 测试数据量
testtable = testtable_all(1:test_size,:); 

%% 去除信号强度异常值
rssi = table2array(testtable(:,8:12));          % 5列rssi数值
invalid_index = zeros(test_size,1);
for i = 1:test_size                             % 查找信号强度异常值
    flag = 0;
    for j = 1:5
        if rssi(i,j) > -30
            flag = 1;
        end
    end
    if flag == 1
        invalid_index(i) = 1;
    end
end
avg = mean(rssi,2);                             % 平均
date = table2array(testtable(:,1));             % 日期与时间
time = datenum(date);

testtable.avg = avg;                            % 加入table
testtable.time = time;
testtable(invalid_index == 1,:) = [];           % 去除异常值
train = testtable;   
save train.mat train;

%% 建立位置与小区编号的关系
minidata = table2array(train(:,[14,15,21]));
latti = minidata(:,1);
longi = minidata(:,2);
rssi_value = minidata(:,3);
TT = table(latti,longi,rssi_value);
Traintable = groupsummary(TT,{'latti','longi'},"mean","rssi_value");  
ID_mat = table2array(Traintable(:,[1,2,4]));
ID_mat(:,3) = round(ID_mat(:,3));
save ID_mat.mat ID_mat;

lat_min = 35.5011;
lat_max = 35.5312;
lon_min = 23.9905;
lon_max = 24.0788;
ID_dict = zeros(302,884);
i = 0;
for lat = lat_min:0.0001:lat_max
    j = 0;
    i = i + 1;
    for lon = lon_min:0.0001:lon_max
        j = j + 1;
        diff = [ID_mat(:,1)-lat, ID_mat(:,2)-lon];
        dis = lat2dis(diff);
        [~,indx] = min(dis);
        ID_dict(i,j) = ID_mat(indx,3);
    end
end

save ID_dict.mat ID_dict;

%% 寻找潜在基站点
mini = table2array(train(:,[14,15,27,21,28]));
pts_base = mini(mini(:,3)>-55,:);               % 信号强度大，可能是基站
latti_pts = pts_base(:,1);                      % 取出可能是基站点的经纬度和rssi
longi_pts = pts_base(:,2);
rssi_value_pts = pts_base(:,3);
pts_Table = table(latti_pts,longi_pts,rssi_value_pts);
pts_Table_s = groupsummary(pts_Table,{'latti_pts','longi_pts'},"mean","rssi_value_pts");  % 平均同一个地理位置的rssi强度
pts = table2array(pts_Table_s(:,[1,2,4]));

%% 处理潜在基站点
total = length(pts);
avger = zeros(total,1);             % 潜在基站点平均rssi
cellidd = zeros(total,1);           % 潜在基站点小区id
score = zeros(total,1);             % 基站点可信度
lamda = 0.1;
for i = 1:total                     % 取出潜在基站点所有数据，并计算平均rssi，记录小区id（假设一个小区只有一个基站）
    pts_test = mini(mini(:,1)==pts(i,1) & mini(:,2)==pts(i,2),:);
    avger(i) = mean(pts_test(:,3));
    cellidd(i) = pts_test(1,4);
    score(i) = avger(i) + lamda*size(pts_test,1); 
    if size(pts_test,1)<3           % 数据量过小，扣分
        score(i) = score(i)-20;
    end
end

%% 确定基站位置
dit_fd = zeros(8,3);
i = 1;
for target_id = 60561:60565
    [ms,indx] = max(score(cellidd==target_id));
    base_ll = pts(score==ms & cellidd==target_id,1:2);
    dit_fd(i,:) = [target_id,base_ll];
    i = i + 1;
end
save dit_fd.mat dit_fd;
