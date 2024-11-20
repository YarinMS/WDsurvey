import mlreportgen.report.*
import mlreportgen.dom.*

% Create a report object
year = 2024;
month = 10;
day =  31;
Args.save = '~/Projects/NightRun/';
Args.Date = sprintf('%04d-%02d-%02d',year,month,day);
Args.ReportName = sprintf('%04d-%02d-%02d_WD_Observation_Report.pdf',year,month,day);
reportFile = fullfile(Args.save, Args.ReportName);
rpt = Report(reportFile, 'pdf');

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


for m = [4,8,6,10]
    for tel = 1:4
         telescopeID = sprintf('LAST.01.%02d.%02d', m, tel);
         Date = Args.Date;
        try
            % Run WDmain and get results
            tab = WDmain(m, tel, year,month,day, 4);
           
            stackedWDtable = vertcat(tab{:});
            T{end+1} = stackedWDtable;
            
            % Chapter Title
            chapter = Chapter(sprintf('Telescope: %s Date: %s', telescopeID,Args.Date));

            % Add Notes
            para = Paragraph(sprintf('Date: %s\nTelescope: %s', ...
                Date, telescopeID));
            para.Style = {OuterMargin("0pt", "0pt", "10pt", "10pt")};
            add(chapter, para);

            % Summary Statistics
            totalWDs = height(stackedWDtable);
            detectedWDs = sum(stackedWDtable.Detected == true);
            statTable = Table({'Metric', 'Value'; ...
                                'Total WDs: ', totalWDs; ...
                                'Detected WDs: ', detectedWDs});
            statTable.Style = [statTable.Style {OuterMargin("0pt", "0pt", "10pt", "10pt")}];
            add(chapter, statTable);

            % Add Plots
            % 1. RMS vs Magnitude
            figure;
            args.Tel = telescopeID;
            args.Date = Date;
            args.Nwds =  detectedWDs;
            args.legend = false;
            plotRMSvsMagnitude(stackedWDtable, args);
            rmsFile = fullfile(Args.save, sprintf('%s_%s_RMS.png',Date, telescopeID));
            saveas(gcf, rmsFile);
            close;
            img = Image(rmsFile);
            img.Width = '8in';
            img.Height = '6in';
            add(chapter, img);

            % 2. Detection Efficiency
            figure;
            plotDetectionEfficiency(stackedWDtable, args);
            detFile = fullfile(Args.save, sprintf('%s_%s_DetectionEfficiency.png',Date, telescopeID));
            saveas(gcf, detFile);
            close;
            img = Image(detFile);
            img.Width = '8in';
            img.Height = '6in';
            add(chapter, img);

            % Add chapter to report
            add(rpt, chapter);

        catch ME
            % Log errors as a failed chapter
            chapter = Chapter(sprintf('Telescope: %s (Failed)',telescopeID));
            para = Paragraph(sprintf('Error: %s', ME.message));
            para.Style = {OuterMargin("0pt", "0pt", "10pt", "10pt")};
            add(chapter, para);
            add(rpt, chapter);
        end
    end
end



% Combine all tables
stackedWDtable = vertcat(T{:});

% Final Summary Chapter
finalChapter = Chapter('Final Summary');

% Add Overall Statistics
totalWDs = height(stackedWDtable);
detectedWDs = sum(stackedWDtable.Detected == true);
% eventWDs
finalStatTable = Table({'Metric', 'Value'; ...
                        'Total WDs: ', totalWDs; ...
                        'Detected WDs: ', detectedWDs});
finalStatTable.Style = [finalStatTable.Style {OuterMargin("0pt", "0pt", "10pt", "10pt")}];
add(finalChapter, finalStatTable);

% Add Combined Plots
% 1. RMS vs Magnitude
figure;
args.Tel = 'All Telescopes';
args.Date ='';
args.Nwds = detectedWDs;
  args.legend = false;
plotRMSvsMagnitude(stackedWDtable, args);
combinedRMSFile = fullfile(Args.save, 'Combined_RMS.png');
saveas(gcf, combinedRMSFile);
close;
img = Image(combinedRMSFile);
            img.Width = '7in';
            img.Height = '5in';
          
add(finalChapter, img);

% 2. Detection Efficiency
figure;
plotDetectionEfficiency(stackedWDtable, args);
combinedDetFile = fullfile(Args.save, 'Combined_DetectionEfficiency.png');
saveas(gcf, combinedDetFile);
close;
img = Image(combinedDetFile);
            img.Width = '7in';
            img.Height = '5in';
            add(finalChapter, img);

% Add Final Chapter to Report
add(rpt, finalChapter);



% Final Chapter with Light Curves
finalImageChapter = Chapter('Light Curves');
lightCurveImages = dir(fullfile(Args.save, '*.png'));
for k = 1:length(lightCurveImages)
    imgFile = fullfile(lightCurveImages(k).folder, lightCurveImages(k).name);
    imgTitle = Paragraph(sprintf('Light Curve: %s', lightCurveImages(k).name));
    imgTitle.Style = {OuterMargin("0pt", "0pt", "10pt", "10pt"), Bold()};
    add(finalImageChapter, imgTitle);
    img = Image(imgFile);
    img.Width = '7in';
    img.Height = '5in';
    add(finalImageChapter, img);
    add(finalImageChapter, PageBreak());
end
add(rpt, finalImageChapter);

% Close the report
close(rpt);
fprintf('Report generated: %s\n', reportFile);


