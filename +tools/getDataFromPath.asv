% WDJ19174
%% Data acquisiton

cd('~/marvin/LAST.01.05.03/2024/08/07/proc/')
List = MatchedSources.rdirMatchedSourcesSearch('FileTemplate','*WDJ19174*')

contains(List.FileName,'WDJ19174')
%%
list1.FileName = List.FileName(contains(List.FileName,'WDJ19174'));
list1.Folder   = List.Folder(contains(List.FileName,'WDJ19174'));
list1.CropID = List.CropID;
ms1 =  MatchedSources.readList(list1);


%%
cd('~/marvin/LAST.01.05.03/2024/08/06/proc/')
List = MatchedSources.rdirMatchedSourcesSearch('CropID',16)
list2.FileName = List.FileName(contains(List.FileName,'WDJ19174'));
list2.Folder   = List.Folder(contains(List.FileName,'WDJ19174'))
list2.CropID = List.CropID
ms2 =  MatchedSources.readList(list2);
%%
LC171725 = [];
LC1725175 = [];
LC1751775 = [];
LC177518  = [];
LC181825 = [];
LC1825185 = [];
LC1851875 = [];
LC187519 = [];
LC191925  = [];
LC1925195  = [];


for i = 1 :4

    if i == 1

        mms = ms1;

        for j = 3:length(mms)

            lc171725 = GetMagBin(mms(j),'MagMin',17.0,'MagMax',17.25);
            lc1725175 = GetMagBin(mms(j),'MagMin',17.25,'MagMax',17.5);
            lc1751775 = GetMagBin(mms(j),'MagMin',17.5,'MagMax',17.75);
            lc177518 = GetMagBin(mms(j),'MagMin',17.5,'MagMax',17.75);
            lc181825 = GetMagBin(mms(j),'MagMin',18.0,'MagMax',18.25);
            lc1825185 = GetMagBin(mms(j),'MagMin',18.25,'MagMax',18.5);
            lc1851875 = GetMagBin(mms(j),'MagMin',18.5,'MagMax',18.75);
            lc187519 = GetMagBin(mms(j),'MagMin',18.75,'MagMax',19.0);
            lc191925  = GetMagBin(mms(j),'MagMin',19.0,'MagMax',19.25);


            LC171725 = [LC171725 lc171725];
            LC1725175 = [LC1725175 lc1725175];
            LC1751775 = [LC1751775 lc1751775];
            LC177518  = [LC177518 lc177518];
            LC181825 = [LC181825 lc181825];
            LC1825185 = [LC1825185 lc1825185];
            LC1851875 = [LC1851875 lc1851875];
            LC187519 = [LC187519 lc187519];
            LC191925  = [LC191925 lc191925];






        end

    end

    if i == 2



        mms = ms2;

        for j = 2:length(mms)

            lc171725 = GetMagBin(mms(j),'MagMin',17.0,'MagMax',17.25);
            lc1725175 = GetMagBin(mms(j),'MagMin',17.25,'MagMax',17.5);
            lc1751775 = GetMagBin(mms(j),'MagMin',17.5,'MagMax',17.75);
            lc177518 = GetMagBin(mms(j),'MagMin',17.75,'MagMax',18);
            lc181825 = GetMagBin(mms(j),'MagMin',18.0,'MagMax',18.25);
            lc1825185 = GetMagBin(mms(j),'MagMin',18.25,'MagMax',18.5);
            lc1851875 = GetMagBin(mms(j),'MagMin',18.5,'MagMax',18.75);
            lc187519 = GetMagBin(mms(j),'MagMin',18.75,'MagMax',19.0);
            lc191925  = GetMagBin(mms(j),'MagMin',19.0,'MagMax',19.25);
            lc1925195  = GetMagBin(mms(j),'MagMin',19.25,'MagMax',19.5);


            LC171725 = [LC171725 lc171725];
            LC1725175 = [LC1725175 lc1725175];
            LC1751775 = [LC1751775 lc1751775];
            LC177518  = [LC177518 lc177518];
            LC181825 = [LC181825 lc181825];
            LC1825185 = [LC1825185 lc1825185];
            LC1851875 = [LC1851875 lc1851875];
            LC187519 = [LC187519 lc187519];
            LC191925  = [LC191925 lc191925];
            LC1925195  = [LC1925195 lc1925195];

        end


    end
