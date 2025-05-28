function test_trapezoidalIntegration()
% TEST_TRAPEZOIDALINTEGRATION Runs test cases for trapezoidalIntegration.m
%
% @ Author: Dr. Tanuj Puri
% @ Date:   01/2014
% @ Warning: This is an untested code/implementation and should be used
% with caution in clinical and pre-clinical settings. The author takes no 
% responsibility of any kind about the output results from this code.
%
fprintf('Running tests for trapezoidalIntegration()...\n\n');

test_cases = {
    % --- Format: {time_vec, Cp_vec, expected_last_val, should_error}
    
    % Valid cases
    { [0; 1; 2], [0; 0; 0], 0, false },                          % Zero Cp
    { [0; 1; 2], [1; 1; 1], 2, false },                          % Constant Cp
    { [0; 1; 2], [0; 1; 2], 2.0, false },                        % Linearly increasing
    { [0; 1; 2; 3], [0; 1; 2; 3], 4.5, false },                  % 3 trapezoids
    { [0; 1; 3], [0; 2; 4], 7, false },                          % Non-uniform time    
    { linspace(0,5,6)', (1:6)', 17.5, false },                   % Increasing Cp, uniform time
    { linspace(0,5,6)', exp(0:1:5)', trapz(0:1:5, exp(0:1:5)), false }, % Exponential Cp

    % Error cases
    { [0; 1; 2], [1; 2], NaN, true },                            % Mismatched lengths
    { [0; NaN; 2], [1; 2; 3], NaN, true },                       % NaN in time
    { [0; 1; 2], [1; 2; Inf], NaN, true },                       % Inf in Cp
    { 'time', [1; 2; 3], NaN, true },                            % Non-numeric time
    { [0; 1; 2], 'Cp', NaN, true },                              % Non-numeric Cp
    { [0, 1, 2], [1, 2, 3], 4.0, false },                        % Row vectors (should auto-fix)
    { 0, 5, NaN, true },                                         % Scalars
    { [0], [1], NaN, true },                                     % Too short
    { [1; 2], [1; 2], NaN, true },                               % staring value is not 0
};

for i = 1:length(test_cases)
    case_i = test_cases{i};
    time_vec = case_i{1};
    Cp_vec   = case_i{2};
    expected = case_i{3};
    should_err = case_i{4};

    try
        result = trapezoidalIntegration(time_vec, Cp_vec);                
        if should_err
            fprintf('Test %d failed: Expected error but function executed.\n', i);
        elseif abs(result(end) - expected) < 1e-6
            fprintf('Test %d passed: Result = %.4f\n', i, result(end));
        else
            fprintf('Test %d failed: Incorrect result. Got %.4f, expected %.4f\n', ...
                    i, result(end), expected);
        end
    catch ME
        if should_err
            fprintf('Test %d passed (expected error): %s\n', i, ME.message);
        else
            fprintf('Test %d failed (unexpected error): %s\n', i, ME.message);
        end
    end
end

fprintf('\nAll tests complete.\n');

end
