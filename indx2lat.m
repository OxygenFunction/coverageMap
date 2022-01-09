function out = indx2lat(i,j)
    lat_min = 35.5011;
    lon_min = 23.9905;
    lat = (10000*lat_min + i -1) /10000;
    lon = (10000*lon_min + j -1) /10000;
    out = [lat,lon];
end