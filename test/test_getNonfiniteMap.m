function test_getNonfiniteMap()
%
% TEST_GETNONFINITEMAP: Comprehensive test suite for getNonfiniteMap
% Tests detection of complex, Inf, and NaN values in 2D and 3D arrays,
% input validation, visualization flag handling, and expected edge cases.
%
% Author: Dr. Tanuj Puri 
% Date: 01/2014 (adapted from test_getInfMap)
% Warning: This is an untested code/implementation and should be used
% with caution in clinical and pre-clinical settings.
%
fprintf('Running extended tests for getNonfiniteMap...\n');

for testID = 1:24
    try
        switch testID
            case 1
                A = [1, 2, 3; NaN, 5, 6; 7+2i, 8, 9];
                [notfinite_Ct, count] = getNonfiniteMap(A);
                expected = zeros(size(A)); 
                expected(2,1) = 1; expected(3,1) = 1;
                assert(isequal(notfinite_Ct, expected));
                assert(count == 2);

            case 2
                B = zeros(2,2,2);
                B(1,1,1) = 3+4i;
                B(2,2,2) = NaN;
                B(1,2,1) = Inf;
                [notfinite_Ct, count] = getNonfiniteMap(B);
                expected = zeros(size(B)); expected(1,1,1) = 1; expected(2,2,2) = 1; expected(1,2,1) = 1;
                assert(isequal(notfinite_Ct, expected));
                assert(count == 3);

            case 3
                C = [-1, 0, 1; 2, 3, 4];
                [notfinite_Ct, count] = getNonfiniteMap(C);
                assert(all(notfinite_Ct(:) == 0));
                assert(count == 0);

            case 4
                D = [1+1i, 2+2i; 3+3i, 4+4i];
                [notfinite_Ct, count] = getNonfiniteMap(D);
                assert(count == 4 && all(notfinite_Ct(:) == 1));

            case 5
                E = NaN(3,3);
                [notfinite_Ct, count] = getNonfiniteMap(E);
                assert(count == 9 && all(notfinite_Ct(:) == 1));

            case 6
                F = rand(10,10,5);
                F(4,4,3) = 3+2i; 
                F(9,1,5) = NaN;
                [notfinite_Ct, count] = getNonfiniteMap(F);
                assert(count == 2 && notfinite_Ct(4,4,3)==1 && notfinite_Ct(9,1,5)==1);

            case 7
                G = 1e5 * ones(5,5); 
                G(3,3) = Inf;
                [notfinite_Ct, count] = getNonfiniteMap(G);
                assert(count == 1 && notfinite_Ct(3,3) == 1);

            case 8
                G = 1e5 * ones(5,5); 
                G(3,3) = NaN;
                getNonfiniteMap(G, 1); % Run 2D visualization

            case 9
                H = [];
                [notfinite_Ct, count] = getNonfiniteMap(H);
                assert(isempty(notfinite_Ct) && count == 0);

            case 10
                I = 2+5i;
                [notfinite_Ct, count] = getNonfiniteMap(I);
                assert(isequal(notfinite_Ct, 1) && count == 1);

            case 11
                J = 42;
                [notfinite_Ct, count] = getNonfiniteMap(J);
                assert(isequal(notfinite_Ct, 0) && count == 0);

            case 12
                try
                    getNonfiniteMap(rand(2), 10);
                    error('Expected failure for bad visualize flag');
                catch ME
                    assert(strcmp(ME.identifier, 'getNonfiniteMap:InvalidVisualizeFlag'));
                end

            case 13
                try
                    getNonfiniteMap(rand(2,2,2,2));
                    error('Expected failure for 4D input');
                catch ME
                    assert(strcmp(ME.identifier, 'getNonfiniteMap:TooManyDimensions'));
                end

            case 14
                try
                    getNonfiniteMap(rand(2), 0, 1);
                    error('Expected failure for too many inputs');
                catch ME
                    assert(strcmp(ME.identifier, 'getNonfiniteMap:TooManyInputs'));
                end

            case 15
                A = rand(4,4,2);
                A(2,2,1) = complex(Inf, 0);
                A(3,3,2) = complex(5.5, 0);
                [notfinite_Ct, count] = getNonfiniteMap(A);
                assert(count == 1 && notfinite_Ct(2,2,1) == 1 && notfinite_Ct(3,3,2) == 0);

            case 16
                B = zeros(3,3); B(1,1) = -2+3i;
                [notfinite_Ct, count] = getNonfiniteMap(B);
                assert(count == 1 && notfinite_Ct(1,1) == 1);

            case 17
                C = eye(5) * 2i;
                [notfinite_Ct, count] = getNonfiniteMap(C);
                assert(count == 5 && all(diag(notfinite_Ct)==1));

            case 18
                D = rand(5,5,3);
                D(1,1,1) = 2+3i; D(5,5,3) = 5i;
                [notfinite_Ct, count] = getNonfiniteMap(D);
                assert(count == 2 && notfinite_Ct(1,1,1)==1 && notfinite_Ct(5,5,3)==1);

            case 19
                E = complex(ones(2,2,2), ones(2,2,2));
                [notfinite_Ct, count] = getNonfiniteMap(E);
                assert(count == 8 && all(notfinite_Ct(:)==1));

            case 20
                F = realmax * ones(3); F(2,2) = 3+7i;
                [notfinite_Ct, count] = getNonfiniteMap(F);
                assert(count == 1 && notfinite_Ct(2,2)==1);

            case 21
                G = rand(1,20,2); G(1,10,1) = 9i;
                [notfinite_Ct, count] = getNonfiniteMap(G);
                assert(count == 1 && notfinite_Ct(1,10,1)==1);

            case 22
                H = zeros(10,10);
                cmplx_locs = [1,1; 5,5; 10,10];
                for i = 1:size(cmplx_locs,1)
                    H(cmplx_locs(i,1), cmplx_locs(i,2)) = 1i;
                end
                [notfinite_Ct, count] = getNonfiniteMap(H);
                assert(count == 3 && all(diag(notfinite_Ct)==[1;0;0;0;1;0;0;0;0;1]));

            case 23
                try
                    F = rand(5,5,3); 
                    F(2,2,1) = 4+1i; F(3,3,2) = 3+9i; F(4,4,3) = 2i;
                    getNonfiniteMap(F, 1);
                catch ME
                    error('3D Visualization test failed: %s', ME.message);
                end

            case 24
                try
                    A = rand(4,4,2);
                    A(1,1,1) = A(1,1,1) + 1i*0.1;
                    A(2,3,2) = A(2,3,2) + 1i*5;
                    A(4,4,1) = A(4,4,1) + 1i*3;
                    [notfinite_Ct, count] = getNonfiniteMap(A);
                    assert(count == 3 && all([notfinite_Ct(1,1,1), notfinite_Ct(2,3,2), notfinite_Ct(4,4,1)] == 1));
                catch ME
                    error('New complex number test FAILED: %s\n', ME.message);                    
                end
        end
        fprintf('Test %d PASSED.\n', testID);
    catch ME
        fprintf('Test %d FAILED: %s\n', testID, ME.message);
    end
end

fprintf('Extended test suite completed.\n');

end
