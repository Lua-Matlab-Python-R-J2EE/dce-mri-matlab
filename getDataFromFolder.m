function [ Y,Loc,FA,ST,SD,repT,Pid,Info,FA_ST,repT_ST] ...
                               = getDataFromFolder(parentDir, folderName)
%-------------------------------------------------------------------------------------------------------------
% FUNCTION: getDataFromFolder
%
% getDataFromFolder
%     ├── getNames
%     │       - Purpose: Returns list of file/folder names (without extensions)
%     │       - Used to scan directories for folders and files.
%     │
%     └── readDicomImgs
%     |        - Purpose: Reads all DICOM image files in a folder,
%     |                  extracts image data and key metadata.
%     |        - Returns image arrays, slice location, flip angle, series time,
%     |          repetition time, patient ID, and header info.
%     |
%     └── Internally uses dicomread and dicominfo (built-in functions).
%
% PURPOSE:
%   Recursively searches within a parent directory for subfolders matching
%   a specified folderName pattern (case-insensitive). For each matching
%   folder, it further explores its subfolders, reads DICOM images using
%   the readDicomImgs function, and collects image data along with key
%   metadata such as Slice Location, Flip Angle, Series Time, Repetition Time,
%   Patient ID, and DICOM header info.
%
%   The function organizes the collected data into cell arrays and matrices,
%   facilitating multi-level storage of image sets and metadata for analysis.
%
% INPUTS:
%   parentdir  - String path of the parent directory to search within.
%   folderName - Partial or full folder name pattern to identify target
%                folders (search is case-insensitive and partial matching).
%
% OUTPUTS:
%   Y         - 2D Cell array of image data arrays returned by readDicomImgs,
%               organized by subfolder and folder indices.
%   Loc       - Vector of Slice Locations (from last read folder).
%   FA        - Matrix of Flip Angles (per image set), size matches data.
%   ST        - Matrix of Series Times (numeric), corresponding to image sets.
%   SD        - Series Date string (from last read folder).
%   repT      - Matrix of Repetition Times (seconds), per image set.
%   Pid       - Patient ID string (from last read folder).
%   Info      - 2D Cell array of DICOM metadata structs for each image set.
%   FA_ST     - Matrix combining Flip Angle and Series Time for quick ref.
%   repT_ST   - Matrix combining Repetition Time and Series Time similarly.
%
% NOTE:
%   - Depends on external helper functions `getNames` and `readDicomImgs`.
%   - Internally uses `dicomread` and `dicominfo` (built-in functions).
%   - Assumes directory structure contains DICOM image sets inside nested
%     folders named consistently with folderName pattern.
%   - Outputs Loc, SD, Pid correspond to last folder read (if multiple folders matched).
%
% WARNING:
%   This is untested code and should be used cautiously in clinical
%   or pre-clinical workflows. The author disclaims any responsibility
%   for the correctness or safety of results produced.
%
%   => PLEASE TEST BEFORE USING IT <=
%
% AUTHOR: Dr. Tanuj Puri
% DATE:   01/2014, updated 06/2025
% 
% Example:
%    [Y,Loc,FA,ST,SD,repT,Pid,Info,FA_ST,repT_ST] = getDataFromFolder(parentdir,'tip');% data from VFA
%    or
%    [Y,Loc,FA,ST,SD,repT,Pid,Info,FA_ST,repT_ST] = getDataFromFolder(parentdir,'vtr');% data from VTR
%
%
% =========================================================================
% DATA ORGANIZATION EXPLANATION 
% =========================================================================
%
%---------------------------------
% Disk-Level Folder Organization:
% --------------------------------
% Each Flip Angle (FA) corresponded to a folder: tip02, tip05, tip10, tip18.
% Each folder contained 6 subfolders, representing 6 different recovery times.
% Inside each subfolder contained a stack of 2D DICOM images (forming a 3D volume)
%-----------------------------------------------------------------------------------------
%| Flip Angle (°) | Tip Folder | DICOM Subfolders (relative path)   | Notes              |
%| -------------- | ---------- | ---------------------------------- | ------------------ |
%|     2          |  tip02     |  02,   03,  04, 05, 06, 07         | → 6 recovery times |
%|     5          |  tip05     |  08,   09,  10, 11, 12, 13         |                    |
%|     10         |  tip10     |  14,   15,  16, 17, 18, 19         |                    |
%|     18         |  tip18     |  20,   21,  22, 23, 24, 25         |                    |
%-----------------------------------------------------------------------------------------
%
% Inside each subfolder is a DICOM image like 00010016, 00020016, etc.
%
% ----------------------------
% In-Memory Structure (Y):
% ----------------------------
% Y is a 2D cell array of size: [6 × 4]
%   → Rows    (1 to 6): Recovery time points (from subfolders 02–07, etc.)
%   → Columns (1 to 4): Flip angles (2°, 5°, 10°, 18°)
%
% Each Y{j,i} is 3D array of size [X × Y × Z], where Z is typically the number of slices.
% Each Y{j,i} contains a stack of 2D DICOM images forming a 3D image volume, where,
%   - j = time point (1 to 6)
%   - i = flip angle index (1 to 4)
%
%------------------------------------------------------------------------------------
%|        | FA = 2° (Tip02) | FA = 5° (Tip05) | FA = 10° (Tip10) | FA = 18° (Tip18) |
%| ------ | --------------- | --------------- | ---------------- | ---------------- |
%| Time 1 |    Y{1,1}       |     Y{1,2}      |    Y{1,3}        |    Y{1,4}        |
%| Time 2 |    Y{2,1}       |     Y{2,2}      |    Y{2,3}        |    Y{2,4}        |
%| Time 3 |    Y{3,1}       |     Y{3,2}      |    Y{3,3}        |    Y{3,4}        |
%| Time 4 |    Y{4,1}       |     Y{4,2}      |    Y{4,3}        |    Y{4,4}        |
%| Time 5 |    Y{5,1}       |     Y{5,2}      |    Y{5,3}        |    Y{5,4}        |
%| Time 6 |    Y{6,1}       |     Y{6,2}      |    Y{6,3}        |    Y{6,4}        |
%------------------------------------------------------------------------------------
%
% Example:
%   Y{3,2} → a stack of 2D DICOM images forming a 3D volume at 3rd time point, 2nd flip angle (i.e., FA = 5°)
%
% =========================================================================

