% For a specific obs and source find in catlaog images. 
T = []; M = [];
ra = 60.2175670304
dec = 34.0772904188

%% navigate to obs proc folder:
cd('/last04e/data2/archive/LAST.01.04.02/2024/10/28/proc')

%% Create Matched sources object:

Dir = dir;

Index = zeros(length(Dir)-2,24);

for i = 3:length(Dir)
    cd(Dir(i).name)
    
    for c = 1:24
        
           ms = MatchedSources.rdirMatchedSourcesSearch('CropID',c);
           
           MS = MatchedSources.readList(ms);
           
           ind = MS.coneSearch(ra,dec,6).Ind;
           
           if ~isempty(ind)
               
               Index(i,c) = ind;
               sprintf('\nFound in %s CropID: %i',Dir(i).name,c)
           end
     
           
           
    end
    
    cd ../
    
    
    
end
    
    


%% create MS for crop ID for entire night.
[a,b] = find(Index ~=0)
CropID = 16 ;%unique(b)


for Ic = 1 : length(CropID)
    
     ms = MatchedSources.rdirMatchedSourcesSearch('CropID',CropID(Ic))

     MS = MatchedSources.readList(ms);
     
     goodVIs = 1;
     goodFlag = true;
     
     while goodFlag 
         
         if ~isempty(MS(goodVIs).coneSearch(ra,dec).Ind)
             goodFlag = false ;
             
         else
             goodVIs = goodVIs +1;
         end
         
         
             
         
     end
     
     MSU = mergeByCoo(MS,MS(goodVIs) );
     MSU.bestMag;
     Isrc = MSU.coneSearch(ra,dec).Ind;
     MSU.plotLC(Isrc,'SubPlot',false)'
     [t,m] = MSU.getLC_ind(Isrc);
     hold on

     
end








%%


T = [T; t];
M = [M;m];






%%


figure();
plot(T,M,'.')
set(gca,'Ydir','reverse')

%%







%%


% ------------------Helper functions ----------------


function Fig = plotLC(Obj, IndSrc, Args)
            % Changes to 
            % Plot LC of individual source in MatchedSources object.
            % Input  : - A single MatchedSources object.
            %          - Index of source (colum index) in the
            %            MatchedSources Data matrices.
            %          * ...,key,val,...
            %            'SubPlot' - A logical indicating if to use
            %                   subplot (true), or regular plot (false).
            %                   Default is true.
            %            'MagField' - Magnitude field name to display.
            %                   Default is 'MAG_BEST'.
            %            'UnitsTime' - Time units in MatachedSources JD.
            %                   Default is 'day'.
            %            'DispUnitsTime' - xlabel plot time units.
            %                   Default is 'min'.
            %            'SubT0' - Substrcat minimum time in time axis.
            %                   Default is true.
            %            'BD' - A BitDictionary object.
            %                   Default is BitDictionary.
            %            'FlagsField' - FLAGS field in the MatchedSources
            %                   Data struct. Default is 'FLAGS'.
            %            'DefaultSymbol' - Plot default symbols.
            %                   Default is {'ko','MarkerFaceColor','k','MarkerSize',4}
            %            'ListFlags' - Cell array of FLAGS names and their
            %                   corresponding plot symbols.
            %                   Default is {'Saturated',{'b^'}; ...
            %                               'NaN',{'r>'}; ...
            %                                'Negative',{'rv'}; ...
            %                                'CR_DeltaHT',{'b<'}}
            % Output : - Figure handle.
            % Author : Eran Ofek (May 2024)
            % Example: Cand(I).plotLC(Cand(I).IndSrc)
            

            arguments
                Obj(1,1)
                IndSrc

                Args.SubPlot logical       = true;
                Args.FigN                  = 1;

                Args.MagField              = 'MAG_BEST';
                Args.UnitsTime             = 'day';
                Args.DispUnitsTime         = 'min';
                Args.SubT0 logical         = true;

                Args.BD                    = BitDictionary;
                Args.FlagsField            = 'FLAGS';
                Args.DefaultSymbol         = {'ko','MarkerFaceColor','k','MarkerSize',4};
                Args.ListFlags             = {'Saturated',{'b^'}; ...
                                              'NaN',{'r>'}; ...
                                              'Negative',{'rv'}; ...
                                              'CR_DeltaHT',{'b<'}};
            end

            JD = Obj.JD;
            if Args.SubT0
                JD = JD - min(JD);
            end
            Time = convert.timeUnits(Args.UnitsTime, Args.DispUnitsTime, JD);

            if Args.SubPlot
                subplot(2,2, Args.FigN);
                Fig = Args.FigN;
                cla;
                box on;
            else
                Fig=figure(Args.FigN);
                cla;
                box on;
            end

            Nflag = size(Args.ListFlags,1);
            FlagPlot = false(Obj.Nepoch, Nflag);
            for Iflag=1:1:Nflag
                VecFlag = Obj.Data.(Args.FlagsField)(:,IndSrc);
                VecFlag(isnan(VecFlag)) = 0;
                FlagPlot(:,Iflag) = Args.BD.findBit(VecFlag, Args.ListFlags(Iflag,1), 'Method','any');

                plot(Time(FlagPlot(:,Iflag)), Obj.Data.(Args.MagField)(FlagPlot(:,Iflag),IndSrc))
                hold on;

            end

            FlagG = all(~FlagPlot, 2);
            plot(Time(FlagG), Obj.Data.(Args.MagField)(FlagG,IndSrc), Args.DefaultSymbol{:});

            
            %plot(Time, Obj.MS.Data.(Args.MagField)(:,IndSrc))
            plot.invy;

            H = xlabel(sprintf('Time [%s]',Args.DispUnitsTime));
            H.FontSize = 14;
            H.Interpreter = 'latex';
            H = ylabel('Magnitude');
            H.FontSize = 14;
            H.Interpreter = 'latex';

            hold off;



        end

