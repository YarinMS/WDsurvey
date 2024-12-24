function plotHRDiagramWithSource(gaiaData, sourceMg,sourceBpRp)
    % Inputs:
    %   gaiaData - Struct containing Gaia 100 pc HR diagram data (fields: bp_rp, mg)
    %   sourceMg - Absolute magnitude (Mg) of the additional source
    %   sourceBpRp - BP-RP color index of the additional source
    %   sourceBp - BP magnitude of the additional source (for legend label)

    % Create the figure

    

    hold on;

    % Plot Gaia 100 pc data in semi-transparent gray
    scatter(gaiaData.bp_rp, gaiaData.mg, 8, 'MarkerEdgeColor', [0.5 0.5 0.5], ...
        'MarkerFaceAlpha', 0.6, 'MarkerEdgeAlpha', 0.6);

    % Plot the special source in burnt orange
    scatter(sourceBpRp, sourceMg, 30, 'MarkerEdgeColor', [0.85, 0.33, 0.1], ...
        'MarkerFaceColor', [0.85, 0.33, 0.1], 'LineWidth', 1.5);

    % Add labels to the axes
    xlabel('$B_p-R_p$ (mag)', 'FontSize', 12);
    ylabel('$M_G$ (mag)', 'FontSize', 12);
    set(gca, 'YDir', 'reverse'); % Invert y-axis (HR diagram convention)

    % Add legend
    legend({'100 pc Gaia Sources', sprintf('($M_G$=%.2f, $B_p-R_p$=%.2f)', ...
        sourceMg, sourceBpRp)}, 'FontSize', 10);

    % Add grid for better visualization
    grid on;

    % Enhance the appearance
    title('HR diagram (100 pc Gaia)', 'FontSize', 14);
    hold off;
end
