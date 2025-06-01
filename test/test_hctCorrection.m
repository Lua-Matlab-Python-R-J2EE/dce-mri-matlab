function test_hctCorrection()
%% TEST_HCTCORRECTION Unit tests for the hctCorrection function.
%
% Author: Dr. Tanuj Puri
% Date:   01/2014
% Warning: This is an untested code/implementation and should be used
% with caution in clinical and pre-clinical settings. The author takes no 
% responsibility of any kind about the output results from this code.
%
%% Define all test cases as strings
    tests = {
        "Cp = hctCorrection([1.5, 2.0], 0.38);"     % Custom Hct
        "Cp = hctCorrection(5.2);"                  % Default Hct
        "Cp = hctCorrection([2.0; 3.0], 0.35);"     % Custom Hct, column vector
        "Cp = hctCorrection(5);"                    % Scalar input
        "Cp = hctCorrection([1.0, 2.5, 3.0]);"      % Row vector
        "Cp = hctCorrection([1.0; 2.0; 3.0], 0.30);" % Column vector
        "Cp = hctCorrection(0);"                    % Zero input
        "Cp = hctCorrection([0, 1.1, 2.2], 0.25);"   % Mixed zero & positive
        "Cp = hctCorrection([1 2; 3 4]);"            % Matrix input
        "Cp = hctCorrection([-1, 2, 3]);"            % Negative input
        "Cp = hctCorrection([1, NaN]);"             % NaN
        "Cp = hctCorrection([1, Inf]);"             % Inf
        "Cp = hctCorrection([1 + 2i]);"             % Complex
        "Cp = hctCorrection('string');"             % Non-numeric
        "Cp = hctCorrection(1.2, -0.1);"            % Hct < 0
        "Cp = hctCorrection(1.2, 1);"               % Hct = 1
        "Cp = hctCorrection(1.2, 1.5);"             % Hct > 1
        "Cp = hctCorrection(1.2, NaN);"             % Hct NaN
        "Cp = hctCorrection(1.2, Inf);"             % Hct Inf
        "Cp = hctCorrection(1.2, [0.3 0.4]);"        % Hct vector
        "Cp = hctCorrection(1.2, 'high');"          % Hct non-numeric
        "Cp = hctCorrection();"                    % Too few args
        "Cp = hctCorrection(1.2, 0.4, 999);"        % Too many args
        "Cp = hctCorrection([1.0, 2.5, 3.0],[0.3, 0.2]);" % Hct not scaler
        "[a, b] = hctCorrection(1.2);"              % Too many outputs
    };

    % Track results
    fprintf('--- Running hctCorrection Test Suite ---\n\n');
    for i = 1:length(tests)
        testLine = tests{i};
        try
            eval(testLine);
            fprintf('PASS Test %2d passed: %s\n', i, testLine);
        catch ME
            fprintf('FAIL Test %2d failed: %s\n   → %s\n', i, testLine, ME.message);
        end
    end
    fprintf('\n--- Test Suite Complete ---\n');
end
