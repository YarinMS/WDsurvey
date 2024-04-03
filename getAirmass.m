function [AirMass,t] = getAirmass(Res,Args)

arguments 
    Res
    Args.plot = true;
end




ObsLon = 35.04085833;
ObsLat = 30.0530725 ;
t = Res.JD;
Coords = Res.Coord;

ObsCoo  = [ObsLon, ObsLat];
[AirMass,~,~] = celestial.coo.airmass(t,Coords(:,1)*(pi/180),Coords(:,2)*(pi/180),ObsCoo*(pi/180));

if Args.plot
    figure('Color','white');
    
    plot(datetime(t,'convertfrom','jd'),AirMass,'.','Color',[0.1 0.1 0.1])
    set(gca,'YDir','reverse')
    ylabel('Airmass','Interpreter','latex')
    xlabel('Time','Interpreter','latex')
end