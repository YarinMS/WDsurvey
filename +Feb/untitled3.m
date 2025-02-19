log_scaled_color_bin_edges = log10(color_bin_edges); % Convert color bin edges to log scale

% Define histogram properties
bar_x_max = 19.2; % Rightmost x position of the histogram
bar_width = 0.8; % Width of each bar in the x-direction
normalized_counts = color_bin_counts / max(color_bin_counts) * bar_width; % Scale counts to fit bar width

% Plot the histogram using log-scaled edges
for c = 1:length(color_bin_counts)
    % Coordinates for the bar (rectangle)
    x_left = bar_x_max - normalized_counts(c); % Bar extends leftwards
    x_right = bar_x_max; % Right edge of the bar
    y_bottom = 10^log_scaled_color_bin_edges(c); % Log-scaled bottom edge
    y_top = 10^log_scaled_color_bin_edges(c+1); % Log-scaled top edge
    % Draw the bar using patch
    patch([x_left x_right x_right x_left], [y_bottom y_bottom y_top y_top], 'k', ...
          'FaceAlpha', 0.5, 'EdgeColor', 'k'); % Black bars with transparency
end