function test_interpolateTime()
% test_interpolateTime - Unit test suite for the interpolateTime function.
%
% This function tests the behavior of `interpolateTime` with a range of
% valid and invalid inputs. It ensures that the function only accepts
% clean, strictly increasing numeric vectors and returns correct interpolated
% output at 1-second intervals.
%
% The test prints PASS/FAIL for each case and summarizes results.
%
% DEPENDENCIES:
%   ├── interpolateTime.m
%   └── isValidTimeVector.m
%
% USAGE:
%   test_interpolateTime()
%
% AUTHOR:   Dr. Tanuj Puri
% DATE:     01/2014, updated 06/2025
%

    fprintf('Running tests for interpolateTime...\n\n');

    tests = {
        % Description,             Input,            Expected Output,        Should Pass?
        {'Simple increasing',      [0 4 8 10],        0:10,                   true}
        {'Non-zero start',         [1 11 12],         1:12,                   true}
        {'Column vector input',    [1; 3; 5],         1:5,                    true}
        {'Column vector input',    [1; 0; 5],         1:5,                    false}
        {'Decimal seconds',        [0.5 1.5 3.5],     [],                     false}
        {'Single time point',      5,                 [],                     false}
        {'Non-numeric string',     '1 2 3',           [],                     false}
        {'Empty vector',           [],                [],                     false}
        {'Complex input',          [1+2i 2+3i],       [],                     false}
        {'Contains NaN',           [1 NaN 3],         [],                     false}
        {'Contains Inf',           [1 Inf 3],         [],                     false}
        {'Non-increasing',         [0 1 1 2],         [],                     false}
        {'Negative time',          [-1 0 1],          [],                     false}
    };

    nPass = 0;
    for k = 1:numel(tests)
        test = tests{k};
        name = test{1};
        inputVec = test{2};
        expected = test{3};
        shouldPass = test{4};

        fprintf('Test %2d: %-25s ... ', k, name);
        try
            result = interpolateTime(inputVec);
            if shouldPass
                % Compare result
                if isequal(result, expected)
                    fprintf('[PASS]\n');
                    nPass = nPass + 1;
                else
                    fprintf('[FAIL] (unexpected output)\n');
                end
            else
                fprintf('[FAIL] (should have thrown error)\n');
            end
        catch
            if shouldPass
                fprintf('[FAIL] (unexpected error)\n');
            else
                fprintf('[PASS]\n');
                nPass = nPass + 1;
            end
        end
    end

    % Summary
    fprintf('\nSummary: %d/%d tests passed.\n', nPass, numel(tests));
end
