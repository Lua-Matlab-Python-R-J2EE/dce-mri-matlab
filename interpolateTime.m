function tInterp = interpolateTime(t)
% interpolateTime - Generate a 1-second interval time vector between the first and last time points.
%
% This function takes a numeric time vector (row or column, in seconds),
% validates it using `isValidTimeVector`, and returns an interpolated time
% vector with 1-second intervals from the first to the last value.
%
% -------------------------------------------------------------------------
% DEPENDENCY STRUCTURE
% -------------------------------------------------------------------------
% interpolateTime
% ├── Input:
% │   └── t (numeric vector, in seconds; must be strictly increasing)
% │
% ├── Dependencies:
% │   └── isValidTimeVector.m
% │       ├── Validates the input time vector
% │       ├── Ensures it is numeric, non-empty, non-complex, real,
% │       │    non-negative, finite, and strictly increasing
% │       └── Used to enforce robustness of temporal assumptions
% │
% └── Output:
%     └── tInterp (1-second uniformly spaced time vector from min(t) to max(t))
%
% Notes:
% - Assumes input time vector is in seconds
% - Output is returned as a row vector
% - Used in time-series modeling where fixed sampling is required
%
% USAGE:
%   tInterp = interpolateTime([0 2 4 6 8]);
%   % returns: [0 1 2 3 4 5 6 7 8]
%
% AUTHOR: Dr. Tanuj Puri
% DATE:   01/2014, updated 06/2025
%

    % Validate input using isValidTimeVector
    if ~isValidTimeVector(t)
        error('Input time vector is not valid. See warnings above.');
    end

    % Ensure column vector for consistency (optional – output will be row)
    t = t(:);

    % Get first and last time values
    tStart = t(1);        % assuming vector is strictly increasing
    tEnd = t(end);

    % Generate interpolated time vector at 1-second intervals
    tInterp = tStart:1:tEnd;

    % Return as row vector
    tInterp = tInterp(:)';  % convert to row for consistent output
end
