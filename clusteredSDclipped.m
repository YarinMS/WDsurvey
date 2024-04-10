function [TypicalSD,Colors] = clusteredSD(MS,Args)

arguments
    MS MatchedSources
    Args.None= {};
    Args.ExtData = false;
    Args.ZP      = true;
    Args.MedInt  = 0;
    Args.Sys     = false;
    Args.Color  = 0;
    Args.CC     ={};
    
    
end

if Args.ExtData
    if isempty(Args.CC)
       MS.addExtMagColor;
       Colors = MS.SrcData.ExtColor;
    else
        if ~isempty(Args.CC)
             Colors = Args.CC
        else
            Colors = 0 ;
        end
    end
    
  if ~Args.Sys
       
    % set Bin interval
    MinMag = Args.MedInt - 0.125 ;
    MaxMag = Args.MedInt + 0.125 ;
    MinCol = Args.Color  - 0.25 ;
    MaxCol = Args.Color  + 0.25 ;    
    
    % find all sources within this Interval
    PSFmat = MS.Data.MAG_PSF;
    PSFmag = median(PSFmat,'omitnan');
    
    MagFlag        = (MinMag <= PSFmag ) & (PSFmag <= MaxMag);
    MagFlagIdx     = find(MagFlag == 1);
    colors_MagFlag = Colors(MagFlag);
    ColorDist      = abs(colors_MagFlag-Args.Color);
    [Val,Sorted]   = sort(ColorDist);  
   

    % calc the median sd of all sources    
    PSFmat = PSFmat(:,MagFlagIdx(Sorted(1:10)));
    TypicalSD = median(std(PSFmat,'omitnan'),'omitnan'); 
    
  else
      Colors = Colors(MS.Data.SrcIdx);
      % set Bin interval
      MinMag = Args.MedInt - 0.125 ;
      MaxMag = Args.MedInt + 0.125 ;
      MinCol = Args.Color  - 0.25 ;
      MaxCol = Args.Color  + 0.25 ;    
    
    % find all sources within this Interval
    PSFmat = MS.Data.MAG_PSF;
    PSFmag = median(PSFmat,'omitnan');
    
    MagFlag        = (MinMag <= PSFmag ) & (PSFmag <= MaxMag);
    MagFlagIdx     = find(MagFlag == 1);
    colors_MagFlag = Colors(MagFlag);
    ColorDist      = abs(colors_MagFlag-Args.Color);
    [Val,Sorted]   = sort(ColorDist);  
   

    % calc the median sd of all sources    
    Len = length(Sorted);
    if Len >= 10 
    
         PSFmat = PSFmat(:,MagFlagIdx(Sorted(1:10)));
         
    elseif Len >= 5
        PSFmat = PSFmat(:,MagFlagIdx(Sorted(1:5)));
        
    else
        PSFmat = PSFmat(:,MagFlag);
    end
    TypicalSD = median(std(PSFmat,'omitnan'),'omitnan'); 
  end
else
    
    if Args.ZP
    
        Colors = 0;
    % set Bin interval
    MinMag = Args.MedInt - 0.125;
    MaxMag = Args.MedInt + 0.125;
    
    
    % Find all sources within this Interval
    PSFmat = MS.Data.MAG_PSF;
    PSFmag = median(PSFmat,'omitnan');
    
    MagFlag = (MinMag <= PSFmag ) & (PSFmag <= MaxMag);

    % calc the median sd of all sources    
    PSFmat = PSFmat(:,MagFlag);
    % Sigma clip all sources signals And get SD:
    PSFsd  = NaN(size(PSFmat(1,:)));

    for Isource = 1 : length(PSFmat(1,:))

        [newM,newS]    = SigmaClips(PSFmat(:,Isource),'SigmaThreshold',3,...
            'MeanClip',false);
        PSFsd(Isource) = newS ;

    end


    TypicalSD = median(PSFsd,'omitnan');
    
    
    end


end