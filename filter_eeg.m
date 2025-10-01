function eeg_filtered = filter_eeg(eeg)
% FILTER_EEG Filters the EEG signal.
%
%   EEG_FILTERED = FILTER_EEG(EEG) applies a bandpass filter (0.5-70 Hz)
%   and a notch filter (60 Hz) using a third-order Butterworth filter.
%
%   Input:
%       - EEG: The EEG signal (re-referenced) to be filtered.
%
%   Output:
%       - EEG_FILTERED: The filtered EEG signal.

fs = 256; % Define the sampling frequency (Hz).
% SIGNAL FILTERING
disp("filtering...") % Display status message.

% Convert the input (expected to be a table) to an array for filtering.
filt_array = table2array(eeg);

% Define filter parameters:
% 1. Bandpass filter: 0.5 - 70 Hz (to retain typical EEG frequency range).
% 2. Notch filter: 59.5 - 60.5 Hz (to remove 60 Hz power line noise).
filters = [0.5, 70; 59.5, 60.5];
filter_type = ["bandpass", "stop"]; % Corresponding filter types.
f_or = 3; % Butterworth filter order.

% Apply filters iteratively.
for i=1:length(filter_type)
    % Design the Butterworth filter. Cutoff frequencies are normalized by the Nyquist frequency (fs/2).
    [b, a] = butter(f_or, [filters(i, 1) filters(i, 2)]/(fs/2), filter_type(i));
    % Apply zero-phase digital filtering (forward and reverse) to avoid phase distortion.
    filt_array = filtfilt(b, a, filt_array);
end

eeg_filtered = array2table(filt_array, "VariableNames", eeg.Properties.VariableNames);
end