function test_isValidTimeVector()
% test_isValidTimeVector - Unit test suite for the isValidTimeVector function.
%
% This function runs a comprehensive set of test cases to verify the behavior 
% of `isValidTimeVector`. It checks both valid and invalid inputs, including 
% numeric vectors, empty arrays, strings, cell arrays, logicals, and structures.
%
% The test suite prints a PASS/FAIL status for each case and reports the total 
% number of successful tests at the end.
%
% No input or output arguments.
%
% USAGE:
%   test_isValidTimeVector()
%
% This function is intended to be run interactively in the MATLAB/Octave console 
% to validate updates or modifications to `isValidTimeVector`.
%
% AUTHOR:   Dr. Tanuj Puri
% DATE:     01/2014, updated 06/2025
%  
    fprintf('Running tests for isValidTimeVector...\n\n');
    
    tests = {
        % ---- Valid cases ----
        {'Simple valid time vector', [0 1 2 3], true}
        {'Column vector', [0; 1; 2; 3], true}

        % ---- Invalid cases ----
        {'Decimal values', [0.0 0.1 0.2 0.3], false}
        {'Single element', 0, false}
        {'Not strictly increasing', [0 1 1 2], false}
        {'Negative values', [-1 0 1 2], false}
        {'NaN values', [0 1 NaN 2], false}
        {'Inf values', [0 1 Inf 2], false}
        {'Complex numbers', [0 1+1i 2], false}
        {'String input', 'time', false}
        {'Mixed numeric and string (cell array)', {0, '1', 2}, false}
        {'Empty input', [], false}
        {'Matrix input (not a vector)', [1 2; 3 4], false}
        {'Special characters in string', '@#$', false}
        {'Logical values (booleans)', [true, true, false], false}
        {'Cell array with numbers', {1, 2, 3}, false}
        {'Struct input', struct('a', 1), false}
        {'Duplicate times with decimals', [0 0.5 0.5 1], false}        
    };

    passCount = 0;

    for i = 1:length(tests)
        name = tests{i}{1};
        input = tests{i}{2};
        expected = tests{i}{3};

        try
            result = isValidTimeVector(input);
            success = isequal(result, expected);
        catch
            result = 'ERROR';
            success = expected == false;  % Errors are acceptable for invalid cases
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
