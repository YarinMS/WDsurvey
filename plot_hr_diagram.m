function fig = plot_hr_diagram(filename, wd_bp_rp, wd_mg)
% plot_hr_diagram Loads Gaia data from a file and plots the HR diagram
%   plot_hr_diagram(filename) loads BP-RP and Absolute Magnitude (M_G) from
%   the provided .mat file or CSV and creates a Hertzsprung-Russell diagram.
%   Optionally, the function can also mark a white dwarf (WD) on the diagram.
%   plot_hr_diagram(filename, wd_bp_rp, wd_mg) plots the HR diagram and marks
%   the white dwarf with a different marker.
%   If wd_bp_rp and wd_mg are not provided, it will only plot the HR diagram.

    % Check file extension and load data accordingly
    [~, ~, ext] = fileparts(filename);
    
    if strcmp(ext, '.mat')
        % Load from MAT file
        data = load(filename);
        bp_rp = data.bp_rp;
        mg = data.mg;
    elseif strcmp(ext, '.csv')
        % Load from CSV file
        data = readtable(filename);
        bp_rp = data.bp_rp;
        mg = data.mg;
    else
        error('Unsupported file format. Please provide a .mat or .csv file.');
    end

    % Plot the HR Diagram
    fig = figure;
    scatter(bp_rp, mg, 5, 'filled', 'MarkerFaceAlpha', 0.5, 'MarkerEdgeAlpha', 0.5, 'MarkerFaceColor', [0.5, 0.5, 0.5]);
    set(gca, 'YDir', 'reverse'); % Invert y-axis for brighter stars at the top
    xlabel('$B_p-R_p$');
    ylabel('Absolute Magnitude ($G$)');
    title('100pc Gaia HR Diagram');
    grid on;

    % Plot the white dwarf if provided
      % Plot the white dwarf if provided
    if exist('wd_bp_rp', 'var') && exist('wd_mg', 'var')
        hold on;
         wd_plot = scatter(wd_bp_rp, wd_mg, 50, 'Marker', 'H', 'MarkerEdgeColor', [0.8500, 0.3250, 0.0980], 'MarkerFaceColor', [0.8500, 0.3250, 0.0980]);
        legend(wd_plot, sprintf('White Dwarf ($B_p-R_p$: %.3f, Abs $G$: %.3f)', wd_bp_rp, wd_mg), 'Location', 'best');
        hold off;
    end
end