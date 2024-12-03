function nightlyReport(year,month,day,Args)

arguments
    year
    month
    day
    Args.mainPath = sprintf('~/Documents/MainTest/%04d-%02d-%02d',year,month,day);
    Args.ReportName = sprintf('%04d-%02d-%02d_WD_Observation_Report_2.pdf',year,month,day);
    Args.ReportPath = '~/Documents/MainTest/Reports';


end

import mlreportgen.report.*
import mlreportgen.dom.*
%% Initilize report:


reportFile = fullfile(Args.ReportPath,Args.ReportName);
rpt = Report(reportFile, 'pdf');

%% Report Title page:

% Title Page
titlePage = TitlePage;
titlePage.Title = 'WD Observation Report';
titlePage.Subtitle = 'Summary of Observations';
titlePage.Author = 'Yarin Shani';
%titlePage.Image = which('matlab_icon.png'); % Optional image
add(rpt, titlePage);
T = {};
% Add a table of contents
toc = TableOfContents;
add(rpt, toc);

%% Get dates and telecope tables:

% Date dir (contain tables from all telescopes for a given date)
dateDir = dir(fullfile(Args.mainPath,'Results_table*.mat'));
tableFileName = dateDir( ~ismember({dateDir.name}, {'.', '..','Report Results','LAST*'}));


for Itab = 1: length(tableFileName)
% Load file (usualy 2 tables for night)

% input 
nightlyChapters = chapterAnalysis(tableFileName(Itab));

for Ich = 1 : numel(nightlyChapters)

    add(rpt,nightlyChapters{Ich})

end


end %tableFN loop

close(rpt);
fprintf('Report generated: %s\n', reportFile);


end % end function





% ######## Helper functions

function chapters = chapterAnalysis(tableFileName)
import mlreportgen.report.*
import mlreportgen.dom.*

chapters = {};

filePath = fullfile(tableFileName.folder,tableFileName.name);
Tab = load(filePath);
tab = Tab.tab;

if ~isempty(tab)
% All the magic happens
pattern = 'Results_table_(.*?)_(\d{4}-\d{2}-\d{2})\_(.*?).mat';

% Extract TelescopeID and Date
tokens = regexp(tableFileName.name, pattern, 'tokens');

% Extracted data (cell array)
TelescopeID = tokens{1}{1};
Date = tokens{1}{2};

% Create directory to store images
reportProdSaveDir = fullfile(tableFileName.folder, TelescopeID)
if ~exist(reportProdSaveDir, 'dir') 
    mkdir(reportProdSaveDir);
end


for Ifield = 1 : width(tab)

    currentTable = tab{Ifield};
    numWDs = height(currentTable);
    NcatDetected = 0;
    NforcedDetected = 0;
    if any(strcmp(currentTable.Properties.VariableNames, 'catDetected'))
        NcatDetected = sum(currentTable.catDetected);
    end
    if any(strcmp(currentTable.Properties.VariableNames, 'forcedDetected'))
        NforcedDetected = sum(currentTable.forcedDetected);
    end

    % Total events
    totalEvents = {NcatDetected, NforcedDetected, NcatDetected + NforcedDetected};
    eventWDsIdx = currentTable.Nevents | currentTable.NeventsF;
    doubleDetection = sum(currentTable.Nevents & currentTable.NeventsF);
    eventWDs    = currentTable(eventWDsIdx,:);
    NeventWDs   = height(eventWDs);
    tabFieldID = currentTable.FieldID(1);


    % Chapter Title
    chapter = Chapter(sprintf('%s Date: %s ; FieldID %s', TelescopeID,Date,tabFieldID));

    % Add Notes
    para = Paragraph(sprintf('Night results. Lightcurves of %i visits. Total visit: %i',currentTable.BatchSize(1),currentTable.Nvisits(1)));
    para.Style = {OuterMargin("0pt", "0pt", "10pt", "10pt")};
    add(chapter, para);

            % Summary Statistics
            
            
            statTable = Table({'', ''; ...
                                'Number of expected WDs in the field  :  ', numWDs; ...
                                'Catalog Detected WDs  :  ', NcatDetected;...
                                'Forced Detected WDs  :  ',NforcedDetected;...
                                'WDs with Events  :  ',NeventWDs;...
                                'Forced & Catalog Events  :  ',doubleDetection});
            statTable.Style = [statTable.Style {OuterMargin("0pt", "0pt", "10pt", "10pt")}];
            add(chapter, statTable);


            %%  ADD detection plot 
            tabArgs.Date = Date;
            tabArgs.Tel  = sprintf('%s-%s',TelescopeID,tabFieldID);
            tabArgs.Nwds = sum(currentTable.catDetected | currentTable.forcedDetected);
            
            plotCatForcedDetectionEfficiency(currentTable, tabArgs)
            
            %plotDetectionEfficiency(stackedWDtable, args);
            DetFile = fullfile(reportProdSaveDir, sprintf('%s_%s_%s_DetectionEfficiency.png',TelescopeID,Date,tabFieldID));
            saveas(gcf, DetFile);
            close;
            img = Image(DetFile);
            img.Style = {ScaleToFit(true), Width('200%'),Height('200%')};
            %img.Width = '8in';
            %img.Height = '6in';
            add(chapter, img);
            add(chapter, PageBreak());
            % YOU need a  page brerak 

            % plot light curves ( all )
            section = Heading(2, 'Events')
            append(chapter,section)

            for Itgt = 1:height(currentTable)
                WD = currentTable(Itgt,:);
                if any(strcmp(WD.Properties.VariableNames, 'BatchData')) || any(strcmp(WD.Properties.VariableNames, 'BatchDataF'))
                    %plotBatchLightCurves(tab(Itgt, :), saveDir);

                    plotBatchLightCurves1toChapter(WD, reportProdSaveDir,'ReportChapter',chapter,'plotOnlyEvents',true)
                    %img = Image(gcf);
                    
                end
            end
            




            chapters{end+1} = chapter;


            %% plots
    
                


end
end


end