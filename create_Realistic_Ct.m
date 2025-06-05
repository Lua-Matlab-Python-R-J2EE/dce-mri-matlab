function Ct = create_Realistic_Ct()
%
% Function to generate a synthetic tissue concentration (Ct) curve
% resembling a realistic DCE-MRI tissue time activity curve 
%
% Output: Ct - a 120-point column vector representing contrast agent 
% concentration in plasma over time, scaled to a maximum of 0.15.
% It also saves the Ct values as a .mat file.
%
% Author: Dr. Tanuj Puri 
% Date: 01/2014 
% Warning: This is an untested code/implementation and should be used
% with caution in clinical and pre-clinical settings.
%
%
    % Number of time points
    n = 120;
    t = linspace(0, 5, n);  % time in minutes

    % Parameters for the AIF-like Cp
    delay = 0.5;        % delay in minutes before bolus appears
    amplitude = 0.015;  % peak amplitude
    tau = 0.2;          % bolus sharpness (rise time)
    washout = 1.5;      % washout time constant (decay)

    % Initialize Cp as zeros
    Ct = zeros(size(t));

    % Indices where t > delay
    idx = t > delay;

    % Gamma-variate like function for Cp
    Ct(idx) = amplitude * ((t(idx) - delay) / tau) .* exp(-(t(idx) - delay) / washout);

    Ct = Ct(:); % ensure column vector
    save('Ct.mat', 'Ct')
end
