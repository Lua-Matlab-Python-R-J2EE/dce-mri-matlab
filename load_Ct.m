function [Ct] = load_Ct(varargin)
%% LOAD_CT Load a Ct (tissue time-activity curve) vector from a .mat file and perform strict validation.
% 
%   Ct = load_Ct() loads the default file 'Ct.mat' in the current directory.
%   Ct = load_Ct(filepath) loads the Ct vector from the specified file.
%
%   The loaded data must:
%       - Be a numeric 1D vector (row or column)
%       - Contain no NaN or Inf values
%       - Contain only real, non-negative numbers
%
%   Example:
%       Ct = load_Ct('data/myCt.mat');
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
        % loc = 'D:\Ct_D_0.1.mat'; % hardcoded path
        
        % Ct.mat has been provided (with variable anmed Ct) and should exist in the current directory; 
        % otherwise, a function named create_Realistic_Ct.m is available to generate it.  
        loc = fullfile(pwd, 'Ct.mat'); 
    end

    %% Check if file exists
    if ~isfile(loc)
        error('File not found: %s', loc);
    end

    %% Load .mat file
    loadedData = load(loc);
    
    % Expecting the file to contain a variable named 'Ct'
    if ~isfield(loadedData, 'Ct')
        error('The .mat file must contain a variable named "Ct".');
    end

    Ct = loadedData.Ct;

    %% Validate Ct contents
    if ~isnumeric(Ct)
        error('Ct must be numeric.');
    end

    if ~isvector(Ct)
        error('Ct must be a 1D vector.');
    end

    if any(~isfinite(Ct))
        error('Ct contains NaN or Inf values.');
    end

    if ~isreal(Ct)
        error('Ct contains complex numbers. Only real values are allowed.');
    end

    if any(Ct < 0)
        error('Ct contains negative values. Only non-negative values are allowed.');
    end
end
