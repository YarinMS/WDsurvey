function Flux = MagToFlux(Mag, Args)
% Convert magnitudes to fluxes.
% Input:
%       - magnitudes: Array of magnitudes.
%       - zero_point_flux: Zero point flux for the photometric system.
% Output:
%       - fluxes: Array of fluxes.

% Calculate fluxes from magnitudes

arguments
    Mag 
    Args.ZPflux =   3631; % in Janskys for AB magnitude system
end
 

Flux = Args.ZPflux * 10.^(-0.4 * Mag);

end  



%% Checking if MS is effected by zpmediff
%ms = MS(3);
%figure('Color','white')
%hold on
%plot(ms.Data.FLUX_APER_3(:,10))
%hold on

%Rzp = lcUtil.zp_meddiff(ms, 'MagField','MAG_APER_3', 'MagErrField','MAGERR_PSF');
%ms.applyZP(Rzp.FitZP);

%plot(ms.Data.FLUX_APER_3(:,10))
%hold on
