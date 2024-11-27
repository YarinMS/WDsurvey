function Fig = plotRMS2(Obj, IndSrc, Args)
    %
    arguments
        Obj
        IndSrc

        Args.SubPlot logical  = true;
        Args.FigN    = 2;
        Args.ResRMS  = [];

        Args.MagField              = 'MAG_BEST';
        Args.NsigmaPredRMS         = 5;
        Args.MinDetRMS             = 15;
    end

    if isempty(Args.ResRMS)
        ResRMS   = Obj.rmsMag('MagField', Args.MagField, 'MinDetRmsVar', Args.MinDetRMS, 'NsigmaPred', Args.NsigmaPredRMS);
    else
        ResRMS = Args.ResRMS;
    end

    if Args.SubPlot
        subplot(2, 1, Args.FigN);
        Fig = Args.FigN;
        cla;
        box on;
    else
        Fig = figure(Args.FigN);
        cla;
        box on;
    end

    % Primary log-scale y-axis plot
    semilogy(ResRMS.MeanMag, ResRMS.StdPar, '.', 'Color', [0.5, 0.5, 0.5], 'MarkerSize', 7);  % Dark grey
    alpha(0.5);  % Set opacity to 0.5
    hold on;

    % Sorted lines
    [~, SI] = sort(ResRMS.MeanMag);
    semilogy(ResRMS.MeanMag(SI), ResRMS.InterpMeanStd(SI), '-', 'Color', [0, 0, 0.5], 'LineWidth', 1.25);  % Burnt orange
    semilogy(ResRMS.MeanMag(SI), ResRMS.InterpMeanStd(SI) + ResRMS.InterpPredStd(SI) .* Args.NsigmaPredRMS, '--', ...
        'Color', [0.8, 0.33, 0.0], 'LineWidth', 1.25);  % Navy blue dashed line
    
    % Highlighted point
    plot(ResRMS.MeanMag(IndSrc), ResRMS.StdPar(IndSrc), 'o', 'MarkerFaceColor', [255, 160, 122] ./ 255, 'MarkerSize', 14);  % Highlighted point
    axis tight;

    % Adjust axis labels
    xlabel('Magnitude', 'FontSize', 14, 'Interpreter', 'latex');
    ylabel('RMS [mag]', 'FontSize', 14, 'Interpreter', 'latex');
    legend({'RMS', 'Interp Mean Std', '$5 - \sigma $ ', 'Source'}, 'FontSize', 12, 'Interpreter', 'latex', 'Location', 'best');
 
    hold off;
end
