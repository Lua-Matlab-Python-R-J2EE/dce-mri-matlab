function test_strtIndex()
%
% @ Author: Dr. Tanuj Puri
% @ Date:   01/2014
% @ Warning: This is an untested code/implementation and should be used
% with caution in clinical and pre-clinical settings. The author takes no 
% responsibility of any kind about the output results from this code.
%
    fprintf('Running tests for strtIndex...\n');

    tests = {
        struct('input', [1 1 1], 'expected', 1),          % Basic positive case
        struct('input', [0 0 1 1 1], 'expected', 3),      % Start later
        struct('input', [1 0 1 1 1], 'expected', 3),      % Break before sequence
        struct('input', [0 1 1 0 1 1 1], 'expected', 5),  % Disjoint segments
        struct('input', [0 0 0], 'expected', -1),         % All zeros
        struct('input', [-1 -2 -3], 'expected', -1),      % All negative
        struct('input', [1 NaN 1 1], 'expected', -1),     % Contains NaN
        struct('input', [0 Inf 1 1 1], 'expected', -1),   % Contains Inf 
        struct('input', [1 1], 'expected', -1),           % Too short
        struct('input', [1 1 0 1 1 1], 'expected', 4),    % Late match
        struct('input', [], 'expected', -1),              % Empty input
        struct('input', [0 0 0 0 0 1 1 0 0 1 1 0 1 1 1], 'expected', 13), % Match late
        struct('input', [1 1 1 0 1 1 1], 'expected', 1),  % Early match
        struct('input', [1 1 1 1], 'expected', 1),        % Longer valid sequence
        struct('input', [0 0 1 0 0 1 1], 'expected', -1), % Never 3 consecutive
        struct('input', [0 0 1 1 0 0 1 1 1], 'expected', 7), % Only one match
        struct('input', [1 + 1i, 1, 1], 'expected', -1),  % Complex input not accepted
        struct('input', [1 2 3], 'expected', 1),          % All positive
        struct('input', [-1 -1 -1 0 0 0], 'expected', -1),% All non-positive
        struct('input', [0 1 1 2 0 1 1 1 0], 'expected', 2) % Multiple potential
        struct('input', [1 0 0 2 0 0 3 1 0], 'expected', -1) % Multiple potential
    };

    for i = 1:length(tests)
        try
            result = strtIndex(tests{i}.input);
            expected = tests{i}.expected;

            if isequal(result, expected)
                fprintf('Test %2d PASSED: input = [%s] → result = %d\n', ...
                        i, num2str(tests{i}.input), result);
            else
                fprintf('Test %2d FAILED: input = [%s] → expected %d, got %d\n', ...
                        i, num2str(tests{i}.input), expected, result);
            end
        catch ME
            fprintf('Test %2d ERROR: input = [%s] → Error message: %s\n', ...
                    i, num2str(tests{i}.input), ME.message);
        end
    end

    fprintf('All strtIndex tests completed.\n');
end
