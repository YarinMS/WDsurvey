 function plotLightCurve2(results, Iwd, Ibatch, LC, Methods,flux, FluxMethods)
                t = datetime(LC.JD, 'ConvertFrom', 'jd');
                [t,sidx] = sort(t);
                y = LC.lc(sidx);
                c = LC.Ctrl.CtrlStar(sidx);
                C = LC.Ctrl.medLc(sidx);

                if Methods(1)
                    results{1}.detection1.events = find(ismember(sidx,results{1}.detection1.events));
                end

                if Methods(2)

                    results{1}.detection2.events = find(ismember(sidx,results{1}.detection2.events));
                end


               
                [lmt,sidx] = sort(datetime(LC.catJD, 'ConvertFrom', 'jd'));
                 lm = LC.limMag(sidx);
                
                plot(t, y, 'O-','Color', [0.25, 0.25, 0.25], 'LineWidth', 2,'DisplayName', sprintf('$\\sigma =$ %.3f',std(y,'omitnan')));
                hold on;
                
                plotDetectedEvents(results, Iwd, Ibatch, t, y, Methods, FluxMethods);
                
                plot(lmt, lm, 's-','Color', [0.6350, 0.0780, 0.1840],'LineWidth', 1.5,'DisplayName', 'Lim Mag');
                
                if ~isempty(c)
                   % plot(t, c, '-','Color',[0, 0.4470, 0.7410], 'LineWidth', 1.0,'DisplayName', 'Control Star');
                end

                plot(t, C, '-','Color',[0, 0.4470, 0.7410], 'LineWidth', 1,'DisplayName', 'Control LC');
                
                if ~isempty(LC.nanIndices)
                  %  plot(t(LC.nanIndices), y(LC.nanIndices), 'kx', 'MarkerSize', 15,'DisplayName', 'NaNs');
                end
                
                WDtransits3.formatLightCurvePlot(LC, Methods, y,flux);
 end



  function plotDetectedEvents(results, Iwd, Ibatch, t, y, Methods,FluxMethods)

                markerSize = 6;
                if Methods(1)
                    MarkedEvents = results{Iwd,Ibatch}.detection1.events;
                    plot(t(MarkedEvents), y(MarkedEvents), 'Or', 'MarkerSize', markerSize,'DisplayName','Events');
                elseif Methods(2)
                    FlagRunMean = results{Iwd,Ibatch}.detection2.FlagRunMean;
                    plot(t(FlagRunMean), y(FlagRunMean), 'Or', 'MarkerSize', markerSize,'DisplayName','Events');
             %   elseif Methods(3)
              %      D = results{Iwd,Ibatch}.detection3.events;
               %     plot(t(logical(D)), y(logical(D)), 'Or', 'MarkerSize', markerSize,'DisplayName','Events');
                end
                if ~any(Methods)
                    if FluxMethods(1)
                        MarkedEvents = results{Iwd,Ibatch}.detection1flux.events;
                        plot(t(MarkedEvents), y(MarkedEvents), 'Or', 'MarkerSize', markerSize,'DisplayName','Events');
                    elseif FluxMethods(2)
                        FlagRunMean = results{Iwd,Ibatch}.detection2flux.FlagRunMean;
                        plot(t(FlagRunMean), y(FlagRunMean), 'Or', 'MarkerSize', markerSize,'DisplayName','Events');
               %     elseif FluxMethods(3)
                %        D = results{Iwd,Ibatch}.detection3flux.events;
                 %       plot(t(logical(D)), y(logical(D)), 'Or', 'MarkerSize', markerSize,'DisplayName','Events');
                    end

                end

    end
            
    function formatLightCurvePlot(LC, Methods, y,flux)
                set(gca, 'YDir', 'reverse');
                ylim([min(y)-0.15,max(y)+0.15]);
                
                v = 1:3;
                formatStr = strjoin(arrayfun(@(x) sprintf('\\#%i', x), v(Methods), 'UniformOutput', false), ' ');
                title(sprintf('Detect in Method %s \n %s , %s', formatStr, LC.Tel, LC.Date));
                
                xlabel(sprintf('Coord : %.6f , %.6f ;\n Gmag = %.3f', LC.Table.RA, LC.Table.Dec, LC.Table.Gmag));
                if flux ==9
                    legend('show', 'Location', 'southwest');
                else
                    legend('show', 'Location', 'northwestoutside');
                end
    end