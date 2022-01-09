function out = get_cellID(lat,lon)
    lat_min = 35.5011;
    lon_min = 23.9905;

    lat_i = round((lat-lat_min)*10000)+1;
    lon_j = round((lon-lon_min)*10000)+1;
    out = [lat_i,lon_j];
end




