function string = cell2str(cellstr)
% CELL2STR Convert a 2-D cell array of strings to a string in MATLAB syntax.
%   STR = CELL2STR(CELLSTR) converts the 2-D cell-string CELLSTR to a 
%   MATLAB string so that EVAL(STR) produces the original cell-string.
%   Works as corresponding MAT2STR but for cell array of strings instead of 
%   scalar matrices.
%
%   Example
%       cellstr = {'U-234','Th-230'};
%       cell2str(cellstr) produces the string '{''U-234'',''Th-230'';}'.
%
%   See also MAT2STR, STRREP, CELLFUN, EVAL.

%   Developed by Per-Anders Ekstr�m, 2003-2007 Facilia AB.
%------------------------------------------------------------------------------
% % DISCLAIMER: This function was not authored by me; it was taken from another 
%               source and was used as-is without modifications or testing.
%               Comments updated by Dr. Tanuj Puri, dated 01/2014, updated 2025
%------------------------------------------------------------------------------
% Validate number of input arguments
if nargin ~= 1
    error('CELL2STR:Nargin', 'Takes 1 input argument.');
end

% If input is already a character array (not a cell array), convert to string format
% by wrapping in single quotes, and escape internal quotes (e.g., 'O''Reilly')
if ischar(cellstr)
    string = ['''' strrep(cellstr, '''', '''''') ''''];  % e.g., 'abc' -> '''abc'''
    return
end

% If input is not a cell array of strings, raise an error
if ~iscellstr(cellstr)
    error('CELL2STR:Class', 'Input argument must be cell array of strings.');
end

% Input must be 2-dimensional (i.e., a matrix of strings, not ND array)
if ndims(cellstr) > 2
    error('CELL2STR:TwoDInput', 'Input cell array must be 2-D.');
end

% Get number of columns in cell array
ncols = size(cellstr, 2);

% Process all columns except the last
% For each element: wrap with quotes and escape internal single quotes,
% then append a comma at the end
for i = 1:ncols-1
    cellstr(:, i) = cellfun(@(x) ['''' strrep(x, '''', '''''') ''','], ...
        cellstr(:, i), 'UniformOutput', false);
end

% Process the last column
% Append a semicolon instead of a comma to denote the end of a row
if ncols > 0
    cellstr(:, ncols) = cellfun(@(x) ['''' strrep(x, '''', '''''') ''';'], ...
        cellstr(:, ncols), 'UniformOutput', false);
end

% Transpose the cell array so it can be concatenated row-wise into a single string
cellstr = cellstr';

% Concatenate all elements into a single string and wrap in curly braces
% to create a proper MATLAB cell array syntax
string = ['{' cellstr{:} '}'];

end
