% For the main function:

% We need a code that goes through marvin telescope directories. and start
% proccesing them one by one. stroe the data to a table and it has a
% feature that it knows which files he already go through in the past for
% future runs of the funciton i dont want it to repet observing nights it
% already visited

%% Test sort batches. 

% Path to marvin:

cd('~/marvin')

% example of the direcories hirearcy
% ls LAST*  LAST_Visits_20240716.mat  LAST_Visits_20240810.mat  LAST_Visits_20241113.mat
% LAST_Visits_20240802.mat  LAST_Visits_20241007.mat  LAST_Visits.mat
% 
% LAST.01.01.01:
% 2023  2024  new_mode2  new_simone
% 
% LAST.01.01.02:
% 2023  2024  new_simone
% 
% LAST.01.01.03:
% 2023  2024  new_simone
% 
% LAST.01.01.04:
% 2023  2024  new_mode2  newOffset0  new_simone
% 
% LAST.01.02.01:
% 2022  2023  2024  newMode2
% 
% LAST.01.02.02:
% 2022  2023  2024  newMode2
% 
% LAST.01.02.03:
% 2022  2023  2024  newMode2
% 
% LAST.01.02.04:
% 2023  2024  new1  newMode2
% 
% LAST.01.03.01:
% 2023  2024
% 
% LAST.01.03.02:
% 2023  2024
% 
% LAST.01.03.03:
% 2023  2024
% 
% LAST.01.03.04:
% 2023  2024
% 
% LAST.01.04.01:
% 2023  2024
% 
% LAST.01.04.02:
% 2023  2024
% 
% LAST.01.04.03:
% 2023  2024  calib_phot
% 
% LAST.01.04.04:
% 2023  2024
% 
% LAST.01.05.01:
% 2023  2024
% 
% LAST.01.05.02:
% 2023  2024
% 
% LAST.01.05.03:
% 2023  2024
% 
% LAST.01.05.04:
% 2023  2024
% 
% LAST.01.06.01:
% 2023  2024
% 
% LAST.01.06.02:
% 2023  2024
% 
% LAST.01.06.03:
% 2023  2024
% 
% LAST.01.06.04:
% 2023  2024
% 
% LAST.01.08.01:
% 2022	     David
% 2023	     MS_LAST.01.08.01_202303_SN2022wlm.mat
% 2023BU_Orig  MS_LAST.08.01_202303_Ast2023DM.mat
% 2024	     newMode2
% 
% LAST.01.08.02:
% 2022  2023  2023BU_Orig  2024  DavidP  newMode2
% 
% LAST.01.08.03:
% 2022  2023  2023BU_Orig  2024  newMode2
% 
% LAST.01.08.04:
% 2022  2023  2023BU_Orig  2024  newMode2
% 
% LAST.01.10.01:
% 2023  2024
% 
% LAST.01.10.02:
% 2023  2024
% 
% LAST.01.10.03:
% 2023  2024
% 
% LAST.01.10.04:
% 2023  2024

% Where to scan all observing nights mean to go over the year directories
% (2022,2023,2023 in this case)

% inside each year directory there is a month directory :
cd('LAST.01.01.01/2024/')
% >>>> ls
% 01  02	03  04	05  06	07  08	09  10	11
% And inside every month directory there is a day directory:
cd 10
% ls
% 08  10	22  23	24  26	27  28	29  31

% In the example above we have 10 nights of observation in october 2024. 

% inside every ~/marvin/Last.01.<mount>.<Tel>/year/month/day/proc there are
% visit directories. lets look at en exmaple:
% 
% pwd     '/home/yarinms/marvin/LAST.01.01.01/2024/10/29/proc'
% 
% ls
% 000056v0  162334v0  172727v0  183308v0	193405v0  204243v0  215101v0  231511v0
% 004703v0  163014v0  173407v0  183948v0	194149v0  205008v0  215847v0  232234v0
% 005445v0  163654v0  174047v0  184628v0	194934v0  205733v0  220633v0
% 010229v0  164335v0  174727v0  185308v0	195716v0  210515v0  221416v0
% 155314v0  165406v0  175456v0  185948v0	200500v0  211240v0  222140v0
% 155654v0  170047v0  180136v0  190628v0	201226v0  212025v0  222926v0
% 160334v0  170727v0  180817v0  191308v0	201949v0  212807v0  223708v0
% 161014v0  171407v0  181457v0  191948v0	202713v0  213551v0  224452v0
% 161654v0  172047v0  182137v0  192629v0	203457v0  214335v0  225236v0


