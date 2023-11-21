function [SNR,Noise] = TheoreticalSNR(MS,Args)
% Compute the theoretical SNR by supplying avg background level 
% 
%


arguments

    MS
    Args.Background  = 20.5*1.25 % MAG/arcsec^2 * 1.25/1 [arcsec^2/pix] 
    Args.MagFlag     = true;
    Args.DarkCurrent = 0.01      % electrons per pixel per second
    Args.RN          = 3.5       % electrons per pixel per read
    Args.Gain        = 0.75      % electrons per ADU
    Args.Npix        = 3*3/1.25  % 3 x 3 arcsec ^2 * 1/1.25 [pix/arcsec^2] = 
    
end

if Args.MagFlag
    
    % convert mag to flux 
    
    Args.Background = 10^(-0.4*Args.Background) ; % ADU
    
end


f        = MS.Data.FLUX_PSF(:,1) ;
t        = MS.JD(~isnan(f)) ;
f        = f(~isnan(f)) ;
f_median = median(f) ;
if f_median < 1
    fprintf('median counts is 0 or negative check why')
    %SNR = sqrt(Args.Background * Args.Gain)
    SNR = nan;
    
else
     S        = f_median * Args.Gain ;      % electrons
     Bkg      = Args.Background * Args.Gain ; % electrons
     Noise    = sqrt(S +  Args.Npix*(Args.RN^2 + 20*Args.DarkCurrent + Bkg )) ;

     SNR = S/Noise ;
end

end





