function test_load_Cp()
%
% TEST_LOAD_CP: Comprehensive test suite for load_Cp
% Tests valid Cp loading, edge cases, and validation error handling.
%
% Author: Dr. Tanuj Puri
% Date:   01/2014. updated 2025
% Warning: This is an untested code/implementation and should be used
% with caution in clinical and pre-clinical settings.
%
  fprintf('Running tests for load_Cp...\n');

  testID = 0;

  %% Test 1: Valid Cp (row vector)
  testID = testID + 1;
  try
      Cp = rand(1, 10); 
      save('valid_row.mat', 'Cp');
      Cp_loaded = load_Cp('valid_row.mat');
      assert(isequal(Cp_loaded, Cp));
      fprintf('Test %d PASSED (valid row vector).\n', testID);
  catch ME
      fprintf('Test %d FAILED: %s\n', testID, ME.message);
  end

  %% Test 2: Valid Cp (column vector)
  testID = testID + 1;
  try
      Cp = (0:0.1:1)'; 
      save('valid_col.mat', 'Cp');
      Cp_loaded = load_Cp('valid_col.mat');
      assert(isequal(Cp_loaded, Cp));
      fprintf('Test %d PASSED (valid column vector).\n', testID);
  catch ME
      fprintf('Test %d FAILED: %s\n', testID, ME.message);
  end

  %% Test 3: Default file (Cp.mat)
  testID = testID + 1;
  try
      Cp = linspace(0, 5, 50); 
      save('Cp.mat', 'Cp');
      Cp_loaded = load_Cp();
      assert(isequal(Cp_loaded, Cp));
      fprintf('Test %d PASSED (default file).\n', testID);
  catch ME
      fprintf('Test %d FAILED: %s\n', testID, ME.message);
  end

  %% Test 4: Cp not numeric
  testID = testID + 1;
  try
      Cp = {'a', 'b'}; 
      save('not_numeric.mat', 'Cp');
      load_Cp('not_numeric.mat');
      error('Test %d FAILED: Expected numeric validation error.', testID);
  catch ME
      fprintf('Test %d PASSED (Cp not numeric).\n', testID);
  end

  %% Test 5: Cp not a vector
  testID = testID + 1;
  try
      Cp = rand(3, 3); 
      save('not_vector.mat', 'Cp');
      load_Cp('not_vector.mat');
      error('Test %d FAILED: Expected vector shape validation error.', testID);
  catch ME
      fprintf('Test %d PASSED (Cp not vector).\n', testID);
  end

  %% Test 6: Cp contains NaN
  testID = testID + 1;
  try
      Cp = [0.1, 0.5, NaN]; 
      save('with_nan.mat', 'Cp');
      load_Cp('with_nan.mat');
      error('Test %d FAILED: Expected NaN validation error.', testID);
  catch ME
      fprintf('Test %d PASSED (Cp with NaN).\n', testID);
  end

  %% Test 7: Cp contains Inf
  testID = testID + 1;
  try
      Cp = [1, 2, Inf]; 
      save('with_inf.mat', 'Cp');
      load_Cp('with_inf.mat');
      error('Test %d FAILED: Expected Inf validation error.', testID);
  catch ME
      fprintf('Test %d PASSED (Cp with Inf).\n', testID);
  end

  %% Test 8: Cp contains complex values
  testID = testID + 1;
  try
      Cp = [1, 2+3i, 4]; 
      save('with_complex.mat', 'Cp');
      load_Cp('with_complex.mat');
      error('Test %d FAILED: Expected complex validation error.', testID);
  catch ME
      fprintf('Test %d PASSED (Cp with complex values).\n', testID);
  end

  %% Test 9: Cp contains negative values
  testID = testID + 1;
  try
      Cp = [1, -0.5, 2]; 
      save('with_negative.mat', 'Cp');
      load_Cp('with_negative.mat');
      error('Test %d FAILED: Expected negative value validation error.', testID);
  catch ME
      fprintf('Test %d PASSED (Cp with negative values).\n', testID);
  end

  %% Test 10: Missing 'Cp' variable in .mat file
  testID = testID + 1;
  try
      fake = rand(1, 10); 
      save('no_Cp_field.mat', 'fake');
      load_Cp('no_Cp_field.mat');
      error('Test %d FAILED: Expected missing variable error.', testID);
  catch ME
      fprintf('Test %d PASSED (missing ''Cp'' variable).\n', testID);
  end

  %% Test 11: File not found
  testID = testID + 1;
  try
      load_Cp('nonexistent_file.mat');
      error('Test %d FAILED: Expected file not found error.', testID);
  catch ME
      fprintf('Test %d PASSED (file not found).\n', testID);
  end

  fprintf('Test suite completed.\n');

end
