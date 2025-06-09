function [Mo, R1o, sse] = measureMoR1o_fast_VTR(signal, repTime, FA, doPlot, varargin)
%--------------------------------------------------------------------------
% FUNCTION: measureMoR1o_fast_VTR
%
%    measureMoR1o_fast_VTR
%    ├── Inputs:
%    │   ├── signal      (measured MRI signals)
%    │   ├── repTime     (repetition times TR)
%    │   ├── FA          (flip angles in degrees)
%    │   ├── doPlot      (flag to plot results)
%    │   └── varargin    (optional: repitition count)
%    │
%    ├── External Functions:
%    │   ├── lsqcurvefit      [Toolbox OR custom version required]
%    │   ├── optimset         [Optional: For optimization settings]
%    │
%    ├── Internal/Nested Functions:
%    │   ├── T1_Cal(x, repTime, FA)
%    │   │   └── Computes the SPGR/VFA signal model:
%    │   │       S = Mo * sin(FA) * (1 - exp(-TR*R1o)) / (1 - cos(FA)*exp(-TR*R1o))
%    │   │
%    │   └── plotFittingResult(repTime, signal, FA, Mo, R1o)
%    │       └── Plots measured signal vs fitted signal
%    │
%    ├── Internal Variables and Logic:
%    │   ├── Initial Guess Generator (randomized Mo and R1o)
%    │   ├── Multiple fitting attempts (loop over repitition)
%    │   ├── Error handling for bad fits (NaN/Inf protection)
%    │   ├── Best-fit selection using min(SSE)
%    │   └── Optional visualization if doPlot is true
%    │
%    └── Output:
%        ├── Mo       (estimated magnetization)
%        ├── R1o      (estimated relaxation rate)
%        └── sse      (sum of squared error of fit)
%
% PURPOSE:
%   Estimates equilibrium magnetization (Mo) and longitudinal relaxation
%   rate (R1o = 1/T1o) from variable flip angle (VFA) spoiled gradient echo
%   MRI signals using nonlinear curve fitting.
%
%   It fits the VFA signal model:
%       S(TR) = Mo * sin(FA) * (1 - exp(-TR*R1o)) / (1 - cos(FA)*exp(-TR*R1o))
%
%   The function uses multiple initial guesses to avoid convergence to
%   local minima and returns the solution with the lowest fitting error.
%
% INPUTS:
%   signal   - Vector of measured MRI signal intensities at different TRs.
%   repTime  - Vector of repetition times (TRs) in seconds.
%   FA       - Vector of flip angles (in degrees) corresponding to each TR.
%
% OUTPUTS:
%   Mo       - Estimated equilibrium longitudinal magnetization.
%   R1o      - Estimated longitudinal relaxation rate (R1o = 1 / T1o).
%   sse      - Sum of squared errors for the best-fit model.
%
% NOTE:
%   - Depends on (`lsqcurvefit`).
%   - A local lsqcurvefit function is also provided
%   - Internal helper function `T1_Cal` models the VFA signal equation.
%
% AUTHOR: Dr. Tanuj Puri
% DATE:   01/2014, updated 06/2025
% WARNING: This code is untested and may not be suitable for clinical use.
%
%--------------------------------------------------------------------------

  %------------------------- INPUT VALIDATION -------------------------------
  % Input for repitition variable
  if ~isempty(varargin) && isnumeric(varargin{1}) && isscalar(varargin{1})
     repitition = max(2, round(varargin{1}));
  else
     repitition = 2;
  end

  if nargin < 4
     doPlot = false;
  end

  if nargin < 3
      error('measureMoR1o_fast_VTR:NotEnoughInputs', ...
            'Function requires 3 inputs: signal, repTime, and FA.');
  end

  % Ensure column vectors
  signal   = signal(:);
  repTime  = repTime(:);
  FA       = FA(:);

  % Check size consistency
  N = numel(signal);
  if numel(repTime) ~= N || numel(FA) ~= N
      error('measureMoR1o_fast_VTR:InputSizeMismatch', ...
            'All inputs (signal, repTime, FA) must be vectors of equal length.');
  end

  % Check for finite numeric input
  if ~isnumeric(signal) || ~isnumeric(repTime) || ~isnumeric(FA) || ...
     any(~isfinite(signal)) || any(~isfinite(repTime)) || any(~isfinite(FA))
      error('measureMoR1o_fast_VTR:InvalidInputValues', ...
            'Inputs must be finite numeric vectors.');
  end

  % Initial guess for Mo and T1o (sec). These are scaled later per trial.
  mo_  = 5000;   % Initial guess for Mo
  t1o_ = 1.30;   % Initial guess for T1o (in seconds)

  % Initialize storage for sum of squared errors (SSE) for each repetition
  sse_ = Inf(1, repitition);

  % Initialize storage for estimated parameters [Mo; R1o] for each trial
  ahat = zeros(2, repitition);

  %-----------------------------------------------------------------------
  % Optimization settings for lsqcurvefit:
  % Depends on (`lsqcurvefit`) if the toolbox is available,
  % Otherwise uses local/custom implementation is available.
  %-----------------------------------------------------------------------
  if exist('lsqcurvefit', 'file') ~= 2
     warning('lsqcurvefit not found. Ensure a compatible local implementation is available.');
  end

  if exist('optimset', 'file') == 2
      options = optimset('Display','off','TolFun',1e-6,'TolX',1e-6,'MaxIter',500);
  else
      % Fallback for Octave / minimal setup
      options = struct();
      options.Display = 'off'; % Suppress verbose output in local lsqcurvefit
  end

  % Fit model multiple times with varied initial guesses
  for repIdx = 1:repitition
      % Create varying initial guesses for [Mo, R1o] by scaling

      % x0 = [mo_ * repIdx, 1 / (t1o_ * repIdx)];
      % Above is a bad guess. function won't work without a good initail guess

      % New better guess
      Mo_guess       = 10*max(signal) * (0.9 + 0.2 * rand);
      R1o_guess      = (1 / 1.2) * (0.9 + 0.2 * rand);
      Mo_guess       = max(Mo_guess, 1);     % prevent near-zero
      R1o_guess      = max(R1o_guess, 0.01); % prevent divide-by-zero or zero exponent
      x0s(repIdx, :) = [Mo_guess, R1o_guess];

      fprintf('Rep %d init guess: Mo_guess=%.1f, R1o_guess=%.4f\n', repIdx, Mo_guess, R1o_guess);

      % Fit the VFA signal model using nonlinear least squares
      try
          [ahat(:,repIdx), sse_(repIdx)] = lsqcurvefit( ...
          @(x, xdata) T1_Cal(x, repTime, FA), ...   % Function to fit
          x0s(repIdx, :), ...                       % Initial guess
          repTime, ...                              % xdata: repetition times
          signal, ...                               % ydata: measured signals
          [], [], options);                         % No lower/upper bounds
      catch ME
          warning('Fitting attempt %d failed: %s', repIdx, ME.message);
          ahat(:,repIdx) = [NaN; NaN];
          sse_(repIdx) = Inf;
      end
  end

  %----------------------------------------------------------
  % Check if all fitting attempts resulted in non-finite SSE
  % (e.g., due to convergence failure or invalid outputs).
  % If so, return NaNs for Mo, R1o, and sse to signal failure.
  %----------------------------------------------------------
  if all(~isfinite(sse_))
      warning('All fitting attempts failed. Returning NaNs.');
      Mo = NaN;        % Return NaN for Mo since no valid fit
      R1o = NaN;       % Return NaN for R1o since no valid fit
      sse = NaN;       % Return NaN for SSE
      return;          % Exit the function early
  end

  %----------------------------------------------------------
  % Identify which fitting attempts yielded finite SSE values
  % (i.e., successful fits that didn't return Inf or NaN)
  %----------------------------------------------------------
  valid = isfinite(sse_);  % Logical array: true where SSE is a valid number

  %----------------------------------------------------------
  % If none of the attempts produced a valid fit, exit early
  % This is a fallback safety check to prevent using bad results
  %----------------------------------------------------------
  if ~any(valid)
      warning('All fitting attempts failed. Returning NaNs.');
      Mo = NaN;        % No valid estimate for Mo
      R1o = NaN;       % No valid estimate for R1o
      sse = NaN;       % No valid sum of squared errors
      return;          % Exit function early
  end

  % Select parameters that resulted in lowest sum of squared errors
  [~, bestIdx] = min(sse_(valid));
  validIdx = find(valid);
  Mo = ahat(1, validIdx(bestIdx));
  R1o = ahat(2, validIdx(bestIdx));
  sse = sse_(validIdx(bestIdx));

  %----------------------------------------------------------
  % Ensure the selected Mo and R1o values are valid
  % This protects against numerical issues like:
  % - division by zero
  % - non-converging fits that result in NaN or Inf
  %----------------------------------------------------------
  if ~isfinite(Mo) || ~isfinite(R1o)
      warning('Fitting did not converge. Returning NaNs.');

      % Set outputs to NaN to indicate failure
      Mo  = NaN;  % Invalid or undefined Mo
      R1o = NaN;  % Invalid or undefined R1o
      sse = NaN;  % No meaningful fit quality (SSE)
  end


  % Plot the result is doPlot is true
  if doPlot
     fprintf('Best fit: Mo = %.2f, R1o = %.4f (T1 = %.3f s), SSE = %.2e\n', ...
            Mo, R1o, 1/R1o, sse);
     plotFittingResult(repTime, signal, FA, Mo, R1o);
  end

  %--------------------------------------------------------------------------
  % Nested helper function: T1_Cal
  %
  % PURPOSE:
  %   Computes the theoretical VFA signal based on parameters [Mo, R1o],
  %   repetition time (xdata), and flip angles (FA).
  %
  % INPUTS:
  %   k     - 2-element vector: [Mo, R1o]
  %   xdata - Vector of repetition times (TR)
  %   FA    - Vector of flip angles in degrees
  %
  % OUTPUT:
  %   F     - Predicted signal values corresponding to xdata
  %--------------------------------------------------------------------------
  function F = T1_Cal(k, xdata, FA)
      % Apply the SPGR/VFA signal equation:
      %   S(TR) = Mo * sin(FA) * (1 - exp(-TR*R1o)) / (1 - cos(FA)*exp(-TR*R1o))
      Mo_  = k(1);
      R1o_ = k(2);
      E1   = exp(-xdata .* R1o_);
      F    = Mo_ * sin(FA * pi / 180) .* (1 - E1) ./ (1 - cos(FA * pi / 180) .* E1);
  end % end of T1_Cal

  %--------------------------------------------------------------------------
  % FUNCTION: plotFittingResult
  %
  % Plots the measured SPGR signal vs. the fitted signal based on estimated Mo and R1o.
  %--------------------------------------------------------------------------
  function plotFittingResult(repTime, signal, FA, Mo, R1o)

    if ~isfinite(Mo) || ~isfinite(R1o)
        warning('Cannot plot fit: invalid Mo or R1o.');
        return;
    end

    % Generate fitted signal for comparison
    fitSignal = Mo * sin(FA * pi / 180) .* ...
                (1 - exp(-repTime .* R1o)) ./ ...
                (1 - cos(FA * pi / 180) .* exp(-repTime .* R1o));

    figure;
    plot(repTime, signal, 'ro', 'MarkerSize', 8, 'DisplayName', 'Measured'); hold on;
    plot(repTime, fitSignal, 'b-', 'LineWidth', 2, 'DisplayName', 'Fitted');
    xlabel('Repetition Time (TR) [s]');
    ylabel('Signal Intensity');
    title('SPGR Signal Fitting');
    legend('Location', 'northeast');
    grid on;
  end % end of plotFittingResult

end % end of measureMoR1o_fast_VTR