%-------------------------------------------------------------------------------------------------------------

    %----------------------- INPUT VALIDATION ----------------------------------

    % Check if 'parentDir' is a non-empty string or character vector
    if ~(ischar(parentDir) || (isstring(parentDir) && isscalar(parentDir)))
        error('Input ''parentDir'' must be a non-empty string or character vector.');
    end
    parentDir = char(parentDir); % Convert to char if string

    % Check if directory exists and is accessible
    if ~exist(parentDir, 'dir')
        error('Specified parent directory "%s" does not exist or is not accessible.', parentDir);
    end

    % Validate 'folderName' is a string/char and non-empty
    if ~(ischar(folderName) || (isstring(folderName) && isscalar(folderName)))
        error('Input ''folderName'' must be a non-empty string or character vector.');
    end
    folderName = char(folderName);

    if isempty(folderName)
        error('Input ''folderName'' cannot be an empty string.');
    end

    %----------------------- INITIALIZE OUTPUTS ---------------------------------

    Y        = {};          % 2D Cell array to hold DICOM image data arrays per folder
    Info     = {};          % 2D Cell array to hold DICOM header info structs
    FA       = [];          % Flip Angle matrix (numeric)
    ST       = [];          % Series Time matrix (numeric)
    SD       = '';          % Series Date (string)
    repT     = [];          % Repetition Time matrix (numeric)
    Pid      = 'unknown';   % Patient ID (string)
    FA_ST    = [];          % Combined Flip Angle and Series Time matrix
    repT_ST  = [];          % Combined Repetition Time and Series Time matrix
    Loc      = [];          % Slice Location vector (from last read folder)

    %----------------------- FIND MATCHING FOLDERS ------------------------------

    % Get all folder names in parentDir (using getNames, which returns base names)
    Folders = getNames(parentDir);

    % Ensure output is cell array of strings
    if ~iscell(Folders)
        error('getNames did not return a cell array of folder names as expected.');
    end

    % Filter folders matching 'folderName' substring (case-insensitive)
    matchMask = ~cellfun('isempty', strfind(upper(Folders(:)), upper(folderName)));
    Folders = Folders(matchMask);

    % Check if any folders matched the substring
    if isempty(Folders)
        warning('No folders containing substring "%s" found in parent directory.', folderName);
        % Return empty outputs since no data found
        return;
    end

    %----------------------- PROCESS EACH MATCHING FOLDER -----------------------

    % Loop over each matched folder found in parentDir
    for i = 1:length(Folders)

        % Construct full path to the matched folder
        Path = fullfile(parentDir, Folders{i});

        % Check if Path is a valid directory (should be but double-check)
        if ~exist(Path, 'dir')
            warning('Matched folder path "%s" does not exist or is not accessible. Skipping.', Path);
            continue;
        end

        % Retrieve all items (files/folders) inside matched folder (subfolders assumed)
        PathScan = getNames(Path);

        % getNames should return cell array
        if ~iscell(PathScan)
            warning('getNames failed to return a cell array for folder "%s". Skipping.', Path);
            continue;
        end

        % Loop through each item (subfolder) inside the matched folder
        for j = 1:length(PathScan)

            % Build full path to subfolder inside the matched folder
            PathScanPath = fullfile(parentDir, Folders{i}, PathScan{j});

            % Check if subfolder exists before proceeding
            if ~exist(PathScanPath, 'dir')
                warning('Subfolder path "%s" does not exist or is not accessible. Skipping.', PathScanPath);
                continue;
            end

            % Attempt to read DICOM images and metadata from the subfolder
            try
                [vol, Loc_tmp, FA_, ST_, SD_, repT_, Pid_, Info_] = readDicomImgs(PathScanPath);
            catch ME
                warning('Error reading DICOM images from folder "%s": %s', PathScanPath, ME.message);
                % Skip this subfolder on error, continue to next
                continue;
            end

            % Validate expected outputs from readDicomImgs

            Y{j,i} = vol;  % Store 3D image volume
            Info{j,i} = Info_;

            % Slice Location vector for last read folder only (overwritten)
            Loc = Loc_tmp;

            % Store Flip Angle and Repetition Time into matrices
            FA(j,i)   = validateNumericScalar(FA_, 'Flip Angle');
            repT(j,i) = validateNumericScalar(repT_, 'Repetition Time');

            % Convert Series Time (string) to double (seconds, numeric)
            ST(j,i) = str2double(ST_);
            if isnan(ST(j,i))
                warning('Series Time conversion to numeric failed for folder "%s". Setting to NaN.', PathScanPath);
            end

            % Store Series Date and Patient ID for last read folder only (overwritten)
            SD  = SD_;
            Pid = Pid_;

            % Compose combined FA_ST and repT_ST matrices
            % First row contains Flip Angle or Repetition Time
            FA_ST(1,i)     = FA(j,i);
            repT_ST(1,i)   = repT(j,i);

            % Subsequent rows contain Series Time as numeric
            FA_ST(1+j,i)   = ST(j,i);
            repT_ST(1+j,i) = ST(j,i);

        end % for j ends

    end % for i ends

end% end of getDataFromFolder


%--------------------------------------------------------------------------
% Helper function to validate a numeric scalar output and warn if invalid
function val = validateNumericScalar(inputVal, fieldName)
    if isnumeric(inputVal) && isscalar(inputVal)
        val = inputVal;
    else
        warning('%s is expected to be a numeric scalar. Received invalid value; setting to NaN.', fieldName);
        val = NaN;
    end
end
