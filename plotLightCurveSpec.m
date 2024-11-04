function plotLightCurveSpec(results, Iwd, Ibatch, LC, Methods,flux, FluxMethods)
                t = datetime(LC.JD, 'ConvertFrom', 'jd');
                y = LC.lc;
                c = LC.Ctrl.CtrlStar;
                C = LC.Ctrl.medLc;
                lm = LC.limMag;
                lmt = datetime(LC.catJD, 'ConvertFrom', 'jd');
                
                plot(t, y, 'O-','Color',[0.6, 0.6, 0.6], 'LineWidth', 2,'DisplayName', sprintf('Catalog $\\sigma =$ %.3f',std(y,'omitnan')));
                hold on;
                
                WDtransits3.plotDetectedEvents(results, Iwd, Ibatch, t, y, Methods, FluxMethods);
                
              %  plot(lmt, lm, 's-','Color', [0.6350, 0.0780, 0.1840],'LineWidth', 1.5,'DisplayName', 'Lim Mag');
                
                if ~isempty(c)
                  %  plot(t, c, '-','Color',[0.8500, 0.3250, 0.0980], 'LineWidth', 1.0,'DisplayName', 'Catalog Control Star');
                end

               % plot(t, C, '-','Color',[0, 0.4470, 0.7410], 'LineWidth', 1,'DisplayName', 'Control LC');
                
                if ~isempty(LC.nanIndices)
                    plot(t(LC.nanIndices), y(LC.nanIndices), 'kx', 'MarkerSize', 15,'DisplayName', 'Cat NaNs');
                end
                
                WDtransits3.formatLightCurvePlot(LC, Methods, y,flux);
            end