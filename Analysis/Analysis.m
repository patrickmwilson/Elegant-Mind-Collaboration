% Analysis
% Created by Patrick Wilson on 1/20/2020
% Github.com/patrickmwilson
% Created for the Elegant Mind Collaboration at UCLA 
% with Professor Katsushi Arisaka
% Copyright � 2020 Elegant Mind Collaboration. All rights reserved.

% Creates a compiled scatter plot with best fit chi-squared minimized
% fit lines, a compiled scatter plot with weighted least sum of squares fit 
% lines, a compiled log10-log10 plot with a best fit line, a scatter 
% plot and histogram of Letter height/Eccentricity for each subject 
% (divided and distribution figures), and residual plots and histograms.

% Add helper functions to path
libPath = fullfile(pwd, 'lib');
addpath(libPath); 

% Supress directory warnings
warning('off','MATLAB:MKDIR:DirectoryExists');

% Reset workspace and close figures
clear variables;
close all; 

% Input dialogue: all data?
dataAnswer = questdlg('All recorded data? Press no to only analyze data in Active_Data', '', 'Yes', 'No', 'Cancel', 'Yes');
allData = (char(dataAnswer(1)) == 'Y');

if allData
    csvOutput = {'0','All','Averaged','00'};
else
    % Input dialogue for session index, type, subject code, and date of session 
    csvOutput = inputdlg({'Session Index','Type (Study/Mock/Internal)', ...
        'Subject Code (all caps)', 'Date of Session (MM-DD-YY)' },  ...
        'Session Info', [1 70], {'0','Internal','TEST','00-00-00'}); 
    csvOutput = csvOutput';
end
rawCsvOutput = csvOutput;

names = ["Fully Crowded", "Crowded Periphery 9x9", "Crowded Periphery", ...
    "Crowded Periphery Outer", "Anstis", "Crowded Center 9x9",  ...
    "Crowded Center 3x3", "Isolated Character"];

csvIdentifiers = ["T1", "Crowded Periphery 9x9", "Crowded Periphery", ...
    "Crowded Periphery Outer", "Anstis", "Crowded Center 9x9",  ...
    "Crowded Center 3x3", "Isolated Character"];

identifiers = ["T1", "CP9", "CP", "CPO", "A", "CC9", "CC3", "IC"];

% Checkbox input dialogue - chooses which protocols to include data from
global CHECKBOXES;
ButtonUI(names);

trimCC = true;
if(CHECKBOXES(6) || CHECKBOXES(7))
    % Input dialogue: save plots?
    dataAnswer = questdlg('Exclude small eccentricity from CC?', '', 'Yes', 'No', 'Cancel', 'Yes');
    trimCC = (char(dataAnswer(1)) == 'Y');
end

% Input dialogue: save plots?
dataAnswer = questdlg('Save plots?', '', 'Yes', 'No', 'Cancel', 'Yes');
saveOutput = (char(dataAnswer(1)) == 'Y');

% Input dialogue: save parameters?
dataAnswer = questdlg('Save parameters to csv?', '', 'Yes', 'No', 'Cancel', 'Yes');
saveParams = (char(dataAnswer(1)) == 'Y');

% Creating graphs that will include multiple sets of data
pointSlopeGraph = figure('Name','Point Slope');

% Creating graphs that will include multiple sets of data
polyfitGraph = figure('Name','Poly Fit');
    
% List of plot colors and axis limits for divided and distribution figures
colors = [0 0.8 0.8; 0.83 0.86 .035; 0.9 0.3 0.9; 0.5 0 0.9; 0 0 0; ...
    0 0.1 1; 0.4 0.8 0.5; 1 0.6 0];
divLims = [45 1.5; 45 0.35; 45 0.35; 45 0.2; 45 0.2; 45 0.15; 45 inf; 45 0.15];

mkdir(fullfile(pwd, 'Analysis_Results'));

% Plots data from each experiment one at a time, producing a divided and a
% distribution figure for each experiment, and a point-slope and
% log10-log10 plot on which data from all experiments is graphed
for p = 1:(length(names))
    if(CHECKBOXES(p)) 
        name = names(p);
        id = identifiers(p);
        csvid = csvIdentifiers(p);

        [data, fitData, outliers] = readCsv(csvid, id, allData, trimCC);
        
        % Calculate parameters and produce figures
        clear('makeFigs');
        [csvOutput, rawCsvOutput] = makeFigs(data, fitData, outliers, name, ...
            csvOutput, rawCsvOutput, (((p-1)*4)+5), colors(p,:), divLims(p,:), ...
            pointSlopeGraph, polyfitGraph, saveOutput);
    end
end

% Axes and text formatting for point slope plot
formatFigure(pointSlopeGraph, [0 45], [0 11], "Eccentricity (deg)", ...
    "Letter Height (deg)", "Letter Height vs. Retinal Eccentricity", ...
    false);

% Axes and text formatting for point slope plot
formatFigure(polyfitGraph, [0 45], [0 11], "Eccentricity (deg)", ...
    "Letter Height (deg)", "Letter Height vs. Retinal Eccentricity", ...
    false);

if saveOutput
    % Saving point slope, log-log, and combined dist plots as png
    fFolderName = strcat(string(csvOutput{1,3}), "_", string(csvOutput{1,4}));
    folderName = fullfile(pwd, 'Analysis_Results', 'Plots', ...
        string(csvOutput{1,2}), fFolderName);

    fileName = sprintf('%s%s', string(csvOutput{1,3}), "_point_slope.png");
    saveas(pointSlopeGraph, fullfile(folderName, fileName));
    
    fileName = sprintf('%s%s', string(csvOutput{1,3}), "_poly_fit.png");
    saveas(polyfitGraph, fullfile(folderName, fileName));
end

if saveParams
    csvName = fullfile(pwd, 'Analysis_Results', 'Compiled_Parameters.csv');
    rawCsvName = fullfile(pwd, 'Analysis_Results', 'Analysis_Summary_Raw.csv');
    writeToCsv(csvOutput, rawCsvOutput, rawCsvName, csvName);
end

uiwait(helpdlg('Click OK to finish and close figures'));
close all;

