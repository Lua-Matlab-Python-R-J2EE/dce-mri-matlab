function tSec = convertTimeMinToSec(t)
% convertTimeMinToSec - Converts a time vector from minutes to seconds.
%
% INPUT:
%   t - A 1xN or Nx1 numeric vector of strictly increasing time points (in minutes)
%
% OUTPUT:
%   tSec - A vector of the same size, converted to seconds.
%
% This function internally validates the input using isValidTimeVector. If the
% input is invalid, an error is thrown.
%
% EXAMPLE:
%   t = [1 2 3];                    % minutes
%   tSec = convertTimeMinToSec(t);  % returns [60 120 180]
%
% DEPENDENCY STRUCTURE:
% convertTimeMinToSec
% ├── Inputs:
% │   └── t : Numeric vector of strictly increasing time points in minutes
% │
% ├── Dependencies:
% │   └── isValidTimeVector.m : validates the input vector
% │
% ├── Functionality:
% │   ├── Checks input validity via isValidTimeVector
% │   ├── Converts time from minutes to seconds
% │
% └── Output:
%     └── tSec : Converted time vector in seconds
%
%   Author: Dr. Tanuj Puri
%   Date:   01/2014, updated 06/2015
%   Warning: This is an untested code/implementation and should be used
%            with caution in clinical and pre-clinical settings. The author takes no
%            responsibility of any kind about the output results from this code.
%

    if ~isvector(t)
        warning('Input is not a vector.');
        return;
    end
    
    % Validate input
    if ~isValidTimeVector(t)
        error('convertTimeMinToSec:InvalidInput', ...
              'Input time vector is invalid. Ensure it passes isValidTimeVector.');
    end

    % Convert minutes to seconds
    tSec = t * 60;
    disp(tSec)
end
