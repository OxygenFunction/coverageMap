load ID_dict;
load train;
load model;
latt = zeros(302*884,3);
k= 0;
for i=1:302
    for j=1:884
        k = k + 1;
        d = indx2lat(i,j);
        latt(k,1) = d(1);
        latt(k,2) = d(2);
        latt(k,3) = ID_dict(i,j);
    end
end

latitude = latt(:,1);
longitude = latt(:,2);
cellID = latt(:,3);
time = table2array(train(1:302*884,[28]));

TT = table(latitude,longitude,cellID,time);
yy = trainedModel.predictFcn(TT);

learn_cover = zeros(302,884);
k= 0;
for i=1:302
    for j=1:884
        k = k + 1;
        learn_cover(i,j) = yy(k);
    end
end