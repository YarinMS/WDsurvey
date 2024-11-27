function [FlagGood, FlagInfo]=flagByQuality2(Obj, Args)
            % Select stars with good quality photometry
            %   Select stars with good photometric quality.
            %   Including chi2 of PSF fitting, jitter in coordinates, and
            %   difference between APER2 and APER3.
            % Input  : - A searchMatchedSources object.
            %          * ...,key,val,...
            %            'MaxAstStd' - Maximum astrometric std allowed.
            %                   Default is 0.4./3600 [deg].
            %            'AperPhotPair' - Cell array of aperture phot. for
            %                   which to calculate difference.
            %                   Default is {'MAG_APER_2','MAG_APER_3'}
            %            'AperPhotPairQuantile' - Lower and upper quantile
            %                   for aper phot, diff. selection.
            %                   Default is [0.02 0.98].
            %
            %            See code for additional arguments.
            %
            % Output : - A vector of logicals indicating stars with good
            %            photometric data.
            %          - Structure with specific flags data.
            % Author : Eran Ofek (Mar 2024) (modulations by YS)
            

            arguments
                Obj
                
                Args.MagField              = 'MAG_BEST';
                Args.MaxChi2Dof            = 3;

                Args.MinNdet               = 2;
                Args.MaxOverlapFrac        = 0.5;
                
                Args.RAField               = 'RA';
                Args.DecField              = 'Dec';
                Args.MaxAstStd             = 0.5./3600;  % deg

                Args.AperPhotPair          = {'MAG_APER_2','MAG_APER_3'};
                Args.AperPhotPairQuantile  = [0.02 0.98];
            end

            % Detections
            FlagDet = ~isnan(Obj.MS.Data.(Args.MagField));
            Ndet    = sum(FlagDet, 1);

            FlagInfo.N    = Ndet;
            FlagInfo.Ndet = Ndet>=Args.MinNdet;
            
            % remove near edge - even one
            FlagNearEdge = searchFlags(Obj.MS, 'FlagsList',{'NearEdge'});
            FlagAll.NotNearEdge = all(~FlagNearEdge,1);

            % remove ovelap- if > Args.MaxOverlapFrac
            %FlagOverlap = searchFlags(Obj.MS, 'FlagsList',{'Overlap'});
            %FlagInfo.NotOverlap = sum(FlagOverlap, 1)./Obj.MS.Nepoch < Args.MaxOverlapFrac;

            % chi2/dof
            Obj.MS.addSrcData;
            FlagInfo.Chi2 = Obj.MS.SrcData.PSF_CHI2DOF<Args.MaxChi2Dof;

            % astrometric jitter
            Dec = median(Obj.MS.Data.(Args.DecField), 1, 'omitnan');
            % Positional noise [deg]
            StdRA  = std(Obj.MS.Data.(Args.RAField), [],1,'omitnan').*cosd(Dec);
            StdDec = std(Obj.MS.Data.(Args.DecField), [],1,'omitnan');
            FlagInfo.NoAstJitter = ~(StdRA>Args.MaxAstStd | StdDec>Args.MaxAstStd);
   
            % aperture photometry diff
            DiffAper = median(Obj.MS.Data.(Args.AperPhotPair{1}) - Obj.MS.Data.(Args.AperPhotPair{2}), 1, 'omitnan');
            QR = quantile(DiffAper, Args.AperPhotPairQuantile);
            FlagInfo.AperDiff = DiffAper>QR(1) & DiffAper<QR(2);


            % summarize all flags
            FlagGood  = FlagInfo.Ndet(:) & FlagAll.NotNearEdge(:)  & FlagInfo.Chi2(:) & FlagInfo.NoAstJitter(:) & FlagInfo.AperDiff(:);


end