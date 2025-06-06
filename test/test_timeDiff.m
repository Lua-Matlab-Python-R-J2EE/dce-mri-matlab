function test_timeDiff()
%
% TEST_TIMEDIFF: Unit tests for the timeDiff function.
% This function checks a variety of valid and invalid scenarios to ensure the function behaves correctly.
%
% Author: Dr. Tanuj Puri
% Date:   01/2014, updated 2025
% Warning: This is an untested code/implementation and should be used
% with caution in clinical and pre-clinical settings. The author takes no 
% responsibility of any kind about the output results from this code.
%
fprintf('\nRunning test_timeDiff()...\n');

% Initialize test cases as a struct array
testCases = [ ...
    % ==== Pass Cases ====
    struct('T1', '16:40:07.875', 'T2', '16:41:07.875', 'expected', 60, 'shouldError', false); ...
    struct('T1', '00:00:00.000', 'T2', '00:00:00.000', 'expected', 0, 'shouldError', false); ...
    struct('T1', '12:00:00',     'T2', '13:00:00',     'expected', 3600, 'shouldError', false); ...    
    struct('T1', '12:00:00.000',  'T2', '14:00:00.000', 'expected', 7200, 'shouldError', false); ...           
    struct('T1', '23:59:59',      'T2', '00:00:10',     'expected', 86389, 'shouldError', false); ... 
    struct('T1', '23:59:59.999', 'T2', '23:59:59.000', 'expected', 0.999, 'shouldError', false); ...
    struct('T1', '16:00:00',     'T2', '15:00:00',     'expected', 3600, 'shouldError', false); ... 
    
    % ==== Edge/Fail Cases ====
    struct('T1', '',              'T2', '12:00:00',     'expected', NaN, 'shouldError', true); ...
    struct('T1', '12:00:00',      'T2', '',             'expected', NaN, 'shouldError', true); ...
    struct('T1', '30:90:07',      'T2', '12:00:00',     'expected', NaN, 'shouldError', true); ...
    struct('T1', 'not a time',    'T2', '16:00:00',     'expected', NaN, 'shouldError', true); ...
    struct('T1', 12345,           'T2', '16:00:00',     'expected', NaN, 'shouldError', true); ...
    struct('T1', '12:00:00',      'T2', NaN,            'expected', NaN, 'shouldError', true); ...
    struct('T1', '12:00:00',      'T2', '12:60:00',     'expected', NaN, 'shouldError', true); ...
    struct('T1', '12:00:00',      'T2', '12:00:60',     'expected', NaN, 'shouldError', true); ...
];

passCount = 0;
failCount = 0;

for i = 1:length(testCases)
    tc = testCases(i);
    try
        out = timeDiff(tc.T1, tc.T2);

        if tc.shouldError
            fprintf('Test %d FAILED (Expected error, but function returned %.3f)\n', i, out);
            failCount = failCount + 1;
        else
            if abs(out - tc.expected) < 1e-6
                fprintf('Test %d PASSED\n', i);
                passCount = passCount + 1;
            else
                fprintf('Test %d FAILED (Expected %.3f, got %.3f)\n', i, tc.expected, out);
                failCount = failCount + 1;
            end
        end
    catch ME
        if tc.shouldError
            fprintf('Test %d PASSED (Error caught: %s)\n', i, ME.message);
            passCount = passCount + 1;
        else
            fprintf('Test %d FAILED (Unexpected error: %s)\n', i, ME.message);
            failCount = failCount + 1;
        end
    end
end

fprintf('\nTest Summary: %d PASSED, %d FAILED\n', passCount, failCount);
end