end


%% count NaNs

1 - sum(isnan(LC1751775))/20

binEdges = linspace(17.0, 21, 33);

binCenters = (binEdges(1:end-1) + binEdges(2:end)) / 2;
binEfficiencies = zeros(1, length(binCenters));


for Ibin = 1:length(binCenters)


    if binEdges(Ibin) >= 17 && binEdges(Ibin+1) <= 17.25
    binIndices = mean(LC171725,'omitnan') >= binEdges(Ibin) & mean(LC171725,'omitnan') < binEdges(Ibin+1);
    binEfficiencies(Ibin) = mean(1 - sum(isnan(LC1751775(:,binIndices)))/20);
    end

    if binEdges(Ibin) >= 17.25 && binEdges(Ibin+1) <= 17.5
    binIndices = mean(LC1725175,'omitnan') >= binEdges(Ibin) & mean(LC1725175,'omitnan') < binEdges(Ibin+1);
    binEfficiencies(Ibin) = mean(1 - sum(isnan(LC1725175(:,binIndices)))/20);
    end

    if binEdges(Ibin) >= 17.5 && binEdges(Ibin+1) <= 17.75
    binIndices = mean(LC1751775,'omitnan') >= binEdges(Ibin) & mean(LC1751775,'omitnan') < binEdges(Ibin+1);
    binEfficiencies(Ibin) = mean(1 - sum(isnan(LC1751775(:,binIndices)))/20);
    end

    if binEdges(Ibin) >= 17.75 && binEdges(Ibin+1) <= 18
    binIndices = mean(LC177518,'omitnan') >= binEdges(Ibin) & mean(LC177518,'omitnan') < binEdges(Ibin+1);
    binEfficiencies(Ibin) = mean(1 - sum(isnan(LC177518(:,binIndices)))/20);
    end

    if binEdges(Ibin) >= 18 && binEdges(Ibin+1) <= 18.25
    binIndices = mean(LC181825,'omitnan') >= binEdges(Ibin) & mean(LC181825,'omitnan') < binEdges(Ibin+1);
    binEfficiencies(Ibin) = mean(1 - sum(isnan(LC181825(:,binIndices)))/20);
    end
    if binEdges(Ibin) >= 18.25 && binEdges(Ibin+1) <= 18.5
    binIndices = mean(LC1825185,'omitnan') >= binEdges(Ibin) & mean(LC1825185,'omitnan') < binEdges(Ibin+1);
    binEfficiencies(Ibin) = mean(1 - sum(isnan(LC1825185(:,binIndices)))/20);
    end
    if binEdges(Ibin) >= 18.5 && binEdges(Ibin+1) <= 18.75
    binIndices = mean(LC1851875,'omitnan') >= binEdges(Ibin) & mean(LC1851875,'omitnan') < binEdges(Ibin+1);
    binEfficiencies(Ibin) = mean(1 - sum(isnan(LC1851875(:,binIndices)))/20);
    end
    if binEdges(Ibin) >= 18.75 && binEdges(Ibin+1) <= 19
    binIndices = mean(LC187519,'omitnan') >= binEdges(Ibin) & mean(LC187519,'omitnan') < binEdges(Ibin+1);
    binEfficiencies(Ibin) = mean(1 - sum(isnan(LC187519(:,binIndices)))/20);
    end

    if binEdges(Ibin) >= 19 && binEdges(Ibin+1) <=19.25
    binIndices = mean(LC191925,'omitnan') >= binEdges(Ibin) & mean(LC191925,'omitnan') < binEdges(Ibin+1);
    binEfficiencies(Ibin) = mean(1 - sum(isnan(LC191925(:,binIndices)))/20);
    end

    if binEdges(Ibin) >= 19.25 && binEdges(Ibin+1) <= 19.5
    binIndices = mean(LC1925195,'omitnan') >= binEdges(Ibin) & mean(LC1925195,'omitnan') < binEdges(Ibin+1);
    binEfficiencies(Ibin) = mean(1 - sum(isnan(LC1925195(:,binIndices)))/20);
    end

end

% Plot the histogram
bar(binCenters, binEfficiencies);
xlabel('Magnitude');
ylabel('Average Detection Efficiency');
title('Detection Efficiency vs Magnitude');

