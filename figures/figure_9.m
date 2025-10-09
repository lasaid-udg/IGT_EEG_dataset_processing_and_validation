function figure_9(segmentated_eeg, path)
n = 59;
fs = 256;
electrodes = segmentated_eeg.s_01.w001.Properties.VariableNames;
eoi = [5, 10, 20]; %electrodos [Cz, Fz, Pz];
for i=1:n
    disp(i)
    folderName = sprintf('s_%02d', i);
    try
        eeg_wind = segmentated_eeg.(folderName);
    catch
        % Handle case where the data struct is empty or subject field is missing (e.g., for testing).
        disp("Skipping subject " + i + ": Data field '" + folderName + "' not found in struct.");
        continue;
    end
    sample(:, :, i) = calculate_ERP(eeg_wind, eoi);
end
s2 =median(sample, 3);
%%
close all;
f = figure();
titles = electrodes(eoi);
t_P300 = [180, 249; 180, 249; 250, 340];
t_N400 = [350, 480; 350, 480];
t_FRN = [251, 348; 251, 330];

color_N400 = [250, 141, 120]/256;
color_P300 = [120, 205, 250]/256;
color_FRN = [255, 166, 238]/256;
subp_place = [2, 1, 3];
for i=1:length(titles)
    subplot(3, 1, subp_place(i))
    title(titles(i) + " - (A1 - A2)/2" ); hold on;
    signal_to_plot = s2(:, i)*10;
    t = transpose(((1/fs:1/fs:length(signal_to_plot)/fs)-2)*1000);
    sample_smooth = smoothdata(signal_to_plot, "SamplePoints",t);
    [env_sample_upper, env_sample_lower] = envelope(signal_to_plot, 14, "peak");

    plot(t, s2(:, i)*10, "Color",[125, 128, 125]/256);
    plot(t, sample_smooth, '-k');
    % plot(t, env_sample_upper, '-g');
    % plot(t, env_sample_lower, '-g');

    % FILL COMPLETE
    fill([t; flipud(t)], ...
        [env_sample_upper; flipud(env_sample_lower)], ...
        [204 252 218]/256, ...       
        'EdgeColor', 'none', ...
        'FaceAlpha', 0.4);       % transparencia (0 = transparente, 1 = opaco)
    % plot 0 line
    xline(0, '--r')

    % FILL ERP
    if titles(i) == "Cz"
        plot_ERP(t_P300(1, :), t, sample_smooth, env_sample_lower, env_sample_upper, color_P300);
        plot_ERP(t_N400(1, :), t, sample_smooth, env_sample_lower, env_sample_upper, color_N400);
        plot_ERP(t_FRN(1, :), t, sample_smooth, env_sample_lower, env_sample_upper, color_FRN);
        legend({"mean signal", "smooth signal", "envelope", "decision made","P300", "", "N400", "", "FRN"}, 'Location', 'southwest');
    elseif titles(i) == "Fz"
        plot_ERP(t_FRN(2,:), t, sample_smooth, env_sample_lower, env_sample_upper, color_FRN);
        plot_ERP(t_P300(2, :), t, sample_smooth, env_sample_lower, env_sample_upper, color_P300);
        legend({"mean signal", "smooth signal", "envelope", "decision made",  "FRN", "","P300"}, 'Location', 'southwest')
    elseif titles(i) == "Pz"
        plot_ERP(t_P300(3, :), t, sample_smooth, env_sample_lower, env_sample_upper, color_P300);
        plot_ERP(t_N400(2,:), t, sample_smooth, env_sample_lower, env_sample_upper, color_N400);
        legend({"mean signal", "smooth signal", "envelope", "decision made", "P300", "","N400"}, 'Location', 'southwest');
    end

    xlabel("Time (s)");
    xlim([-100 600])
    ylabel("Amplitude (mV)"); grid minor;
    ylim([-8 8])
end
%exportgraphics(f, "figure9_2.png", Resolution=300);
%%
end
function plot_ERP(t_stamps, t, sample, env_lower, env_upper, color)
% FILL COMPLETE
idx = (t >= t_stamps(1)) & (t <= t_stamps(2));

fill([t(idx); flipud(t(idx))], ...
    [env_upper(idx); flipud(env_lower(idx))], ...
    color, ...         % color (azul claro, cambia a gusto)
    'EdgeColor', 'none', ...
    'FaceAlpha', 0.4);       % transparencia (0 = transparente, 1 = opaco)
plot(t(idx), sample(idx), "Color", color-0.4, LineWidth=1.5);
end

function s = calculate_ERP(eeg_w, eoi)
window_names = fieldnames(eeg_w);
n_wind = length(window_names);

for i=21:n_wind % por cada ventana de ESTIMULO
    sample(:, :, i) = table2array(eeg_w.(window_names{i})(:, eoi));
end
s = mean(sample,3);
end