function ResRMS=getRMS2(Obj,Args)
            %

            arguments
                Obj
                %IndSrc

                Args.SubPlot logical  = true;
                Args.FigN    = 2;
                Args.ResRMS  = [];

                Args.MagField              = 'MAG_BEST';
                
                Args.NsigmaPredRMS         = 5;
                Args.MinDetRMS             = 1;
            end

            if isempty(Args.ResRMS)
                ResRMS   = Obj.rmsMag('MagField',Args.MagField, 'MinDetRmsVar',Args.MinDetRMS, 'NsigmaPred',Args.NsigmaPredRMS);
            else
                ResRMS = Args.ResRMS;
            end

           
        end