%% 40 s

% WDJ19174
%% Data acquisiton

cd('~/marvin/LAST.01.04.03/2024/08/07/proc/')
List = MatchedSources.rdirMatchedSourcesSearch('CropID',16)

contains(List.FileName,'DZ19M')
%%
list1.FileName = List.FileName(contains(List.FileName,'DZ19M'));
list1.Folder   = List.Folder(contains(List.FileName,'DZ19M'));
list1.CropID = List.CropID;
ms1 =  MatchedSources.readList(list1);


%%
cd('~/marvin/LAST.01.04.03/2024/08/06/proc/')
List = MatchedSources.rdirMatchedSourcesSearch('CropID',16)
list2.FileName = List.FileName(contains(List.FileName,'DZ19M'));
list2.Folder   = List.Folder(contains(List.FileName,'DZ19M'))
list2.CropID = List.CropID
ms2 =  MatchedSources.readList(list2);
%%
LC171725 = [];
LC1725175 = [];
LC1751775 = [];
LC177518  = [];
LC181825 = [];
LC1825185 = [];
LC1851875 = [];
LC187519 = [];
LC191925  = [];
LC1925195  = [];


for i = 1 :4

    if i == 1

        mms = ms1;

        for j = 3:length(mms)

            lc171725 = GetMagBin(mms(j),'MagMin',17.0,'MagMax',17.25);
            lc1725175 = GetMagBin(mms(j),'MagMin',17.25,'MagMax',17.5);
            lc1751775 = GetMagBin(mms(j),'MagMin',17.5,'MagMax',17.75);
            lc177518 = GetMagBin(mms(j),'MagMin',17.5,'MagMax',17.75);
            lc181825 = GetMagBin(mms(j),'MagMin',18.0,'MagMax',18.25);
            lc1825185 = GetMagBin(mms(j),'MagMin',18.25,'MagMax',18.5);
            lc1851875 = GetMagBin(mms(j),'MagMin',18.5,'MagMax',18.75);
            lc187519 = GetMagBin(mms(j),'MagMin',18.75,'MagMax',19.0);
            lc191925  = GetMagBin(mms(j),'MagMin',19.0,'MagMax',19.25);
            lc1925195  = GetMagBin(mms(j),'MagMin',19.25,'MagMax',19.5);

            LC171725 = [LC171725 lc171725];
            LC1725175 = [LC1725175 lc1725175];
            LC1751775 = [LC1751775 lc1751775];
            LC177518  = [LC177518 lc177518];
            LC181825 = [LC181825 lc181825];
            LC1825185 = [LC1825185 lc1825185];
            LC1851875 = [LC1851875 lc1851875];
            LC187519 = [LC187519 lc187519];
            LC191925  = [LC191925 lc191925];
            LC1925195  = [LC1925195 lc1925195];






        end

    end

    if i == 2



        mms = ms2;

        for j = 2:length(mms)

            lc171725 = GetMagBin(mms(j),'MagMin',17.0,'MagMax',17.25);
            lc1725175 = GetMagBin(mms(j),'MagMin',17.25,'MagMax',17.5);
            lc1751775 = GetMagBin(mms(j),'MagMin',17.5,'MagMax',17.75);
            lc177518 = GetMagBin(mms(j),'MagMin',17.75,'MagMax',18);
            lc181825 = GetMagBin(mms(j),'MagMin',18.0,'MagMax',18.25);
            lc1825185 = GetMagBin(mms(j),'MagMin',18.25,'MagMax',18.5);
            lc1851875 = GetMagBin(mms(j),'MagMin',18.5,'MagMax',18.75);
            lc187519 = GetMagBin(mms(j),'MagMin',18.75,'MagMax',19.0);
            lc191925  = GetMagBin(mms(j),'MagMin',19.0,'MagMax',19.25);
            lc1925195  = GetMagBin(mms(j),'MagMin',19.25,'MagMax',19.5);


            LC171725 = [LC171725 lc171725];
            LC1725175 = [LC1725175 lc1725175];
            LC1751775 = [LC1751775 lc1751775];
            LC177518  = [LC177518 lc177518];
            LC181825 = [LC181825 lc181825];
            LC1825185 = [LC1825185 lc1825185];
            LC1851875 = [LC1851875 lc1851875];
            LC187519 = [LC187519 lc187519];
            LC191925  = [LC191925 lc191925];
            LC1925195  = [LC1925195 lc1925195];

        end


    end
