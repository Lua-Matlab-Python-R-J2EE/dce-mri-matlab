function [X,Loc,FA,ST,SD,repT,Pid,Info] = readDicomImgs(Folder)
%--------------------------------------------------------------------------
% FUNCTION: readDicomImgs
%
% readDicomImgs
%    ├─ calls getNames      ← obtains list of DICOM file base names
%    ├─ calls dicomread     ← reads pixel data from each DICOM file
%    ├─ calls dicominfo     ← extracts metadata from each DICOM file
%    └─ calls getfield_safe ← safely retrieves fields from metadata structs (helper function)
%
% PURPOSE:
%   Reads all DICOM image files from a specified folder and extracts
%   the image data and relevant metadata such as Flip Angle, Series Time,
%   Slice Location, and Repetition Time. It assumes all DICOM files are
%   single-slice (2D) and belong to a consistent imaging series.
%
% INPUT:
%   Folder - String path to the folder containing DICOM (.dcm) image files.
%
% OUTPUTS:
%   X     - 3D array of DICOM image slices, sorted by Slice Location.
%   Loc   - Vector of Slice Location values for each slice.
%   FA    - Flip Angle (from DICOM metadata, same for all slices).
%   ST    - Series Time (from DICOM metadata).
%   SD    - Series Date (from DICOM metadata).
%   repT  - Repetition Time in seconds (converted from ms in DICOM).
%   Pid   - Patient ID (assumed same across slices).
%   Info  - Cell array of DICOM metadata structures for each slice.
%
% NOTE:
%   - Relies on a helper function `getNames` to get base filenames.
%   - Assumes all files in the folder are valid DICOM files.
%   - This version includes comprehensive input validation and error checks.
%
% AUTHOR: Dr. Tanuj Puri
% DATE  : 01/2014, comments updated 06/2025
%
% DISCLAIMER:
%   This is untested code and should not be used for diagnostic purposes
%   without validation. No guarantees are made about its correctness.
%
%   => PLEASE TEST BEFORE USING IT <=
%
%--------------------------------------------------------------------------

    % Check for exactly one input argument (the folder path)
    if nargin ~= 1
        error('readDicomImgs:InvalidNumInputs', ...
              'Function requires exactly one input argument: the folder path.');
    end

    % Ensure input is a non-empty string
    if isempty(Folder) || ~ischar(Folder)
        error('readDicomImgs:InvalidInputType', ...
              'Input must be a non-empty character array (string path).');
    end

    % Ensure the input folder exists
    if ~exist(Folder, 'dir')
        error('readDicomImgs:FolderNotFound', ...
              'The specified folder does not exist: %s', Folder);
    end

    % Retrieve base names of files (no extension) from the folder
    try
        outNames = getNames(Folder);  % Custom helper function call
    catch ME
        error('readDicomImgs:getNamesFailed', ...
              'Failed to retrieve file names using getNames(): %s', ME.message);
    end

    % Count the number of files returned
    NumImgs = length(outNames);

    % Check that at least one file was found
    if NumImgs == 0
        error('readDicomImgs:NoFilesFound', ...
              'No DICOM files found in the provided folder.');
    end

    % Build full path to the first file for initial dimension and header check
    firstFile = fullfile(Folder, outNames{1});

    % Confirm the first file exists
    if ~exist(firstFile, 'file')
        error('readDicomImgs:MissingFirstFile', ...
              'First DICOM file does not exist: %s', firstFile);
    end

    % Attempt to read the first DICOM file
    try
        firstImg = double(dicomread(firstFile));  % Read image data
        hdrInfo  = dicominfo(firstFile);          % Read metadata
    catch
        error('readDicomImgs:CorruptFirstFile', ...
              'Unable to read the first DICOM file: %s', firstFile);
    end

    % Allocate the 3D image volume with dimensions [NumSlices x Height x Width]
    X = zeros([NumImgs size(firstImg)]);

    % Initialize vector for slice locations
    Loc = zeros(NumImgs, 1);

    % Initialize cell array to store DICOM headers
    Info = cell(NumImgs, 1);

    % Initialize metadata fields (first slice only)
    FA   = NaN;
    ST   = '';
    SD   = '';
    repT = NaN;
    Pid  = 'unknown';

    % Loop through all image files
    for i = 1:NumImgs

        % Construct full path to current image
        filePath = fullfile(Folder, outNames{i});

        % Check file existence before reading
        if ~exist(filePath, 'file')
            error('readDicomImgs:MissingFile', 'File not found: %s', filePath);
        end

        % Try reading image and metadata
        try
            image   = double(dicomread(filePath));
            hdrInfo = dicominfo(filePath);
        catch ME
            error('readDicomImgs:ReadError', ...
                  'Failed to read DICOM file: %s\n%s', filePath, ME.message);
        end

        % Ensure image is 2D (single slice)
        if size(image, 3) ~= 1
            error('readDicomImgs:Non2DImage', ...
                  'Only 2D DICOM slices are supported: %s', filePath);
        end

        % Retrieve rescale parameters from header or set defaults
        RescaleIntercept = getfield_safe(hdrInfo, 'RescaleIntercept', 0);
        RescaleSlope     = getfield_safe(hdrInfo, 'RescaleSlope', 1);

        % Apply intensity scaling using DICOM parameters
        scaledImg = image * RescaleSlope + RescaleIntercept;

        % Store scaled image in output volume
        X(i,:,:) = scaledImg;

        % Get slice location or fallback to index if not present
        Loc(i) = getfield_safe(hdrInfo, 'SliceLocation', i);

        % Save full metadata struct
        Info{i} = hdrInfo;

        % Extract shared metadata from first slice only
        if i == 1
            FA   = getfield_safe(hdrInfo, 'FlipAngle', NaN);
            ST   = getfield_safe(hdrInfo, 'SeriesTime', '');
            SD   = getfield_safe(hdrInfo, 'SeriesDate', '');
            repT = getfield_safe(hdrInfo, 'RepetitionTime', NaN) / 1000; % Convert ms to sec
            Pid  = getfield_safe(hdrInfo, 'PatientID', 'unknown');
        end
    end

    % Sort slices by SliceLocation
    [~, I] = sort(Loc);        % Sort indices
    X      = X(I,:,:);         % Reorder image volume
    Loc    = Loc(I);           % Reorder location vector
    Info   = Info(I);          % Reorder metadata
end                            % end of readDicomImgs

%--------------------------------------------------------------------------
% HELPER FUNCTION: getfield_safe
%--------------------------------------------------------------------------
% FUNCTION: getfield_safe
%
% PURPOSE:
%   Safely retrieves the value of a specified field from a structure.
%   If the field does not exist, returns a provided default value instead
%   of throwing an error. This helps in robust handling of optional or
%   missing fields, especially in metadata structures like DICOM headers.
%
% INPUTS:
%   S         - Structure from which to retrieve the field value.
%   fieldname - String name of the field to access within the structure S.
%   default   - Value to return if the field 'fieldname' does not exist in S.
%
% OUTPUT:
%   val       - Value of the field if it exists, otherwise the default value.
%
% EXAMPLE USAGE:
%   val = getfield_safe(hdrInfo, 'FlipAngle', 0);
%   % This returns hdrInfo.FlipAngle if it exists, else returns 0.
%
%--------------------------------------------------------------------------

function val = getfield_safe(S, fieldname, default)
    % Check if the input structure S has a field named 'fieldname'
    if isfield(S, fieldname)
        % If field exists, return its value
        val = S.(fieldname);
    else
        % If field does not exist, return the default value provided
        val = default;
    end
end % end of getfield_safe

