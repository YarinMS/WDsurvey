function [MS] = PlotModel(Data,Args)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
arguments
    Data
    Args.Txt       = '';
    Args.Imod      = [];
    Args.Holdon    = true;

end
set(0,'DefaultFigureWindowStyle','docked')

model = Data(Args.Imod,:);

if Args.Holdon 

    plot(model,'--')

else
   figure('Color','white')
   plot(model,'--')

end


%figure('Color','white')
%lc    = Data();
%lcErr = MS.Data.MAGERR_PSF(:,Args.Isrc);
%if Args.Err 
%    errorbar(time,lc,lcErr,'k')
%    set(gca,'YDir','reverse')
%else
%    plot(time,lc,'k.','MarkerSize',2)
%    set(gca,'YDir','reverse')
%end

end