end


%% count NaNs

1 - sum(isnan(LC1751775))/20

binEdges = linspace(17.0, 21, 33);

binCenters = (binEdges(1:end-1) + binEdges(2:end)) / 2;
binEfficiencies = zeros(1, length(binCenters));


for Ibin = 1:length(binCenters)


    if binEdges(Ibin) >= 17 && binEdges(Ibin+1) <= 17.25
    binIndices = mean(LC171725,'omitnan') >= binEdges(Ibin) & mean(LC171725,'omitnan') < binEdges(Ibin+1);
    binEfficiencies(Ibin) = mean(1 - sum(isnan(LC1751775(:,binIndices)))/20);
    end

    if binEdges(Ibin) >= 17.25 && binEdges(Ibin+1) <= 17.5
    binIndices = mean(LC1725175,'omitnan') >= binEdges(Ibin) & mean(LC1725175,'omitnan') < binEdges(Ibin+1);
    binEfficiencies(Ibin) = mean(1 - sum(isnan(LC1725175(:,binIndices)))/20);
    end

    if binEdges(Ibin) >= 17.5 && binEdges(Ibin+1) <= 17.75
    binIndices = mean(LC1751775,'omitnan') >= binEdges(Ibin) & mean(LC1751775,'omitnan') < binEdges(Ibin+1);
    binEfficiencies(Ibin) = mean(1 - sum(isnan(LC1751775(:,binIndices)))/20);
    end

    if binEdges(Ibin) >= 17.75 && binEdges(Ibin+1) <= 18
    binIndices = mean(LC177518,'omitnan') >= binEdges(Ibin) & mean(LC177518,'omitnan') < binEdges(Ibin+1);
    binEfficiencies(Ibin) = mean(1 - sum(isnan(LC177518(:,binIndices)))/20);
    end

    if binEdges(Ibin) >= 18 && binEdges(Ibin+1) <= 18.25
    binIndices = mean(LC181825,'omitnan') >= binEdges(Ibin) & mean(LC181825,'omitnan') < binEdges(Ibin+1);
    binEfficiencies(Ibin) = mean(1 - sum(isnan(LC181825(:,binIndices)))/20);
    end
    if binEdges(Ibin) >= 18.25 && binEdges(Ibin+1) <= 18.5
    binIndices = mean(LC1825185,'omitnan') >= binEdges(Ibin) & mean(LC1825185,'omitnan') < binEdges(Ibin+1);
    binEfficiencies(Ibin) = mean(1 - sum(isnan(LC1825185(:,binIndices)))/20);
    end
    if binEdges(Ibin) >= 18.5 && binEdges(Ibin+1) <= 18.75
    binIndices = mean(LC1851875,'omitnan') >= binEdges(Ibin) & mean(LC1851875,'omitnan') < binEdges(Ibin+1);
    binEfficiencies(Ibin) = mean(1 - sum(isnan(LC1851875(:,binIndices)))/20);
    end
    if binEdges(Ibin) >= 18.75 && binEdges(Ibin+1) <= 19
    binIndices = mean(LC187519,'omitnan') >= binEdges(Ibin) & mean(LC187519,'omitnan') < binEdges(Ibin+1);
    binEfficiencies(Ibin) = mean(1 - sum(isnan(LC187519(:,binIndices)))/20);
    end

    if binEdges(Ibin) >= 19 && binEdges(Ibin+1) <=19.25
    binIndices = mean(LC191925,'omitnan') >= binEdges(Ibin) & mean(LC191925,'omitnan') < binEdges(Ibin+1);
    binEfficiencies(Ibin) = mean(1 - sum(isnan(LC191925(:,binIndices)))/20);
    end

    if binEdges(Ibin) >= 19.25 && binEdges(Ibin+1) <= 19.5
    binIndices = mean(LC1925195,'omitnan') >= binEdges(Ibin) & mean(LC1925195,'omitnan') < binEdges(Ibin+1);
    binEfficiencies(Ibin) = mean(1 - sum(isnan(LC1925195(:,binIndices)))/20);
    end

end

