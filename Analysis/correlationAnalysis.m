% Correlation Analysis
% Created by Patrick Wilson on 1/20/2020
% Github.com/patrickmwilson
% Created for the Elegant Mind Collaboration at UCLA 
% with Professor Katsushi Arisaka
% Copyright � 2020 Elegant Mind Collaboration. All rights reserved.

% Suppress warnings about modified csv headers & directory existing
warning('off','MATLAB:table:ModifiedAndSavedVarnames');
warning('off','MATLAB:MKDIR:DirectoryExists');
%Add helper functions to path (readCsv.m)
functionPath = fullfile(pwd, 'lib');
addpath(functionPath); 

close all; 

dataAnswer = questdlg('Add subject names?', '', 'Yes', 'No', 'Cancel', 'Yes');
graphNames = (char(dataAnswer(1)) == 'Y');

dotColor = [0 0.1 1];

table = readCsv('Compiled');

t1 = figure();
cp = figure();
cpo = figure();
cc9 = figure();
cc3 = figure();
cp9 = figure();
cc39 = figure();
cpocp = figure();

names = strings(0);
params = [];
errors = [];

count = 1;
for i = 2:size(table,1)
    name = string(table{i,3});

    for j = 1:7
        currParams(j) = table{i,(((j-1)*4)+5)};
        currErrors(j) = table{i,(((j-1)*4)+7)};
    end
    
    currParams(isnan(currParams)) = 0;
    currErrors(isnan(currErrors)) = 0;
    if(isempty(names) || ~any(strcmp(names(1,:),name)))
        index = count;
        count = count+1;
        names(index) = name;
        params(index,:) = currParams;
        errors(index,:) = currErrors;
    else
        index = find(names == name);
        div = (1*(currParams(1,:) ~= 0))+1;
        params(index,:) = (params(index,:) + currParams)./div;
        div = (1*(currErrors(1,:) ~= 0))+1;
        errors(index,:) = (errors(index,:) + currErrors)./div;
    end
end

figures = [t1,cp,cpo,cc9,cc3,cp9,cc39,cpocp];

yIndex = [1, 2, 3, 4, 5, 7, 4, 3];
xIndex = [6, 6, 6, 6, 6, 6, 5, 2];

for j = 1:length(figures)
    
    xI = xIndex(j);
    yI = yIndex(j);
    
    for i = 1:size(params,1)
        if((params(i,yI) ~= 0) && (params(i,xI) ~= 0))
            
            figure(figures(j));
            hold on;
            errorbar(params(i,xI), params(i,yI), errors(i,xI), ...
                'horizontal','.', 'HandleVisibility', 'off', ...
                'Color', [0.43 0.43 0.43], 'CapSize', 0);
            
            errorbar(params(i,xI), params(i,yI), errors(i,yI), ...
                'vertical','.', 'HandleVisibility', 'off', ...
                'Color', [0.43 0.43 0.43], 'CapSize', 0);
            
            scatter(params(i,xI), params(i,yI), 25, dotColor, ...
                "filled", 'HandleVisibility', 'off');
            
            if graphNames
                text((params(i,xI)*1.01), (params(i,yI)*1.01), names(i), 'FontSize', 8);
            end

        end
    end
end


titles = ["T1 slope vs. IC slope", ...
    "Crowded Periphery Center slope vs. IC slope", ...
    "Crowded Periphery outer slope vs. IC slope", ...
    "Crowded Center 9x9 slope vs. IC slope", ...
    "Crowded Center 3x3 slope vs. IC slope", ...
    "Crowded Periphery 9x9 slope vs. IC slope", ...
    "Crowded Center 9x9 slope vs. Crowded Center 3x3 slope", ...
    "Crowded Periphery Outer slope vs. Crowded Periphery Center slope"];
yLabels = ["T1 slope", ...
    "CPC slope", ...
    "CPO slope", ...
    "CC9x9 slope", ...
    "CC3x3 slope", ...
    "CP9x9 slope", ...
    "CC9x9 Slope", ...
    "CPO Slope"];
xLabels = ["IC slope", ...
    "IC slope", ...
    "IC slope", ...
    "IC slope", ...
    "IC slope", ...
    "IC slope", ...
    "CC3x3 Slope", ...
    "CPC Slope"];

filenames = [ "T1vsIC", "CPCvsIC", "CPOvsIC", "CC9x9vsIC", "CC3x3vsIC", ...
    "CP9x9vsIC", "CC9x9vsCC3x3", "CPOvsCPC"];

params(params == 0) = NaN;
for i = 1:length(figures)
    figure(figures(i));
    xlim([0, (max(params(:,xIndex(i)))*1.3)]);
    ylim([0 (max(params(:,yIndex(i)))*1.3)]);
    title(titles(i));
    xlabel(xLabels(i));
    ylabel(yLabels(i));
    grid on;
    box on;
    
    yavg = nanmean(params(:,yIndex(i)));
    xavg = nanmean(params(:,xIndex(i)));
    
    slope = yavg/xavg;

    xvals = linspace(0,(max(params(:,xIndex(i)))*2));
    yvals = xvals.*slope;

    plot(xvals,yvals,'Color', [1 0 0], 'LineWidth', 0.8, 'HandleVisibility', ...
        'off');
    
    folderName = fullfile(pwd, 'Analysis Results', 'Correlation Analysis'); 
    mkdir(folderName);
    fileName = sprintf('%s%s', filenames(i), '.png');
    saveas(figures(i), fullfile(folderName, fileName));
end

uiwait(helpdlg('Click OK to finish and close figures'));



