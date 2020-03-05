% Correlation Analysis
% Created by Patrick Wilson on 1/20/2020
% Github.com/patrickmwilson
% Created for the Elegant Mind Collaboration at UCLA 
% with Professor Katsushi Arisaka
% Copyright © 2020 Elegant Mind Collaboration. All rights reserved.

close all;

folder = fullfile(pwd, 'Analysis Results');
filename = fullfile(folder, "Compiled_Parameters.csv");

table = readtable(filename);

t1 = figure();
cp = figure();
cpo = figure();
cc9 = figure();
cc3 = figure();
cc39 = figure();
cpocp = figure();


figures = [t1,cp,cpo,cc9,cc3,cc39,cpocp];
names = strings(0);
nameNumbers = [];
params = [];
count = 1;
for i = 2:size(table,1)
    name = string(table{i,3});
%     t1Slope = str2double(table{i,5});
%     cpSlope = str2double(table{i,9});
%     cpoSlope = str2double(table{i,13});
%     cc9Slope = str2double(table{i,17});
%     cc3Slope = str2double(table{i,21});
%     icSlope = str2double(table{i,25});
    
    currParams(1) = str2double(table{i,5});
    currParams(2) = str2double(table{i,9});
    currParams(3) = str2double(table{i,13});
    currParams(4) = str2double(table{i,17});
    currParams(5) = str2double(table{i,21});
    currParams(6) = str2double(table{i,25});
    
    if(isempty(names) || ~any(strcmp(names(1,:),name)))
        index = count;
        count = count+1;
        names(index) = name;
        params(index,:) = currParams;
    else
        index = find(names == name);
        div = (~isnan(params(index,:))) + (~isnan(currParams(1,:)));
        params(index,:) = (params(index,:) + currParams)/div;
    end
end

yIndex = [1, 2, 3, 4, 5, 4, 3];
xIndex = [6, 6, 6, 6, 6, 5, 2];

for i = 1:size(params,1)
    for j = 1:length(figures)
        xI = xIndex(j);
        yI = yIndex(j);
        if ~isnan(params(i,yI))
            hold on;
            figure(figures(j));
            scatter(params(i,xI), params(i,yI), 10, [0 0 1], ...
                "filled", 'HandleVisibility', 'off');
            
%             dx = 0.005; dy = 0.005; % displacement so the text does not overlay the data points
            text((params(i,xI)*1.01), params(i,yI), names(i), 'FontSize', 8);
            
        end
    end
end

% t1 = figure();
% cp = figure();
% cpo = figure();
% cc9 = figure();
% cc3 = figure();

titles = ["T1 slope vs. IC slope", "Crowded Periphery Center slope vs. IC slope", ...
    "Crowded Periphery outer slope vs. IC slope", ...
    "Crowded Center 9x9 slope vs. IC slope", ...
    "Crowded Center 3x3 slope vs. IC slope", ...
    "Crowded Center 9x9 slope vs. Crowded Center 3x3 slope", ...
    "Crowded Periphery Outer slope vs. Crowded Periphery Center slope"];
yLabels = ["T1 slope", ...
    "Crowded Periphery Center slope", ...
    "Crowded Periphery outer slope", ...
    "Crowded Center 9x9 slope", ...
    "Crowded Center 3x3 slope", ...
    "Crowded Center 9x9 Slope", ...
    "Crowded Periphery Outer Slope"];
xLabels = ["IC slope", ...
    "IC slope", ...
    "IC slope", ...
    "IC slope", ...
    "IC slope", ...
    "Crowded Center 3x3 Slope", ...
    "Crowded Periphery Center Slope"];

for i = 1:length(figures)
    figure(figures(i));
    xlim([0, (max(params(:,xIndex(i)))*1.3)]);
    ylim([0 (max(params(:,yIndex(i)))*1.3)]);
    title(titles(i));
    xlabel(xLabels(i));
    ylabel(yLabels(i));
    grid on;
    box on;
%     xvals = 0:1e-6:(max(params(:,xIndex(i)))*2);
%     yvals = 0:1e-6:(max(params(:,yIndex(i)))*2);
    xvals = linspace(0,(max(params(:,xIndex(i)))*2));
    yvals = linspace(0,(max(params(:,yIndex(i)))*2));
%     yfit = xvals
    plot(xvals,yvals,'Color', [1 0 0], 'LineWidth', 0.8, 'HandleVisibility', ...
        'off');
end

% for i = 1:length(figures)
%     xMax = (max(params(:,i))*1.3);
%     divs = [1, 
%     for j = 1:6
%         xStart = 
%         line(
%     end
% end


