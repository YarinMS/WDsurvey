%%
set(0,'DefaultFigureWindowStyle','docked')



%% Get light curves


[light_curves, errors, times] = load_light_curves('/Users/yarinms/Documents/Master/Results/Next2/')
%% Bootstrap


BootstrapLC = {}

BootstrapGen = {}

for Ilc = 1 : size(light_curves,2)

    BootstrapLC{end+1}   = bootstrap(light_curves{1,Ilc});
     BootstrapGen{end+1} = GeneralRMS{Ilc};

end

for Ilc = 1 : size(light_curves,2)

    BootstrapLC{end+1}   = bootstrap(light_curves{1,Ilc});
     BootstrapGen{end+1} = GeneralRMS{Ilc};

end

for Ilc = 1 : size(light_curves,2)

    BootstrapLC{end+1}   = bootstrap(light_curves{1,Ilc});
     BootstrapGen{end+1} = GeneralRMS{Ilc};

end


for Ilc = 1 : size(light_curves,2)

    BootstrapLC{end+1}   = bootstrap(light_curves{1,Ilc});
     BootstrapGen{end+1} = GeneralRMS{Ilc};

end
for Ilc = 1 : size(light_curves,2)

    BootstrapLC{end+1}   = bootstrap(light_curves{1,Ilc});
     BootstrapGen{end+1} = GeneralRMS{Ilc};

end
for Ilc = 1 : size(light_curves,2)

    BootstrapLC{end+1}   = bootstrap(light_curves{1,Ilc});
     BootstrapGen{end+1} = GeneralRMS{Ilc};

end

%% detect
Events = zeros(size(BootstrapLC,2),1);
FAP    = {};
Xax    = 50:50: size(BootstrapLC,2)
for Ilc = 1 : size(BootstrapLC,2)

    Events(Ilc) = detect_events2(BootstrapLC{1,Ilc},'plot',false,'Threshold',2.5,'GeneralRMS',BootstrapGen{Ilc});

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
figure('color','white')
idx = find(Events>0)
plot(BootstrapLC{(idx(3))},'.','MarkerSize',15)
set(gca,'YDir','reverse')



%%

lg_lbl = {};
%% detect 2 sigma 
Events = zeros(size(BootstrapLC,2),1);
FAP    = {};
Xax    = 50:50: size(BootstrapLC,2)
for Ilc = 1 : size(BootstrapLC,2)

    Events(Ilc) = detect_events2(BootstrapLC{1,Ilc},'plot',false,'Threshold',2.5,'GeneralRMS',BootstrapGen{Ilc});

    if mod(Ilc,50) == 0 

        FAP{end+1} = sum(Events)/Ilc 
    end
        
end

fprintf('\nDetected events : %i out of %i',sum(Events),length(Events))

%reshape(Events(:),[],1)
%%
figure('color','white')
fap = cell2mat(reshape(FAP,size(FAP,2),[]))
lg_lbl{end+1} = sprintf('Threshold = 2.5 - $\\simga$')
plot(Xax,fap,LineWidth= 2,Color='#77AADD')

%% detect 2.75
Events275 = zeros(size(BootstrapLC,2),1);
FAP275    = {};
Xax275    = 50:50: size(BootstrapLC,2)
for Ilc = 1 : size(BootstrapLC,2)

    Events275(Ilc) = detect_events2(BootstrapLC{1,Ilc},'plot',false,'Threshold',2.75,'GeneralRMS',BootstrapGen{Ilc});

    if mod(Ilc,50) == 0 

        FAP275{end+1} = sum(Events275)/Ilc ;
    end
        
end

fprintf('\nDetected events : %i out of %i',sum(Events275),length(Events275))

%reshape(Events(:),[],1)
%%
%figure('color','white')
hold on
lg_lbl{end+1} = sprintf('Threshold = 2.75 - $\\simga$')
fap275 = cell2mat(reshape(FAP275,size(FAP275,2),[]))
plot(Xax275,fap275,LineWidth= 2,Color='#EE8866')


%% detect 3
Events3 = zeros(size(BootstrapLC,2),1);
FAP3    = {};
Xax3    = 50:50: size(BootstrapLC,2)
for Ilc = 1 : size(BootstrapLC,2)

    Events3(Ilc) = detect_events2(BootstrapLC{1,Ilc},'plot',false,'Threshold',3,'GeneralRMS',BootstrapGen{Ilc});

    if mod(Ilc,50) == 0 

        FAP3{end+1} = sum(Events3)/Ilc ;
    end
        
end

fprintf('\nDetected events : %i out of %i',sum(Events3),length(Events3))

%reshape(Events(:),[],1)
%%
%figure('color','white')
hold on
lg_lbl{end+1} = sprintf('Threshold $ = 3 - \simga$')
fap3 = cell2mat(reshape(FAP3,size(FAP3,2),[]))
plot(Xax3,fap3,LineWidth= 2,Color=[0.4 0.4 0.4])

xlabel('\# Trails','Interpreter','latex','FontSize',18)
ylabel('False Positive Probability','Interpreter','latex','FontSize',18)
legend(sprintf('Threshold  = 2.5 $\\sigma$'),sprintf('Threshold  = 2.75 $\\sigma$'),...
    sprintf('Threshold  = 3 $\\sigma$'),...
    'Interpreter','latex','box','off','FontSize',16)