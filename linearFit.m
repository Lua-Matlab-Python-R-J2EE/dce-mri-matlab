function [slope, intercept, yfit, R_squared] = linearFit(xVal, yVal)
% LINEARFIT Performs a robust linear regression on two numeric vectors.
%
%   [slope, intercept, yfit, R_squared] = linearFit(xVal, yVal)
%
%   Inputs:
%       xVal - 1D numeric vector of independent variable (x)
%       yVal - 1D numeric vector of dependent variable (y)
%
%   Outputs:
%       slope      - Slope of the best-fit line
%       intercept  - Intercept of the best-fit line
%       yfit       - Fitted y-values using the regression line
%       R_squared  - Coefficient of determination
%
%   Example:
%       [m, b, yfit, R2] = linearFit( 1:5, [2 4 5 4 5] )
%
%   Author: Dr. Tanuj Puri 
%   Date: 01/2014, updated 2025
%   Disclaimer: Untested code so use with caution at your own risk.
%
%% --- Input Validation ---
  if nargin ~= 2
      error('Function requires exactly two input arguments: xVal and yVal.');
  end
  
  if ~isnumeric(xVal) || ~isnumeric(yVal)
      error('Both inputs must be numeric vectors.');
  end
  
  if ~isvector(xVal) || ~isvector(yVal)
      error('Inputs must be 1D vectors.');
  end
  
  if length(xVal) ~= length(yVal)
      error('The length of xVal and yVal must be the same.');
  end
  
  if any(~isfinite(xVal)) || any(~isfinite(yVal))
      error('Inputs must not contain NaN or Inf values.');
  end
  
  % Convert to column vectors
  x = xVal(:);
  y = yVal(:);
  
  %% --- Linear Fit ---
  p = polyfit(x, y, 1);
  slope = p(1);
  intercept = p(2);
  yfit = polyval(p, x);
  
  %% --- Goodness of Fit (R²) ---
  residuals = y - yfit;
  SSresid = sum(residuals.^2);
  SStotal = (length(y)-1) * var(y);
  R_squared = 1 - (SSresid / SStotal);
  
  %% --- Optional Display ---
  fprintf('Linear Fit: y = %.4f * X + %.4f\n', slope, intercept);
  fprintf('R-squared: %.4f\n', R_squared);

end
