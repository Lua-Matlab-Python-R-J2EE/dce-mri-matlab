function test_d_T1o_VS_d_Ct()
% TEST_D_T1O_VS_D_CT - Unit tests for d_T1o_VS_d_Ct.m
% Thoroughly checks the function with valid and invalid inputs
%
% Author: Dr. Tanuj Puri
% Date:   01/2014
% Warning: This is an untested code/implementation and should be used
% with caution in clinical and pre-clinical settings. The author takes no 
% responsibility of any kind about the output results from this code.
%
fprintf('Running tests for d_T1o_VS_d_Ct...\n');

% -----------------------------
% Pass cases
% -----------------------------
try
    % Basic test with expected values
    Ct = [0.1; 0.2; 0.15];
    T1o = 1000; % ms
    gd = 3.4;   % s⁻¹·mMol⁻¹
    d_T1o = [-50; 0; 50]; % ms
    out = d_T1o_VS_d_Ct(Ct, T1o, gd, d_T1o);
    assert(isnumeric(out), 'Output must be numeric.');
    assert(all(isfinite(out)), 'Output must be finite.');
    assert(all(size(out) == size(Ct)), 'Output must match Ct size.');
    fprintf('PASS: Basic functionality\n');
catch e
    fprintf('FAIL: Basic functionality\n%s\n', e.message);
end
disp("-------")
try
    % Basic test with expected values
    Ct = [0.1, 0.2, 0.15];
    T1o = 1000; % ms
    gd = 3.4;   % s⁻¹·mMol⁻¹
    d_T1o = [-50, 0, 50]; % ms
    out = d_T1o_VS_d_Ct(Ct, T1o, gd, d_T1o);
    assert(isnumeric(out), 'Output must be numeric.');
    assert(all(isfinite(out)), 'Output must be finite.');
    assert(all(size(out) == size(Ct)), 'Output must match Ct size.');
    fprintf('PASS: Basic functionality\n');
catch e
    fprintf('FAIL: Basic functionality\n%s\n', e.message);
end
disp("-------")
try
    % Vectorized d_T1o
    Ct = ones(1, 10) * 0.5;
    d_T1o = linspace(-100, 100, 10);
    out = d_T1o_VS_d_Ct(Ct, 1200, 3.4, d_T1o);
    assert(length(out) == length(Ct));
    fprintf('PASS: Vectorized d_T1o\n');
catch e
    fprintf('FAIL: Vectorized d_T1o\n%s\n', e.message);
end
disp("-------")
try
    % Edge case: d_T1o = 0 should return original Ct
    Ct = rand(1, 5);
    out = d_T1o_VS_d_Ct(Ct, 1200, 3.4, 0);
    assert(all(abs(out - Ct) < 1e-10), 'd_T1o = 0 should give original Ct.');
    fprintf('PASS: d_T1o = 0 gives original Ct\n');
catch e
    fprintf('FAIL: d_T1o = 0 gives original Ct\n%s\n', e.message);
end

disp("-------------------------")
% -----------------------------
% Fail cases
% -----------------------------
failCases = {
    {'non-numeric Ct', 'abc', 1000, 3.4, 10}, ...
    {'NaN in Ct', [0.1, NaN], 1000, 3.4, 10}, ...
    {'Negative Ct', [-0.1, 0.2], 1000, 3.4, 10}, ...
    {'T1o is zero', [0.1, 0.2], 0, 3.4, 10}, ...
    {'T1o is complex', [0.1, 0.2], 1000+1i, 3.4, 10}, ...
    {'gd is negative', [0.1, 0.2], 1000, -3.4, 10}, ...
    {'gd is Inf', [0.1, 0.2], 1000, Inf, 10}, ...
    {'d_T1o has Inf', [0.1, 0.2], 1000, 3.4, [10, Inf]}, ...
    {'d_T1o has NaN', [0.1, 0.2], 1000, 3.4, [10, NaN]}, ...
    {'Mismatched Ct and d_T1o sizes', [0.1, 0.2], 1000, 3.4, [10; 20]},...
    {'d_T1o is complex', [0.1, 0.2], 1000, 3.4, [10, 2+1i]}
};

for i = 1:numel(failCases)
    disp("-------")
    label = failCases{i}{1};
    Ct = failCases{i}{2};
    T1o = failCases{i}{3};
    gd = failCases{i}{4};
    d_T1o = failCases{i}{5};
    try
        d_T1o_VS_d_Ct(Ct, T1o, gd, d_T1o);
        fprintf('FAIL: %s (expected error)\n', label);
    catch
        fprintf('PASS: Error caught for %s\n', label);
    end
end

fprintf('All tests completed.\n');

end
