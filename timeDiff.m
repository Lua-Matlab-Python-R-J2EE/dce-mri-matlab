function timeD = timeDiff(T1, T2)
% timeDiff: Computes the time difference in seconds between two time strings.
%
% INPUTS:
%   T1, T2 - Time strings in the format 'HH:MM:SS' or 'HH:MM:SS.FFF'
%
% OUTPUT:
%   timeD - Non-negative scalar representing the absolute time difference in seconds
%
% FEATURES:
%   - Accepts time strings with or without fractional seconds
%   - Automatically swaps inputs if T2 is earlier than T1 (no error)
%
% VALIDATION:
%   - Checks for number of inputs
%   - Verifies input types (must be character or string)
%   - Validates format with regular expressions
%   - Ensures time components are within valid ranges
%
% ERRORS:
%   - Missing inputs
%   - Non-string inputs
%   - Invalid format
%   - Invalid numeric time components (e.g., 25:00:00 or 12:00:60)
%
% Author: Dr. Tanuj Puri
% Date:   01/2014
% Warning: This is an untested code/implementation and should be used
% with caution in clinical and pre-clinical settings. The author takes no 
% responsibility of any kind about the output results from this code.
%
    %% 1. Check for exactly two inputs
    if nargin ~= 2
        error('timeDiff:ArgumentCount', ...
              'Function requires exactly 2 input arguments.');
    end

    %% 2. Check for non-empty string inputs
    if isempty(T1) || isempty(T2)
        error('timeDiff:EmptyInput', ...
              'One or both input time strings are empty.');
    end

    if ~(ischar(T1) || isstring(T1)) || ~(ischar(T2) || isstring(T2))
        error('timeDiff:InvalidType', ...
              'Inputs must be character arrays or strings.');
    end

    %% 3. Validate format using regex
    % Accepts 'HH:MM:SS' or 'HH:MM:SS.FFF' (optional milliseconds)
    validPattern = '^([01]?\d|2[0-3]):[0-5]\d:[0-5]\d(\.\d{1,3})?$';
    if isempty(regexp(T1, validPattern, 'once')) || ...
       isempty(regexp(T2, validPattern, 'once'))
        error('timeDiff:InvalidFormat', ...
              'Time format must be ''HH:MM:SS'' or ''HH:MM:SS.FFF''.');
    end

    %% 4. Parse time strings with fallback (with and without milliseconds)
    try
        t1 = datevec(T1, 'HH:MM:SS.FFF');
    catch
        t1 = datevec(T1, 'HH:MM:SS');
    end

    try
        t2 = datevec(T2, 'HH:MM:SS.FFF');
    catch
        t2 = datevec(T2, 'HH:MM:SS');
    end

    %% 5. Ensure parsing succeeded
    if any(isnan(t1)) || any(isnan(t2))
        error('timeDiff:NaNError', ...
              'Invalid time string. Parsing returned NaN values.');
    end

    %% 6. Validate time component ranges
    % t(4) = hour, t(5) = minute, t(6) = second
    if any(t1(4) > 23 | t1(4) < 0 | t1(5) > 59 | t1(5) < 0 | t1(6) < 0 | t1(6) >= 60) || ...
       any(t2(4) > 23 | t2(4) < 0 | t2(5) > 59 | t2(5) < 0 | t2(6) < 0 | t2(6) >= 60)
        error('timeDiff:InvalidTimeRange', ...
              'Invalid time components. HH [0–23], MM [0–59], SS [0–59.999] expected.');
    end

    %% 7. Compute initial time difference
    timeD = etime(t2, t1);

    %% 8. If negative (T2 earlier than T1), swap to ensure positive difference
    if timeD < 0
        tmp = t1;
        t1 = t2;
        t2 = tmp;
        timeD = etime(t2, t1);  % recompute
    end
end
