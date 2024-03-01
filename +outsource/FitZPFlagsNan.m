function [Obj] = FitZPFlagsNan(Obj,Args)
    % Fit zero-point(ZP) for sources with specified conditions.
    %     First turn hard flags to NaN. Then applies the ZP correction
    %     According to sources with full magnitude data and removes bad data
    %     i.e with more than 0.75% NaN. Finally it performs the Sysrem algorithm
    %     on the remaining good data.
    % Input  : - A MatchedSources object.
    %          * ...,key,val,...
    %            'MinNumSrc' - Minimum number of sources required to perform
    %                the ZP fit. Default is 20.
    %            'MagField' - Name of the field containing magnitude data.
    %                Default is 'MAG_APER_3'.
    %            'MagErrField' - Name of the field containing magnitude
    %                error data. Default is 'MAGERR_APER_3'.
    %            'HardFlagsMask' - Mask for identifying bad data using the
    %                FlagIdentification function. Default is determined by
    %                FlagIdentification.
    %
    % Output : The updated MatchedSources object with ZP applied to sources
    %           meeting the specified conditions.  
    % Author: Yehuda Stern (September 2023).
    % Example: sourcesObj = FitZPFlagsNan(sourcesObj);

    arguments
        Obj MatchedSources
        Args.MinNumSrc         = 20;
        Args.MagField char     = 'MAG_APER_2';
        Args.MagErrField char  = 'MAGERR_APER_2';
        Args.HardFlagsMask     = outsource.FlagIdentification(Obj);
    end

    MSCopy = copy(Obj);
    %% ZP according sources with full data
    Mag = MSCopy.Data.(Args.MagField);
    Mag(Args.HardFlagsMask) = NaN;
    mask = sum(~isnan(Mag),1) == MSCopy.Nepoch;%mask for source without any NaN
    if sum(mask) < Args.MinNumSrc
        error('Not enough sources that meet the conditions');
    end
    MSCopy.Data.(Args.MagField) = Mag(:,mask);
    MSCopy.Data.(Args.MagErrField) = MSCopy.Data.(Args.MagErrField)(:,mask);
    R = lcUtil.zp_meddiff(MSCopy,'MagField','MAG_PSF' ,'MagErrField','MAGERR_PSF');
    format long;
    Obj.applyZP(R.FitZP,'ApplyToMagField', 'MAG_PSF' );
    
    ms = Obj.copy();
    
    Rs = lcUtil.zp_meddiff(MSCopy,'MagField','MAG_APER_2' ,'MagErrField','MAGERR_APER_2');

    ms.applyZP(Rs.FitZP,'ApplyToMagField', 'MAG_APER_2' );
    figure(2);
    hold on
    Obj.plotRMS('PlotSymbol','.','PlotColor','black','FieldX','MAG_PSF')
    
    figure(3);
    hold on
    ms.plotRMS('PlotSymbol','.','PlotColor','black','FieldX','MAG_APER_2')
    
    
    %% Throw out bad data
    outsource.ApplyMask(Obj, 'Mask',Args.HardFlagsMask,'Fields',{Args.MagField,Args.MagErrField}, 'Value', NaN);
    ToMuchNaNMask=sum(isnan(Obj.Data.(Args.MagField)),1)/Obj.Nepoch > 0.75;%mask for source withmore than 0.75% NaN
    outsource.ApplyMask(Obj, 'Mask',~ToMuchNaNMask, 'Value', 'erash');
    SourceNum = (1:Obj.Nsrc);
    Obj.addMatrix(SourceNum(~ToMuchNaNMask),'SourceNum');
    Obj.addMatrix(sum(~ToMuchNaNMask),'NewNsrc');
    
    %Sysrem on good data only
    Obj.sysrem('MagFields' ,{'MAG_PSF'} , 'MagErrFields',{'MAGERR_PSF'},'sysremArgs',{'Niter',2});
    ms.sysrem('MagFields' ,{'MAG_APER_2'} , 'MagErrFields',{'MAGERR_APER_2'},'sysremArgs',{'Niter',2})
    
    figure(2);
    hold on
    Obj.plotRMS('PlotSymbol','s','PlotColor','blue','FieldX','MAG_PSF')
    
    figure(3);
    hold on
    ms.plotRMS('PlotSymbol','s','PlotColor','blue','FieldX','MAG_APER_2')
end
