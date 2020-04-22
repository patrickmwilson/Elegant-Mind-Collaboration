% Analysis
% Created by Patrick Wilson on 1/20/2020
% Github.com/patrickmwilson
% Created for the Elegant Mind Collaboration at UCLA 
% with Professor Katsushi Arisaka
% Copyright � 2020 Elegant Mind Collaboration. All rights reserved.

% Creates a compiled scatter plot with best fit chi-squared minimized
% lines, a compiled log10-log10 plot with a best fit line, and a scatter 
% plot and histogram of Letter height/Eccentricity for each subject 
% (divided and distribution figures).

% Add helper functions to path
libPath = fullfile(pwd, 'lib');
addpath(libPath); 

% Supress directory already exists warning
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

names = ["T1", "Crowded Periphery", "Crowded Periphery Outer", ...
        "Crowded Center 9x9", "Crowded Center 3x3",  ... 
        "Isolated Character", "Crowded Periphery 9x9", "Anstis"];

% Checkbox input dialogue - chooses which protocols to include data from
global CHECKBOXES;
ButtonUI(names);

% Input dialogue: save plots?
dataAnswer = questdlg('Save plots?', '', 'Yes', 'No', 'Cancel', 'Yes');
saveOutput = (char(dataAnswer(1)) == 'Y');

% Input dialogue: save parameters?
dataAnswer = questdlg('Save parameters to csv?', '', 'Yes', 'No', 'Cancel', 'Yes');
saveParams = (char(dataAnswer(1)) == 'Y');

% Creating graphs that will include multiple sets of data
pointSlopeGraph = figure('Name','Point Slope');
wlssPointSlopeGraph = figure('Name','WLSS Point Slope');
logPlot = figure('Name', 'Log-Log Plot');
combinedDist = figure('Name', 'Combined Histogram');
logCombinedDist = figure('Name', 'Log Combined Histogram');
    
% List of plot colors and axis limits for divided and distribution figures
colors = [0 0.8 0.8; 0.9 0.3 0.9; 0.5 0 0.9; ...
        0 0.1 1; 0.4 0.8 0.5; 1 0.6 0; 0.83 0.86 .035; 0 0 0];
divLims = [45 1.5; 45 0.35; 45 0.35; 45 0.2; 45 0.2; 45 0.15; 45 inf; 45 0.15];
maxDistX = 0;
maxGaussHeight = 0;

mkdir(fullfile(pwd, 'Analysis_Results'));

% Plots data from each experiment one at a time, producing a divided and a
% distribution figure for each experiment, and a point-slope and
% log10-log10 plot on which data from all experiments is graphed
for p = 1:(length(names))
    if(CHECKBOXES(p))
        name = names(p);
        data = readCsv(name, allData);
        
        % Creates a 2 column matrix of the data. Eccentricity is placed in
        % column 1, letter height in column 2. 
        data(:,1) = data(:,3);
        % T1 data is stored differently, letter height is in column 4 of
        % the csv rather than column 2
        data(:,2) = data(:,(2 + 2*(strcmp(name,'T1'))));
        
        % Removes all rows from the data matrix which contain a zero.
        i = 1;
        while(i <= size(data,1))
            if(data(i,1) == 0 || data (i, 2) == 0)
                data(i,:) = [];
                continue;
            end
            i = i + 1;
        end
        
        % Calculate parameters and produce figures
        [csvOutput, rawCsvOutput] = makeFigs(data, name, csvOutput, ...
            rawCsvOutput, (((p-1)*4)+5), colors(p,:), divLims(p,:), ...
            wlssPointSlopeGraph, pointSlopeGraph, logPlot, combinedDist, ...
            logCombinedDist, saveOutput);
    end
end

% Axes and text formatting for point slope plot
formatFigure(pointSlopeGraph, [0 45], [0 11], "Eccentricity (degrees)", ...
    "Letter Height (degrees)", "Letter Height vs. Retinal Eccentricity", ...
    false)

% Axes and text formatting for Weighted LSS point slope plot
formatFigure(wlssPointSlopeGraph, [0 45], [0 11], "Eccentricity (degrees)", ...
    "Letter Height (degrees)", ...
    "Letter Height vs. Retinal Eccentricity (Weighted LSS)", false)

% Axes and text formatting for log-log plot
formatFigure(logPlot, [-1 2], [-1 2], "Log of Eccentricity (degrees)", ...
    "Log of Letter Height (degrees)", ...
    "Log of Letter Height vs. Log of Retinal Eccentricity", true)

% Axes, title, and labels for combined distribution graph
formatFigure(combinedDist, [0 inf], [0 0.7], ...
    "Letter Height (degrees)/Eccentricity (degrees)", ...
    "Number of Occurences (Normalized to Probability)", ...
    "Distribution of Letter Height/Eccentricity", false)

% Axes, title, and labels for log combined distribution graph
formatFigure(logCombinedDist, [-2 0.5], [0 0.7], ...
    "Log10[Letter Height (deg)/Eccentricity (deg)]", ...
    "Number of Occurences (Normalized to Probability)", ...
    "Distribution of Log10[Letter Height/Eccentricity]", false)

if saveOutput
    % Saving point slope, log-log, and combined dist plots as png
    fFolderName = strcat(string(csvOutput{1,3}), "_", string(csvOutput{1,4}));
    folderName = fullfile(pwd, 'Analysis_Results', 'Plots', ...
        string(csvOutput{1,2}), fFolderName);

    figs = [pointSlopeGraph, wlssPointSlopeGraph, logPlot, combinedDist, ...
        logCombinedDist];
    figNames = ["_point_slope.png", "_wlss_point_slope.png", ...
        "_log_log_plot.png", "_combined_histogram.png", ...
        "_log_combined_histogram.png"];

    for i = 1:length(figs) 
        fig = figs(i);
        figName = figNames(i);
        fileName = sprintf('%s%s', string(csvOutput{1,3}), ...
            figName);
        saveas(fig, fullfile(folderName, fileName));
    end
end

if saveParams
    csvName = fullfile(pwd, 'Analysis_Results', 'Compiled_Parameters.csv');
    rawCsvName = fullfile(pwd, 'Analysis_Results', 'Analysis_Summary_Raw.csv');
    writeToCsv(csvOutput, rawCsvOutput, rawCsvName, csvName);
end

uiwait(helpdlg('Click OK to finish and close figures'));
close all;

