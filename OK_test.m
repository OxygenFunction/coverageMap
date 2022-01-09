load train;
mini = table2array(train(:,[14,15,27,21,28]));

%% 选取指定小区编号，指定时间段的数据
cellID = 60561;
start_time = datenum({'2012-09-12 18:00:00'});
end_time = datenum({'2012-09-12 24:00:00'});

minidata = mini(mini(:,4)==cellID & mini(:,5)<end_time & mini(:,5)>=start_time ,:);
latti = minidata(:,1);
longi = minidata(:,2);
rssi_value = minidata(:,3);
TT = table(latti,longi,rssi_value);
Traintable = groupsummary(TT,{'latti','longi'},"mean","rssi_value");  % 利用table来平均同一个地理位置的rssi强度

%% 计算两两之间经纬度差值与半方差
minidata = table2array(Traintable(:,[1,2,4]));
[n,~] = size(minidata);
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

% [xData, yData] = prepareCurveData( xx, yy );
% f_fit = fittype('c*(1-exp(-h/a))','independent','h','coefficients',{'c','a'});
% opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
% opts.Display = 'Off';
% opts.StartPoint = [35 2];
% [fitresult, gof] = fit( xData, yData, f_fit, opts );

[fitmodel, gof] = semivariogram_Fit(dis,value);

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
result = zeros(n,1);
for i = 1:n
    latti_0 = minidata(i,1);
    longi_0 = minidata(i,2);
    latti_d = minidata(:,1) - latti_0;
    longi_d = minidata(:,2) - longi_0;
    dll_0 = [latti_d,longi_d];
    diff(1:n) = lat2dis(dll_0);                     % 计算diff
    lamda = coff_mat\diff;
    result(i) = sum(lamda(1:n).*minidata(:,3));
end
OK_value = [minidata(:,1:2),result];
difference = result - minidata(:,3);
rmse = sqrt(mean(difference.^2));
