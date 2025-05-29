function [cumsum_trapezoids] = trapezoidalIntegration(time_resampled, Cp_resampled)
% TRAPEZOIDALINTEGRATION Compute cumulative AUC using trapezoidal rule.
%
%   cumsum_trapezoids = trapezoidalIntegration(time_resampled, Cp_resampled)
%
%   This function computes the area under the Cp vs time curve using the
%   trapezoidal rule and returns the cumulative sum of trapezoidal areas.
%
%   Inputs:
%       time_resampled - [n x 1] numeric vector of time points (e.g., 0:1:t_end)
%       Cp_resampled   - [n x 1] numeric vector of Cp(t) values (same length)
%
%   Output:
%       cumsum_trapezoids - [n x 1] cumulative area under curve from t=0 to t(i)
%
%   Note:
%       Assumes time(1) = 0 and uniform or non-uniform spacing is acceptable.
%       cumsum_trapezoids(1) = 0 by definition (area before t=0).
%
%   Author: Dr. Tanuj Puri
%   Date:   01/2014
%   Warning: This is an untested code/implementation and should be used
%            with caution in clinical and pre-clinical settings. The author takes  
%            no responsibility of any kind about the output results from this code.
%
    %% --- Input Validation ---
    if nargin ~= 2
        error('Function requires exactly two input arguments.');
    end
    
    if time_resampled(1) ~= 0
        error('Time vector must start at 0. time_resampled(1) ~= 0.');
    end

    if ~isnumeric(time_resampled) || ~isnumeric(Cp_resampled)
        error('Both inputs must be numeric vectors.');
    end

    if ~isvector(time_resampled) || ~isvector(Cp_resampled)
        error('Inputs must be 1D vectors.');
    end

    if length(time_resampled) ~= length(Cp_resampled)
        error('Inputs must be the same length.');
    end

    if any(~isfinite(time_resampled)) || any(~isfinite(Cp_resampled))
        error('Inputs must not contain NaN or Inf values.');
    end

    % Force column vectors
    time_resampled = time_resampled(:);
    Cp_resampled   = Cp_resampled(:);

    n = length(time_resampled);
    if n < 2
        error('Input vectors must have at least two elements.');
    end

    %% --- Compute Trapezoidal Areas ---
    delta_t   = diff(time_resampled);                     % [n-1 x 1]
    avg_Cp    = 0.5 * (Cp_resampled(1:end-1) + Cp_resampled(2:end)); % [n-1 x 1]
    trap_area = delta_t .* avg_Cp;                        % [n-1 x 1]

    %% --- Cumulative Sum ---
    cumsum_trapezoids = [0; cumsum(trap_area)];           % [n x 1]

end
