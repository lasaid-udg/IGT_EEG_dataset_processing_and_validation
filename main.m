function main(path)

%% Configuration and Iteration Setup
path = "... \data\"; % Define the base directory for the dataset.
n = 59;             % Define the total number of subjects (iterations).
addpath figures\
addpath preprocessing\
for i = 1:n         % Start loop to iterate through each subject from 1 to 'n'.
    disp("Current process: s_" +num2str(i));

    % Construct the subject-specific folder name, ensuring two digits (e.g., s-01, s-10).
    folderName = sprintf('s-%02d', i);

    % Construct the full file path for the raw EEG data (EEG.csv).
    filePath_eeg = fullfile(path, folderName, 'EEG.csv');

    % Construct the full file path for the behavioral data (IGT.csv).
    filePath_igt = fullfile(path, folderName, 'IGT.csv');

    % Load the raw EEG data from the specified path.
    raw_eeg = load_eeg(filePath_eeg);

    % Load the event timestamps (EEG sample indices) from the IGT data.
    timestamps = load_igt(filePath_igt);

    % Call the external preprocessing function with the loaded data.
    % NOTE: The 'preprocessing' function must be defined separately.
    segmentated_eeg.("s_"+sprintf('%02d', i)) = main_preprocessing(raw_eeg, timestamps);
   
    %disp("Data s_" +num2str(i)+" preprocessed.");
end
%% PROCESS - ERP -
%% FIGURES
main_figures(path, segmentated_eeg);
end % End of the main function 'make_preprocess'.

%% Helper Functions

function timestamps = load_igt(igtpath)
%LOAD_IGT Loads the IGT data and extracts the 'EEG sample' timestamps.
%   'igtpath': Full path to the IGT.csv file.
%   'timestamps': Vector containing the 'EEG sample' indices for event markers.

% Read the IGT table, preserving variable names as they might contain spaces or special chars.
t = readtable(igtpath, "VariableNamingRule","preserve");

% Extract the 'EEG sample' column (the event timestamps in sample index).
timestamps = t.("EEG sample");
end

function eeg_sig = load_eeg(eegpath)
%LOAD_EEG Loads the raw EEG data table.
%   'eegpath': Full path to the EEG.csv file.
%   'eeg_sig': The timetable or table containing the raw EEG signal data.

% Read the EEG data from the specified CSV file.
eeg_sig = readtable(eegpath);
end