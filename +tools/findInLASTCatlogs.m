function MS = findInLASTCatlogs(Path,Args)
    % Load Matched sources adjecent visits, Looks for a target in the MS.
    arguments

        Path 
        Args.Coords
        Args.Nvisits   =3

    end
    
    % Consider only consecutive visits.
    D = pipeline.DemonLAST;
    D.BasePath = Path;
    List=D.prepListOfProcVisits("YearTemp",'*4');
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