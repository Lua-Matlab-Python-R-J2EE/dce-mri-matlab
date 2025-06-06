function [peakVal, peakInd] = peakIndex(input_vec)
% PEAKINDEX - Returns the maximum (peak) value and its index in the input vector.
%
%   [peakVal, peakInd] = peakIndex(input_vec)
%
%   Input:
%       input_vec - A numeric 1D vector (row or column)
%
%   Outputs:
%       peakVal - Maximum value found in input_vec
%       peakInd - Index (1-based) of the first occurrence of the maximum value
%
%   Example:
%       [val, idx] = peakIndex([1 5 3 5 2])
%       % val = 5, idx = 2
%
%   Author: Dr. Tanuj Puri
%   Date:   01/2014, updated 2025
%   Warning: This is an untested code/implementation and should be used
%   with caution in clinical and pre-clinical settings. The author takes no 
%   responsibility of any kind about the output results from this code.
%
    %% Input validation
    if nargin ~= 1
        error('Exactly one input argument is required.');
    end

    if ~isnumeric(input_vec) || ~isvector(input_vec)
        error('Input must be a numeric 1D vector.');
    end

    if isempty(input_vec)
        error('Input vector is empty.');
    end

    if any(isnan(input_vec)) || any(isinf(input_vec))
        error('Input vector must not contain NaN or Inf values.');
    end

    %% Core logic
    [peakVal, peakInds] = max(input_vec);  % Get max value and all matching indices
    peakInd = find(input_vec == peakVal, 1, 'first');  % Ensure first occurrence

end
