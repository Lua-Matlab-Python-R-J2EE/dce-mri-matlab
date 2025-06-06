function test_peakIndex()
%% TEST_PEAKINDEX - Unit tests for the peakIndex function.
%
% Author: Dr. Tanuj Puri
% Date:   01/2014, updated 2025
% Warning: This is an untested code/implementation and should be used
% with caution in clinical and pre-clinical settings. The author takes no 
% responsibility of any kind about the output results from this code.
%
% This test suite verifies correctness, robustness, and error handling
% for the peakIndex function, which is expected to return the maximum
% value in a vector and its index. The test includes:
%   - Normal test cases with known peak values
%   - Edge cases like flat vectors, negatives, or single elements
%   - Error cases with NaN, Inf, and empty vectors
%%
    fprintf('\nRunning test_peakIndex()...\n');

    % Define test cases as a cell array of structs
    % Each struct contains:
    %   - input: input vector
    %   - expectedVal: expected peak value (max)
    %   - expectedInd: expected index of the peak
    %   - expectError: true if the input should cause an error
    testCases = {
        % Nominal / typical cases
        struct('input', [1, 2, 3, 2, 1],         'expectedVal', 3,  'expectedInd', 3, 'expectError', false),
        struct('input', [0, 0, 10, 0, 0],        'expectedVal', 10, 'expectedInd', 3, 'expectError', false),
        struct('input', [1, 5, 3, 5, 2],         'expectedVal', 5,  'expectedInd', 2, 'expectError', false),
        struct('input', [10],                   'expectedVal', 10, 'expectedInd', 1, 'expectError', false),
        struct('input', [-5, -10, -2, -20],      'expectedVal', -2, 'expectedInd', 3, 'expectError', false),
        struct('input', [4, 4, 4, 4],            'expectedVal', 4,  'expectedInd', 1, 'expectError', false),
        struct('input', (1:100),                'expectedVal', 100,'expectedInd', 100,'expectError', false),
        struct('input', flip(1:100),            'expectedVal', 100,'expectedInd', 1,  'expectError', false),
        struct('input', [0, 1, 2, 3, 2, 1, 0],   'expectedVal', 3,  'expectedInd', 4, 'expectError', false),

        % Error cases (NaN, Inf, empty vector)
        struct('input', [1, NaN, 3],             'expectedVal', [], 'expectedInd', [], 'expectError', true),
        struct('input', [1, Inf, 3],             'expectedVal', [], 'expectedInd', [], 'expectError', true),
        struct('input', [],                     'expectedVal', [], 'expectedInd', [], 'expectError', true)
    };

    % Loop through each test case
    for k = 1:length(testCases)
        disp("----")
        tc = testCases{k};
        try
            % Call the function under test
            [val, ind] = peakIndex(tc.input);

            % If an error was expected but not raised, it's a failed test
            if tc.expectError
                error('Test %d failed: Expected an error, but function returned without error.', k);
            end

            % Validate returned peak value
            assert(isequal(val, tc.expectedVal), ...
                'Test %d failed: Expected value %.2f, got %.2f.', k, tc.expectedVal, val);

            % Validate returned peak index
            assert(isequal(ind, tc.expectedInd), ...
                'Test %d failed: Expected index %d, got %d.', k, tc.expectedInd, ind);

            % Report success
            fprintf('Test %2d passed.\n', k);

        catch ME
            % If error was expected, the test passes
            if tc.expectError
                fprintf('Test %2d passed (error caught as expected: %s).\n', k, ME.message);
            else
                % Unexpected error: report failure
                fprintf('Test %2d failed: %s\n', k, ME.message);
            end
        end
    end

    fprintf('All tests in test_peakIndex completed.\n');
end
