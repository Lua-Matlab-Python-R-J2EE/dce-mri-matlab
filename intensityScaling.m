function y = intensityScaling(x, wC, wW, yMin, yMax)
% intensityScaling - Applies window-level intensity scaling to 2D image data.
%
% Syntax:
%   y = intensityScaling(x, wC, wW, yMin, yMax)
%
% Inputs:
%   x     - 2D numeric matrix (image pixel values)
%   wC    - Window center (level), scalar
%   wW    - Window width, scalar > 0
%   yMin  - Minimum display intensity, scalar
%   yMax  - Maximum display intensity, scalar > yMin
%
% Output:
%   y     - 2D matrix with scaled intensities in [yMin, yMax]
%
% Description:
%   Performs window-level linear scaling of image intensities for display.
%   Clips values below and above the window to yMin and yMax respectively.
%
% Author: Dr. Tanuj Puri
% Date:   01/2014, updated 2025
% Warning: This is an untested code/implementation and should be used
% with caution in clinical and pre-clinical settings. The author takes no 
% responsibility of any kind about the output results from this code.
%
    %% Input Validation

    if nargin ~= 5
        error('intensityScaling:ArgumentCount', ...
              'Function requires exactly 5 input arguments.');
    end

    % Validate input image
    if ~isnumeric(x) || ~ismatrix(x)
        error('intensityScaling:InvalidInput', ...
              'Input x must be a 2D numeric matrix.');
    end
    if any(isnan(x(:))) || any(isinf(x(:))) || ~isreal(x)
        error('intensityScaling:InvalidImageData', ...
              'Input x must be real, finite, and non-NaN.');
    end

    % Validate scalars
    scalarChecks = {wC, 'wC'; wW, 'wW'; yMin, 'yMin'; yMax, 'yMax'};
    for k = 1:size(scalarChecks, 1)
        val = scalarChecks{k, 1};
        name = scalarChecks{k, 2};
        if ~isnumeric(val) || ~isscalar(val) || isnan(val) || isinf(val) || ~isreal(val)
            error('intensityScaling:InvalidScalar', ...
                  'Input %s must be a real, finite scalar.', name);
        end
    end

    if wW <= 0
        error('intensityScaling:InvalidWindowWidth', ...
              'Window width (wW) must be greater than 0.');
    end

    if yMax <= yMin
        error('intensityScaling:InvalidDisplayRange', ...
              'yMax must be greater than yMin.');
    end

    %% Compute window parameters
    a = wC - 0.5;
    b = wW - 1;

    %% Apply scaling using vectorized operations
    y = zeros(size(x));

    below = x <= (a - b/2);
    above = x >  (a + b/2);
    inRange = ~(below | above);

    y(below) = yMin;
    y(above) = yMax;
    y(inRange) = ((x(inRange) - a) / b + 0.5) * (yMax - yMin) + yMin;

end
