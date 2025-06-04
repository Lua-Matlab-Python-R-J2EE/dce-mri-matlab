function [complex_Ct, count] = getComplexMap(R1t_, visualize)
%
% getComplexMap: Detects and maps complex values in a 2D or 3D numeric array.
%
% INPUTS:
%   R1t_      : Required. A 2D or 3D numeric array (e.g., image or volume data).
%   visualize : Optional (default = 0). If 1, shows a visual map of complex values.
%
% OUTPUTS:
%   complex_Ct : Binary array of same size as R1t_ where complex values are marked as 1
%   count      : Number of complex values in R1t_
%
% VALIDATION:
%   - Rejects more than two inputs
%   - Validates that input is 2D/3D only
%
% Author: Dr. Tanuj Puri 
% Date: 01/2014 (adapted from getInfMap)
% Warning: This is an untested code/implementation and should be used
% with caution in clinical and pre-clinical settings.
%
    %% 1. Validate number of inputs
    if nargin < 1
        error('getComplexMap:MissingInput', 'Input matrix R1t_ is required.');
    elseif nargin > 2
        error('getComplexMap:TooManyInputs', 'Too many input arguments. Only R1t_ and optional visualize flag are accepted.');
    end

    %% 2. Default value for visualize
    if nargin < 2
        visualize = 0;
    end

    if ~isscalar(visualize) || ~ismember(visualize, [0, 1])
        error('getComplexMap:InvalidVisualizeFlag', 'Second argument must be 0 or 1.');
    end

    %% 3. Check dimensionality
    R1t_size = size(R1t_);
    nd = ndims(R1t_);
    if nd > 3
        error('getComplexMap:TooManyDimensions', 'Input must be 2D or 3D.');
    end

    %% 4. Initialize output
    complex_Ct = zeros(R1t_size);
    count = 0;

    %% 5. Scan for complex values (non-vectorized)
    if nd == 2
        for i = 1:R1t_size(1)
            for j = 1:R1t_size(2)
                if abs(imag(R1t_(i, j))) > eps
                    complex_Ct(i, j) = 1;
                    count = count + 1;
                end
            end
        end
    elseif nd == 3
        for i = 1:R1t_size(1)
            for j = 1:R1t_size(2)
                for k = 1:R1t_size(3)
                    if abs(imag(R1t_(i, j, k))) > eps
                        complex_Ct(i, j, k) = 1;
                        count = count + 1;
                    end
                end
            end
        end
    end

    %% 6. Optional Visualization
    if visualize
        if nd == 2
            figure;
            imagesc(complex_Ct);
            colormap(gray); colorbar;
            axis image;
            title('Complex Value Map (2D)');
            xlabel('Columns'); ylabel('Rows');
        elseif nd == 3
            figure;
            isosurface(complex_Ct, 0.5); % Show locations with complex values (== 1)
            title('Isosurface of Complex Voxels (3D)');
            xlabel('X (Coronal Slices)');
            ylabel('Y');
            zlabel('Z');
            axis tight;
            view(3);
            camlight;
            lighting gouraud;
        end
    end
end
