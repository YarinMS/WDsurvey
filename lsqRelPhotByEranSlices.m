function [Result,Model,GoodFlagSources]=lsqRelPhotByEranSlices(MS, Args)
    % Perform relative photometry calibration using the linear least square method.
    %   This function solves the following linear problem:
    %   m_ij = z_i + M_j + alpha*C + ... (see Ofek et al. 2011).
    %   By default will perfporm two iterations, where in the second
    %   iteration, the errors will be taken from the magnitude vs. std
    %   diagram, and stars with bad measurments will be removed.
    % Input  : - A matrix of instrumental magnitude, in which the epochs
    %            are in the rows, and stars are in the columns.
    %            If empty, then run a simulation.
    %          * ...,key,val,...
    %            'MagErr' - A scalar, or a matrix of errors in the
    %                   instrumental magnitudes.
    %            'Method' - LSQ solver method: 'lscov'.
    %                   Default is 'lscov'.
    %            'Algo' - ALgorithm for the lscov function: 'chol'|'orth'.
    %                   Default is 'chol'.
    %            'Niter' - Number of iterations for error estimation and
    %                   bad source removal. Default is 2.
    %            'MaxStarStd' - In the second iteration, remove stars with
    %                   std larger than this value. Default is 0.1.
    %            'UseMagStdErr' - If true, then in the second iteration
    %                   will replace the MagErr with the errors (per star)
    %                   estimated from the mag vs. std plot.
    %                   Default is true.
    %            'CalibMag' - A vector of calibrated magnitude for all the
    %                   stars. You can use NaN for unknown/not used
    %                   magnitudes. If empty, then do not calibrate.
    %                   Default is [].
    %            'Sparse' - Use sparse matrices. Default is true.
    %            
    %            'ZP_PrefixName' - In the column names cell of the design matrix, this is the
    %                   prefix of the images zero point.
    %            'MeanMag_PrefixName' - In the column names cell of the design matrix, this is the
    %                   prefix of the stars mean magnitudes.
    %            'StarProp' - A cell array of vectors. Each vector
    %                   must be of the length equal to the number of stars.
    %                   Each vector in the cell array will generate a new
    %                   column in the design matrix with a property per
    %                   star (e.g., color of each star).
    %                   Default is {}.
    %            'StarPropNames' - A cell array of names for the StarProp
    %                   column names. If this is a string than will be the
    %                   string prefix, with added index. Default is 'SP'.
    %            'ImageProp' - Like StarProp but for the images.
    %                   E.g., airmass.
    %                   Default is {}.
    %            'ImagePropNames' - Like StarPropNames, but for the images.
    %                   Default is 'IP'.
    %            'ThresholdSigma' - Threshold in sigmas (std) for flagging good
    %                   data (used by imUtil.calib.resid_vs_mag).
    %                   Default is 3.
    %            'resid_vs_magArgs' - A cell array of arguments to pass to 
    %                   imUtil.calib.resid_vs_mag
    %                   Default is {}.
    % Output : - A structure with the following fields:
    %            .Par   - All fitted parameters.
    %            .ParErr - Error in all fitted parameters.
    %            .ParZP - Fitted ZP parameters
    %            .ParMag - Fitted mean mag parameters.
    %            .Resid - All residuals.
    %            .Flag - Logical flags indicating which stars where used in
    %                   the solution.
    %            .NusedMeas - Number of used measurments.
    %            .StdResid - Std of used residuals.
    %            .RStdResid - Robust std of used residuals..
    %            .Stdstar - Std of each star measurments used in the
    %                   solution over all epochs.
    %            .StdImage - Std of each image measurments used in the
    %                   solution over all stars.
    %            .AssymStd - Assymptoic rms in the mag vs. std plot,
    %                   estimated from the minimum of the plot.
    %                   (Return NaN if Niter=1).
    %            .MagAssymStd - Magnitude of the assymptotic rms.
    %                   (Return NaN if Niter=1).
    %            .ColNames - Column names of the solution.
    % Author : Eran Ofek (Jun 2023)
    % Example: imUtil.calib.lsqRelPhot; % simulation mode
    
    
    % Modified by yarin
    
    arguments
        
        MS(1,1)  MatchedSources    % Use on a Forced Photometry product [Nepoch,NSrc]
        Args.InstMag                    = [];
        Args.MagErr                = 0.02;
        Args.Method                = 'lscov';
        Args.Algo                  = 'chol';  % 'chol' | 'orth'
        Args.Niter                 = 2;
        Args.MaxStarStd            = 0.1;
        Args.UseMagStdErr logical  = true;
        Args.CalibMag              = [];
        
        
        Args.StartInd              = 1;
        Args.EndInd                = MS.Nepoch
        
        
        Args.Sparse logical        = true;
        Args.ZP_PrefixName         = 'Z';
        Args.MeanMag_PrefixName    = 'M';
        Args.StarProp              = {};  % one vector of properties per star - e.g., color
        Args.StarPropNames         = 'SP';
        Args.ImageProp             = {};  % one vector of properties per image - e.g., airmass
        Args.ImagePropNames        = 'IP';
        
        Args.ThresholdSigma        = 3;
        Args.resid_vs_magArgs cell = {};
        
        Args.obj                   = {};
        Args.wdt                   =  1;        
        
        Args.BitDic       = BitDictionary;
        Args.PropFlags    = 'FLAGS';
        Args.FlagsList    = {'NearEdge','Saturated','NaN','Negative'};
        Args.Operator      = @or; % @or | @and
    end
    
   Args.InstMag     = MS.Data.MAG_PSF(Args.StartInd:Args.EndInd,:) ;
   Args.MagErr = MS.Data.MAGERR_PSF(Args.StartInd:Args.EndInd,:) ;
    
    
    if isempty(Args.InstMag)
        % run in simulation mode
        
        MagErr = 0.03;
        Nimage = 50;
        Nstar  = 300;
        Mag    = rand(Nstar,1).*10;
        ZP     = rand(Nimage,1).*2;

        Args.InstMag = ZP + Mag.';
        Args.InstMag = Args.InstMag + MagErr.*randn(size(Args.InstMag));
        %InstMag(100) +InstMag + 0.5;
        % add outliers
        
        
        Args.MagErr = MagErr;
    end
    
    [Nimage, Nstar] = size(Args.InstMag);
    
    if numel(Args.MagErr)==1
        ErrY = Args.MagErr.*ones(Nimage.*Nstar,1);
    else
        ErrY = Args.MagErr(:);
    end
    VarY = ErrY.^2;
    
    Y    = Args.InstMag(:);

    if isempty(Args.CalibMag)
        AddCalibBlock = false;
    else
        AddCalibBlock = true;
        Y             = [Y; Args.CalibMag(:)];
    end
    
    % for first Iter take SNR > 10
    
    Flag = true(size(Y))  ;
    for Iiter=1:1:Args.Niter
        
        
        %if Iiter == 1 
        
        [H,CN] = imUtil.calib.calibDesignMatrix(Nimage, Nstar, 'Sparse',Args.Sparse,...
                                                               'ZP_PrefixName',Args.ZP_PrefixName,...
                                                               'MeanMag_PrefixName',Args.MeanMag_PrefixName,...
                                                               'StarProp',Args.StarProp,...
                                                               'StarPropNames',Args.StarPropNames,...
                                                               'ImageProp',Args.ImageProp,...
                                                               'ImagePropNames',Args.ImagePropNames,...
                                                               'AddCalibBlock',AddCalibBlock);

        
        
        % filter any critical flags
        BitClass = Args.BitDic.Class;
        Flags = BitClass(MS.Data.(Args.PropFlags));
        Flags = Flags(Args.StartInd:Args.EndInd,:);
        FLAG = zeros(size(Flags));
        Nflag  = numel(Args.FlagsList);
        for Iflag = 1:1:Nflag
            FieldIndex = find(strcmp(Args.BitDic.Dic.BitName, Args.FlagsList{Iflag}));
            if ~isempty(FieldIndex)
                FLAG = Args.Operator(FLAG, bitget(Flags,FieldIndex));
            else
                error('Field "%s" not found in dictionary', Args.Flags{Iflag});
            end
        end
            
        FLAG = ~FLAG(:);
        
        Flag2 = true(size(Args.InstMag));
        
        % remove NaNs and BAD FLAGs and SNR lower than 10

       
        
        if Iiter == 1 
            
           for i = 1 : length(Args.StarProp{:})
            
               if isnan(Args.StarProp{1}(i)) 
                
                     Flag2(:,i) = false;
            
               end
            
           end
        
            Flag2 = Flag2(:);
            
        
            Flag = Flag & ~isnan(Y) & FLAG & (ErrY < Args.MaxStarStd) & Flag2;
            
        end
            
            
             
 
            
        
        switch lower(Args.Method)
            case 'lscov'
               [Par, ParErr] = lscov(H(Flag,:), Y(Flag), 1./VarY(Flag), Args.Algo);
              %[Par,ParErr] = lscov(H(Flag,:), Y(Flag)); 
              Model =  H*Par ;    
              Resid = Y - Model;  % all residuals (including bad stars)
            otherwise
               error('Unknown Method option');
        end
        
             ParZP  = Par(1:Nimage);
             ParMag = Par(Nimage+1:end);
             % Std per star
             ResidSquare = reshape(Resid,[Nimage, Nstar]);
             FlagSquare  = reshape(Flag,[Nimage, Nstar]);
             ResidSquare(~FlagSquare) = NaN;  % set anused stars to NaN
             StdStar     = std(ResidSquare, [], 1, 'omitnan');
             
             MS.SrcData.phot_g_mean_mag(1) = Args.obj.Mag(Args.wdt);
             figure(777);
             [rms1,meanmag1]  = CalcRMS(MS.SrcData.phot_g_mean_mag,ResidSquare,Args.obj,Args.wdt,'Marker','.k','Predicted',false);
             
             xlabel('Gaia g mag','Interpreter','latex')
             ylabel('RMS','Interpreter','latex')
             
             IntervalLength = Args.EndInd - Args. StartInd ;
             
             GoodFlagSources = sum(FlagSquare) >= IntervalLength ;
             
             if sum(GoodFlagSources) < 5
                 
                 GoodFlagSources = sum(FlagSquare) >= 1
                 
                 if sum(GoodFlagSources) < 5
                     
                     fprintf('\nNo Stars to use')
                     break;
                     
                 end
                 
             end
             
             hold on

             pause(2);
             semilogy(  MS.SrcData.phot_g_mean_mag(GoodFlagSources),rms1(GoodFlagSources),'o')
             pause(2);
             semilogy( MS.SrcData.phot_g_mean_mag(1),rms1(1),'G*') 
             legend('All Targets','Used Targets','WD','Interpreter','latex','Location','best')
             xlim([10,20])
             pause(2);
             close;
            
            
            
        
             if Iiter<Args.Niter
                 % skip this step in the last iteration
              % [FlagResid,Res] = imUtil.calib.resid_vs_mag(ParMag(:), StdStar(:)) %, Args.ThresholdSigma, Args.resid_vs_magArgs{:});
               % FlagResid = repmat(FlagResid(:),[1, Nimage]).';
            
                 % calc VarY
               %  if Args.UseMagStdErr
               %      NewErr = repmat(Res.InterpStdResid.', Nimage, 1);
               %      VarY   = NewErr(:).^2;
               %  end
            
                 MatStdStar = repmat(StdStar, Nimage, 1);
                 GoodFlags  =  false(size(FlagSquare));
                 GoodFlags(:,GoodFlagSources) = true;
                 GFlags = GoodFlags(:);
                 
            
               %  FlagResid = FlagResid(:);
                 Flag = Flag & GFlags % & MatStdStar(:)<Args.MaxStarStd;
             end
        
        %std(ParZP - ZP)   % should be eq to MagErr/sqrt(Nimage)
        %std(ParMag  - Mag)  % should be eq to MagErr/sqrt(Nstar)
        
        %end
    end
    
    Result.Par       = Par;
    Result.ParErr    = ParErr;
    Result.ParZP     = ParZP;
    Result.ParMag    = ParMag;
    Result.Resid     = Resid;
    Result.Flag      = Flag;
    Result.NusedMeas = sum(Flag);
    Result.StdResid  = std(Resid(Flag), [], 1, 'omitnan');
    Result.RStdResid = tools.math.stat.rstd(Resid(Flag));
    Result.StdStar   = StdStar;
    Result.StdImage  = std(ResidSquare, [], 2, 'omitnan');
    
    if Args.Niter>1
       % [Result.AssymStd, Imin] = min(Res.InterpStdResid);
       % Result.MagAssymStd      = Res.Mag(Imin);
    else
        Result.AssymStd    = NaN;
        Result.MagAssymStd = NaN;
    end
    Result.ColNames         = CN;
end
