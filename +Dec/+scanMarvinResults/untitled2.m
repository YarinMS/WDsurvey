%%
MSe = {};
obsData = {};
for i = [10, 22, 23, 24, 26, 28,29]

    [stackedWDtable,mainMS,mainObsData] = Util.getMSDate(4, 1, 2024, 10, i, 60,'CropID',19,'getMS',true)

    if ~isempty(mainMS)
        MSe{end+1} = mainMS{:};
        obsData{end+1} = mainObsData{:};
    end

end

%%
MS =  [MSe{1} MSe{2} MSe{3} MSe{4} MSe{5} MSe{6} MSe{7}];
save('/media/yarinms/Data2/230MasterOTvisCropID19.mat','MS','-v7.3')
save('/media/yarinms/Data2/230MasterOTvisCropID19ObsData.mat','obsData','-v7.3')


%%

%rowInd =2 % Some loop over Res.
eventInfo = marvinFP.evenInfoTable(gtab,Res(rowInd))
eventInfo.rowID = Res(rowInd);
eventRow = gtab(Res(rowInd),:);
% funpack localy and run pipeline
Data = marvinFP.SSHunpackFitsFilesMarv(eventInfo)
% FP
[fn] = marvinFP.automateRemoteProcessingMarv(Data);
ms = dir(sprintf('~/Projects/MarvinRunRes/*Row%i.mat',eventInfo.tabID))
ms= load(fullfile(ms.folder,ms.name));
ms = ms.ms;
figure()
plot(ms.JD,ms.Data.MAG_PSF(:,1))
hold on
plot(eventRow.JD{:},eventRow.MAG_PSF{:})



%%
Data = marvinFP.SSHunpackFitsFilesMarv(Data)
% FP
[fn] = marvinFP.automateRemoteProcessingMarv(Data);