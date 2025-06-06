function test_getNanMap()
%
% TEST_GETNANMAP: Comprehensive test suite for getNanMap
% Includes a wide range of numeric types (real, complex, NaN, Inf),
% input validation, 2D and 3D structures, and visualization flag behavior.
%
% Author: Dr. Tanuj Puri
% Date: 01/2014, updated 2025
% Warning: This is an untested code/implementation and should be used
% with caution in clinical and pre-clinical settings.
%
fprintf('Running extended tests for getNanMap...\n');

for testID = 1:23
    try
        switch testID
            case 1
                A = [1, 2, Inf; NaN, 5, 6; 7, 8, 9];
                [nan_Ct, count] = getNanMap(A);
                expected = zeros(size(A)); 
                expected(2,1) = 1;
                assert(isequal(nan_Ct, expected));
                assert(count == 1);

            case 2
                B = zeros(2,2,2);
                B(1,1,1) = Inf;
                B(2,2,2) = NaN;
                B(1,2,1) = 3+4i;
                [nan_Ct, count] = getNanMap(B);
                expected = zeros(size(B)); expected(2,2,2) = 1;
                assert(isequal(nan_Ct, expected));
                assert(count == 1);

            case 3
                C = [-1, 0, 1; 2, 3, 4];
                [nan_Ct, count] = getNanMap(C);
                assert(all(nan_Ct(:) == 0));
                assert(count == 0);

            case 4
                D = [1+1i, 2+2i; 3+3i, 4+4i];
                [nan_Ct, count] = getNanMap(D);
                assert(count == 0 && all(nan_Ct(:) == 0));

            case 5
                E = NaN(3,3);
                [nan_Ct, count] = getNanMap(E);
                assert(count == numel(E) && all(nan_Ct(:) == 1));

            case 6
                F = rand(10,10,5);
                F(4,4,3) = NaN; 
                F(9,1,5) = NaN;
                [nan_Ct, count] = getNanMap(F);
                assert(count == 2 && nan_Ct(4,4,3)==1 && nan_Ct(9,1,5)==1);

            case 7
                G = 1e5 * ones(5,5); 
                G(3,3) = NaN;
                [nan_Ct, count] = getNanMap(G);
                assert(count == 1 && nan_Ct(3,3) == 1);

            case 8
                G = 1e5 * ones(5,5); 
                G(3,3) = NaN;
                getNanMap(G, 1); % Run 2D visualization

            case 9
                H = [];
                [nan_Ct, count] = getNanMap(H);
                assert(isempty(nan_Ct) && count == 0);

            case 10
                I = NaN;
                [nan_Ct, count] = getNanMap(I);
                assert(isequal(nan_Ct, 1) && count == 1);

            case 11
                J = 42;
                [nan_Ct, count] = getNanMap(J);
                assert(isequal(nan_Ct, 0) && count == 0);

            case 12
                try
                    getNanMap(rand(2), 10);
                    error('Expected failure for bad visualize flag');
                catch ME
                    assert(strcmp(ME.identifier, 'getNanMap:InvalidVisualizeFlag'));
                end

            case 13
                try
                    getNanMap(rand(2,2,2,2));
                    error('Expected failure for 4D input');
                catch ME
                    assert(strcmp(ME.identifier, 'getNanMap:TooManyDimensions'));
                end

            case 14
                try
                    getNanMap(rand(2), 0, 1);
                    error('Expected failure for too many inputs');
                catch ME
                    assert(strcmp(ME.identifier, 'getNanMap:TooManyInputs'));
                end

            case 15
                A = rand(4,4,2) + 1i*rand(4,4,2);
                A(2,2,1) = NaN; A(3,3,2) = 5.5;
                [nan_Ct, count] = getNanMap(A);
                assert(count == 1 && nan_Ct(2,2,1) == 1);

            case 16
                B = zeros(3,3); B(1,1) = NaN;
                [nan_Ct, count] = getNanMap(B);
                assert(count == 1 && nan_Ct(1,1) == 1);

            case 17
                C = eye(5) * NaN;
                [nan_Ct, count] = getNanMap(C);
                assert(count == 5 && all(diag(nan_Ct)==1));

            case 18
                D = rand(5,5,3);
                D(1,1,1) = NaN; D(5,5,3) = NaN;
                [nan_Ct, count] = getNanMap(D);
                assert(count == 2 && nan_Ct(1,1,1)==1 && nan_Ct(5,5,3)==1);

            case 19
                E = NaN(2,2,2);
                [nan_Ct, count] = getNanMap(E);
                assert(count == 8 && all(nan_Ct(:)==1));

            case 20
                F = realmax * ones(3); F(2,2) = NaN;
                [nan_Ct, count] = getNanMap(F);
                assert(count == 1 && nan_Ct(2,2)==1);

            case 21
                G = rand(1,20,2); G(1,10,1) = NaN;
                [nan_Ct, count] = getNanMap(G);
                assert(count == 1 && nan_Ct(1,10,1)==1);

            case 22
                H = zeros(10,10);
                nan_locs = [1,1; 5,5; 10,10];
                for i = 1:size(nan_locs,1)
                    H(nan_locs(i,1), nan_locs(i,2)) = NaN;
                end
                [nan_Ct, count] = getNanMap(H);
                assert(count == 3 && all(diag(nan_Ct)==[1;0;0;0;1;0;0;0;0;1]));

            case 23
                try
                    F = rand(5,5,3); 
                    F(2,2,1) = NaN; F(3,3,2) = NaN; F(4,4,3) = NaN;
                    getNanMap(F, 1);  % Run 3D visualization
                catch ME
                    error('3D Visualization test failed: %s', ME.message);
            end

        end
        fprintf('Test %d PASSED.\n', testID);
    catch ME
        fprintf('Test %d FAILED: %s\n', testID, ME.message);
    end
end

fprintf('Extended test suite completed.\n');

end
