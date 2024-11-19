function plotRMSvsMagnitude(stackedWDtable, args)
    % Plot RMS vs. Magnitude for each WD across all batches in one plot
    %
    % Inputs:
    %   stackedWDtable - Combined table with all WDs across fields
    %   args - Arguments structure containing Date and Telescope information

    figure;
    hold on;
    colors = lines(height(stackedWDtable)); % Generate unique colors for each WD
    
    for i = 1:height(stackedWDtable)
        batchDataArray = stackedWDtable.BatchData{i}; % Access BatchData for current WD
        rmsValues = [];
        magnitudes = [];
        
        % Extract RMS and magnitude for each batch
        D = false;
        for j = 1:numel(batchDataArray)
            batchData = batchDataArray{j};
            if isfield(batchData,'eventMetrics') 
                rmsValues = [rmsValues; batchData.eventMetrics.stdWithEvent];
                magnitudes = [magnitudes; stackedWDtable.Gmag(i)];
                  if ~isnan(batchData.eventMetrics.stdOutOfEvent)
                    D = true;
                  end
            end
        end

        
        if D
            

            plot(mean(magnitudes), mean(log10(rmsValues)), 'o', 'MarkerFaceColor', colors(i, :), ...
            'MarkerSize', 6, 'DisplayName', sprintf('WD #%d Gmag = %.3f (WithEvent); Det Eff = %.2f %% ', i,stackedWDtable.Gmag(i),100*stackedWDtable.BatchDetections(i) / stackedWDtable.Nbatch(i)));
    


        else 
        
        % Plot RMS vs. Magnitude for this WD
        plot(mean(magnitudes), mean(log10(rmsValues)), '.', 'Color', colors(i, :), ...
            'MarkerSize', 15, 'DisplayName', sprintf('WD #%d Gmag = %.3f ; Det Eff = %.2f %%', i,stackedWDtable.Gmag(i),100*stackedWDtable.BatchDetections(i) / stackedWDtable.Nbatch(i)));
    
        
        end

    end
    
    hold off;
    xlabel('Magnitude (Gmag)');
    ylabel('RMS');
    title(sprintf('median RMS vs. Magnitude for All %i WDs\n%s - %s \n Circles include events',args.Nwds, args.Date, args.Tel));
    if args.legend
        legend('show','Location','northwestoutside');
        
    end
    grid on;
end
