figure();
scatter(binned_X, binned_Y, 30, binned_C, 'filled', 'MarkerFaceAlpha', 0.7); % Scatter plot
set(gca, 'YScale', 'log');
colormap(jet); % Apply colormap
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

% Map the color_bin_edges to the X-axis limits
x_min = 11.0; % Minimum X-axis limit
x_max = 19.2; % Maximum X-axis limit
color_bin_edges_scaled = x_min + (x_max - x_min) * ((color_bin_edges - min(color_bin_edges)) / (max(color_bin_edges) - min(color_bin_edges)));

% Add the top histogram for color bins
hist_y_top =0.25; % Top of the Y-axis
max_height = 0.2; % Maximum height of the histogram (scaling factor)

for c = 1:length(color_bin_counts)
    % Draw a rectangle for each bin
    x_start = color_bin_edges_scaled(c);
    x_end = color_bin_edges_scaled(c+1);
    y_bottom = hist_y_top; % Start from the top of the Y-axis
    y_top = hist_y_top - (color_bin_counts(c) / max(color_bin_counts)) * max_height; % Scale height downwards
    patch([x_start x_end x_end x_start], [y_bottom y_bottom y_top y_top], ...
          'k', 'FaceAlpha', 0.5, 'EdgeColor', 'k'); % Black bars with transparency
end
% Add a secondary top Y-axis for color bins
ax1 = gca; % Main plot axis
ax2 = axes('Position', ax1.Position, ... % Same position as the main plot
           'XAxisLocation', 'top', ... % Top X-axis
           'YAxisLocation', 'right', ... % Right-side Y-axis
           'Color', 'none', ... % Transparent background
           'XColor', 'none', ... % Hide X-axis
           'YTick', [], ... % Hide Y-ticks
           'YTickLabel', '', ... % Hide Y-tick labels
           'YColor', 'k'); % Black color for the Y-axis labels

% Add tick labels for the top Y-axis based on color bins
set(ax2, 'XAxisLocation', 'top', ...
         'XTick', (color_bin_edges_scaled(1:end-1) + color_bin_edges_scaled(2:end)) / 2, ... % Midpoints of bins
         'XTickLabel', sprintfc('%.2f', color_bin_edges(1:end-1))); % Label ticks with color bin values
xlabel(ax2, '$B_p - R_p$', 'Interpreter', 'latex'); % Label for the secondary axis

hold off;

% Save the plot
PN_binned_histogram = sprintf('%s_CID_%i_BN_%i_Binned_TopHistogram.png', ObsID, I, g);
saveas(gcf, PN_binned_histogram);
