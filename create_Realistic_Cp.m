function Cp = create_Realistic_Cp()
%
% Function to generate a synthetic plasma concentration (Cp) curve
% resembling a realistic DCE-MRI arterial input function (AIF)
%
% Output: Cp - a 120-point column vector representing contrast agent 
% concentration in plasma over time, scaled to a maximum of 0.2.
% It also saves the Cp values as a .mat file.
%
% Author: Dr. Tanuj Puri 
% Date:   01/2014, updated 2025
% Warning: This is an untested code/implementation and should be used
% with caution in clinical and pre-clinical settings.
%
%
    % Total number of time points (e.g., over a time span like 0–5 minutes)
    n = 120;

    % Time vector, not directly used but implies uniform sampling across 5 minutes
    t = linspace(0, 5, n); % from 0 to 5 minutes, uniformly sampled

    % Initialize Cp vector with all zeros
    Cp = zeros(1, n);

    % Parameters to define phases of Cp curve
    delay_pts = 10;  % number of initial zero points before contrast appears
    rise_pts = 3;    % number of points in sharp rise (contrast injection)
    fall_pts = 3;    % number of points in immediate sharp fall after peak
    % Remaining points used for exponential washout
    tail_pts = n - (delay_pts + rise_pts + fall_pts); % remaining timepoints

    % Values during the sharp rise (arbitrary units before scaling)
    peak_vals = [4, 12, 18];  % simulates bolus injection rise

    % Values during the sharp fall following the peak
    fall_vals = [15, 10, 6];  % simulates fast plasma clearance

    % Exponential washout tail, mimicking physiological contrast decay
    tail = 6 * exp(-0.05 * (0:tail_pts-1)); % starts from 6, decays over time

    % Fill Cp vector with the peak values during the rise phase
    Cp(delay_pts+1 : delay_pts+rise_pts) = peak_vals;

    % Fill Cp vector with fall values immediately after the rise
    Cp(delay_pts+rise_pts+1 : delay_pts+rise_pts+fall_pts) = fall_vals;

    % Fill remaining Cp vector with the exponential tail
    Cp(delay_pts+rise_pts+fall_pts+1 : end) = tail;

    % Normalize Cp so that its maximum value is exactly 0.2
    Cp = 0.2 * Cp / max(Cp);

    % Convert Cp to a column vector for consistency
    Cp = Cp(:);

    % Save the Cp vector to a .mat file named 'Cp.mat'
    save('Cp.mat', 'Cp')
end
