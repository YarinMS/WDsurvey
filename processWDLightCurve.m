
function processWDLightCurves(Coordinates, Args)
    % Main function to process sources light curves within LAST data 
    % Input : 
    % Coordinates - Target coordinates. (Ra,Dec) at the moment.
    % Arguments:
    %       catPath - Path to the directory of LAST observed fields (from
    %       findAllVisits)
    %       LCPath  - Given LCPath. No search is conducted. Extracting straight
    %       from LCPath 
    %
    %
    %
    % args - structure with additional arguments like Plot, ExcelPath, etc.

    arguments
        Coordinates (1,2) double
        Args.catPath str  = '/Users/yarinms/Catalogs/LAST_Visits.mat';
        Args.LCPath       = [];

    end
%% Find in LAST catalogs
    % Find path
    if isempty(Args.LCPath)
        OT = load('/Users/yarinms/Catalogs/LAST_Visits.mat'); % Load LAST data
        % Args.LCPath = findInAllVisits(Coordinates,OT) Get a path to directories
    end



%%
    % Find and extract light curves
    [lightCurves, controlStar] = extractLightCurves(data, Coordinates, Args);

    % Handle and clean MatchedSources
    lightCurves = cleanMatchedSources(lightCurves);

    % Determine if no detection occurred
    handleNoDetections(lightCurves);

    % Create control group
    controlGroup = createControlGroup(data, Coordinates);

    % Generate control star model
    controlStarModel = generateControlStarModel(controlGroup);

    % Apply section method to light curve
    sectionedLightCurves = applySectionMethod(lightCurves);

    % Plot results if requested
    if isfield(Args, 'Plot') && Args.Plot
        plotResults(lightCurves, controlStar, controlStarModel);
    end

    % Update Excel sheet with results
    if isfield(Args, 'ExcelPath')
        updateExcelSheet(Args.ExcelPath, Coordinates, lightCurves, controlStar);
    end
end











%% Sub functions
function MS = findInLASTCatlogs(Path,Args)
    % Load Matched sources adjecent visits, Looks for a target in the MS.
    arguments

        Path str
        Args.Coords
        Args.Nvisits   =3

    end
    
    % Consider only consecutive visits.
    D = pipeline.DemonLAST;
    D.BasePath = Path;
    List=D.prepListOfProcVisits;
    AllConsecutive = D.searchConsecutiveVisitsOfField('List',List,'MaxTimeBetweenVisits',(20*40)./86400);

    fprintf('\n%i consecutive fields',size(AllConsecutive,2))
    Length = numel(AllConsecutive);
    isOdd = mod(Length/Args.Nvisits, 2) ~= 0;
    if Length == 1 
        fprintf('\n%i Visits for field %s',numel(AllConsecutive{1}), AllConsecutive{1}(1).FieldID)
        pathList = {AllConsecutive{2}(:).Path};
        batches = tools.createBatches(pathList, Args.Nvisits)
    else


        for I=1:Length
            fprintf('\n%i Visits for field %s',numel(AllConsecutive{I}), AllConsecutive{I}(1).FieldID)
        end
    end


    Batches = tools.createBatches(pathList, Args.Nvisits);
    [ms_Batch,Res] = tools.FindInMS(Batches,"Coords",Args.Coords);
    for Ibatch =1 :numel(Batches)

        MSU = mergeByCoo(ms(Ibatch,:),ms(Ibatch,1))
        Ind = MSU.coneSearch(Args.Coords(1),Args.Coords(2)).Ind
        figure()
        plot(MSU.JD,MSU.Data.MAG_PSF(:,Ind))
        set(gca,'YDir','reverse')
        title(sprintf('%i Visits LC',Args.Nvisits))
        xlabel('JD');
        ylabel('Mag PSF');


    end



end

