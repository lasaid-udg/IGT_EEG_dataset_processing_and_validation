function figure_8(segmentated_eeg)
%FIGURE_8 Calculates and plots the mean Power Spectral Density (PSD)
%   for the Noise Floor (NF) and the main Cortical Band of interest (BOI).
%
%   The function processes segmented EEG data from multiple subjects,
%   calculates the PSD for two defined frequency bands (NF and BOI),
%   and visualizes the results using a box plot. The results are scaled
%   from (mV^2/Hz) to (uV^2/Hz) for presentation.
%
%   INPUTS:
%       segmentated_eeg - A structure array where each field corresponds
%                         to a subject (e.g., 's_01') and contains
%                         segmented EEG data (e.g., in a table format).
%
%   OUTPUTS:
%       None - The function generates a figure with a box plot.
%
%   SUBFUNCTIONS:
%       noise_floor - Calculates the PSD in the noise floor frequency band.
%       psd_in_boi  - Calculates the PSD in the cortical band of interest.
%       filter_for_nf - Applies filters for noise floor calculation.
%       filter_for_boi - Applies filters for cortical band calculation.
%       get_psd     - Calculates the integrated PSD over a specified band.
%       getfft      - Calculates the Power Spectral Density (PSD) using FFT.
%

% --- Main Function: figure_8 ---

n = 59;
% Define the number of subjects to process.

fs = 256;
% Define the sampling frequency in Hz.

labels = {'NF', 'BOI'};
% Define initial labels (unused, as labels are redefined later for the plot).

for i=1:n
% Loop through each subject from 1 to 'n'.

    folderName = sprintf('s_%02d', i);
    % Format the subject's field name (e.g., 's_01', 's_02').

    try
        eeg_wind = segmentated_eeg.(folderName);
        % Attempt to access the EEG data for the current subject.
    catch
        % Catch block handles errors if the subject's field is missing.
        disp("Skipping subject " + i + ": Data field '" + folderName + "' not found in struct.");
        % Display a message indicating that the subject is being skipped.
        continue;
        % Skip to the next iteration of the loop.
    end

    nf(:, i) = noise_floor(eeg_wind, fs);
    % Calculate the Noise Floor (NF) PSD for the current subject and store it.
    
    boi(:, i) = psd_in_boi(eeg_wind, fs);
    % Calculate the PSD in the Band of Interest (BOI) for the current subject and store it.

end

mean_nf = mean(nf);
% Calculate the mean NF PSD across all windows for each subject.

mean_boi = mean(boi);
% Calculate the mean BOI PSD across all windows for each subject.

labels = ["Noise floor"; "Cortical band"];
% Redefine the labels for the box plot.

f = figure(); 
% Create a new figure handle.

