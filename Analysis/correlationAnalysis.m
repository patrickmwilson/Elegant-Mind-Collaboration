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

fileName = fullfile(pwd, 'Analysis_Results', 'Compiled_Parameters.csv');
table = readtable(fileName);

folderName = fullfile(pwd, 'Analysis_Results', 'Correlation_Analysis'); 
mkdir(folderName);

dataAnswer = questdlg('Add subject names?', '', 'Yes', 'No', 'Cancel', 'Yes');
graphNames = (char(dataAnswer(1)) == 'Y');

dotColor = [0 0.1 1];

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
    
    currParams = [];
    currErrors = [];

    for j = 1:7
        avgIndex = ((j-1)*4)+5;
        errIndex = ((j-1)*4)+7;
        currParams(j) = table{i,avgIndex};
        currErrors(j) = table{i,errIndex};
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

figs = [t1,cp,cpo,cc9,cc3,cp9,cc39,cpocp];

txt = 'Correlation Coefficient: %4.2f';

yIndex = [1, 2, 3, 4, 5, 7, 4, 3];
xIndex = [6, 6, 6, 6, 6, 6, 5, 2];

for j = 1:length(figs)
    
    xI = xIndex(j);
    yI = yIndex(j);

    x = [];
    y = [];
    xe = [];
    ye = [];
    n = [];
    
    for i = 1:size(params,1)
        if((params(i,yI) ~= 0) && (params(i,xI) ~= 0))

            x = [x params(i,xI)];
            y = [y params(i,yI)];
            xe = [xe errors(i,xI)];
            ye = [ye errors(i,yI)];
            n = [n names(i)];
            
            figure(figs(j));
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
    if length(x) > 0
        errorbar(x, y, xe, 'horizontal','.', 'HandleVisibility', 'off', ...
            'Color', [0.43 0.43 0.43], 'CapSize', 0);
        errorbar(x, y, ye, 'vertical','.', 'HandleVisibility', 'off', ...
            'Color', [0.43 0.43 0.43], 'CapSize', 0);
        scatter(x, y, 25, dotColor, "filled", 'HandleVisibility', 'off');

        if graphNames
            text((x.*1.01), (y.*1.01), n, 'FontSize', 8);
        end

        R = corr2(x,y);

        xavg = mean(x);
        yavg = mean(y);

        slope = yavg/xavg;

        xvals = linspace(0,(max(x)*2));
        yvals = xvals.*slope;

        plot(xvals,yvals,'Color', [1 0 0], 'LineWidth', 0.8, 'DisplayName', ...
            sprintf(txt,R));

        formatFigure(figs(j), [0 max(x)*1.3], [0 max(y)*1.3], xLabels(j), ...
            yLabels(j), titles(j), false);

        fileName = sprintf('%s%s', filenames(j), '.png');
        saveas(figs(j), fullfile(folderName, fileName));
    end
end

uiwait(helpdlg("Click OK to finish and close figures"));

close all;



