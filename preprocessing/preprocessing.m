
function processed_eeg = preprocessing(raw_eeg, timestamps)
%   PROCESSED_EEG = PREPROCESSING(RAW_EEG, TIMESTAMPS) performs standard
%   preprocessing steps on raw EEG data, including re-referencing, filtering,
%   and signal segmentation into epochs (windows).
%
%   Inputs:
%       - RAW_EEG: Table or matrix containing the raw EEG signal data (time x channels).
%       - TIMESTAMPS: Column vector of sample indices (timestamps) indicating
%                     the central point for task-related windows.
%
%   Output:
%       - PROCESSED_EEG: Structure array where each field ('w001', 'w002', ...)
%                        contains an epoched segment (window) of the processed EEG signal.
%
%   Dataset Reference:
%   "Chávez-Sánchez, Manuel; Torres-Ramos, Sulema ; Roman-Godinez, Israel; Salido-Ruiz,
%   Ricardo A. (2025), “An electroencephalographic and behavioral dataset from the Iowa
%   Gambling Task application on non-clinical participants”, Mendeley Data,
%   V1, doi: 10.17632/2pw2m39yct.1"
%
%   Note: Sampling frequency (fs) of 256 Hz for filtering and windowing.

% RE-REFERENCING SIGNAL TO AURICLES
% Applies the common average reference (CAR) or specific reference (e.g., linked-auricles)
% as implemented in the external function rereference_eeg.
reref_sig = rereference_eeg(raw_eeg);

% FILTERS THE SIGNAL
% Applies bandpass and notch filtering to the re-referenced signal.
[processed_eeg] = filter_eeg(reref_sig);

% SEGMENTS THE SIGNAL INTO WINDOWS/EPOCHS
% Divides the continuous, filtered EEG signal into epochs based on timestamps,
% including segments for a baseline state.
%processed_eeg = segmentation_eeg(eeg_sig, timestamps);

end
