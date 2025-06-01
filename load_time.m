function [time] = load_time(varargin)
%% LOAD_TIME Load a time vector from a .mat file and perform strict validation.
%
%   time = load_time() loads the default file 'D:\time_D_0.1.mat'.
%   time = load_time(filepath) loads the time vector from the specified file.
%
%   The loaded data must:
%       - Be a numeric 1D vector (row or column)
%       - Contain no NaN or Inf values
%       - Contain only real, non-negative numbers
%
%   Example:
%       time = load_time('data/mytime.mat');
%
%   Author: Dr. Tanuj Puri
%   Date:   01/2014
%   Warning: This is an untested code/implementation and should be used
%            with caution in clinical and pre-clinical settings. The author takes no 
%            responsibility of any kind about the output results from this code.
%
%% Handle input arguments
    if nargin == 1
        loc = varargin{1};
    else
        loc = 'D:\time_D_0.1.mat';
    end

    %% Check if file exists
    if ~isfile(loc)
        error('File not found: %s', loc);
    end

    %% Load .mat file
    loadedData = load(loc);
    
    % Expecting the file to contain a variable named 'time'
    if ~isfield(loadedData, 'time')
        error('The .mat file must contain a variable named "time".');
    end

    time = loadedData.time;

    %% Validate time contents
    if ~isnumeric(time)
        error('time must be numeric.');
    end

    if ~isvector(time)
        error('time must be a 1D vector.');
    end

    if any(~isfinite(time))
        error('time contains NaN or Inf values.');
    end

    if ~isreal(time)
        error('time contains complex numbers. Only real values are allowed.');
    end

    if any(time < 0)
        error('time contains negative values. Only non-negative values are allowed.');
    end
end
