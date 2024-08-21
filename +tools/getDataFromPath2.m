h = waitbar(0);

for I =  1 :24

waitbar(I/24,h,sprintf('Now analyzing Crop %i/24',I))


cd('~/marvin/LAST.01.04.03/2024/08/01/proc/')
List = MatchedSources.rdirMatchedSourcesSearch('CropID',I)

%contains(List.FileName,'DR2E80160');
%%
list1.FileName = List.FileName(contains(List.FileName,'DR2E80160'));
list1.Folder   = List.Folder(contains(List.FileName,'DR2E80160'));
list1.CropID = List.CropID;
ms1 =  MatchedSources.readList(list1);


%%
cd('~/marvin/LAST.01.04.03/2024/08/02/proc/')
List = MatchedSources.rdirMatchedSourcesSearch('CropID',I)
list2.FileName = List.FileName(contains(List.FileName,'DR2E80160'));
list2.Folder   = List.Folder(contains(List.FileName,'DR2E80160'));
list2.CropID = List.CropID;
ms2 =  MatchedSources.readList(list2);
list1
list2
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

        for j = 3:length(mms)

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
    binEfficiencies(Ibin) = mean(1 - sum(isnan(LC171725(:,binIndices)))/20);
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
figure();
bar(binCenters, binEfficiencies);
xlabel('Magnitude');
ylabel('Detection Efficiency')
title(sprintf('Average Detection Efficiency (CropID %i 20s Exp)',I));



end