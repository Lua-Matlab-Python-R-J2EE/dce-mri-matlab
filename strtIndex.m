function [strtInd] = strtIndex(input_vec)
% STRTINDEX Finds index of the first 3 consecutive positive values (>0).
%
%   strtInd = strtIndex(input_vec)
%
%   INPUT:
%       input_vec : Numeric, real 1D vector (row or column)
%
%   OUTPUT:
%       strtInd   : 1-based index of the first sequence of 3 consecutive
%                   positive (>0) values. Returns -1 if not found.
%

    %% --- Input Validation ---
    if nargin ~= 1
        error('Function requires exactly one input argument.');
    end

    if ~isnumeric(input_vec) || ~isvector(input_vec)
        error('Input must be a numeric 1D vector.');
    end

    if isempty(input_vec)
        warning('Input vector is empty. Returning -1.');
        strtInd = -1;
        return;
    end

    if any(~isfinite(input_vec))
        warning('Input contains NaN or Inf. Returning -1.');
        strtInd = -1;
        return;
    end

    if ~isreal(input_vec)
        warning('Input contains complex values. Returning -1.');
        strtInd = -1;
        return;
    end

    % Ensure input is column vector for consistency
    input_vec = input_vec(:);
    N = length(input_vec);

    %% --- Initialize Output ---
    strtInd = -1;

    %% --- Search for 3 Consecutive Positives ---
    i = 1;
    while i <= N - 2
        if input_vec(i) > 0 && input_vec(i + 1) > 0 && input_vec(i + 2) > 0
            strtInd = i;
            return;
        end
        i = i + 1;
    end

    %% --- Output Check ---
    if ~isscalar(strtInd) || ~isnumeric(strtInd)
        error('Output must be a numeric scalar.');
    end
    
end
