function [Result,Refstars,Model]=lsqrelphotMAT(M,dM ,Args)


    % Fit this function to get a matrix of magnitudes and a matrix of
    % errors, color in Arguments
    
    
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
        M 
        dM
        Args.InstMag                    = M;
        Args.MagErr                = dM;
        Args.Method                = 'lscov';
        Args.Algo                  = 'chol';  % 'chol' | 'orth'
        Args.Niter                 = 2;
        Args.MaxStarStd            = 0.1;
        Args.UseMagStdErr logical  = true;
        Args.CalibMag              = [];
        
        
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
        
        Args.TargetBpRp    = nan;
        
    end
    
   %Args.InstMag = MS.Data.MAG_PSF ;
   %Args.MagErr  = MS.Data.MAGERR_PSF ;
   %bprp         = MS.SrcData.phot_bp_mean_mag - MS.SrcData.phot_rp_mean_mag;
   %bprp(1)      = Args.TargetBpRp ;
   
        if ~isempty(Args.StarProp)
            
              GoodStars =  ~isnan(Args.StarProp{:});
              Args.InstMag = M(:,GoodStars);
              Args.MagErr  = dM(:,GoodStars);
              Args.StarProp = {Args.StarProp{:}(GoodStars)};
         
          
            
            
            
        end
   
    
    
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
    
    % for first Iter take SNR > 30
    
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

        
        
   
            

        
        % remove NaNs and BAD FLAGs and SNR lower than 10

        Flag = Flag & ~isnan(Y) ;
            
            
     %   Flag = Flag & Y > 15;
      %  Flag = Flag & Y < 17.5;
        
       
            
        
        switch lower(Args.Method)
            case 'lscov'
               [Par, ParErr] = lscov(H(Flag,:), Y(Flag), 1./VarY(Flag), Args.Algo);
              %[Par,ParErr] = lscov(H(Flag,:), Y(Flag)); 
                   
              Resid = Y - H*Par;  % all residuals (including bad stars)
              Model = H*Par ; 
            case 'cgs'
                % congugate gradient method
                A      = H(Flag,:).'*H(Flag,:);
                YY     = H(Flag,:).' * Y(Flag);
                Par    = cgs(A, YY);
                ParErr = nan(size(Par));
                Resid  = Y - H*Par;
                Model  = H*Par; 
            
            otherwise
               error('Unknown Method option');
        end
        
             ParZP  = Par(1:Nimage);
             ParMag = Par(Nimage+1:end);
             % Std per star
             ResidSquare = reshape(Resid,[Nimage, Nstar]);
             FlagSquare  = reshape(Flag,[Nimage, Nstar]);
 %            ResidSquare(~FlagSquare) = NaN;  % set anused stars to NaN
             StdStar     = std(ResidSquare, [], 1, 'omitnan');
             Result.r2     = ResidSquare;
             
             Refstars = cell(0,1) ; 
             counter = 0;
             for Istr = 1 : Nstar
                 
                 UsedPoints = sum(FlagSquare(:,Istr)) ;
                 
                 if UsedPoints/Nimage > 0.75
                     
                     counter           = counter+ 1 ;
                     Refstars{counter} = Istr;
                 end
                 
             end
             
            
             
             if Iiter<Args.Niter
                 
                  FinalRef = [];
                  c = 0;
                 % skip this step in the last iteration
              % [FlagResid,Res] = imUtil.calib.resid_vs_mag(ParMag(:), StdStar(:)) %, Args.ThresholdSigma, Args.resid_vs_magArgs{:});
               % FlagResid = repmat(FlagResid(:),[1, Nimage]).';
                [rms0,meanmag0]  = CalcRMS(median(Args.InstMag,'omitnan'),ResidSquare,Args.obj,Args.wdt,'Marker','ok','Predicted',false)
                 pause(2)
                 hold on
                 
                 % mark Bad Targets
                 
                 Mark = false(size(rms0));
                 MedMag = median(Args.InstMag,'omitnan');
                 
                 Bad = (rms0 > 0.1) | (MedMag > 18);
                 
                 semilogy(MedMag(Bad),rms0(Bad),'x')
                
                 pause(3)
                 close;
                 
                 if isempty(Bad)
                     
                     fprintf('\nNo Bad Targets')
                     
                 else
                  
                     FlagSquare(:,Bad) = false ;
                     Flag = Flag & FlagSquare(:);
                     
                 end
                 
                 
                 
                 
                 
                 
               %  semilogy(meanmag0(cell2mat(Refstars)),rms0(cell2mat(Refstars)),'gx')
               %  pause(4)
               %  hold off
               %  close;
                 
                % MagIntervals = [11:0.5:19];
                % ref_index    = cell2mat(Refstars);
                % rms          = rms0(ref_index) ;
                % gmag         = meanmag0(ref_index);
                % store_flag = false(size(FlagSquare));
                 
                 
                 %for Ibin = 1:numel(MagIntervals) -1 
                     
                  %   MinMag = MagIntervals(Ibin);
                   %  MaxMag = MagIntervals(Ibin+1);
                     
                    % bin_index = (MinMag < gmag ) & (gmag < MaxMag);
                     
                    % Nref = sum(bin_index);
                     
                     
                    % if Nref > 0
                         
                     %    [val,inx] = find(bin_index == 1);
                         
                      %   Mrms = median(rms(inx));
                       %  take = rms(inx) < 3 *Mrms;
                         
                             
                        %  store_flag(:,ref_index(inx(take))) = true;
                         % min_c = c ;
                         %max_c = c + length(inx(take)) ;
                          
                          %if min_c == 0
                              
                          
                    %          FinalRef = [FinalRef ; ref_index(inx(take))'];
                     %     else
                      %        FinalRef = [FinalRef ; ref_index(inx(take))']

                       %   end
                          
                        %  c = max_c ;
                     %end
                     
               %  end
                 
                 
                         
                        
                         
              
                     
                 
                 
                 
                 % calc VarY
                 if Args.UseMagStdErr
%                     NewErr = repmat(Res.InterpStdResid.', Nimage, 1);
 %                    VarY   = NewErr(:).^2;
                 end
            
  %               MatStdStar = repmat(StdStar, Nimage, 1);
            
   %              FlagResid = FlagResid(:);
    %             FlagResid = store_flag(:);
     %            Flag = Flag & FlagResid & MatStdStar(:)<Args.MaxStarStd;
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
  
    Result.Model = reshape(Model,[Nimage, Nstar]);
    
    if Args.Niter>1
     %   [Result.AssymStd, Imin] = min(Res.InterpStdResid);
      %  Result.MagAssymStd      = Res.Mag(Imin);
    else
       % Result.AssymStd    = NaN;
       % Result.MagAssymStd = NaN;
    end
    Result.ColNames         = CN;
end
