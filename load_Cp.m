function [Cp] = load_Cp(varargin)
%% LOAD_CP Load a Cp (plasma time-activity curve) vector from a .mat file and perform strict validation.
%
%   Cp = load_Cp() loads the default file 'Cp.mat' in the current directory.
%   Cp = load_Cp(filepath) loads the Cp vector from the specified file.
%
%   The loaded data must:
%       - Be a numeric 1D vector (row or column)
%       - Contain no NaN or Inf values
%       - Contain only real, non-negative numbers
%
%   Example:
%       Cp = load_Cp('data/myCp.mat');
%
%   Author: Dr. Tanuj Puri
%   Date:   01/2014
%   Warning: This is an untested code/implementation and should be used
%            with caution in clinical and pre-clinical settings. The author  
%            takes no responsibility of the output results from this code.
%
%% Handle input arguments
    if nargin == 1
        loc = varargin{1};
    else
        % loc = 'D:\Cp_D_0.1.mat'; % hard coded path

        % Cp.mat has been provided (with variable named Cp) and should exist in the current directory; 
        % otherwise, a function named create_Realistic_Cp.m is available to generate it.  
        loc = fullfile(pwd, 'Cp.mat');         
    end

    %% Check if file exists
    if ~isfile(loc)
        error('File not found: %s', loc);
    end

    %% Load .mat file
    loadedData = load(loc);
    
    % Expecting the file to contain a variable named 'Cp'
    if ~isfield(loadedData, 'Cp')
        error('The .mat file must contain a variable named "Cp".');
    end

    Cp = loadedData.Cp;

    %% Validate Cp contents
    if ~isnumeric(Cp)
        error('Cp must be numeric.');
    end

    if ~isvector(Cp)
        error('Cp must be a 1D vector.');
    end

    if any(~isfinite(Cp))
        error('Cp contains NaN or Inf values.');
    end

    if ~isreal(Cp)
        error('Cp contains complex numbers. Only real values are allowed.');
    end

    if any(Cp < 0)
        error('Cp contains negative values. Only non-negative values are allowed.');
    end
end
