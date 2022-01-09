function out = LDPL_coverage(date)


load train.mat train;
load dit_fd.mat dit_fd;
load ID_dict.mat ID_dict;
mini = table2array(train(:,[14,15,27,21,28]));
coverage_map = zeros(302,884);

%% 选取指定小区编号，指定时间段的数据
for cellID = 60561:60565
    start_time = datenum(date);
    end_time = datenum(date);
    n = 0;
    base_locat = dit_fd((dit_fd(:,1)==cellID),2:3);  % 假设的基站坐标
    
    while n < 60
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
    
 
    
    %% 对每个点插值，计算误差
    cell = ID_dict == cellID;
    for i = 1:302
        for j = 1:884
            if cell(i,j)
                dll_0 = indx2lat(i,j);
                dist = lat2dis(dll_0 - base_locat);
                if dist~=0
                    coverage_map(i,j)=-50 - 10*alpha*log10(dist);
                else
                    coverage_map(i,j)=-50;
                end
            end
        end
    end

end

out = coverage_map;


end