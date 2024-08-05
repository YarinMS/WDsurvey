%% AM VS JD for all fields

% the loading part
[FJD1,FAM1,Fcoo1] =load_Fields_tables('/Users/yarinms/Documents/Master/Results/')


%% The ploting part:
DateOff = [];
figure('Color','white');

for If = 2 : numel(FJD1)
t = FJD1{If};
AirMass = FAM1{If};

threshold = max(AirMass);
if threshold < 1.23
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



%% the loading part Next
%% 2nd loading

[FJD2,FAM2,Fcoo2] =load_Fields_tables('/Users/yarinms/Documents/Master/Results/Next')


%% The ploting part:
DateOff2 = [];
%figure('Color','white');

for If = 2 : numel(FJD2)
t = FJD2{If};
AirMass2 = FAM2{If};

threshold = max(AirMass2);
if threshold < 1.23
tdate = datetime(t,'convertfrom','jd')
obstime = max(tdate)-min(tdate);
DateOff2 = [DateOff2 ; min(tdate)];
tax   = [20/3600:hours(obstime)/length(tdate):hours(obstime)];
[h,m,s] = hms(tdate-hours(1.5));
%Get the output as a duration() array
tax = duration(h,m,s)
plot(tax,AirMass2,'.','Color',[0.4 0.4 0.4])
hold on

set(gca,'YDir','reverse')
ylabel('Airmass','Interpreter','latex')
xlabel('Observation Time','Interpreter','latex')
end
title(sprintf('AirMass Vs Observing Time for %i single telescope fields',length(DateOff2)),'Interpreter','latex')
end



%% 3rd batch
[FJD3,FAM3,Fcoo3] =load_Fields_tables('/Users/yarinms/Documents/Master/Results/Next2')


%% The ploting part:
DateOff3 = [];
%figure('Color','white');

for If = 2 : numel(FJD3)
t = FJD3{If};
AirMass3 = FAM3{If};

threshold = max(AirMass3);
if threshold < 1.23
tdate = datetime(t,'convertfrom','jd')
obstime = max(tdate)-min(tdate);
if obstime > hours(1)
    if length(tdate) > 400
DateOff3 = [DateOff3 ; min(tdate)];
tax   = [20/3600:hours(obstime)/length(tdate):hours(obstime)];
[h,m,s] = hms(tdate-hours(2.5));
%Get the output as a duration() array
tax = duration(h,m,s)
plot(tax ,AirMass3,'.','Color',[0.3 0.3 0.3])
hold on

set(gca,'YDir','reverse')
ylabel('Airmass','Interpreter','latex')
xlabel('Observation Time','Interpreter','latex')
    end
end
end
title(sprintf('AirMass Vs Observing Time for %i single telescope fields',length(DateOff2)+length(DateOff)+length(DateOff3)),'Interpreter','latex')
end


