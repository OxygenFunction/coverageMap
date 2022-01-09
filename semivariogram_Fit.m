function [fitresult, gof] = semivariogram_Fit(xx, yy)
%% Fit: 'semivariogram fit'.
[xData, yData] = prepareCurveData( xx, yy );

% Set up fittype and options.
ft = fittype( 'c*(1-exp(-x/a))', 'independent', 'x', 'dependent', 'y' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.StartPoint = [0.392227019534168 0.655477890177557];

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );

% % Plot fit with data.
% figure( 'Name', 'semivariogram fit' );
% h = plot( fitresult, xData, yData );
% legend( h, 'yy vs. xx', 'semivariogram fit', 'Location', 'NorthEast', 'Interpreter', 'none' );
% % Label axes
% xlabel( 'xx', 'Interpreter', 'none' );
% ylabel( 'yy', 'Interpreter', 'none' );
% grid on


