%% AM VS JD
%% AM VS JD for all fields

% the loading part
[FJD1,FAM1,Fcoo1] =load_Fields_tables('/Users/yarinms/Documents/Master/NewResults/4mounts')


%% The ploting part:
DateOff = [];
figure('Color','white');

for If = 2 : numel(FJD1)
t = FJD1{If};
AirMass = FAM1{If};

threshold = max(AirMass);
if threshold < 1.2
tdate = datetime(t,'convertfrom','jd')
obstime = max(tdate)-min(tdate);
DateOff = [DateOff ; min(tdate)];
tax   = [20/3600:hours(obstime)/length(tdate):hours(obstime)];
[h,m,s] = hms(tdate-hours(2.5));
%Get the output as a duration() array
tax = duration(h,m,s)
plot(tax,AirMass,'.','Color',[0.1 0.1 0.1])
hold on

set(gca,'YDir','reverse')
ylabel('Airmass','Interpreter','latex')
xlabel('Observation Time','Interpreter','latex')
end
title(sprintf('AirMass Vs Observing Time for %i single telescope fields',length(DateOff)),'Interpreter','latex')
end

%%
%%
%% load all light curves

[light_curves, errors, times,Coords,GeneralRMS,Events,Bp] = load_light_curves_dir('/Users/yarinms/Documents/Master/NewResults/4mounts/')
%%


BootstrapLC = {}

BootstrapGen = {}

for Ilc = 1 : size(light_curves,2)

    BootstrapLC{end+1} = bootstrap(light_curves{1,Ilc});
    
     BootstrapGen{end+1} =GeneralRMS{Ilc};

end

%% detect
Events = zeros(size(BootstrapLC,2),1);
FAP    = {};
Xax    = 50:50: size(BootstrapLC,2)
for Ilc = 1 : size(BootstrapLC,2)

    Events(Ilc) = detect_events2(BootstrapLC{1,Ilc},'plot',false,'Threshold',2.5,'GeneralRMS',GeneralRMS{Ilc});

    if mod(Ilc,50) == 0 

        FAP{end+1} = sum(Events)/Ilc 
    end
        
end

fprintf('\nDetected events : %i out of %i',sum(Events),length(Events))

%reshape(Events(:),[],1)
%%
figure('color','white')


fap = cell2mat(reshape(FAP,size(FAP,2),[]))
plot(Xax,fap)


%%


idx = find(Events>0)
for i = 1 : length(idx)
figure('color','white')
plot(BootstrapLC{(idx(i))},'.','MarkerSize',15)
set(gca,'YDir','reverse')
title(sprintf('%i',idx(i)))
pause(4.5);
close
end








%% load tables

[WDmag,WDtimes,ObsTime] = load_Tables_dir('/Users/yarinms/Documents/Master/NewResults/4mounts/')

%%

TotalMag  = [];
TotalObs = [];



for Iwd = 1 :numel(WDmag)

    TotalMag = [TotalMag;WDmag{:,Iwd}];

   %TotalObs = [TotalObs;WDtimes{:,Iwd}/max(WDtimes{:,Iwd})];
   TotalObs = [TotalObs;WDtimes{:,Iwd}/(ObsTime{Iwd})];


end



% Example data (replace with your actual data)
magnitudes = TotalMag(TotalObs>0);  % Example magnitudes vector
observing_time = TotalObs(TotalObs>0);  % Example observing time vector

% Define the edges for the magnitude bins
magnitude_bins = linspace(10,20, 51); % Adjust the number of bins as needed

% Group observing time values by magnitude bins
observing_time_grouped = zeros(size(magnitude_bins));
Nbin = zeros(size(magnitude_bins))
for i = 1:length(magnitude_bins)-1
    indices = magnitudes >= magnitude_bins(i) & magnitudes < magnitude_bins(i+1);
    observing_time_grouped(i) = mean(observing_time(indices),'omitnan');
    Nbin(i) = sum(indices)
end

%%
Ntag = sum(Nbin'.*observing_time_grouped','omitnan')
%%
figure('Color','white')
% Plotting the bar plot
bar(magnitude_bins, observing_time_grouped,1,'FaceColor','#77AADD','EdgeAlpha',0.0,'FaceAlpha',0.8);
xlabel('$G_{B_p}$','Interpreter','latex','FontSize',18);
ylabel('Fraction Of Observing Time','Interpreter','latex','FontSize',16);
%title('Fraction of Observing Time vs Magnitudes ','Interpreter','latex','FontSize',16);

xlim([15,20])
ylim([0,1])
%%


figure('Color','white')
% Plotting the bar plot
H1 = histogram(TotalMag,'BinEdges',[15:0.25:20],'DisplayStyle','bar','FaceColor','#000000','EdgeColor','#000000','LineWidth',2,'FaceAlpha',0.2,'EdgeAlpha',0.0);
lg_lbl{1} = sprintf('WDs within the observed fields (%i)',length(TotalMag))
hold on
H2 = histogram(TotalMag(TotalObs>0),'BinEdges',[15:0.25:20],'DisplayStyle','bar','LineWidth',2,'EdgeAlpha',0.0,'FaceAlpha',0.4);
lg_lbl{2} = sprintf('WDs with available LCs (%i)',sum((TotalObs>0)))
legend(lg_lbl{:},'Interpreter','latex','FontSize',16,'Location','best','box','off')
xlabel('$G_{B_p}$','Interpreter','latex','FontSize',18);
ylabel('Number of White Dwarfs','Interpreter','latex','FontSize',16);
%title('Fraction of Observing Time vs Magnitudes ','Interpreter','latex','FontSize',16);

xlim([15,20])


%%
% Example data (replace with your actual data)
magnitudesfalse = TotalMag(TotalObs==0);  % Example magnitudes vector
observing_timefalse = ones(size(TotalObs(TotalObs==0)))/sum(TotalObs(TotalObs==0));  % Example observing time vector

