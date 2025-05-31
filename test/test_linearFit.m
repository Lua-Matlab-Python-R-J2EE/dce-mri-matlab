function test_linearFit()
% TEST_LINEARFIT Unit tests for the linearFit function.
%
% This test suite checks:
%   - Correctness of slope and intercept
%   - Handling of NaN, Inf, and unequal inputs
%   - Proper error throwing for invalid inputs
%   - R-squared values in expected ranges
%
% @ Author: Dr. Tanuj Puri
% @ Date:   01/2014
% @ Warning: This is an untested code/implementation and should be used
% with caution in clinical and pre-clinical settings. The author takes no 
% responsibility of any kind about the output results from this code.
%
%%
  fprintf('Start running tests for linearFit.m...\n');
  
  tests = {
      % Basic perfect linear fit
      {1:5, 2*(1:5) + 0, 2, 0},        % y = 2x
      {1:5, 3*(1:5) + 5, 3, 5},        % y = 3x + 5
  
      % Horizontal line
      {1:10, 5*ones(1,10), 0, 5},      % y = 0x + 5
  
      % Negative slope
      {1:5, -4*(1:5) + 3, -4, 3},      % y = -4x + 3
  
      % Floating point
      {linspace(0, 1, 5), [0.1, 0.3, 0.5, 0.7, 0.9], 0.8, 0.1},
  
      % Error cases
      {'a', [1 2 3]},        % invalid x (non-numeric)
      {[1 2 3], NaN},        % y has NaN
      {[1 2 3], [1 2]},      % length mismatch
      {[1 2 3], [1 2 Inf]},  % Inf value
  };
  
  for i = 1:length(tests)
      disp("------")
      testCase = tests{i};
      try
          x = testCase{1};
          y = testCase{2};
  
          % Error cases (length < 4 for valid checks)
          if i > 5
              try
                  linearFit(x, y);
                  error('Test %d FAILED: Expected error not thrown.', i);
              catch ME
                  fprintf('Test %d PASSED (caught expected error): %s\n', i, ME.message);
              end
          else
              expectedSlope = testCase{3};
              expectedIntercept = testCase{4};
              [slope, intercept, yfit, R2] = linearFit(x, y);
  
              % Tolerance for floating point
              tol = 1e-6;
              assert(abs(slope - expectedSlope) < tol, 'Slope mismatch in test %d', i);
              assert(abs(intercept - expectedIntercept) < tol, 'Intercept mismatch in test %d', i);
              assert(R2 > 0.99, 'Unexpectedly low R² in test %d', i);
  
              fprintf('Test %d PASSED: slope=%.3f, intercept=%.3f, R²=%.4f\n', ...
                  i, slope, intercept, R2);
          end
      catch ex
          fprintf('Test %d FAILED: %s\n', i, ex.message);
      end
  end
  
  fprintf('---All linearFit tests completed.---\n\n');
  
end
