function val = isoValue(data)
%%  ISOVALUE  IsoValue calculator.
%   VAL = ISOVALUE(V) calculates an isoValue from data V using hist
%   function.  Utility function used by ISOSURFACE and ISOCAPS.
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2002/06/17 13:37:43 $
% -------------------------------------------------------------------------------------
%   Comments updated by Dr. Tanuj Puri, dated 01/2014
%   This function computes a value based on the histogram distribution of input `data`.
%   The intent appears to be to identify a central or stable value in the distribution,
%   excluding outliers or disproportionately large peaks (such as background noise).
%
%   Input:
%       data - A numeric array (vector or matrix) of values.
%
%   Output:
%       val  - A scalar 'iso' value extracted from the histogram analysis of `data`.
%
%% --- Step 1: Set sampling rate for large datasets ---
    r = 1;  % Default sampling rate (use all data)
    len = length(data(:));  % Flatten the input and get the total number of elements

    % If the data is large, sample only a subset to reduce computation
    if len > 20000
        r = floor(len / 10000);  % Sample ~10,000 values max
    end

    % --- Step 2: Compute histogram of sampled data ---
    % Use 100 bins to create histogram of sampled data
    [n, x] = hist(data(1:r:end), 100);  % n: bin counts, x: bin centers

    % --- Step 3: Handle unusually large peaks (likely background) ---
    % Find bin(s) with the maximum count
    pos = find(n == max(n));
    pos = pos(1);  % In case of multiple, use the first

    % Check if max peak is at the start (often due to background or zero-padding)
    % and disproportionately large compared to average
    q = max(n(1:2));  % Look at first two bins
    if pos <= 2 && q / (sum(n)/length(n)) > 10
        % Remove the first two bins (assumed to be background)
        n = n(3:end);
        x = x(3:end);
    end

    % --- Step 4: Remove small bins (insignificant histogram bars) ---
    % Eliminate bins with counts < 1/50 of max count
    pos = find(n < max(n) / 50);
    
    % Only remove them if there are not too many (i.e., histogram is not sparse)
    if length(pos) < 90
        x(pos) = [];  % Remove corresponding x (bin centers)
    end

    % --- Step 5: Return central value ---
    % Return the value at the center of the remaining bin centers
    val = x(floor(length(x) / 2));

end
