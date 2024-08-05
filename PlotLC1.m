function [MS] = PlotLC1(MS,Args)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
arguments
    MS MatchedSources
    Args.Isrc = 1;
    Args.Err  = true;

end
set(0,'DefaultFigureWindowStyle','docked')
figure('Color','white')
t    = MS.JD;
time = datetime(t,'ConvertFrom','jd');
lc    = MS.Data.MAG_PSF(:,Args.Isrc);
lcErr = MS.Data.MAGERR_PSF(:,Args.Isrc);
if Args.Err 
    errorber(time,lc,lcErr)
else
    plot(time,lc,'.','MarkerSize',2)
end

end