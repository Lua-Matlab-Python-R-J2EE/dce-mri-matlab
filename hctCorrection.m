function [Cp] = hctCorrection(Cb, Hct)
%% HctCORRECTION calculates plasma concentration (Cp)
% from whole blood concentration (Cb), corrected for hematocrit (Hct)
%
% Author: Dr. Tanuj Puri
% Date:   01/2014
% Warning: This is an untested code/implementation and should be used
% with caution in clinical and pre-clinical settings. The author takes no 
% responsibility of any kind about the output results from this code.
%
% Syntax:
%   Cp = hctCorrection(Cb)
%   Cp = hctCorrection(Cb, Hct)
%
% Inputs:
%   Cb  - Blood concentration (numeric scalar or vector, non-negative)
%   Hct - Hematocrit value (optional, numeric scalar in range [0, 1), default = 0.42)
%
% Outputs:
%   Cp  - Plasma concentration (same size as Cb)
%
%%
    % Check number of input arguments
    if nargin < 1 || nargin > 2
        error('hctCorrection requires 1 or 2 input arguments.');
    end

    % Check number of output arguments
    if nargout > 1
        error('hctCorrection returns only one output argument.');
    end

    % Check Cb: must be numeric, non-complex, real, finite, non-negative, scalar or vector
    if ~isnumeric(Cb) || ~isreal(Cb) || any(~isfinite(Cb)) || any(Cb(:) < 0)
        error('Input Cb must be numeric.');
    end
    if any(isnan(Cb(:))) || any(isinf(Cb(:)))
        error('Input Cb must not contain NaN or Inf values.');
    end
    if ~isvector(Cb) && ~isscalar(Cb)
        error('Input Cb must be a scalar or vector (not a matrix).');
    end

    % Assign or validate Hct
    if nargin < 2
        Hct = 0.42; % Default value
    else
        % Check Hct: must be numeric scalar in [0, 1)
        if ~isnumeric(Hct) || ~isscalar(Hct) || ~isreal(Hct) || isnan(Hct) || isinf(Hct)
            error('Hct must be a real numeric scalar.');
        end
        if Hct < 0 || Hct >= 1
            error('Hct must be in the range [0, 1).');
        end
    end

    % Perform correction
    Cp = Cb ./ (1 - Hct);

    % Output size check
    if ~isequal(size(Cp), size(Cb))
        error('Output Cp must have the same size as input Cb.');
    end
end
