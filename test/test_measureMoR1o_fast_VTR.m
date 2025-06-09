function test_measureMoR1o_fast_VTR()
%--------------------------------------------------------------------------
% FUNCTION: test_measureMoR1o_fast_VTR
%
% PURPOSE:
%   Runs a series of synthetic tests on the function
%   `measureMoR1o_fast_VTR` to validate its robustness.
%
%   The function generates SPGR signals using known parameters (Mo and T1),
%   adds controlled Gaussian noise, fits the data using the estimator, and
%   evaluates how close the fitted results are to the ground truth.
%
%   At the end, it summarizes the number of test cases passed and failed.
%
% AUTHOR: Dr. Tanuj Puri
% DATE:   01/2014, updated 06/2025
% WARNING: This code is untested and may not be suitable for clinical use.
%
%--------------------------------------------------------------------------

    %-----------------------------
    % Define Ground Truth Values
    %-----------------------------
    Mo_values  = [1000, 2000, 3000, 5000];     % Simulated Mo values (equilibrium magnetization)
    T1o_values = [0.5, 1.0, 1.5, 2.0];         % Simulated T1 relaxation times (in seconds)

    %-----------------------------
    % MRI Acquisition Parameters
    %-----------------------------
    TR       = linspace(0.005, 0.030, 10)';    % Repetition times in seconds (vector)
    flip_deg = linspace(2, 25, 10)';           % Flip angles in degrees (vector)

    repitition = 3;                            % Number of random initial guesses per fit
    doPlot = false;                            % Set true to visualize fits
    noise_percent = 0.05;                      % Noise level: 5% of max signal
    rng(42);                                   % Fix random seed for reproducibility

    %-----------------------------
    % Initialize Counters
    %-----------------------------
    total_cases   = 0;    % Total number of test cases executed
    passed_cases  = 0;    % Number of test cases that passed
    failed_cases  = 0;    % Number of test cases that failed

    fprintf('Running multi-case test for measureMoR1o_fast_VTR...\n\n');

    %=============================
    % Begin Loop Over All Cases
    %=============================
    for i = 1:length(Mo_values)
        for j = 1:length(T1o_values)

            %-----------------------------
            % Update Test Counter
            %-----------------------------
            total_cases = total_cases + 1;

            %-----------------------------
            % Define Ground Truth for This Test
            %-----------------------------
            true_Mo  = Mo_values(i);                % True equilibrium magnetization
            true_T1o = T1o_values(j);               % True longitudinal relaxation time
            true_R1o = 1 / true_T1o;                % Relaxation rate

            %-----------------------------
            % Generate Noise-Free SPGR Signal
            %-----------------------------
            ideal_signal = true_Mo * sin(flip_deg * pi / 180) .* ...
                           (1 - exp(-TR * true_R1o)) ./ ...
                           (1 - cos(flip_deg * pi / 180) .* exp(-TR * true_R1o));

            %-----------------------------
            % Add Gaussian Noise
            %-----------------------------
            sigma_noise = noise_percent * max(ideal_signal);
            noisy_signal = ideal_signal + sigma_noise * randn(size(ideal_signal));

            %-----------------------------
            % Run Estimator Function
            %-----------------------------
            [Mo_fit, R1o_fit, sse] = measureMoR1o_fast_VTR( ...
                                      noisy_signal, TR, flip_deg, doPlot, repitition);
            est_T1o = 1 / R1o_fit;  % Convert back to T1 for error check

            %-----------------------------
            % Display Results
            %-----------------------------
            fprintf('Case %2d: Mo = %-5d, T1 = %.2f s\n', total_cases, true_Mo, true_T1o);
            fprintf(' → Estimated Mo  = %.2f (err = %.2f%%)\n', Mo_fit, 100 * abs(Mo_fit - true_Mo)/true_Mo);
            fprintf(' → Estimated T1  = %.3f s (err = %.2f%%)\n', est_T1o, 100 * abs(est_T1o - true_T1o)/true_T1o);
            fprintf(' → SSE           = %.2e\n', sse);

            %-----------------------------
            % Tolerance Check (±25%)
            %-----------------------------
            Mo_within_tol  = abs(Mo_fit - true_Mo) < 0.25 * true_Mo;
            R1o_within_tol = abs(R1o_fit - true_R1o) < 0.25 * true_R1o;

            if Mo_within_tol && R1o_within_tol
                passed_cases = passed_cases + 1;
                fprintf(" PASS: Fit within tolerance\n\n");
            else
                failed_cases = failed_cases + 1;
                fprintf(" FAIL: Estimate outside tolerance\n\n");
            end
        end % end of j loop
    end % end of i loop

    %=============================
    % Final Summary Report
    %=============================
    fprintf('========================\n');
    fprintf('   Multi-case Summary\n');
    fprintf('========================\n');
    fprintf('Total Test Cases Run:   %d\n', total_cases);
    fprintf('Number of PASSES:       %d\n', passed_cases);
    fprintf('Number of FAILURES:     %d\n', failed_cases);
    fprintf('Pass Rate:              %.2f%%\n', 100 * passed_cases / total_cases);

end %end of test_measureMoR1o_fast_VTR
