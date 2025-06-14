function isValid = isValidTimeVector(t)
% isValidTimeVector - Validates a time vector for DCE-MRI or similar time-based analyses.
%
% This function checks whether the input `t` is a strictly increasing numeric vector 
% representing time points. It is designed to ensure that `t` is valid for numerical 
% analyses that require clean and orderly time data (e.g., pharmacokinetic modeling, 
% time-series analysis).
%
% INPUT:
%   t - A 1xN or Nx1 numeric vector of time points.
%
% OUTPUT:
%   isValid - Logical true (1) if all of the following conditions are met:
%       - Input is a vector
%       - Input is non-empty
%       - Input is numeric
%       - No NaN, Inf, or complex numbers
%       - All elements are non-negative
%       - Time points are strictly increasing
%
% EXAMPLES:
%   isValidTimeVector([0 1 2 3])         % returns true
%   isValidTimeVector([0 1 1 2])         % returns false
%   isValidTimeVector([-1 0 1])          % returns false
%   isValidTimeVector({'a', 1, 2})       % returns false
%
% NOTES:
%   This function is designed to be robust against invalid input types,
%   including strings, cell arrays, empty inputs, and logicals.
%
% AUTHOR:   Dr. Tanuj Puri
% DATE:     01/2014, updated 06/2025
%

    % Default output
    isValid = false;

    % Check if input is a vector
    if ~isvector(t)
        warning('Input is not a vector.');
        return;
    end

    % Check if empty
    if isempty(t)
        warning('Time vector is empty.');
        return;
    end

    % Ensure column vector for consistency
    t = t(:);

    % Check if numeric
    if ~isnumeric(t)
        warning('Time vector contains non-numeric values.');
        return;
    end

    % Check for complex numbers
    if ~isreal(t)
        warning('Time vector contains complex values.');
        return;
    end

    % Check for NaN or Inf
    if any(isnan(t)) || any(isinf(t))
        warning('Time vector contains NaN or Inf values.');
        return;
    end

    % Check for negative values
    if any(t < 0)
        warning('Time vector contains negative values.');
        return;
    end

    % Check strictly increasing
    if any(diff(t) <= 0)
        warning('Time vector is not strictly increasing.');
        return;
    end

    % If all checks passed
    isValid = true;
end
