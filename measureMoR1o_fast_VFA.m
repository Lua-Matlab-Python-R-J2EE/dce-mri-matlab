function [Mo, R1o, sse] = measureMoR1o_fast_VFA(signal, alpha, TR, doPlot, varargin)
%--------------------------------------------------------------------------
% FUNCTION: measureMoR1o_fast_VFA
% Estimates Mo and R1o from SPGR/VFA MRI signal using nonlinear least squares.
%
%    measureMoR1o_fast_VFA
%    ├── Inputs:
%    │   ├── signal      (Vector of measured MRI signal intensities)
%    │   ├── alpha       (Vector of flip angles in degrees)
%    │   ├── TR          (single repetition time in seconds)
%    │   ├── doPlot      (optional: flag to plot results)
%    │   └── varargin    (optional: repetition count for optimization attempts)
%    │
%    ├── Dependencies:
%    │   └── lsqcurvefit (Optimization Toolbox or local version)
%    │
%    ├── Internal Functions:
%    │   └── T1_Cal       (SPGR/VFA signal model)
%    │   └── plotFittingResult (visualizes the fit)
%    │
%    ├── Optimization:
%    │   ├── Multiple fitting attempts to avoid local minima
%    │   └── Robust initial guesses
%    │
%    └── Output:
%        ├── Mo          (estimated equilibrium magnetization)
%        ├── R1o         (estimated longitudinal relaxation rate)
%        └── sse         (sum of squared errors for best fit)
%
%
% PURPOSE:
%   Estimates equilibrium magnetization (Mo) and longitudinal relaxation
%   rate (R1o = 1/T1o) from Spoiled Gradient Recalled Echo (SPGR) signals acquired
%   at variable flip angles (VFA) using nonlinear curve fitting.
%
%   In this method, the repetition time (TR) is held constant while the
%   flip angle (α) is varied. The resulting steady-state signals
%   are fit to the SPGR signal equation to estimate Mo and R1o.
%
%   It fits the VFA signal model:
%       S(α) = Mo * sin(α) * (1 - exp(-TR*R1o)) / (1 - cos(α)*exp(-TR*R1o))
%   or
%       S(FA) = Mo × sin(FA) × (1 - exp(-TR × R1)) / (1 - cos(FA) × exp(-TR × R1)),
%
%   where S(α) is the measured signal at a given flip angle,
%         Mo is the equilibrium magnetization,
%         TR is the fixed repetition time (in seconds),
%         α (or FA) is the variable flip angle (in radians or degrees), and
%         R1 is the longitudinal relaxation rate (R1 = 1/T1).
%
%   This model assumes perfect spoiling, steady-state conditions, and no transverse
%   relaxation effects. In VFA-based T1 mapping, multiple signals are acquired at
%   different flip angles, and this equation is fit to the data to estimate Mo and T1 (via R1).
%
% NOTE:
%   - Depends on (`lsqcurvefit`).
%   - A local lsqcurvefit function is also provided.
%   - Internal helper function `T1_Cal` models the VFA signal equation.
%   - The function uses multiple initial guesses to avoid convergence to
%     local minima and returns the solution with the lowest fitting error.
%   - WATER:  mo_=5000; t1o_=3.92;
%   - LUNG:   mo_=5000; t1o_=1.30;
%   - KIDNEY: mo_=50;   t1o_=1.50;
%
%--------------------------------------------------------------------------
% AUTHOR:  Dr. Tanuj Puri
% DATE:    01/2014, updated 06/2025
% WARNING: For research use only. Not tested for clinical reliability.
%--------------------------------------------------------------------------

  %----------------------------- INPUT CHECKS ------------------------------
  % Ensure the function has at least the minimum required inputs:
  % signal, alpha and TR
  if nargin < 3
      error('Function requires at least 3 inputs: signal, alpha, and TR.');
  end

  % Check if the optional 'doPlot' argument is provided and not empty;
  % Otherwise, set default to false (no plotting)
  if nargin < 4 || isempty(doPlot)
      doPlot = false;
  end

  % Handle optional repetition argument from varargin:
  % If a numeric scalar is provided, use it for 'repetition' (minimum 2),
  % otherwise default to 3 attempts for fitting iterations.
  if ~isempty(varargin) && isnumeric(varargin{1}) && isscalar(varargin{1})
      repetition = max(2, round(varargin{1}));
  else
      repetition = 3;
  end

  %-------------------------- VECTOR FORMATTING ----------------------------
  % Ensure both signal and alpha inputs are column vectors to avoid dimension errors
  signal = signal(:);
  alpha  = alpha(:);

  % Verify that signal and alpha have the same number of elements;
  % otherwise fitting will be impossible due to mismatch
  if numel(signal) ~= numel(alpha)
      error('Signal and flip angle vectors must have equal length.');
  end

  %------------------ VALIDATE NUMERIC AND FINITE INPUTS -------------------
  % Check that signal, alpha, and TR inputs are numeric and contain finite values
  % to prevent errors from NaNs, Infs, or non-numeric data types during calculations.
  if ~isnumeric(signal) || ~isnumeric(alpha) || ~isnumeric(TR) || ...
     any(~isfinite(signal)) || any(~isfinite(alpha)) || ~isfinite(TR)
      error('measureMoR1o_fast_VFA:InvalidInputValues', ...
            'Inputs must be finite numeric vectors/scalars.');
  end

  %------------------- CHECK FOR LSQCURVEFIT FUNCTION & OPTIONS --------------
  % Confirm if Optimization Toolbox function 'lsqcurvefit' is available.
  % If not found, warn user to ensure a compatible alternative is accessible.
  if exist('lsqcurvefit', 'file') ~= 2
      warning('lsqcurvefit not found. Ensure a compatible local implementation is available.');
  end

  % Set optimization options for lsqcurvefit or fallback: If 'optimset' exists,
  % use it to specify convergence tolerances and suppress output.
  % Otherwise, create a minimal options struct with display turned off.
  if exist('optimset', 'file') == 2
      options = optimset('Display','off','TolFun',1e-6,'TolX',1e-6,'MaxIter',500);
  else
      options = struct();
      options.Display = 'off';  % suppress output in custom lsqcurvefit fallback
  end

  %------------------------ INITIALIZE RESULT ARRAYS ------------------------
  % Preallocate matrices for storing fitted parameters and sum of squared errors
  % (SSE) for each fitting attempt.
  ahat = zeros(2, repetition);% each column will store [Mo; R1o] for one attempt
  sse_ = NaN(1, repetition);  % initialize SSE array with NaNs to track failed attempts

  %---------------------- FITTING ATTEMPTS LOOP ----------------------------
  % This loop performs multiple iterations of curve fitting to estimate the parameters
  % Mo and R1o, aiming to avoid local minima and enhance robustness. For each attempt,
  % it begins by printing the current attempt number along with initial guesses for
  % Mo and R1o. The initial guess for Mo is scaled based on the maximum measured signal,
  % typically multiplied by 10 (to be close as to the true parameter value),
  % while R1o is initially set to 1.0, corresponding
  % approximately to a 1-second T1 relaxation time. These guesses are combined into a
  % vector x0, which is then used in the lsqcurvefit function to fit the VFA signal
  % model (T1_Cal) to the measured data. The fitted parameters are stored in the matrix
  % ahat for each attempt, and the sum of squared errors (sse_) is computed to assess
  % the quality of the fit. Throughout this process, error handling is implemented to
  % catch any issues during fitting: if an error occurs, a warning is printed indicating
  % the attempt number and the error message, and NaN is assigned to both the parameters
  % and SSE for that attempt. This iterative approach helps improve the robustness and
  % reliability of the parameter estimation.

  % Fit model multiple times with varied initial guesses
  for repIdx = 1:repetition
      % Create varying initial guesses for [Mo, R1o] by scaling

      % x0 = [mo_ * repIdx, 1 / (t1o_ * repIdx)];
      % Above is a bad guess. function won't work without a good initail guess

      % New better guess: V.IMPORTANT
      Mo_guess       = 5*max(signal) * (0.9 + 0.2 * rand);
      R1o_guess      = (1 / 1.2) * (0.9 + 0.2 * rand);
      Mo_guess       = max(Mo_guess, 1);     % prevent near-zero
      R1o_guess      = max(R1o_guess, 0.01); % prevent divide-by-zero or zero exponent
      x0s(repIdx, :) = [Mo_guess, R1o_guess];

      fprintf('Rep %d init guess: Mo_guess=%.1f, R1o_guess=%.4f\n', repIdx, Mo_guess, R1o_guess);

      % Fit the VFA signal model using nonlinear least squares
      try
          [ahat(:,repIdx), sse_(repIdx)] = lsqcurvefit( ...
          @(x, xdata) T1_Cal(x, xdata, TR), ...     % Function to fit
          x0s(repIdx, :), ...                       % Initial guess
          alpha, ...                                % xdata: flip angles
          signal, ...                               % ydata: measured signals
          [], [], options);                         % No lower/upper bounds
      catch ME
          warning('Fitting attempt %d failed: %s', repIdx, ME.message);
          ahat(:,repIdx) = [NaN; NaN];
          sse_(repIdx) = Inf;
      end
  end

  %------------------------- HANDLE FITTING FAILURE ------------------------
  % This safety and validity check is designed to determine whether all or any of
  % the multiple fitting attempts have failed or succeeded. After executing several
  % curve-fitting tries—usually with different initial guesses—the code examines
  % the vector 'sse_', which contains the sum of squared errors (SSE) for each
  % attempt. It uses 'isfinite(sse_)' to identify valid (finite) SSE values,
  % storing this logical vector in 'valid'. To check if all attempts failed,
  % it evaluates 'all(isfinite(sse_))', which returns true only if every attempt
  % produced a valid fit. Conversely, to determine if none succeeded, '~any(valid)'
  % is used, indicating that all SSEs are invalid (Inf or NaN). If all attempts
  % failed (i.e., no valid SSE), a warning is issued to inform the user, and the
  % output parameters (Mo, R1o, sse) are set to NaN to signify failure, with the
  % function exiting early via a return statement. This combined check ensures that
  % failure cases are properly flagged and handled, allowing downstream processes
  % to respond appropriately to unsuccessful fits.
  if all(~isfinite(sse_))
      warning('All fitting attempts failed. Returning NaNs.'); % Notify user of complete failure
      Mo  = NaN;   % Set equilibrium magnetization output to NaN
      R1o = NaN;   % Set longitudinal relaxation rate output to NaN
      sse = NaN;   % Set sum of squared errors output to NaN
      return;      % Exit the function immediately
  end

  %----------------------------------------------------------
  % Identify which fitting attempts yielded finite SSE values
  % (i.e., successful fits that didn't return Inf or NaN)
  %----------------------------------------------------------
  valid = isfinite(sse_);  % Logical array: true where SSE is a valid number

  if ~any(valid)
      warning('No valid fit found. Returning NaNs.'); % Alert user of failure
      Mo  = NaN;    % Set output Mo to NaN
      R1o = NaN;    % Set output R1o to NaN
      sse = NaN;    % Set output SSE to NaN
      return;       % Exit the function early to prevent further processing
  end

  %--------------------------------------------------------------------------
  % SELECT BEST FITTING ATTEMPT BASED ON MINIMUM SSE
  % This process involves selecting the best fitting attempt based on the minimum
  % sum of squared errors (SSE). The purpose is to identify and extract the
  % parameters, Mo and R1o, that correspond to the most accurate (lowest error)
  % fit among multiple attempts. The logic begins with 'sse_' containing the SSE
  % values for each attempt, and a logical array 'valid' indicating which attempts
  % resulted in finite, valid SSEs. By filtering 'sse_' with 'valid',
  % only the valid SSEs are considered, and 'min(sse_(valid))' finds the smallest
  % among these, returning both the minimum value and its index ('idx').
  % The 'find(valid, idx)' function then retrieves the original position of this
  % attempt within the unfiltered array, ensuring the correct parameters are selected,
  % with 'validIdx(end)' handling potential ties by choosing the last occurrence.
  % The output parameters are set to the corresponding Mo and R1o values from the
  % best attempt, and 'sse' is assigned the lowest SSE, representing the best fit quality.
  [~, idx] = min(sse_(valid));         % Find index of minimum valid SSE
  validIdx = find(valid, idx);         % Map back to original index in 'ahat' and 'sse_'

  % Extract best-fit parameters corresponding to that index
  Mo  = ahat(1, validIdx(end));        % Estimated Mo from best attempt
  R1o = ahat(2, validIdx(end));        % Estimated R1o from best attempt
  sse = sse_(validIdx(end));           % SSE for best attempt

  %--------------------------------------------------------------------------
  % FINAL VALIDITY CHECK ON FITTED PARAMETERS
  % The final validity check on the fitted parameters is performed to ensure that
  % the optimization procedure has returned valid (finite) values for both Mo and
  % R1o. Even if the fitting algorithm executes without errors, it may still produce
  % invalid or non-finite results, such as NaN or Inf, particularly in cases where
  % the problem is ill-conditioned. The check uses 'isfinite(x)' to verify that
  % both parameters are real and finite, applying this to Mo and R1o individually.
  % If either parameter fails this test, the fitting is considered unsuccessful,
  % and all output variables are set to NaN to indicate failure. In this case, a
  % warning is displayed to inform the user, and the function exits early, ensuring
  % that invalid results are not used in subsequent analysis.
  if ~isfinite(Mo) || ~isfinite(R1o)
      % Inform user that fitting produced invalid results
      warning('Fitting did not converge. Returning NaNs.');

      % Set output variables to NaN to clearly indicate failure
      Mo  = NaN;   % Invalid Mo (e.g., infinite or undefined)
      R1o = NaN;   % Invalid R1o (e.g., infinite or undefined)
      sse = NaN;   % No valid sum of squared errors

      % Exit the function to avoid propagating bad results
      return;
  end

  %--------------------------- OPTIONAL PLOTTING ---------------------------
  if doPlot
      fprintf('Best Fit: Mo = %.2f, R1o = %.4f (T1 = %.3fs), SSE = %.2e\n', ...
              Mo, R1o, 1/R1o, sse);
      plotFittingResult(alpha, signal, TR, Mo, R1o);
  end

  %--------------------------------------------------------------------------
  % NESTED FUNCTION: T1_Cal
  % This function implements the SPGR/VFA (Spoiled Gradient Recalled Echo / Variable Flip Angle)
  % signal model, which is used within the curve fitting routine to estimate the signal intensity
  % as a function of flip angle based on model parameters. It takes as inputs a parameter vector
  % 'k', consisting of Mo (equilibrium magnetization) and R1o (longitudinal relaxation rate),
  % with k(1) representing Mo and k(2) representing R1o. The flip angles 'xdata' are provided
  % in degrees as the independent variable, and TR is the fixed repetition time in seconds
  % during acquisition. The output 'F' is the model-predicted SPGR signal for each flip angle,
  % calculated using the EQUATION:
  %     S(FA) = Mo * sin(FA) * (1 - exp(-TR * R1o)) / (1 - cos(FA) * exp(-TR * R1o)).
  % The model assumes steady-state acquisition with full spoiling, requiring flip angles
  % to be converted to radians before applying sine and cosine functions. Additionally,
  % E1 = exp(-TR * R1o) represents the longitudinal recovery between excitations.
  function F = T1_Cal(k, xdata, TR)
      %---------------------------------------------
      %   Compute longitudinal recovery factor
      %   E1 = exp(-TR * R1o)
      %   Represents the degree of longitudinal recovery between TR periods.
      %---------------------------------------------
      E1 = exp(-TR * k(2));  % k(2) is R1o (1/T1)

      %---------------------------------------------
      %   Compute SPGR model signal for all flip angles
      %   -Flip angles are converted from degrees to radians.
      %   -Signal is computed using vectorized operations for performance.
      %---------------------------------------------
      F = k(1) * sin(xdata * pi / 180) .* ...              % numerator: Mo * sin(FA)
          (1 - E1) ./ ...                                  % scaled by recovery
          (1 - cos(xdata * pi / 180) * E1);                % denominator: steady-state

      % The output F is a vector of model-predicted signals for each input FA
  end % end of T1_Cal

  %--------------------------------------------------------------------------
  % HELPER FUNCTION: plotFittingResult
  % This function is designed to plot the measured SPGR/VFA signal intensities
  % against the corresponding signal predicted by the fitted model parameters,
  % specifically Mo and R1o, for a given repetition time (TR) and a set of flip
  % angles. It takes as inputs a vector of flip angles in degrees ('alpha'), a
  % vector of measured signal intensities ('signal'), the TR value in seconds,
  % and the estimated parameters Mo and R1o. The operation involves calculating
  % the fitted signal using the SPGR/VFA model with the provided parameters,
  % then plotting both the measured data and the fitted curve against the flip
  % angles. The plot displays measured signal values as red circles and the fitted
  % signal curve as a blue line, enabling a visual comparison of the model fit to
  % the actual data.
  function plotFittingResult(alpha, signal, TR, Mo, R1o)
      %-------------------- MODEL SIGNAL COMPUTATION -----------------------
      % This code calculates the predicted signal intensity based on the SPGR signal equation:
      % S(FA) = Mo * sin(FA) * (1 - exp(-TR * R1o)) / (1 - cos(FA) * exp(-TR * R1o)).
      % The equation models the steady-state signal response to varying flip angles,
      % with FA provided in radians. Using the estimated parameters Mo and R1o along
      % with the sequence timing TR, it computes the expected signal values, allowing
      %  comparison between the modeled and measured signals under the given imaging conditions.
      fitSignal = Mo * sin(alpha * pi / 180) .* ...
                  (1 - exp(-TR * R1o)) ./ ...
                  (1 - cos(alpha * pi / 180) * exp(-TR * R1o));

      % Create a new figure window to display the plot
      figure;

      % Plot the measured signal:
      plot(alpha, signal, 'ro', 'MarkerSize', 8, 'DisplayName', 'Measured');
      hold on;  % Allow overlaying additional plots on the same figure

      % Plot the fitted signal:
      plot(alpha, fitSignal, 'b-', 'LineWidth', 2, 'DisplayName', 'Fitted');

      xlabel('Flip Angle [deg]');

      % Y-axis label: Signal intensity (arbitrary units or scanner units)
      ylabel('Signal Intensity'); % arbitrary or scanner units

      title('SPGR Signal Fitting');

      % Add legend to distinguish between measured and fitted signals
      legend('Location', 'northeast');

      % Add grid to aid interpretation of values
      grid on;

  end  % end of plotFittingResult


end % end of measureMoR1o_fast_VFA