% Plot the histogram
bar(binCenters, binEfficiencies);
xlabel('Magnitude');
ylabel('Average Detection Efficiency');
title('Detection Efficiency vs Magnitude');






%%
%List.Folder
%visit
%visits = [1] %[1,2]
%List.FileName(visits)
%List.FileName = List.FileName(visits);
%List.Folder   = List.Folder(visits);
%List.CropID   = List.CropID
%R = lcUtil.zp_meddiff(MatchedSource,'MagField',Args.MagField,'MagErrField',Args.MagErrField);
%[MS_ZP,ApplyToMagFieldr] = applyZP(MatchedSource, R.FitZP,'ApplyToMagField',Args.MagField);
%open getObsInfo.m
%open BatchSort.m
%List
%matched_source = MatchedSources.readList(list)
%matched_source = MatchedSources.readList(List)
%MSU = mergeByCoo( matched_source, matched_source(1));



%ms1 =  mergeByCoo(ms1,ms1(1)) 
%ms2 =  MatchedSources.readList(list2)
%ms2 =  mergeByCoo(ms2,ms2(1)) 


%% 2nd night
cd('~/marvin/LAST.01.02.01/2023/09/16/proc/')
List = MatchedSources.rdirMatchedSourcesSearch('CropID',14)
%%
list1.FileName = List.FileName(contains(List.FileName,'field1130'));
list1.Folder   = List.Folder(contains(List.FileName,'field1130'))
list1.CropID = List.CropID

list2.FileName = List.FileName(contains(List.FileName,'field1064'));
list2.Folder   = List.Folder(contains(List.FileName,'field1064'))
list2.CropID = List.CropID


MS1 =  MatchedSources.readList(list1)
%MS1 =  mergeByCoo(ms1,ms1(1)) 
MS2 =  MatchedSources.readList(list2)
%MS2 =  mergeByCoo(ms2,ms2(1)) 


%%

LC1 = GetMagBin(ms1(2),'MagMin',17.5,'MagMax',17.75)
LC2 = GetMagBin(ms1(2),'MagMin',17.75,'MagMax',18.0)



isempty(LC1)

%%
LC171725 = [];
LC1725175 = [];
LC1751775 = [];
LC177518  = [];
LC181825 = [];
LC1825185 = [];
LC1851875 = [];
LC187519 = [];
LC191925  = [];

LC1 = [];



