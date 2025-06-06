function [notfinite_Ct, count] = getNonfiniteMap(R1t_, visualize)
%
% getNonfiniteMap detects nonfinite or complex numbers in a 2D or 3D numeric array.
%
% INPUTS:
%   R1t_      : Required. 2D or 3D numeric array (image or volume data).
%   visualize : Optional (default = 0). If 1, shows a 3D visualization.
%
% OUTPUTS:
%   notfinite_Ct : Binary mask with 1 at positions of nonfinite or complex values
%   count        : Total number of such values
%
% Author: Dr. Tanuj Puri (adapted from getInfMap)
% Date  : 01/2014, updated 2025 
%
    if nargin < 1
        error('getNonfiniteMap:MissingInput', 'Input matrix R1t_ is required.');
    elseif nargin > 2
        error('getNonfiniteMap:TooManyInputs', 'Too many input arguments. Only R1t_ and optional visualize flag are accepted.');
    end

    if nargin < 2
        visualize = 0;
    end

    if ~isscalar(visualize) || ~ismember(visualize, [0, 1])
        error('getNonfiniteMap:InvalidVisualizeFlag', 'Second argument must be 0 or 1.');
    end

    % Initialization
    R1t_size = size(R1t_);
    nd = ndims(R1t_);
    if nd > 3
        error('getNonfiniteMap:TooManyDimensions', 'Input must be 2D or 3D.');
    end

    notfinite_Ct = zeros(R1t_size);
    count = 0;

    % Scan the array
    if nd == 2
        for i = 1:R1t_size(1)
            for j = 1:R1t_size(2)
                val = R1t_(i, j);
                if ~isfinite(val) || ~isreal(val)
                    notfinite_Ct(i, j) = 1;
                    count = count + 1;
                end
            end
        end
    elseif nd == 3
        for i = 1:R1t_size(1)
            for j = 1:R1t_size(2)
                for k = 1:R1t_size(3)
                    val = R1t_(i, j, k);
                    if ~isfinite(val) || ~isreal(val)
                        notfinite_Ct(i, j, k) = 1;
                        count = count + 1;
                    end
                end
            end
        end
    end

    % Optional visualization
    if visualize
        if nd == 2
            figure;
            imagesc(notfinite_Ct);
            colormap(gray); colorbar;
            axis image;
            title('Nonfinite or Complex Value Map (2D)');
            xlabel('Columns'); ylabel('Rows');
        elseif nd == 3
            figure;
            isosurface(notfinite_Ct, 0.5);
            title('Nonfinite or Complex Value Map (3D)');
            xlabel('X (Coronal Slices)');
            ylabel('Y');
            zlabel('Z');
            axis tight;
            view(3);
            camlight; lighting gouraud;
        end
    end
end
