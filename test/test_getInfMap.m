function test_getInfMap()
%
% TEST_GETINFMAP: Comprehensive test suite for getInfMap
% Includes a wide range of numeric types (real, complex, NaN, Inf),
% input validation, 2D and 3D structures, and visualization flag behavior.
%
% Author: Dr. Tanuj Puri 
% Date: 01/2014, updated 2025
% Warning: This is an untested code/implementation and should be used
% with caution in clinical and pre-clinical settings.
%
fprintf('Running extended tests for getInfMap...\n');

for testID = 1:23
    try
        switch testID
            case 1
                A = [1, 2, Inf; NaN, 5, 6; 7, 8, 9];
                [inf_Ct, count] = getInfMap(A);
                expected = zeros(size(A)); 
                expected(1,3) = 1;
                assert(isequal(inf_Ct, expected));
                assert(count == 1);

            case 2
                B = zeros(2,2,2);
                B(1,1,1) = Inf;
                B(2,2,2) = NaN;
                B(1,2,1) = 3+4i;
                [inf_Ct, count] = getInfMap(B);
                expected = zeros(size(B)); expected(1,1,1) = 1;
                assert(isequal(inf_Ct, expected));
                assert(count == 1);

            case 3
                C = [-1, 0, 1; 2, 3, 4];
                [inf_Ct, count] = getInfMap(C);
                assert(all(inf_Ct(:) == 0));
                assert(count == 0);

            case 4
                D = [1+1i, 2+2i; 3+3i, 4+4i];
                [inf_Ct, count] = getInfMap(D);
                assert(count == 0 && all(inf_Ct(:) == 0));

            case 5
                E = NaN(3,3);
                [inf_Ct, count] = getInfMap(E);
                assert(count == 0 && all(inf_Ct(:) == 0));

            case 6
                F = rand(10,10,5);
                F(4,4,3) = Inf; 
                F(9,1,5) = Inf;
                [inf_Ct, count] = getInfMap(F);
                assert(count == 2 && inf_Ct(4,4,3)==1 && inf_Ct(9,1,5)==1);

            case 7
                G = 1e5 * ones(5,5); 
                G(3,3) = Inf;
                [inf_Ct, count] = getInfMap(G);
                assert(count == 1 && inf_Ct(3,3) == 1);

            case 8
                G = 1e5 * ones(5,5); 
                G(3,3) = Inf;
                getInfMap(G, 1); % no assert needed unless expecting failure
                                    % Run 2D visualization

            case 9
                H = [];
                [inf_Ct, count] = getInfMap(H);
                assert(isempty(inf_Ct) && count == 0);

            case 10
                I = Inf;
                [inf_Ct, count] = getInfMap(I);
                assert(isequal(inf_Ct, 1) && count == 1);

            case 11
                J = 42;
                [inf_Ct, count] = getInfMap(J);
                assert(isequal(inf_Ct, 0) && count == 0);

            case 12
                try
                    getInfMap(rand(2), 10);
                    error('Expected failure for bad visualize flag');
                catch ME
                    assert(strcmp(ME.identifier, 'getInfMap:InvalidVisualizeFlag'));
                end

            case 13
                try
                    getInfMap(rand(2,2,2,2));
                    error('Expected failure for 4D input');
                catch ME
                    assert(strcmp(ME.identifier, 'getInfMap:TooManyDimensions'));
                end

            case 14
                try
                    getInfMap(rand(2), 0, 1);
                    error('Expected failure for too many inputs');
                catch ME
                    assert(strcmp(ME.identifier, 'getInfMap:TooManyInputs'));
                end

            case 15
                A = rand(4,4,2) + 1i*rand(4,4,2);
                A(2,2,1) = Inf; A(3,3,2) = 5.5;
                [inf_Ct, count] = getInfMap(A);
                assert(count == 1 && inf_Ct(2,2,1) == 1);

            case 16
                B = zeros(3,3); B(1,1) = -Inf;
                [inf_Ct, count] = getInfMap(B);
                assert(count == 1 && inf_Ct(1,1) == 1);

            case 17
                C = eye(5) * Inf;
                [inf_Ct, count] = getInfMap(C);
                assert(count == 5 && all(diag(inf_Ct)==1));

            case 18
                D = rand(5,5,3);
                D(1,1,1) = Inf; D(5,5,3) = Inf;
                [inf_Ct, count] = getInfMap(D);
                assert(count == 2 && inf_Ct(1,1,1)==1 && inf_Ct(5,5,3)==1);

            case 19
                E = Inf(2,2,2);
                [inf_Ct, count] = getInfMap(E);
                assert(count == 8 && all(inf_Ct(:)==1));

            case 20
                F = realmax * ones(3); F(2,2) = Inf;
                [inf_Ct, count] = getInfMap(F);
                assert(count == 1 && inf_Ct(2,2)==1);

            case 21
                G = rand(1,20,2); G(1,10,1) = Inf;
                [inf_Ct, count] = getInfMap(G);
                assert(count == 1 && inf_Ct(1,10,1)==1);

            case 22
                H = zeros(10,10);
                inf_locs = [1,1; 5,5; 10,10];
                for i = 1:size(inf_locs,1)
                    H(inf_locs(i,1), inf_locs(i,2)) = Inf;
                end
                [inf_Ct, count] = getInfMap(H);
                assert(count == 3 && all(diag(inf_Ct)==[1;0;0;0;1;0;0;0;0;1]));
                
            case 23
                try
                    F = rand(5,5,3); 
                    F(2,2,1) = Inf; F(3,3,2) = Inf; F(4,4,3) = Inf;
                    getInfMap(F, 1);  % Run 3D visualization
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
