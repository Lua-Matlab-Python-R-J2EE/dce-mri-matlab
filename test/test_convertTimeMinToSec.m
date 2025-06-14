function test_convertTimeMinToSec()
%
% test_convertTimeMinToSec - Unit test suite for the convertTimeMinToSec function.
%
% This function runs a series of test cases to verify the correct behavior of
% `convertTimeMinToSec`. It tests valid inputs where time vectors are properly
% converted from minutes to seconds, as well as invalid inputs that should trigger
% errors due to input validation failure.
%
% The test suite prints a PASS/FAIL status for each test case and reports the total
% number of successful tests at the end.
%
% No input or output arguments.
%
% USAGE:
%   test_convertTimeMinToSec()
%
% This function is intended to be run interactively in the MATLAB/Octave console
% to ensure the integrity of `convertTimeMinToSec` after changes or before use.
%
% AUTHOR:   Dr. Tanuj Puri
% DATE:     01/2014,  updated 06/2025
%

    fprintf('Running tests for convertTimeMinToSec...\n\n');

    tests = {
        % --- Valid cases ---
        {'Simple valid input', [1 2 3], [60 120 180], true}
        {'Decimals in minutes', [0.5 1 1.5], [30 60 90], true}
        {'Column vector input', [2; 4; 6], [120; 240; 360], true}
        {'Single time point', 5, 300, true}

        % --- Invalid cases (should throw error) ---
        {'Zero-length vector', [], [], false}
        {'Not strictly increasing', [1 2 2], [], false}
        {'Negative values', [-1 0 1], [], false}
        {'Non-numeric input', '10 20 30', [], false}
        {'Complex numbers', [1 2+1i 3], [], false}
        {'Matrix input', [1 2; 3 4], [], false}
        {'Cell array input', {1, 2, 3}, [], false}
    };

    passCount = 0;

    for i = 1:length(tests)
        name = tests{i}{1};
        input = tests{i}{2};
        expected = tests{i}{3};
        shouldPass = tests{i}{4};

        try
            fprintf('Input class: %s, size: %s\n', class(input), mat2str(size(input)));  
            output = convertTimeMinToSec(input);
            if shouldPass
                success = isequal(output, expected);
            else
                success = false;  % It should have failed
            end
        catch
            success = ~shouldPass;
        end

        status = 'FAIL';
        if success
            status = 'PASS';
            passCount = passCount + 1;
        end

        fprintf('[%s] Test %2d: %s\n', status, i, name);
    end

    fprintf('\n%d/%d tests passed.\n', passCount, length(tests));
end
