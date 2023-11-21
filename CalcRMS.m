function [rmse,Predicted] = CalcRMS(Gaiag,Mat,wd,wdt,Args)
% Calc RMSE for a matrix of [Nepoch,Nstars]
% 
arguments
    Gaiag
    Mat
    wd
    wdt
    Args.Plot = true;
    Args.Marker = 'k.'
    Args.Predicted = true;
    
end


Gaiag(1)   = wd.Mag(wdt);
Predicted  = mean(Mat,'omitnan');
Err        = Mat - Predicted;
Npts       = length(Err(:,1));
SE         = (1/Npts).*sum(Err.^2,'omitnan');


rmse = sqrt(SE)      ; 


if Args.Plot
    
    if Args.Predicted
      
        semilogy(Predicted,rmse,Args.Marker)
    
    else
        
        semilogy(Gaiag,rmse,Args.Marker)

    
    end

end

