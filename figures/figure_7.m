function figure_7(path)
% FIGURE7 Processes and plots the behavioral results from the IGT.
%   This function calculates the total credits balance for all subjects
%   across all IGT decisions and plots the grand average.
%
%   INPUT:
%      path - Root path to the data (still needed for IGT.csv).
%
%   NOTE: This function is kept largely *unchanged* as it processes IGT data
%   (IGT.csv) which is not present in the new 'segmentated_eeg' struct.
%   If IGT data is to be passed via the struct, this function requires a complete rewrite.

% Define the total number of subjects (n) to process.
n = 59;
% Initialize a matrix to store the total credits balance (200 decisions x n subjects).
gral_scores = zeros(200, n);

% Loop through each subject to load and process IGT data.
for i=1:n
    % Construct the subject-specific folder name, ensuring two digits (e.g., s-01, s-10).
    folderName = sprintf('s-%02d', i);
    % Construct the full file path for the behavioral data (IGT.csv).
    filePath_igt = fullfile(path, folderName, 'IGT.csv');
    % Read the IGT data table, preserving variable names.
    igt_tbl = readtable(filePath_igt, VariableNamingRule="preserve");
    % Extract the 'balance' column (total credits) for the current subject.
    gral_scores(:, i) = igt_tbl.balance;
end

% Close all existing figures before plotting the new one.
close all
% Create a new figure handle.
f = figure();
% Calculate the mean balance across all subjects for each decision.
x = mean(gral_scores');
% Set the figure title and enable 'hold on' for layering plots.
title("IGT results"); hold on;
% Plot the grand average balance over 200 decisions.
plot(x, LineWidth=1.5, Color="k");
% Set the axis labels.
xlabel("decision"); ylabel("total of credits");
pgon = polyshape([20 20 100 100], [2500 1500 1500 2500]);
plot(pgon,"EdgeColor",'none', "FaceAlpha",0.2, "FaceColor","c");
ylim([1500 2500]);
end