% As you can the visit directories are associated with the time of the
% visit. this folders should be sorted out by time. the main problem herer
% is that after midnight the directories goes on top because it is marked
% as 00... which ruin the natural ordering of the folders. this is how i
% use to sort them :
% Load Visit Directories and Sort Properly
    visitDirs = dir(fullfile(fullPath, '*v0'));
    visitNames = {visitDirs.name};
    
    % Extract hour, minute, second from folder names and handle AM/PM sorting
    visitTimes = cellfun(@(x) sscanf(x, '%06dv0'), visitNames);
    visitHours = floor(visitTimes / 10000);
    amPmMask = visitHours < 12; % AM: hours < 12, PM: hours >= 12
    amVisits = visitDirs(amPmMask);
    pmVisits = visitDirs(~amPmMask);
    
    % Sort AM and PM visits separately
    [~, amOrder] = sort(visitTimes(amPmMask));
    [~, pmOrder] = sort(visitTimes(~amPmMask));
    
    % Concatenate PM visits first, then AM visits
    sortedVisits = [pmVisits(pmOrder); amVisits(amOrder)];
    
% But then i want to group them into consectuive groups in a smart way.
% The motivation is that to process two consecutive groups is better than
% processing all the visits together. another problem is the fact that a
% full visit is associated with a field ID which should be singular in each
% group . we dont want to group two visit from two different fields even if
% they are consecutive. this is how i do it :
 % Group visits into batches
    numVisits = length(sortedVisits);
    batches = {}; %cell(ceil(numVisits / batchSize), 1);
    Fields = {};
    for i = 1:ceil(numVisits / batchSize)
        
        startIdx = (i - 1) * batchSize + 1;
        endIdx = min(i * batchSize, numVisits);
        checkVisDirs = sortedVisits(startIdx:endIdx);

        visitFields = {};
        for Iv = 1 : numel (checkVisDirs)
            
          % get Field ID
          FN     =  dir(fullfile(checkVisDirs(Iv).folder,checkVisDirs(Iv).name,'*001_001_001_sci_proc_Cat_1.fits'));
          fullFN = fullfile(FN.folder,FN.name) ;
          AH = AstroHeader(fullFN,3);
          visitFields  = [visitFields; {AH.Key.FIELDID}];
        end

        [Ufields,Uidx,NewIdx] = unique(visitFields,'rows');
        Fields = [Fields; {Ufields}];
        
        if size(Ufields,1) == 1
      
            batches{end+1} = sortedVisits(startIdx:endIdx);
        else
            %
            [newIdx,~,~] = unique(NewIdx);
            toBatch = [startIdx:1:endIdx];
            for Iidx = 1 : length(newIdx)
                if Iidx == 1 
                    
                    toBatch1 = toBatch(NewIdx == Iidx);
                    batches{end+1} = sortedVisits(toBatch1);

                else
                    toBatch2 = toBatch(NewIdx == Iidx);
                    batches{end+1} = sortedVisits(toBatch2);

                    
                end
            end
        end
    end

%
% So lets begin with what i need . some routine that load the meta table if exist to coninute where it stoped or to create a new one.  
% and i want to test the routin that sort batches to see that it is working
% properly
%
%
%









%% the Meta Table structure should have the following columns (this is not all coloumns so add what you think is relevant and leave room to add more coloumns:
% Is wd?
% mount .
% telescope.
% Date
% path to directories.
% complete code to create the MS sources as an STR.
% Event significance.
% Delta mag (from median)
% brightenning dimming (flare / transit)
% channel of detection.
% Significance.
% SNR.
% Quantile



%% Test for organizeBatchesWfields:
organizeBatchesWfields('~/home/yarinms/marvin/LAST.01.01.01/2024/10/29/proc') % looks like it is working.


% after orgnizing with batches. we can start proccesing the batches
% We want to find unique fields:
allFieldIDs = vertcat(Fields{:});
[uniqueFields,~,NewIdx]  = unique(allFieldIDs);
Nfields = length(uniqueFields);
mainTable = {};

% and then we want to scan every field batches 
















