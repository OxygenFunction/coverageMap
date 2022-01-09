### get_cellID.m

Convert the latitude and longitude coordinates into a function of the corresponding cell ID

Input: (latitude, longitude)

Output: cellID



### indx2lat.m

Convert matrix coordinates to a function of the corresponding latitude and longitude

Input: (i, j)

Output:(latitude, longitude)



### init.m

Script of doing a series of preprocessing including reading data sets, removing outliers, looking for base stations and so on.

Data set is available from [mySignals](http://www.mysignals.gr/research.php).



### lat2dis.m

Convert the difference in latitude and longitude as a function of distance

Input: (delta_latitude, delta_longitude)

Output: distance



### LDPL_coverage.m / OK_coverage.m / OKD_coverage.m

Functions of different methods that calculates the signal strength at each point in the current region at a specific point in time

Input: (time)

Output:  a matrix of RSS



### LDPL_test.m / OK_test.m / OKD_test.m

Scripts that test different methods.



### predict.m

Script that call the prediction functions above. (LDPL_coverage.m / OK_coverage.m / OKD_coverage.m)



### semivariogram_Fit.m

A function that fits a curve of a semi-variance function

Input: (distance, semi-variance)

Output: fit_result

