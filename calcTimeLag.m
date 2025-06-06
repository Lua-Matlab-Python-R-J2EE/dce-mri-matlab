function [timeLag] = calcTimeLag(time, Ct_measured, Cp_measured)
%% CALCTIMELAG Calculates time lag between Cp (plasma time-activity curve) and Ct (tissue time-activity curve) vectors.
%
%   INPUTS:
%       time         - [Nx1] or [1xN] numeric vector (e.g., minutes or seconds)
%       Ct_measured  - [Nx1] or [1xN] numeric vector (tissue curve)
%       Cp_measured  - [Nx1] or [1xN] numeric vector (plasma curve)
%
%   OUTPUT:
%       timeLag      - Scalar value representing the time lag (>=0)
%
%   Logic:
%     (1) Find index of first 3 consecutive positive values in Ct and Cp.
%     (2) Cp must not start after Ct. If it does, return error.
%     (3) If Cp and Ct start at same time, timeLag = 0.
%     (4) If Cp starts before Ct, timeLag = time(Ct_strt) - time(Cp_strt).
%
%   Constraints:
%     - All input vectors must be same length and non-empty
%     - No NaN, Inf, complex, or negative values allowed
%
%   Dependencies:
%     - strtIndex(): must return -1 if valid starting index is not found.
%
%   Author: Dr. Tanuj Puri
%   Date:   01/2014, updated 2025
%   Warning: This is an untested code/implementation and should be used
%            with caution in clinical and pre-clinical settings. The author takes no 
%            responsibility of any kind about the output results from this code.
%
%% Input validation
    if nargin ~= 3
        error('Exactly three input arguments are required: time, Ct_measured, Cp_measured');
    end

    if ~isnumeric(time) || ~isvector(time)
        error('time must be a numeric 1D vector');
    end
    
    if ~isnumeric(Ct_measured) || ~isvector(Ct_measured)
        error('Ct_measured must be a numeric 1D vector');
    end

    if ~isnumeric(Cp_measured) || ~isvector(Cp_measured)
        error('Cp_measured must be a numeric 1D vector');
    end

    if ~isnumeric(Ct_measured) || ~isnumeric(Cp_measured)
        error('Ct_measured and Cp_measured must be numeric vectors');
    end

    if ~isequal(length(time), length(Ct_measured), length(Cp_measured))
        error('All inputs must be of the same length.');
    end

    if any(isnan(time) | isnan(Ct_measured) | isnan(Cp_measured))
        error('Input contains NaN values.');
    end

    if any(~isfinite(time) | ~isfinite(Ct_measured) | ~isfinite(Cp_measured))
        error('Input contains Inf or -Inf values.');
    end

    if ~isreal(time) || ~isreal(Ct_measured) || ~isreal(Cp_measured)
        error('Complex numbers are not allowed.');
    end

    if any(time < 0) || any(Ct_measured < 0) || any(Cp_measured < 0)
        error('Inputs must not contain negative values.');
    end

    %% 1. Get starting index of 3 consecutive positive values
    Ct_strt = strtIndex(Ct_measured);
    Cp_strt = strtIndex(Cp_measured);

    if Ct_strt == -1 || Cp_strt == -1
        error('Could not find 3 consecutive positive values in Ct or Cp.');
    end

    %% 2. Check for invalid timing order
    if Cp_strt > Ct_strt
        error('Cp start time cannot be later than Ct start time.');
    end

    %% 3. If equal, timeLag = 0
    if Cp_strt == Ct_strt
        timeLag = 0;
        return;
    end

    %% 4. Compute time lag
    timeLag = time(Ct_strt) - time(Cp_strt);

    %% Final sanity check
    if timeLag < 0
        error('Calculated timeLag is negative. Check time vector consistency.');
    end

end
