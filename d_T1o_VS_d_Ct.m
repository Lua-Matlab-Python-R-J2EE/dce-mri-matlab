function [new_Ct] = d_T1o_VS_d_Ct(Ct, T1o, gd, d_T1o)
%% d_T1o_VS_d_Ct - Estimates the change in concentration-time curve (Ct)
% due to perturbations in baseline T1 (T1o) values in DCE-MRI modeling.
%
% -------------------------------
% AUTHOR & VERSION
% -------------------------------
% Author: Dr. Tanuj Puri
% Date:   01/2014, updated 2025
% Warning: This is an untested code/implementation and should be used
% with caution in clinical and pre-clinical settings. The author takes no 
% responsibility of any kind about the output results from this code.
%
% -------------------------------
% PURPOSE & CONTEXT
% -------------------------------
% In dynamic contrast-enhanced MRI (DCE-MRI), the concentration of contrast
% agent (typically Gadolinium-based) in tissue is calculated from the 
% observed longitudinal relaxation time (T1) using the following relationship:
%
%       1/T1(t) = 1/T1o + r1 * Ct(t)
%
% Where:
%   - T1(t)  = measured T1 at time t (after injection)
%   - T1o    = baseline T1 (before contrast) in milliseconds (ms)
%   - Ct(t)  = concentration of Gadolinium at time t [mMol/L]
%   - r1     = relaxivity of Gadolinium [1/(sec*mMol)], typically ~3.4
%
% T1o values vary by tissue type and magnetic field strength 
% (e.g., 1.5T vs. 3T), with typical values ranging from ~800 to 1600 ms.
%
% This function estimates the effect of a perturbation 'd_T1o' on Ct using:
%       delta_Ct ≈ d_T1o / (gd * T1o * (T1o + d_T1o))
%
% And then:
%       new_Ct = Ct - delta_Ct
%
% -------------------------------
% DERIVATION OF APPROXIMATION
% -------------------------------
% From the relaxivity equation:
%       Ct = (1/T1(t) - 1/T1o) / r1  
%
% If T1o => T1o + d_T1o, we want:
%       Ct_new = (1/T1(t) - 1/(T1o + d_T1o)) / r1
%
% So the change delta_Ct is:
%       delta_Ct = Ct_new - Ct
%                = [1/T1o - 1/(T1o + d_T1o)] / r1
%                = d_T1o / (r1 * T1o * (T1o + d_T1o))
%
% -------------------------------
% INPUTS
% -------------------------------
%   Ct      - Original concentration-time curve (numeric vector) [mMol/L]
%   T1o     - Baseline T1 relaxation time before contrast [ms] (positive scalar)
%   gd      - Relaxivity of Gadolinium (scalar) [1/(sec*mMol)]
%   d_T1o   - Perturbation in T1o [ms] (numeric vector)
%
% -------------------------------
% OUTPUT
% -------------------------------
%   new_Ct  - Adjusted concentration curve accounting for T1o perturbation
%
% -------------------------------
% EXAMPLE USAGE
% -------------------------------
%   Ct = [0.1, 0.2, 0.15];        % mMol/L
%   T1o = 1200;                   % ms
%   gd = 3.4;                     % 1/(sec*mMol)
%   d_T1o = (-100:100:100)/1000;  % ms perturbations
%   new_Ct = d_T1o_VS_d_Ct(Ct, T1o, gd, d_T1o);
%--------------------------------
%% INPUT VALIDATION
  if nargin ~= 4
      error('Function requires 4 inputs: Ct, T1o, gd, d_T1o');
  end
  
  if ~isnumeric(Ct) || ~isvector(Ct)
      error('Ct must be a numeric vector.');
  end
  
  if any(~isreal(Ct)) || any(Ct < 0) || any(isnan(Ct)) || any(isinf(Ct))
      error('Ct must contain real, finite, non-negative values.');
  end
  
  if ~isscalar(T1o) || ~isreal(T1o) || T1o <= 0 || isnan(T1o) || isinf(T1o)
      error('T1o must be a real, finite, positive scalar.');
  end
  
  if ~isscalar(gd) || ~isreal(gd) || gd <= 0 || isnan(gd) || isinf(gd)
      error('gd must be a real, finite, positive scalar.');
  end
  
  if ~isnumeric(d_T1o) || ~isvector(d_T1o)
      error('d_T1o must be a numeric vector.');
  end
  
  if any(~isreal(d_T1o)) || any(isnan(d_T1o)) || any(isinf(d_T1o))
      error('d_T1o must contain only real, finite values.');
  end
  
  % Ensure Ct and d_T1o are same size
  if ~isequal(size(Ct), size(d_T1o))
      error('d_T1o_VS_d_Ct:InputMismatch', 'Ct and d_T1o must be the same size and orientation (row/column vector).');
  end


  % -------------------------------
  % MAIN COMPUTATION
  % -------------------------------
  d_Ct = d_T1o ./ (gd * T1o .* (T1o + d_T1o));
  
  % Ensure shape consistency 
  if iscolumn(Ct)
      d_Ct = d_Ct(:);
  end
  
  new_Ct = Ct - d_Ct;

  % Ensure the output has the same shape as the input Ct
  new_Ct = reshape(new_Ct, size(Ct));  % Retain original shape

end % end of main function
