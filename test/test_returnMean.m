function test_returnMean()
% TEST_RETURNMEAN Unit tests for returnMean function.
%
% This function checks a variety of input cases, both valid and invalid,
% to verify correctness and robustness of returnMean.
%
% Author: Dr. Tanuj Puri
% Date:   01/2014
% Warning: This is an untested code/implementation and should be used
% with caution in clinical and pre-clinical settings. The author takes no 
% responsibility of any kind about the output results from this code.
%
fprintf('\nRunning test_returnMean() ...\n');

% Define test cases
testCases = {
    struct('desc', 'All zeros in ROI', ...
           'calcVec', zeros(3), 'mask', ones(3), 'expected', NaN),

    struct('desc', 'Simple case with values below 1', ...
           'calcVec', [0.2 0.4 0.6; 0.1 0.3 0.2; 0.0 0.0 0.0], ...
           'mask', [1 1 1; 1 0 0; 0 0 0], ...
           'expected', mean([0.2, 0.4, 0.6, 0.1])),

    struct('desc', 'Values above 1 are excluded', ...
           'calcVec', [0.1 1.2 0.5; 0.2 1.0 0.9; 0.4 0.6 2.0], ...
           'mask', [1 1 1; 1 0 0; 0 0 0], ...
           'expected', mean([0.1, 0.5, 0.2])),  % 0.2667

    struct('desc', 'Empty ROI (all mask zeros)', ...
           'calcVec', rand(4), ...
           'mask', zeros(4), ...
           'expected', NaN),

    struct('desc', 'Mixed values, some >= 1', ...
           'calcVec', [0.7, 1.2; 0.3, 0], ...
           'mask', [1 1; 1 1], ...
           'expected', mean([0.7, 0.3])),  % exclude 1.2, 0

    % === Error Cases ===
    struct('desc', 'Different sized inputs', ...
           'calcVec', rand(3), ...
           'mask', rand(4), ...
           'expectError', true),

    struct('desc', 'Negative values in calcVec', ...
           'calcVec', [0.3 -0.2; 0.5 0.1], ...
           'mask', [1 1; 1 1], ...
           'expectError', true),

    struct('desc', 'NaN in calcVec', ...
           'calcVec', [0.1 NaN; 0.2 0.3], ...
           'mask', [1 1; 1 1], ...
           'expectError', true),

    struct('desc', 'Inf in calcVec', ...
           'calcVec', [0.1 Inf; 0.2 0.3], ...
           'mask', [1 1; 1 1], ...
           'expectError', true),

    struct('desc', 'Complex values in calcVec', ...
           'calcVec', [0.1+1i, 0.2; 0.3, 0.4], ...
           'mask', [1 1; 1 1], ...
           'expectError', true)
};

% Run each test
for i = 1:numel(testCases)
    disp("-----")
    tc = testCases{i};
    fprintf('Test %d: %s ... ', i, tc.desc);

    try
        result = returnMean(tc.calcVec, tc.mask);
        if isfield(tc, 'expectError') && tc.expectError
            error('Expected error but none was thrown.');
        end

        % Both expected and result may be NaN
        if (isnan(tc.expected) && isnan(result)) || isequal(result, tc.expected)
            fprintf('PASS\n');
        elseif abs(result - tc.expected) < 1e-10
            fprintf('PASS (within tolerance)\n');
        else
            fprintf('FAIL\n');
            fprintf('  Expected: %.4f, Got: %.4f\n', tc.expected, result);
        end
    catch ME
        if isfield(tc, 'expectError') && tc.expectError
            fprintf('PASS (expected error: %s)\n', ME.message);
        else
            fprintf('FAIL (unexpected error: %s)\n', ME.message);
        end
    end
end

fprintf('All tests completed.\n');
end