for i = 1 :4

    if i == 1

        mms = ms1;

        for j = 1:length(mms)

            lc171725 = GetMagBin(mms(j),'MagMin',17.0,'MagMax',17.25);
            lc1725175 = GetMagBin(mms(j),'MagMin',17.25,'MagMax',17.5);
            lc1751775 = GetMagBin(mms(j),'MagMin',17.5,'MagMax',17.75);
            lc177518 = GetMagBin(mms(j),'MagMin',17.5,'MagMax',17.75);
            lc181825 = GetMagBin(mms(j),'MagMin',18.0,'MagMax',18.25);
            lc1825185 = GetMagBin(mms(j),'MagMin',18.25,'MagMax',18.5);
            lc1851875 = GetMagBin(mms(j),'MagMin',18.5,'MagMax',18.75);
            lc187519 = GetMagBin(mms(j),'MagMin',18.75,'MagMax',19.0);
            lc191925  = GetMagBin(mms(j),'MagMin',19.0,'MagMax',19.25);


            LC171725 = [LC171725 lc171725];
            LC1725175 = [LC1725175 lc1725175];
            LC1751775 = [LC1751775 lc1751775];
            LC177518  = [LC177518 lc177518];
            LC181825 = [LC181825 lc181825];
            LC1825185 = [LC1825185 lc1825185];
            LC1851875 = [LC1851875 lc1851875];
            LC187519 = [LC187519 lc187519];
            LC191925  = [LC191925 lc191925];






        end

    end

    if i == 2



        mms = ms2;

        for j = 1:length(mms)

                       lc171725 = GetMagBin(mms(j),'MagMin',17.0,'MagMax',17.25);
            lc1725175 = GetMagBin(mms(j),'MagMin',17.25,'MagMax',17.5);
            lc1751775 = GetMagBin(mms(j),'MagMin',17.5,'MagMax',17.75);
            lc177518 = GetMagBin(mms(j),'MagMin',17.5,'MagMax',17.75);
            lc181825 = GetMagBin(mms(j),'MagMin',18.0,'MagMax',18.25);
            lc1825185 = GetMagBin(mms(j),'MagMin',18.25,'MagMax',18.5);
            lc1851875 = GetMagBin(mms(j),'MagMin',18.5,'MagMax',18.75);
            lc187519 = GetMagBin(mms(j),'MagMin',18.75,'MagMax',19.0);
            lc191925  = GetMagBin(mms(j),'MagMin',19.0,'MagMax',19.25);


            LC171725 = [LC171725 lc171725];
            LC1725175 = [LC1725175 lc1725175];
            LC1751775 = [LC1751775 lc1751775];
            LC177518  = [LC177518 lc177518];
            LC181825 = [LC181825 lc181825];
            LC1825185 = [LC1825185 lc1825185];
            LC1851875 = [LC1851875 lc1851875];
            LC187519 = [LC187519 lc187519];
            LC191925  = [LC191925 lc191925];

        end


    end

    if i == 3


        mms = MS1;

        for j = 1:length(mms)

                        lc171725 = GetMagBin(mms(j),'MagMin',17.0,'MagMax',17.25);
            lc1725175 = GetMagBin(mms(j),'MagMin',17.25,'MagMax',17.5);
            lc1751775 = GetMagBin(mms(j),'MagMin',17.5,'MagMax',17.75);
            lc177518 = GetMagBin(mms(j),'MagMin',17.5,'MagMax',17.75);
            lc181825 = GetMagBin(mms(j),'MagMin',18.0,'MagMax',18.25);
            lc1825185 = GetMagBin(mms(j),'MagMin',18.25,'MagMax',18.5);
            lc1851875 = GetMagBin(mms(j),'MagMin',18.5,'MagMax',18.75);
            lc187519 = GetMagBin(mms(j),'MagMin',18.75,'MagMax',19.0);
            lc191925  = GetMagBin(mms(j),'MagMin',19.0,'MagMax',19.25);


            LC171725 = [LC171725 lc171725];
            LC1725175 = [LC1725175 lc1725175];
            LC1751775 = [LC1751775 lc1751775];
            LC177518  = [LC177518 lc177518];
            LC181825 = [LC181825 lc181825];
            LC1825185 = [LC1825185 lc1825185];
            LC1851875 = [LC1851875 lc1851875];
            LC187519 = [LC187519 lc187519];
            LC191925  = [LC191925 lc191925];

        end


    end

    if i ==4 


        mms = MS2;

        for j = 1:length(mms)

                        lc171725 = GetMagBin(mms(j),'MagMin',17.0,'MagMax',17.25);
            lc1725175 = GetMagBin(mms(j),'MagMin',17.25,'MagMax',17.5);
            lc1751775 = GetMagBin(mms(j),'MagMin',17.5,'MagMax',17.75);
            lc177518 = GetMagBin(mms(j),'MagMin',17.75,'MagMax',18);
            lc181825 = GetMagBin(mms(j),'MagMin',18.0,'MagMax',18.25);
            lc1825185 = GetMagBin(mms(j),'MagMin',18.25,'MagMax',18.5);
            lc1851875 = GetMagBin(mms(j),'MagMin',18.5,'MagMax',18.75);
            lc187519 = GetMagBin(mms(j),'MagMin',18.75,'MagMax',19.0);
            lc191925  = GetMagBin(mms(j),'MagMin',19.0,'MagMax',19.25);


            LC171725 = [LC171725 lc171725];
            LC1725175 = [LC1725175 lc1725175];
            LC1751775 = [LC1751775 lc1751775];
            LC177518  = [LC177518 lc177518];
            LC181825 = [LC181825 lc181825];
            LC1825185 = [LC1825185 lc1825185];
            LC1851875 = [LC1851875 lc1851875];
            LC187519 = [LC187519 lc187519];
            LC191925  = [LC191925 lc191925];

        end


    end






end


%%
lg_lbl={};

            sd171725 = std(LC171725,1) ;
            sd1725175 = std(LC1725175,1);
            sd1751775 = std(LC1751775,1);
            sd177518  = std(LC177518,1);          
            sd181825 = std(LC181825,1);
            sd1825185 = std(LC1825185,1);
            sd1851875 = std(LC1851875,1);
            sd187519 = std(LC187519,1);
            sd191925  = std(LC191925,1);

