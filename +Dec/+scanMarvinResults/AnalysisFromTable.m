%% table of targets
Gtab = Tab;
%%
Tab = Gtab(Gtab.FlagGood,:)
%%
Tab = WDtable
%% get WDs
WDtable = Tab(Tab.Pwd> 0 ,:)

Nwds = height(WDtable);

%% Plot some correlations of events:

figure();
subplot(2,2,1)
plot(Tab.C_RA,Tab.maxRMF,'o')
hold  on
plot(WDtable.C_RA,WDtable.maxRMF,'ok')
xlabel('Corr RA')
ylabel('SD from mean (RMF)')
subplot(2,2,2)
plot(Tab.C_Dec,Tab.maxRMF,'o')
hold  on
plot(WDtable.C_Dec,WDtable.maxRMF,'ok')
xlabel('Corr Dec')
ylabel('SD from mean (RMF)')
subplot(2,2,3)
plot(Tab.C_Back,Tab.maxRMF,'o')
hold  on
plot(WDtable.C_Back,WDtable.maxRMF,'ok')
xlabel('Corr background')
ylabel('SD from mean (RMF)')
subplot(2,2,4)
plot(Tab.C_Back,Tab.maxRMF,'o')
hold  on
plot(WDtable.C_Chi2,WDtable.maxRMF,'ok')
xlabel('Corr $\chi^2$')
ylabel('SD from mean (RMF)')



%% Interactuiive:

xT = Tab.C_Back;
yT = Tab.maxRMF;
xW = WDtable.C_Back;
yW = WDtable.maxRMF;


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
figure()
t = Tab.JD(i);
t = datetime(t{1},'convertfrom','jd');
y = Tab.MAG_PSF(i);
plot(t,y{1},'k-o')

title(sprintf('(%.4f,%.4f)  $P_{wd}$ -  %.2f; WD row %i',Tab.RA(i),Tab.Dec(i), Tab.Pwd(i),i))
xlabel(sprintf('Abs  $G$ = %.2f; $B_p-R_p$ = %.3f\n %s %04d-%02d-%02d %s',Tab.AbsMag(i),Tab.BpRp(i),Tab.TelescopeID(i,:),Tab.Year(i),Tab.Month(i),Tab.Day(i),Tab.FieldID{i}))
set(gca,'YDir','reverse')
