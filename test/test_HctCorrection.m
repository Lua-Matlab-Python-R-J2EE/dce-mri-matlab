function test_HctCorrection()
%
% @ Author: Dr. Tanuj Puri
% @ Date:   01/2014
% @ Warning: This is an untested code/implementation and should be used
% with caution in clinical and pre-clinical settings. The author takes no 
% responsibility of any kind about the output results from this code.
%
    % Define all test cases as strings
    tests = {
        "Cp = HctCorrection([1.5, 2.0], 0.38);"     % Custom Hct
        "Cp = HctCorrection(5.2);"                  % Default Hct
        "Cp = HctCorrection([2.0; 3.0], 0.35);"     % Custom Hct, column vector
        "Cp = HctCorrection(5);"                    % Scalar input
        "Cp = HctCorrection([1.0, 2.5, 3.0]);"      % Row vector
        "Cp = HctCorrection([1.0; 2.0; 3.0], 0.30);" % Column vector
        "Cp = HctCorrection(0);"                    % Zero input
        "Cp = HctCorrection([0, 1.1, 2.2], 0.25);"   % Mixed zero & positive
        "Cp = HctCorrection([1 2; 3 4]);"            % Matrix input
        "Cp = HctCorrection([-1, 2, 3]);"            % Negative input
        "Cp = HctCorrection([1, NaN]);"             % NaN
        "Cp = HctCorrection([1, Inf]);"             % Inf
        "Cp = HctCorrection([1 + 2i]);"             % Complex
        "Cp = HctCorrection('string');"             % Non-numeric
        "Cp = HctCorrection(1.2, -0.1);"            % Hct < 0
        "Cp = HctCorrection(1.2, 1);"               % Hct = 1
        "Cp = HctCorrection(1.2, 1.5);"             % Hct > 1
        "Cp = HctCorrection(1.2, NaN);"             % Hct NaN
        "Cp = HctCorrection(1.2, Inf);"             % Hct Inf
        "Cp = HctCorrection(1.2, [0.3 0.4]);"        % Hct vector
        "Cp = HctCorrection(1.2, 'high');"          % Hct non-numeric
        "Cp = HctCorrection();"                    % Too few args
        "Cp = HctCorrection(1.2, 0.4, 999);"        % Too many args
        "Cp = HctCorrection([1.0, 2.5, 3.0],[0.3, 0.2]);" % Hct not scaler
        "[a, b] = HctCorrection(1.2);"              % Too many outputs
    };

    % Track results
    fprintf('--- Running HctCorrection Test Suite ---\n\n');
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