figure('color','white')

histogram(sd171725,30)
lg_lbl{end+1} = sprintf('17 < m < 17.25 ; SD = %.3f',mean(sd171725))
hold on 
histogram(sd1725175,30)
lg_lbl{end+1} = sprintf('17.25 < m < 17.5 ; SD = %.3f',mean(sd1725175))
histogram(sd1751775,30)
lg_lbl{end+1} = sprintf('17.5 < m < 17.75 ; SD = %.3f',mean(sd1751775))
histogram(sd177518,30)
lg_lbl{end+1} = sprintf('17.75 < m < 18 ; SD = %.3f',mean(sd177518))
histogram(sd181825,30)
lg_lbl{end+1} = sprintf('18 < m < 18.25 ; SD = %.3f',mean(sd181825))
histogram(sd1825185,30)
lg_lbl{end+1} = sprintf('18.25 < m < 18.5 ; SD = %.3f',mean(sd1825185))
histogram(sd1851875,30)
lg_lbl{end+1} = sprintf('18.5 < m < 18.75 ; SD = %.3f',mean(sd1851875))
histogram(sd187519,30)
lg_lbl{end+1} = sprintf('18.75 < m < 19 ; SD = %.3f',mean(sd187519))
histogram(sd191925,30)
lg_lbl{end+1} = sprintf('19 < m < 19.25 ; SD = %.3f',mean(sd191925))





title('Noise per Mag Bin')
legend(lg_lbl,'FontSize',18)
%%
Vs = [mean(sd171725);mean(sd1725175);mean(sd1751775);mean(sd177518);mean(sd181825);mean(sd1825185);mean(sd1851875);mean(sd187519);mean(sd191925)]

deltaF = [0.8:-0.05:0.005]
deltaM = -2.5*log10(1-deltaF)
magBins = [17.125:0.5:19.125]
%% Get Sigma_i Per Mag Bins
figure('color','white')
imagesc(deltaM,magBins,deltaM./Vs)
% Add labels and title
xlabel('$\Delta M$','Interpreter','latex');
ylabel('$Mag$','Interpreter','latex');
title('$\Delta M/\sigma$','Interpreter','latex');

% Add colorbar
% c = colorbar;
ylabel(c, '$\Delta M/\sigma$','Interpreter','latex');
% Adjust the axis for correct scaling
%axis xy;


% Create new axes on top of the existing one
ax1 = gca; % Get handle to the current axes
ax1_pos = ax1.Position; % Position of the first axes

% Create a new axes with the same position
ax2 = axes('Position', ax1_pos, 'XAxisLocation', 'top', 'Color', 'none', 'YTick', []);

% Define new x-axis values (for example, converting to a different scale)
new_x = deltaF;

% Set the new x-axis limits and tick values
set(ax2, 'XLim', [new_x(end), new_x(1)], 'XTick', linspace(new_x(end), new_x(1), 9));
set(ax2, 'XTickLabel', arrayfun(@num2str,linspace(new_x(end), new_x(1), 9), 'UniformOutput', true));
ax2.XLabel('$\Delta F$','Interpreter','latex')
% Link the x-axes of both axes
linkaxes([ax1, ax2], 'x');



S = deltaM./Vs;
% Set the colormap (optional)
c = colormap(jet); % You can use any colormap you like
colorbar; % Display the colorbar
ylabel(c, '$\Delta M/\sigma$','Interpreter','latex');
% Get the dimensions of the data matrix
[nRows, nCols] = size(S);

% Loop through each element in the matrix and place the corresponding number
for row = 1:nRows
    for col = 1:nCols
        % Get the value at the current row and column
        value = data(row, col);
        
        % Place the text at the center of the current square
        text(col, row, num2str(value, '%.2f'), ... % Format the number with 2 decimal places
            'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'middle', ...
            'Color', 'white'); % You can change the text color if necessary
    end
end

% Adjust axes for better visualization
axis equal; % Equal scaling of the axes
set(gca, 'XTick', 1:nCols, 'YTick', 1:nRows); % Set the ticks to be at the center of squares

%% Get Delta F - Delta M
