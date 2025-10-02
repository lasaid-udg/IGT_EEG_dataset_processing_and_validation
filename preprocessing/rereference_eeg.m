function data_ref = EEG_ref(eeg)
% EEG_REF Performs re-referencing of EEG data to the mean of A1 and A2.
%
%   DATA_REF = EEG_REF(EEG) re-references the raw EEG data by subtracting
%   the average signal of the A1 and A2 electrodes from all other channels.
%   It removes the A1 and A2 channels and creates a placeholder channel 'Pz'
%   before applying the re-referencing.
%
%   Input:
%       - EEG: Table containing the raw EEG signal data (time x channels).
%              It must include columns named 'A1' and 'A2'.
%
%   Output:
%       - DATA_REF: Table containing the re-referenced EEG signals.
%
%   Dataset Reference:
%   "Chávez-Sánchez, Manuel; Torres-Ramos, Sulema ; Roman-Godinez, Israel; Salido-Ruiz,
%   Ricardo A. (2025), “An electroencephalographic and behavioral dataset from the Iowa
%   Gambling Task application on non-clinical participants”, Mendeley Data,
%   V1, doi: 10.17632/2pw2m39yct.1"
%
%   Note: Sampling frequency (fs) of 256 Hz for filtering and windowing.

disp("rereferencing...") % Display status message.

% Define the electrodes for the reference (auricular bipole A1 + A2).
ref_electrodes = {'A1', 'A2'};

% Call the nested function to perform the re-referencing process.
data_ref = add_ref(eeg, ref_electrodes);

% Nested function that performs the re-referencing process on the EEG data.
    function data_ref = add_ref(data, ref_electrodes)
        % Calculate the new reference electrode (the mean of A1 and A2 signals).
        % table2array converts the table columns to a matrix. mean(..., 2) calculates the mean across columns (i.e., row-wise mean).
        ref_data = mean(table2array(data(:, ref_electrodes)), 2);

        % Remove the original reference channels (A1 and A2).
        data = removevars(data, ref_electrodes);

        % Create a new channel 'Pz' initialized with zeros.
        % NOTE: The 'Pz' channel is likely added as a placeholder or due to a later requirement.
        % The value of zero will be re-referenced along with other channels.
        new_ref = zeros(height(data), 1);
        data.Pz = new_ref;

        % Get the re-referenced EEG data by subtracting the reference data (A1 + A2 mean).
        data_ref_array = table2array(data);
        % Perform the re-referencing operation: New_EEG = Old_EEG - Reference_Mean (row by row subtraction).
        data_ref_array = data_ref_array - ref_data;

        % Get the names of the remaining/new electrodes.
        electrodes = data.Properties.VariableNames;
        % Convert the re-referenced array back to a table with the correct variable names.
        data_ref = array2table(data_ref_array, "VariableNames",electrodes);
    end

% The original display message is removed as it's not strictly necessary for core function execution.
end
