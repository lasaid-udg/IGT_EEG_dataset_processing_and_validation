function eeg_wind = segmentation_eeg(eeg_sig, timestamps)
% WINDOWED_SIGNAL Segments the continuous EEG signal into epochs.
%
%   EEG_WIND = WINDOWED_SIGNAL(EEG_SIG, TIMESTAMPS) creates fixed-length epochs
%   around specified task-related timestamps and generates additional windows
%   for a baseline state.
%
%   Inputs:
%       - EEG_SIG: The continuous, filtered EEG signal.
%       - TIMESTAMPS: Column vector of sample indices for task events.
%
%   Output:
%       - EEG_WIND: Structure array containing the segmented windows.

disp("signal segmentation...") % Display status message.

fs = 256; % Sampling frequency (Hz).

% BASELINE STATE TIMESTAMPS
basa_state_timestamps = 20; % Number of baseline windows to generate.
x_min = 5; % Minimum second in the record to select baseline window start.
x_max = 175; % Maximum second in the record to select baseline window start (i.e., 5 seconds before the test starts).

% Generate equally spaced timestamps (in seconds) for baseline windows.
timestamps_bs = linspace(x_min, x_max, basa_state_timestamps);
% Convert to sample indices and ensure it's a column vector of integers.
timestamps_bs = transpose(round(timestamps_bs * fs));

% Combine baseline and task-related timestamps for all windows.
timestamps_all = [timestamps_bs; timestamps];

% Define window lengths:
bef_m = (2*fs)-1; % Number of samples taken BEFORE the central timestamp (2 seconds - 1 sample).
aft_m = 2*fs; % Number of samples taken AFTER the central timestamp (2 seconds).
% Total window duration is bef_m + aft_m + 1 sample (the central point) = 4*fs samples (4 seconds).

% Epoching loop.
for i=1:length(timestamps_all) % For each window.
    % Define the range of samples for the current window.
    window_range = timestamps_all(i)-bef_m:timestamps_all(i)+aft_m;
    % Store the windowed EEG data in a structure with descriptive field names (w001, w002, ...).
    eeg_wind.("w"+sprintf("%03d",i)) = eeg_sig(window_range,:);

    %save_segment()
end
end
function save_segment(eeg_data, save_path, subject_id)
%SAVE_SEGMENT Writes the preprocessed EEG data to a CSV file.
%   'eeg_data': The data structure (e.g., table or matrix) returned by preprocessing.
%   'save_path': The destination directory ('segments' folder).
%   'subject_id': The subject identifier (e.g., 's-01') used for the filename.
    
    % Construct the output filename using the subject ID.
    filename = sprintf('%s_preprocessed.csv', subject_id);
    
    % Construct the full file path for saving.
    full_save_path = fullfile(save_path, filename);
    
    % Write the data to a CSV file. Assumes 'eeg_data' is a table or matrix compatible with writetable/writematrix.
    if istable(eeg_data)
        writetable(eeg_data, full_save_path);
    else % Assumes a matrix if not a table
        writematrix(eeg_data, full_save_path); 
    end
end