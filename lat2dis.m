function out = lat2dis(dll)
    out = sqrt((100000*dll(:,1)).^2 + (111320*dll(:,2)).^2); 
end