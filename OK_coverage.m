function out = OK_coverage(date)

load train.mat train;
load ID_dict.mat ID_dict;
mini = table2array(train(:,[14,15,27,21,28]));
coverage_map = zeros(302,884);

%% 选取指定小区编号，指定时间段的数据
for cellID = 60561:60565
    start_time = datenum(date);
    end_time = datenum(date);
    n = 0;
    
    while n < 30
        start_time = start_time - 1;
        end_time = end_time + 1;
        minidata = mini(mini(:,4)==cellID & mini(:,5)<end_time & mini(:,5)>=start_time ,:);
        latti = minidata(:,1);
        longi = minidata(:,2);
        rssi_value = minidata(:,3);
        TT = table(latti,longi,rssi_value);
        Traintable = groupsummary(TT,{'latti','longi'},"mean","rssi_value");  % 利用table来平均同一个地理位置的rssi强度
        minidata = table2array(Traintable(:,[1,2,4]));
        [n,~] = size(minidata);
    end
    
    mini_por = zeros(n*(n-1)/2,4);
    k=0;
    for i = 1:n
        for j = i+1:n
            k = k+1;
            mini_por(k,1:2) = minidata(i,1:2)-minidata(j,1:2);
            mini_por(k,4) = 0.5 * (minidata(i,3)-minidata(j,3))^2;
        end
    end
    
    %% 得到距离-半方差关系
    mini_por(:,3) = lat2dis(mini_por(:,1:2));   % 经纬度差值转换为距离
    dis = mini_por(:,3);
    value = mini_por(:,4);
    
    [fitmodel, ~] = semivariogram_Fit(dis,value);
    
    %% 计算插值所用到的矩阵
    diff = ones(n+1,1);                             % 当前点与参考点距离差向量
    dis_mat = zeros(n,n);                           % 参考点两两距离差矩阵
    coff_mat = ones(n+1,n+1);                       % 参考点半方差函数矩阵
    coff_mat(n+1,n+1) = 0;
    k = 0;
    for i = 1:n-1                                   % 计算dis_mat
        for j = i+1:n
            k = k + 1;
            dis_mat(i,j) = dis(k);
            dis_mat(j,i) = dis(k);
        end
    end
    for k = 1:n
        coff_mat(1:n,k) = fitmodel(dis_mat(:,k));   % 计算coff_mat
    end
    
    %% 对每个点插值，计算误差
    cell = ID_dict == cellID;
    for i = 1:302
        for j = 1:884
            if cell(i,j)
                dll_0 = indx2lat(i,j);
                dll_d = [minidata(:,1) - dll_0(1), minidata(:,2) - dll_0(2)];
                diff(1:n) = lat2dis(dll_d);                     % 计算diff
                lamda = coff_mat\diff;
                coverage_map(i,j)=sum(lamda(1:n).*minidata(:,3));
            end
        end
    end

end

out = coverage_map;

end
