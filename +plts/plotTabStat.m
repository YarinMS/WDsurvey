function plotTabStat(Tab,Args)

arguments
    Tab
    Args.Xfield = 'C_Back';
    Args.Yfield = 'maxRMF';
    Args.gaiaData =[];

end
WDtable = Tab(Tab.Pwd > 0 , :);
xT = Tab.(Args.Xfield);
yT = Tab.(Args.Yfield);
xW = WDtable.(Args.Xfield);
yW = WDtable.(Args.Yfield);

figure();


plot(xT,yT,'o')
hold  on
plot(xW,yW,'ok')
xlabel('Corr RA')
ylabel('SD from mean (RMF)')


dcm = datacursormode(gcf);
datacursormode on;
disp('Click on a point to select it.');
pause;
% Wait for user to click a point
c_info = getCursorInfo(dcm); % Retrieve clicked data point
row_idx = find(xT == c_info.Position(1) & yT == c_info.Position(2));



% Plot the light curve
i = row_idx(1);
t=[];
figure();
subplot(2,1,1)
t = Tab.JD(i);
t = datetime(t{1},'convertfrom','jd');
y = Tab.MAG_PSF(i);
plot(t,y{1},'k-o')

title(sprintf('(%.4f,%.4f)  $P_{wd}$ -  %.2f; ID \\# %i',Tab.RA(i),Tab.Dec(i), Tab.Pwd(i),i))
xlabel(sprintf('Abs  $G$ = %.2f; $B_p-R_p$ = %.3f\n %s %04d-%02d-%02d %s',Tab.AbsMag(i),Tab.BpRp(i),Tab.TelescopeID(i,:),Tab.Year(i),Tab.Month(i),Tab.Day(i),Tab.FieldID{i}))
set(gca,'YDir','reverse')

if ~isempty(Tab.AbsMag(i)) && ~isempty(Args.gaiaData)
    subplot(2,1,2)
    plts.plotHRDiagramWithSource(Args.gaiaData, Tab.AbsMag(i), Tab.BpRp(i))
end



end