boxplot(([mean_nf; mean_boi]/1000)', "Labels",labels, "Notch","on");
% Create the box plot:
% 1. Concatenate mean NF and mean BOI arrays.
% 2. Divide by 1000 to convert from (mV^2/Hz) to a standard unit (assuming uV^2/Hz scaling from elsewhere or to match a publication standard).
% 3. Transpose the resulting matrix for correct box plot orientation (subjects as columns).
% 4. Set the labels and enable the notch feature.

ylabel(["Power spectral density"; " (mV^2/Hz)"]);
% Set the y-axis label (note: the unit is shown as mV^2/Hz, which should be consistent with the scaling).

end

% -------------------------------------------------------------------------

function nf = noise_floor(eeg_w, fs)
%NOISE_FLOOR Calculates the PSD in the noise floor frequency band (e.g., 70 Hz to Nyquist).
%
%   INPUTS:
%       eeg_w - Segmented EEG windows for one subject (struct).
%       fs    - Sampling frequency in Hz.
%
%   OUTPUTS:
%       nf    - Array of integrated PSD values for the noise floor band.

window_names = fieldnames(eeg_w);
% Get the names of the fields (windows) in the subject's data structure.

n_wind = length(window_names);
% Get the total number of windows.

psd_nf_bands = {"noise floor", 70, fs/2};
% Define the PSD band: name, start frequency (Hz), end frequency (Nyquist).

for i=1:n_wind
% Loop through each segmented window.

    sample = table2array(eeg_w.(window_names{i}));
    % Convert the window data (table) to a numerical array.
    
    noisy_sample = filter_for_nf(sample,fs, psd_nf_bands);
    % Apply filtering specific for noise floor calculation (stop-band at line noise).
    
    nf(i, :) = get_psd(noisy_sample, psd_nf_bands, fs);
    % Calculate the integrated PSD for the noise floor band and store it.

end
end

% -------------------------------------------------------------------------

function filtered_sig = filter_for_nf(filtered_sig, fs, psd_nf_bands)
%FILTER_FOR_NF Applies notch and bandpass filters for the noise floor calculation.
%
%   INPUTS:
%       filtered_sig - Input EEG signal (data array).
%       fs           - Sampling frequency in Hz.
%       psd_nf_bands - Structure containing the frequency band limits.
%
%   OUTPUTS:
%       filtered_sig - The signal after applying all defined filters.

filters = [59.5, 60.5; 119.5, 120.5; psd_nf_bands{2}, psd_nf_bands{3}-1];
% Define filter frequency limits [low, high]:
% 1. 60 Hz notch band.
% 2. 120 Hz notch band (harmonic).
% 3. Bandpass filter for the noise floor band itself (70 Hz to Nyquist-1).

filter_type = ["stop","stop","bandpass"];
% Define the type of filter for each band.

f_or = 5;
% Define the filter order for the Butterworth filter.

for i=1:length(filter_type)
% Loop through each filter.

    [b, a] = butter(f_or, [filters(i, 1) filters(i, 2)]/(fs/2), filter_type(i));
    % Design the Butterworth filter:
    % 'f_or' is the order, normalized frequencies are [filters] / (fs/2), and filter 'type'.
    
    filtered_sig = filtfilt(b, a, filtered_sig);
    % Apply the filter using zero-phase forward and reverse digital filtering.

end
end

% -------------------------------------------------------------------------

function psd_value = get_psd(sample, psd_bands, fs)
%GET_PSD Calculates the integrated Power Spectral Density (PSD) over a specified band.
%
%   INPUTS:
%       sample    - Input EEG signal segment (data array).
%       psd_bands - Structure containing the band name, start, and end frequencies.
%       fs        - Sampling frequency in Hz.
%
%   OUTPUTS:
%       psd_value - The integrated PSD value over the band (area under the curve).

lim_bands = [psd_bands{2} psd_bands{3}];
% Extract the frequency limits [start, end] from the input structure.

[f, x_fft] = getfft(sample, fs);
% Calculate the frequency vector 'f' and the PSD 'x_fft' for the sample.

% The following two lines were redundant find operations and are removed:
% lim1_f = find(f == lim_bands(1));
% lim2_f = find(f == lim_bands(2));

lim1_f = find(f >= lim_bands(1), 1, 'first');
% Find the index of the first frequency point greater than or equal to the band's start frequency.

lim2_f = find(f <= lim_bands(2), 1, 'last');
% Find the index of the last frequency point less than or equal to the band's end frequency.

try
% Use a try-catch block for conditional operations based on band name (e.g., 'gamma').
if psd_bands{1} == "gamma"
    % Check if the band name is "gamma".
    f_60 = f == 60;
    % Create a logical index for the 60 Hz frequency point.
    x_fft(f_60) = 0;
    % Zero out the PSD value at 60 Hz to remove line noise spike from gamma calculation.
end
catch
% Catch any errors in the conditional check (e.g., if psd_bands{1} is not a string).
end

psd_value = trapz(f(lim1_f:lim2_f), x_fft(lim1_f:lim2_f));
% Calculate the integrated PSD (area under the curve) using the trapezoidal numerical integration method.
% Integration is performed only over the frequency range defined by lim1_f and lim2_f.

end

% -------------------------------------------------------------------------

function [f, psd] = getfft(s, fs)
%GETFFT Calculates the single-sided Power Spectral Density (PSD) of a signal.
%
%   INPUTS:
%       s  - Input signal (data array).
%       fs - Sampling frequency in Hz.
%
%   OUTPUTS:
%       f  - Frequency vector (0 to Nyquist).
%       psd- Power Spectral Density [mV^2/Hz].

N = length(s);
% Get the number of samples in the signal.

xdft = fft(s);
% Compute the Discrete Fourier Transform (DFT).

xdft = xdft(1:N/2+1);
% Keep only the first half of the spectrum (single-sided spectrum, including DC and Nyquist).

psd = (1/fs) * abs(xdft).^2;
% Calculate the Power Spectral Density (PSD) in [Unit^2/Hz] (often V^2/Hz or mV^2/Hz).
% Note: The PSD is calculated without dividing by N (the length of the signal).

psd(2:end-1) = 2*psd(2:end-1);
% Double the power for all points except DC (psd(1)) and Nyquist (psd(end)) to account for the single-sided spectrum.

f = 0:fs/N:fs/2;
% Create the frequency vector from 0 to Nyquist (fs/2) with frequency resolution fs/N.

end

% -------------------------------------------------------------------------

function boi = psd_in_boi(eeg_w, fs)
%PSD_IN_BOI Calculates the PSD in the cortical Band of Interest (BOI) (e.g., 0.5 Hz to 59 Hz).
%
%   INPUTS:
%       eeg_w - Segmented EEG windows for one subject (struct).
%       fs    - Sampling frequency in Hz.
%
%   OUTPUTS:
%       boi   - Array of integrated PSD values for the BOI band.

window_names = fieldnames(eeg_w);
% Get the names of the fields (windows) in the subject's data structure.

n_wind = length(window_names);
% Get the total number of windows.

psd_nf_bands = {"boi", 0.5, 59};
% Define the PSD band: name, start frequency (Hz), end frequency (Hz).

for i=1:n_wind
% Loop through each segmented window.

    sample = table2array(eeg_w.(window_names{i}));
    % Convert the window data (table) to a numerical array.
    
    boi_sample = filter_for_boi(sample, fs);
    % Apply filtering specific for BOI calculation (bandpass 0.5-16 Hz in the filter subfunction).
    
    boi(i, :) = get_psd(boi_sample, psd_nf_bands, fs);
    % Calculate the integrated PSD for the BOI band and store it.

end
end

% -------------------------------------------------------------------------

function signal = filter_for_boi(signal, fs)
%FILTER_FOR_BOI Applies a bandpass filter to focus on the cortical BOI.
%
%   INPUTS:
%       signal - Input EEG signal (data array).
%       fs     - Sampling frequency in Hz.
%
%   OUTPUTS:
%       signal - The signal after applying the bandpass filter.

filters = [0.5, 16];
% Define filter frequency limits [low, high] for the bandpass filter (0.5 to 16 Hz).

filter_type = "bandpass";
% Define the type of filter.

f_or = 5;
% Define the filter order for the Butterworth filter.

for i=1:length(filter_type)
% Loop through each filter (only one in this case).

    [b, a] = butter(f_or, [filters(i, 1) filters(i, 2)]/(fs/2), filter_type(i));
    % Design the Butterworth filter.
    
    signal = filtfilt(b, a, signal);
    % Apply the filter using zero-phase forward and reverse digital filtering.

end
end