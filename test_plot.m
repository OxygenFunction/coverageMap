%% predict
yfit = trainedModel36_4.predictFcn(testtable);
rmse = sqrt(sum((yfit(1:445419)-avg(1:445419)).^2)/(length(avg)-1)); 

%% 缺少转成302*884矩阵的步骤

%% plot
mat = exp(learn_cover/10);
imagesc(mat);