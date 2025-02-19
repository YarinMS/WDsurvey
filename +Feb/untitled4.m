figure();
scatter(binned_X, binned_Y, 30, binned_C, 'filled', 'MarkerFaceAlpha', 0.7); % Scatter plot
set(gca, 'YScale', 'log');
colormap(jet);
grid on;
ylim([0.001 0.25]); % Set Y-limits
xlim([11.0 19.2]); % Set X-limits

% Add the colorbar
cb = colorbar;
cb.Label.Interpreter = 'latex';
cb.Label.String = '$$B_p - R_p$$';
cb.Direction = 'reverse'; % Reverse the colorbar

% Initialize array to store counts for color bins
color_bin_counts = zeros(length(color_bin_edges)-1, 1);

% Count number of points in each color bin
for c = 1:length(color_bin_edges)-1
    color_bin_counts(c) = sum(Colors >= color_bin_edges(c) & Colors < color_bin_edges(c+1));
end

% Create legend handles for color bins
hold on;
legend_handles = gobjects(length(color_bin_edges)-1, 1);

for c = 1:length(color_bin_edges)-1
    % Find closest matching color from the colormap
    color_value = mean([color_bin_edges(c), color_bin_edges(c+1)]); % Midpoint of bin
    legend_handles(c) = scatter(NaN, NaN, 30, color_value, 'filled', ...
        'DisplayName', sprintf('%.2f - $$B_p-R_p$$ (%i) - %.2f', color_bin_edges(c), color_bin_counts(c), color_bin_edges(c+1)), ...
        'MarkerEdgeAlpha', 0.7);
end

legend(legend_handles, 'Location', 'westoutside');
title(sprintf('%s CID %i BN %i 2vis Binned', ObsID, I, g));

% Add the top histogram for color bins
hist_y_top = 0.25; % Top of the Y-axis
max_height = 0.2; % Maximum height of the histogram (scaling factor)

for c = 1:length(color_bin_counts)
    % Draw a rectangle for each bin
    x_start = color_bin_edges(c);
    x_end = color_bin_edges(c+1);
    y_bottom = hist_y_top; % Start from the top of the Y-axis
    y_top = hist_y_top - (color_bin_counts(c) / max(color_bin_counts)) * max_height; % Scale height downwards
    patch([x_start x_end x_end x_start], [y_bottom y_bottom y_top y_top], ...
          'k', 'FaceAlpha', 0.5, 'EdgeColor', 'k'); % Black bars with transparency
end

hold off;

% Save the plot
PN_binned_histogram = sprintf('%s_CID_%i_BN_%i_Binned_TopHistogram.png', ObsID, I, g);
saveas(gcf, PN_binned_histogram);
