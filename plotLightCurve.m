function plotLightCurve(results, Iwd, Ibatch, LC)%, Methods,flux, FluxMethods)
                t = datetime(LC.JD, 'ConvertFrom', 'jd');
                [t,sort_ind] = sort(t);
                y = LC.lc(sort_ind);
                c = LC.Ctrl.CtrlStar(sort_ind);
                C = LC.Ctrl.medLc(sort_ind);
               
                lmt = datetime(LC.catJD, 'ConvertFrom', 'jd');
                [lmt,cat_sort] = sort(lmt);
                lm = LC.limMag(cat_sort);
                
                plot(t, y, 'O-','Color', [0.25, 0.25, 0.25], 'LineWidth', 2,'DisplayName', sprintf('$\\sigma =$ %.3f',std(y,'omitnan')));
                hold on;
                
                %WDtransits1.plotDetectedEvents(results, Iwd, Ibatch, t, y, Methods, FluxMethods);
                
                plot(lmt, lm, 's-','Color', [0.6350, 0.0780, 0.1840],'LineWidth', 1.5,'DisplayName', 'Lim Mag');
               
                
                if ~isempty(c)
                   % plot(t, c, '.b--', 'LineWidth', 1.5,'DisplayName', 'Control Star');
                end

                plot(t, C, '-','Color',[0, 0.4470, 0.7410], 'LineWidth', 1,'DisplayName', 'Control LC');
                
                if isfield(LC,'nanIndices')
                    plot(t(LC.nanIndices), y(LC.nanIndices), 'kx', 'MarkerSize', 15,'DisplayName', 'NaNs');
                end
                Methods = [1 2];
                WDtransits1.formatLightCurvePlot(LC, Methods, y,LC.relFlux);
            end