function [meanVal] = returnMean(calcVecSlice, segmentedROIslice)
%% RETURNMEAN Computes the mean value of calcVecSlice within segmentedROIslice mask.
%
%   meanVal = returnMean(calcVecSlice, segmentedROIslice)
%
%   This function:
%     - Extracts values from calcVecSlice where segmentedROIslice > 0
%     - Removes values >= 1.0 (assumed saturated or outliers)
%     - Computes mean of remaining values > 0
%
%   Inputs:
%     calcVecSlice         - 2D numeric, non-negative, real matrix
%     segmentedROIslice    - 2D numeric or logical matrix, same size
%
%   Output:
%     meanVal              - Mean of valid values in ROI (NaN if none)
%
%   Author:  Dr. Tanuj Puri, dated 01/2014
%   Warning: This is an untested code/implementation and should be used
%            with caution in clinical and pre-clinical settings. The author takes no 
%            responsibility of any kind about the output results from this code.
%
%% Input Validation
    if nargin ~= 2
        error('Exactly two input arguments are required.');
    end

    if ~ismatrix(calcVecSlice) || ~ismatrix(segmentedROIslice)
        error('Both inputs must be 2D matrices.');
    end

    if ~isequal(size(calcVecSlice), size(segmentedROIslice))
        error('Input matrices must be the same size.');
    end

    if ~isnumeric(calcVecSlice) || ~isnumeric(segmentedROIslice)
        error('Both inputs must be numeric.');
    end

    if ~isreal(calcVecSlice)
        error('calcVecSlice contains complex numbers. Only real values are allowed.');
    end

    if any(calcVecSlice(:) < 0)
        error('calcVecSlice contains negative values. Only non-negative values are allowed.');
    end

    if any(~isfinite(calcVecSlice(:)))
        error('calcVecSlice contains NaN or Inf values.');
    end

    %% Extract ROI and Filter
    roiValues = calcVecSlice(segmentedROIslice > 0);  % ROI values
    roiValues(roiValues >= 1.0) = 0;                  % Remove saturated values
    roiValues = roiValues(roiValues > 0);             % Keep only strictly positive

    %% Compute Mean
    if isempty(roiValues)
        warning('No valid ROI values found for mean computation. Returning NaN.');
        meanVal = NaN;
    else
        meanVal = mean(roiValues);
    end

end
