function [Event] = detect_events(light_curve, Args)

arguments
light_curve
Args.Threshold = 2.5;
Args.plot = true;
Args.Errors = {};
Args.Times = {};
Args.title = {};
Args.Model = {};

end
Event = 0;
    % Evaluate 3 sigma clipping
   [newM,newS] = SigmaClips(light_curve,'MaxIter',5,'MeanClip',false);
   %newS  = std(light_curve,'omitnan')
    y_sys = light_curve;
    % Plot light curve with error bars
    
    
    % Find events (consecutive points above threshold)
    thresholds = newS*Args.Threshold ;
    MarkedEventss = [];
     for Ipt = 1 : length(y_sys) - 1
        
        if y_sys(Ipt) - newM > thresholds
            
            if y_sys(Ipt+1) - newM > thresholds
                
                MarkedEventss = [MarkedEventss ; Ipt, Ipt+1];
                
            end
        end
     end
       if ~isempty(MarkedEventss)
             Event = 1;

       end

     if Args.plot

         if ~isempty(MarkedEventss)
            
               Args.Times = datetime(Args.Times,'ConvertFrom','jd');

              lglbl{1} = sprintf('rms = %.3f',newS);


              figure('Color','White')

              h1 =  errorbar(Args.Times, y_sys, Args.Errors, '.', 'Color' , [0.25 0.25 0.25],'DisplayName',lglbl{1});
              threshold_values = [newM-thresholds, newM , newM+ thresholds];
              hold on
              if ~isnan(newM)
        

                   for i = 1:length(threshold_values)
                     if i == 2
                        yline(threshold_values(i), '-', 'Color', [105, 0, 0] / 255); % '--' for dashed style, 'r' for red color
                     elseif i== 3
                        yline(threshold_values(i), '--', 'Color', [85, 0, 0] / 255); % '--' for dashed style, 'r' for red color
                     end
        
                     end
              end 

                     plot(Args.Times(MarkedEventss),y_sys(MarkedEventss),'ro','MarkerSize',8)
              if ~isempty(Args.Model)

                    model =  newM + Args.Model' ;


                  h2 = plot(Args.Times,model,'-','Color',[0.8 0.8 0.8],'LineWidth',2,'DisplayName','Model');
                  legend([h1 h2],'Interpreter','latex','Location','southeast','box','off')

              else
                  legend([h1],'Interpreter','latex','Location','southeast','box','off','FontSize',18)

              end

              
              set(gca,'Ydir','reverse')
              if ~isempty(Args.title) 
                  title(Args.title,'Interpreter','latex','FontSize',20)

              end

              xlabel('Time','FontSize',20,Interpreter='latex')
              ylabel('Magnitude','FontSize',20,Interpreter='latex')
              pause(4)
              close();

         end
    %hold on;
    

    % Plot horizontal line for median
    %line([1, length(light_curve)], [median(light_curve), median(light_curve)], 'Color', 'r');

    % Plot horizontal line for threshold
    %line([1, length(light_curve)], [threshold, threshold], 'Color', 'g');


     end




    hold off;
end