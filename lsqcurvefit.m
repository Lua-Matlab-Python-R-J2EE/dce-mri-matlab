function [x, resnorm, residual] = lsqcurvefit(fun, x0, xdata, ydata, lb, ub, options)
%
% DISCLAIMER: This function was not authored by me; it was taken from another
%             source and is used as-is without modifications or testing.
%
% LSQCURVEFIT - Nonlinear curve fitting via least-squares.
%
% Syntax:
%   x = lsqcurvefit(fun, x0, xdata, ydata)
%   x = lsqcurvefit(fun, x0, xdata, ydata, lb, ub)
%   x = lsqcurvefit(fun, x0, xdata, ydata, lb, ub, options)
%
% Inputs:
%   fun    - Function handle, model function of form y = fun(x, xdata)
%   x0     - Initial guess (vector)
%   xdata  - Independent data
%   ydata  - Dependent data (to fit)
%   lb     - Lower bounds (optional)
%   ub     - Upper bounds (optional)
%   options - Optim options struct (optional)
%
% Outputs:
%   x         - Fitted parameters
%   resnorm   - Residual norm (sum of squared errors)
%   residual  - Residuals (fun(x, xdata) - ydata)

  % --------- Input Checks ---------
  if nargin < 6 || isempty(ub)
    ub = inf * ones(size(x0));
  end
  if nargin < 5 || isempty(lb)
    lb = -inf * ones(size(x0));
  end
  if nargin < 7
    options = optimset();  % Use default options
  end

  % Check for NaNs
  if any(isnan([x0(:); xdata(:); ydata(:)]))
    error("lsqcurvefit: Input contains NaN values");
  end

  % Test output size
  test_output = fun(x0, xdata);
  if ~isequal(size(test_output), size(ydata))
    error("Output of fun(x, xdata) must match size of ydata");
  end

  % Objective function: sum of squared residuals
  objfun = @(x) sum((fun(x, xdata) - ydata).^2);

  % --------- Solver Selection ---------
  use_bounds = any(isfinite(lb)) || any(isfinite(ub));
  have_fminunc = exist('fminunc', 'file') == 2;

  if use_bounds
    fprintf("Using fminsearch with bounds workaround...\n");

    % Bounds transformation
    %transform = @(z) lb + (ub - lb) .* (sin(z) + 1)/2;  % Map R → [lb, ub]
    %revtransform = @(x) asin(2 * (x - lb)./(ub - lb) - 1);  % Approx inverse

    transform = @(z) lb + (ub - lb) .* (tanh(z) + 1)/2;  % tanh: safer, bounded
    revtransform = @(x) atanh(2 * (x - lb)./(ub - lb) - 1);  % safer inverse

    [zopt, resnorm] = fminsearch(@(z) objfun(transform(z)), revtransform(x0), options);
    x = transform(zopt);
    x = real(transform(zopt));           % strip imaginary part
    x = min(max(x, lb), ub);            % strictly clamp to bounds

  else
    if have_fminunc
      fprintf("Using fminunc (no bounds enforced)...\n");
      [x, resnorm] = fminunc(objfun, x0, options);
    else
      fprintf("Using fminsearch (no bounds enforced)...\n");
      [x, resnorm] = fminsearch(objfun, x0, options);
    end
  end

  residual = fun(x, xdata) - ydata;
end
