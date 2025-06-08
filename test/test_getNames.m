function test_getNames()
%--------------------------------------------------------------------------
% TEST FUNCTION: Unit test function for getNames
%
% AUTHOR: Dr. Tanuj Puri
% DATE:   01/2014, updated 06/2025
%
% PURPOSE:
%   This function tests the getNames function across various
%   scenarios including normal operation, edge cases, and error handling.
%   It validates correct output, proper error throwing, and behavior with
%   different input conditions.
%
%   The tests include:
%     - Valid directory with files and subfolders
%     - Empty directory
%     - Invalid input types
%     - Excess input arguments
%     - Non-existent directory path
%     - Excess output arguments requested
%
%--------------------------------------------------------------------------

    fprintf('Running tests for getNames.m ...\n');

    % Disable confirmation prompt for recursive directory removal to allow
    % automated cleanup during tests without manual intervention.
    if exist('confirm_recursive_rmdir', 'builtin')
        confirm_recursive_rmdir(false);
    end

    % Initialize counters for tests passed and failed
    passCount = 0;
    failCount = 0;

    %======================================================================
    %                         TEST STARTS
    %======================================================================

    %--- Test 1: Valid directory containing files and folders ---%
    % This test creates a temporary directory with sample files and a folder.
    % It ensures getNames returns the base names (no extensions) of all
    % items found, including subfolders.
    passCount = passCount + runTest('Valid directory with files/folders', ...
                   @() test_valid_directory(), false);

    %--- Test 2: Empty directory ---%
    % This test creates an empty temporary directory and verifies the output
    % is an empty cell array, confirming correct handling of no contents.
    passCount = passCount + runTest('Empty directory', ...
                          @() test_empty_directory(), false);

    %--- Test 3: Invalid input type (numeric) ---%
    % This test deliberately passes a numeric input instead of a string or char,
    % expecting the function to raise an input type validation error.
    passCount = passCount + runTest('Invalid input: numeric', ...
                          @() getNames(123), true);

    %--- Test 4: Excess input arguments ---%
    % This test calls getNames with more than one input argument, which
    % should cause the function to throw an error due to input validation.
    passCount = passCount + runTest('Too many inputs', ...
                          @() getNames('someDir', 'extra'), true);

    %--- Test 5: Non-existent directory ---%
    % This test attempts to access a directory path that does not exist.
    % The function should raise an error indicating the invalid path.
    passCount = passCount + runTest('Non-existent directory', ...
                          @() test_nonexistent_directory(), true);

    %--- Test 6: Excess output arguments ---%
    % This test calls getNames expecting more than one output argument,
    % which violates the function's contract and should produce an error.
    passCount = passCount + runTest('Too many output arguments', ...
                          @() test_output_count(), true);

    % Calculate how many tests failed
    failCount = 6 - passCount;

    % Display summary of results
    fprintf('\nTest Summary: %d passed, %d failed.\n', passCount, failCount);

    %======================================================================
    %                         HELPER FUNCTIONS
    %======================================================================

    function result = runTest(testName, testFunc, expectError)
    %----------------------------------------------------------------------
    % runTest
    % A helper function to run an individual test case and evaluate its result.
    %
    % Inputs:
    %   testName    - String describing the test scenario.
    %   testFunc    - Function handle to the test case.
    %   expectError - Logical flag indicating if the test expects an error.
    %
    % Output:
    %   result      - Logical flag indicating if test passed (true) or failed (false).
    %
    % This function executes the test and:
    %   - If an error occurs and was expected, the test passes.
    %   - If an error occurs but was not expected, the test fails.
    %   - If no error occurs and was not expected, the test passes.
    %   - If no error occurs but was expected, the test fails.
    %----------------------------------------------------------------------
        try
            testFunc();  % Execute the test function

            if expectError
                % No error occurred but was expected → fail test
                fprintf('[FAIL] %s\n  Expected error but none occurred.\n', testName);
                result = false;
            else
                % No error occurred and none expected → pass test
                fprintf('[PASS] %s\n', testName);
                result = true;
            end
        catch ME
            if expectError
                % Error occurred and was expected → pass test
                fprintf('[PASS] %s (caught expected error)\n', testName);
                result = true;
            else
                % Unexpected error occurred → fail test and show message
                fprintf('[FAIL] %s\n  Unexpected error: %s\n', testName, ME.message);
                result = false;
            end
        end
    end

    function test_valid_directory()
    %----------------------------------------------------------------------
    % Creates a temporary directory with mixed content:
    %   - Two files with extensions
    %   - One subfolder
    %
    % Validates that getNames:
    %   - Returns all file/folder names without their extensions
    %   - Includes folders in the output
    %----------------------------------------------------------------------
        % Generate a unique temporary directory path
        testDir = tempname;
        mkdir(testDir);  % Create the directory on disk

        % Create two dummy files inside the directory
        fclose(fopen(fullfile(testDir, 'file1.txt'), 'w'));
        fclose(fopen(fullfile(testDir, 'file2.dat'), 'w'));

        % Create a subdirectory inside the directory
        mkdir(fullfile(testDir, 'folder1'));

        % Expected output list (base names without extensions)
        expected = {'file1', 'file2', 'folder1'};

        % Invoke the function under test
        actual = getNames(testDir);

        % Verify the returned names match the expected names (order-insensitive)
        assert(isequal(sort(actual), sort(expected)), ...
               'Returned names did not match expected values.');

        % Cleanup: remove the temporary directory and its contents
        rmdir(testDir, 's');
    end

    function test_empty_directory()
    %----------------------------------------------------------------------
    % Creates an empty temporary directory and verifies:
    %   - getNames returns an empty cell array, as there are no files or folders
    %----------------------------------------------------------------------
        testDir = tempname;
        mkdir(testDir);

        % Call function and capture output
        actual = getNames(testDir);

        % Assert output is empty as directory contains no entries (other than '.' and '..')
        assert(isempty(actual), 'Expected empty output for empty directory.');

        % Cleanup
        rmdir(testDir, 's');
    end

    function test_output_count()
    %----------------------------------------------------------------------
    % Attempts to call getNames requesting two output arguments,
    % which violates the function's design and should throw an error.
    % This test confirms proper enforcement of output argument count.
    %----------------------------------------------------------------------
        testDir = tempname;
        mkdir(testDir);

        % Create a dummy file so the function has output to produce
        fclose(fopen(fullfile(testDir, 'file1.txt'), 'w'));

        % Attempt to get two outputs (invalid usage)
        [a, b] = getNames(testDir);

        % Cleanup
        rmdir(testDir, 's');
    end

    function test_nonexistent_directory()
    %----------------------------------------------------------------------
    % Attempts to invoke getNames with a directory path that does not exist.
    % The function is expected to throw an error indicating invalid path.
    %----------------------------------------------------------------------
        getNames('this_dir_does_not_exist_12345');
    end

end % end of test_getNames
