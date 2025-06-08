function [outNames] = getNames(dirPath)
%--------------------------------------------------------------------------
% FUNCTION: getNames
% AUTHOR:   Dr. Tanuj Puri
% DATE:     01/2014, updated 06/2025
%
% DESCRIPTION:
%   Returns the names of all files and folders (excluding '.' and '..') in
%   the given directory, with file extensions removed.
%
% INPUT:
%   dirPath  - (char or string) Path to the directory to be scanned.
%
% OUTPUT:
%   outNames - (cell array of char) List of file/folder names without
%              extensions.
%
% NOTES:
%   - Only names are returned; no filtering between files/folders is done.
%   - This function does not recurse into subdirectories.
%   - Assumes the directory contains valid files/folders; contents are not
%     individually validated.
%
% WARNING:
%   This code is not clinically validated. Use with caution in sensitive
%   environments.
%--------------------------------------------------------------------------

    %=== Input Validation ===%
    if nargin ~= 1
        error('getNames:InvalidInput', 'Exactly one input argument is required.');
    end

    if ~ischar(dirPath) && ~isstring(dirPath)
        error('getNames:InvalidInputType', 'Input must be a character vector or string scalar.');
    end

    % Convert to character array if input is string
    dirPath = char(dirPath);

    % Check if directory exists
    %if ~exist(dirPath, 'dir')
    %    error('getNames:DirNotFound', 'Specified directory does not exist: %s', dirPath);
    %end

    % Check if directory exists
    if exist(dirPath, 'dir') ~= 7 % Mimics what isfolder() does in MATLAB
        error('getNames:InvalidPath', ...
              'Specified directory does not exist: %s', dirPath);
    end

    % Get directory listing
    dirList = dir(dirPath);

    % Extract the names from the dir struct
    names = {dirList.name};

    % Initialize output
    outNames = {};

    % Loop over all names
    for i = 1:numel(names)
        name = names{i};

        % Skip current (.) and parent (..) directory references
        if ~strcmp(name, '.') && ~strcmp(name, '..')

            % Remove extension using fileparts
            [~, nameWithoutExt, ~] = fileparts(name);

            % Append to output list
            outNames{end+1} = nameWithoutExt;
        end
    end

    %=== Output Validation ===%
    if nargout > 1
        error('getNames:TooManyOutputs', 'Too many output arguments.');
    end

end% end getNames