%%
function msu = FindInMS(List,Args)

    arguments
        List
        Args.CropID = {};
        Args.Coords  = {};

    end
    msu = {};
    % Create matched sources list And look for target
    Nfiles = numel(List);

    for Ifile = 1 : Nfiles

         list =  MatchedSources.rdirMatchedSourcesSearch('Path', List{Ifile}{1});

  %%      
         
      if isempty(Args.CropID) 
        Results = tools.ScanMS(list,"Coords",Args.Coords);
        Args.CropID = Results.CropID;
        fprintf('Source Found In CropID %i (visit %s)',Args.CropID,List{Ifile}{1}(end-7:end))

      else
        Results = tools.ScanMS(list,"Coords",Args.Coords);
        if Results.CropID == Args.CropID
            fprintf('SearchID and CropID agree')
        else
            fprintf('SearchID and CropID agree, Continue with CropID %i; (visit %s)',Args.CropID,List{Ifile}{1}(end-7:end))
        end


     end

        
%%
        % create all MS
        Blist.FileName = {};
        Blist.Folder = {};
        Blist.CropID = Args.CropID;
        Nvis = numel(List{Ifile});
        for Ivis = 1 :Nvis

            ms = MatchedSources.rdirMatchedSourcesSearch('Path', List{Ifile}{Ivis},'CropID',Args.CropID);

            Blist.FileName{end+1,1} = ms.FileName{:};
            Blist.Folder{end+1,1} = ms.Folder{:};


        end

        msu = {msu; {MatchedSources.readList(Blist)};







     end

   


end



%% drafts

% use find all proc visits



            Args.BasePath             = '/marvin/LAST.01.01.01';
                Args.YearPat              = '20*';
                Args.MinNfile             = 10;

D = pipeline.DemonLAST;
D.BasePath = '/Users/yarinms/Documents/Data/';
List=D.prepListOfProcVisits
AllConsecutive = D.searchConsecutiveVisitsOfField('List',List,'MaxTimeBetweenVisits',(20*40)./86400)


st = D.findAllVisits('YearPat','20*','MinNfile',10, 'ReadHeader',false)



S=pipeline.DemonLAST.findAllVisitsDir('BasePath','/Users/yarinms/Documents/Data/');




%% find Ms draft

  Overlap =[];
         for Iid = 1:24
            MS  = MatchedSources.readList(list(Iid));

            Ind = MS.coneSearch(Args.Coords(1),Args.Coords(2),6); % 6 arcsec search radius to flag contaminatiors

            if ~isempty(Ind.Ind)
                if Ind.Nsrc >1
                    fprintf('\n Source is probably contaminated')
                    Res = getFlags1(MS,'SrcIdx',Ind.Ind(1));
                else
                    Res = getFlags1(MS,'SrcIdx',Ind.Ind);
                end

                if Res.EFcounts > 0 || ~isempty(Overlap)
                    fprintf('\n Source has %i overlapping data points\nIn CropID %i\n',Res.EFcounts,Iid)
                    if Res.EFcounts ==0
                        Overlap = [Overlap;0];
                        Args.CropID{end +1} = Iid;
                    else
                        Overlap = [Overlap;Res.EFcounts];
                        Args.CropID{end +1} = Iid;
                    end
                end
                if Res.BFcounts(1,end) > 1
                    Results.NearEdge = 1;
                end

                if isempty(Overlap)
                    fprintf('\n Source found in CropID %i',Iid)
                    Args.CropID      = Iid;
                    Res(Ifile).Ind   = Ind;
                    break
                elseif Iid == 24 || Overlap(end)==0
                    
                       fprintf('\n Source found in CropID %i', Args.CropID{:})
                       [m,id] = min(Overlap);
                       Args.CropID = Args.CropID{id};
                       fprintf('\n Source CropID with minimal overlap %i (%i overlapping points)\n', Args.CropID,m)
                       Args.CropID      = Iid;
                        Res(Ifile).Ind   = Ind;
                        break

                
                end
            elseif Iid == 24 && ~isempty(Overlap)
                    fprintf('\n Source found in CropID %i', Args.CropID{:})
                       [m,id] = min(Overlap);
                       Args.CropID = Args.CropID{id};
                       fprintf('\n Source CropID with minimal overlap %i (%i overlapping points)\n', Args.CropID,m)
                       Args.CropID      = Iid;
                       Res(Ifile).Ind   = Ind;
                       break

            elseif Iid == 24 && isempty(Overlap) 
                fprintf('\n Source Could not be found in visit %s\n',list(Ifile).Folder{end}(end-7:end))
            end

         end