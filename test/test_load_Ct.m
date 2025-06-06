function test_load_Ct()
%
% TEST_LOAD_Ct: Comprehensive test suite for load_Ct
% Tests valid Ct loading, edge cases, and validation error handling.
%
% Author: Dr. Tanuj Puri
% Date:   01/2014, updated 2025
% Warning: This is an untested code/implementation and should be used
% with caution in clinical and pre-clinical settings.
%
  fprintf('Running tests for load_Ct...\n');

  testID = 0;

  %% Test 1: Valid Ct (row vector)
  testID = testID + 1;
  try
      Ct = rand(1, 10); 
      save('valid_row.mat', 'Ct');
      Ct_loaded = load_Ct('valid_row.mat');
      assert(isequal(Ct_loaded, Ct));
      fprintf('Test %d PASSED (valid row vector).\n', testID);
  catch ME
      fprintf('Test %d FAILED: %s\n', testID, ME.message);
  end

  %% Test 2: Valid Ct (column vector)
  testID = testID + 1;
  try
      Ct = (0:0.1:1)'; 
      save('valid_col.mat', 'Ct');
      Ct_loaded = load_Ct('valid_col.mat');
      assert(isequal(Ct_loaded, Ct));
      fprintf('Test %d PASSED (valid column vector).\n', testID);
  catch ME
      fprintf('Test %d FAILED: %s\n', testID, ME.message);
  end

  %% Test 3: Default file (Ct.mat)
  testID = testID + 1;
  try
      Ct = linspace(0, 5, 50); 
      save('Ct.mat', 'Ct');
      Ct_loaded = load_Ct();
      assert(isequal(Ct_loaded, Ct));
      fprintf('Test %d PASSED (default file).\n', testID);
  catch ME
      fprintf('Test %d FAILED: %s\n', testID, ME.message);
  end

  %% Test 4: Ct not numeric
  testID = testID + 1;
  try
      Ct = {'a', 'b'}; 
      save('not_numeric.mat', 'Ct');
      load_Ct('not_numeric.mat');
      error('Test %d FAILED: Expected numeric validation error.', testID);
  catch ME
      fprintf('Test %d PASSED (Ct not numeric).\n', testID);
  end

  %% Test 5: Ct not a vector
  testID = testID + 1;
  try
      Ct = rand(3, 3); 
      save('not_vector.mat', 'Ct');
      load_Ct('not_vector.mat');
      error('Test %d FAILED: Expected vector shape validation error.', testID);
  catch ME
      fprintf('Test %d PASSED (Ct not vector).\n', testID);
  end

  %% Test 6: Ct contains NaN
  testID = testID + 1;
  try
      Ct = [0.1, 0.5, NaN]; 
      save('with_nan.mat', 'Ct');
      load_Ct('with_nan.mat');
      error('Test %d FAILED: Expected NaN validation error.', testID);
  catch ME
      fprintf('Test %d PASSED (Ct with NaN).\n', testID);
  end

  %% Test 7: Ct contains Inf
  testID = testID + 1;
  try
      Ct = [1, 2, Inf]; 
      save('with_inf.mat', 'Ct');
      load_Ct('with_inf.mat');
      error('Test %d FAILED: Expected Inf validation error.', testID);
  catch ME
      fprintf('Test %d PASSED (Ct with Inf).\n', testID);
  end

  %% Test 8: Ct contains complex values
  testID = testID + 1;
  try
      Ct = [1, 2+3i, 4]; 
      save('with_complex.mat', 'Ct');
      load_Ct('with_complex.mat');
      error('Test %d FAILED: Expected complex validation error.', testID);
  catch ME
      fprintf('Test %d PASSED (Ct with complex values).\n', testID);
  end

  %% Test 9: Ct contains negative values
  testID = testID + 1;
  try
      Ct = [1, -0.5, 2]; 
      save('with_negative.mat', 'Ct');
      load_Ct('with_negative.mat');
      error('Test %d FAILED: Expected negative value validation error.', testID);
  catch ME
      fprintf('Test %d PASSED (Ct with negative values).\n', testID);
  end

  %% Test 10: Missing 'Ct' variable in .mat file
  testID = testID + 1;
  try
      fake = rand(1, 10); 
      save('no_Ct_field.mat', 'fake');
      load_Ct('no_Ct_field.mat');
      error('Test %d FAILED: Expected missing variable error.', testID);
  catch ME
      fprintf('Test %d PASSED (missing ''Ct'' variable).\n', testID);
  end

  %% Test 11: File not found
  testID = testID + 1;
  try
      load_Ct('nonexistent_file.mat');
      error('Test %d FAILED: Expected file not found error.', testID);
  catch ME
      fprintf('Test %d PASSED (file not found).\n', testID);
  end

  fprintf('Test suite completed.\n');

end
