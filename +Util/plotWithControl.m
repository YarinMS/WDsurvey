function res = plotWithControl(mms,sourceInd,sourceLegend)


meanMag = mean(mms.Data.MAG_PSF(:,sourceInd),'omitnan')
GroupInd = (mean(mms.Data.MAG_PSF,'omitnan') < meanMag + 0.1) & (mean(mms.Data.MAG_PSF,'omitnan') > meanMag - 0.1);

GroupInd = find(GroupInd>0);
if ~isempty(GroupInd)
GroupInd = (mean(mms.Data.MAG_PSF,'omitnan') < meanMag + 0.2) & (mean(mms.Data.MAG_PSF,'omitnan') > meanMag - 0.2);

GroupInd = find(GroupInd>0);

end
Ind = 1;
figure();

t = datetime(mms.JD,'ConvertFrom','jd');
[t,srtInd] = sort(t)

plot(t,mms.Data.MAG_PSF(srtInd,sourceInd),'ok','MarkerFaceColor','k','MarkerSize',5)
hold on 
plot(t,mms.Data.MAG_PSF(srtInd,GroupInd(Ind)),'.','MarkerSize',9)
set(gca,'YDir','reverse')
legend(sourceLegend,'Control')
xlim([min(t) max(t)])

fluxTarget = 10.^(-0.4*mms.Data.MAG_PSF(srtInd,sourceInd));
fluxRef = 10.^(-0.4*mms.Data.MAG_PSF(srtInd,GroupInd(Ind)));

RelFlux = fluxTarget./fluxRef;
% figure();  plot(t,RelFlux./mean(RelFlux,'omitnan'),'.','MarkerSize',8)
% xlim([min(t) max(t)])
% title('Relative photometry')
% legend(sprintf('$\\sigma$ = %.4f',std(RelFlux,'omitnan')))
% 







end