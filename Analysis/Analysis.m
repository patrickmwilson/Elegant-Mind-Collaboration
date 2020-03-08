% Analysis
% Created by Patrick Wilson on 1/20/2020
% Github.com/patrickmwilson
% Created for the Elegant Mind Collaboration at UCLA 
% with Professor Katsushi Arisaka
% Copyright © 2020 Elegant Mind Collaboration. All rights reserved.

% Creates a compiled scatter plot with best fit chi-squared minimized
% lines, a compiled log10-log10 plot with a best fit line, and a scatter 
% plot and histogram of Letter height/Eccentricity for each subject 
% (divided and distribution figures).

clear variables;
close all;

% Add helper functions to path (readCsv.m, makeFigs.m, scaledScatter.m,
% ButtonUI.m)
functionPath = fullfile(pwd, 'Functions');
addpath(functionPath);  

% Input dialogue for session index, type, subject code, and date of session 
csvOutput = inputdlg({'Session Index','Type (Study/Mock/Internal)', ...
    'Subject Code (all caps)', 'Date of Session (MM-DD-YY)' },  ...
    'Session Info', [1 70]); 
csvOutput = csvOutput';
rawCsvOutput = csvOutput;

names = ["T1", "Crowded Periphery", "Crowded Periphery Outer", ...
        "Crowded Center 9x9", "Crowded Center 3x3",  ... 
        "Isolated Character", "Crowded Periphery 9x9", "Anstis"];

% Checkbox input dialogue - chooses which data to analyze
global CHECKBOXES;
ButtonUI(names);

pointSlopeGraph = figure('Name','Point Slope');
logpointSlopeGraph = figure('Name','Log Point Slope');
logPlot = figure('Name', 'Log-Log Plot');
combinedDist = figure('Name', 'Histogram');
    
% List of plot colors and axis limits for divided and distribution figures
colors = [0 0.8 0.8; 0.9 0.3 0.9; 0.5 0 0.9; ...
        0 0.1 1; 0.4 0.8 0.5; 1 0.6 0; 0.83 0.86 .035; 0 0 0];
divLims = [45 1.5; 45 0.35; 45 0.35; 45 0.2; 45 0.2; 45 0.15; 45 inf; 45 0.15];
maxDistX = 0;
maxGaussHeight = 0;

mkdir(fullfile(pwd, 'Analysis Results'));

% Plots data from each experiment one at a time, producing a divided and a
% distribution figure for each experiment, and a point-slope and
% log10-log10 plot on which data from all experiments is graphed
for p = 1:(length(names))
    if(CHECKBOXES(p))
        name = names(p);
        data = readCsv(name);
        
        % Creates a 2 column matrix of the data. Eccentricity is placed in
        % column 1, letter height in column 2. 
        data(:,1) = data(:,3);
        % T1 data is stored differently, letter height is in column 4 of
        % the csv rather than column 2
        data(:,2) = data(:,(2 + 2*(strcmp(name,'T1'))));
        
        % Removes all rows from the data matrix which contain a zero.
        % TODO: Find a cleaner way to do this
        i = 1;
        while(i <= size(data,1))
            if(data(i,1) == 0 || data (i, 2) == 0)
                data(i,:) = [];
                continue;
            end
            i = i + 1;
        end
        
        % See makeFigs.m
%         [csvOutput, rawCsvOutput] = makeFigs(data, name, csvOutput, ...
%         rawCsvOutput, tableIndex, color, divLim, pointSlopeGraph, logPlot, ...
%         combinedDist)
        [csvOutput, rawCsvOutput] = makeFigs(data, name, csvOutput, ...
            rawCsvOutput, (((p-1)*4)+5), colors(p,:), divLims(p,:), ...
            pointSlopeGraph, logpointSlopeGraph, logPlot, combinedDist);
    end
end

% Axes and text formatting for point slope plot
figure(pointSlopeGraph);
xlim([0 45]);
ylim([0 11]);
xlabel("Eccentricity (degrees)");
ylabel("Letter Height (degrees)");
title(sprintf("Letter Height vs. Retinal Eccentricity (%s %s)", ...
    char(csvOutput{1,3}), char(csvOutput{1,4})));
legend('show', 'Location', 'best');

% Axes and text formatting for point slope plot
figure(logpointSlopeGraph);
xlim([0 45]);
ylim([0 11]);
xlabel("Eccentricity (degrees)");
ylabel("Letter Height (degrees)");
title(sprintf("Letter Height vs. Retinal Eccentricity (%s %s)", ...
    char(csvOutput{1,3}), char(csvOutput{1,4})));
legend('show', 'Location', 'best');

% Axes and text formatting for log-log plot
figure(logPlot);
xlim([-1 2]);
ylim([-1 2]);
xlabel("Log of Eccentricity (degrees)");
ylabel("Log of Letter Height (degrees)");
title(sprintf("Log of Letter Height vs. Log of Retinal Eccentricity (%s %s)", ...
    char(csvOutput{1,3}), char(csvOutput{1,4})));
legend('show', 'Location', 'best');
ax = gca;
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';

figure(combinedDist);
xlim([-inf inf]);
ylim([0 0.7]);
title(sprintf("Distribution of Letter Height/Eccentricity (%s) (%s)", ...
char(csvOutput{1,3}), char(csvOutput{1,4})), 'FontSize', 12);
xlabel("Letter Height (degrees)/Eccentricity (degrees) (Logarithmic Scale)", ...
            'FontSize', 10);
% set(gca,'xscale','log');
% Axis labels and title
ylabel("Number of Occurences (Normalized to Probability)", 'FontSize', 10);
legend('show', 'Location', 'best');
box on; grid on;

% Saving point slope and log-log plots as png
fFolderName = strcat(string(csvOutput{1,3}), "_", string(csvOutput{1,4}));
folderName = fullfile(pwd, 'Analysis Results', 'Plots', string(csvOutput{1,2}), ...
    fFolderName);
fileName = sprintf('%s%s', string(csvOutput{1,3}), '_point_slope.png');
saveas(pointSlopeGraph, fullfile(folderName, fileName));
fileName = sprintf('%s%s', string(csvOutput{1,3}), '_log_log_plot.png');
saveas(logPlot, fullfile(folderName, fileName));
fileName = sprintf('%s%s', string(csvOutput{1,3}), '_combined_histogram.png');
saveas(combinedDist, fullfile(folderName, fileName));

csvName = fullfile(pwd, 'Analysis Results', 'Compiled_Parameters.csv');
rawCsvName = fullfile(pwd, 'Analysis Results', 'Analysis_Summary_Raw.csv');
writeToCsv(csvOutput, rawCsvOutput, rawCsvName, csvName);
% formatSpec = '\n%s, %s, %s, %s, %4.3f, %5.4f, %10.9f, %s, %4.3f, %5.4f, %10.9f, %s, %4.3f, %5.4f, %10.9f, %s, %4.3f, %5.4f, %10.9f, %s, %4.3f, %5.4f, %10.9f, %s, %4.3f, %5.4f, %10.9f, %s, %4.3f, %5.4f, %10.9f';
% fileID = fopen(csvName, 'a+');
% fprintf(fileID, formatSpec, csvOutput{1,:});
% fclose(fileID);
