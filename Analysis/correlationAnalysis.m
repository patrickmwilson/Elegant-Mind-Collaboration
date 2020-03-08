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
cp9 = figure();
cc39 = figure();
cpocp = figure();

names = strings(0);
params = [];
errors = [];

count = 1;
for i = 2:size(table,1)
    name = string(table{i,3});
%     t1Slope = str2double(table{i,5});
%     cpSlope = str2double(table{i,9});
%     cpoSlope = str2double(table{i,13});
%     cc9Slope = str2double(table{i,17});
%     cc3Slope = str2double(table{i,21});
%     icSlope = str2double(table{i,25});

    for j = 1:7
        currParams(j) = str2double(table{i,(((j-1)*4)+5)});
        currErrors(j) = str2double(table{i,(((j-1)*4)+7)});
    end
    
%     currParams(1) = str2double(table{i,5});
%     currParams(2) = str2double(table{i,9});
%     currParams(3) = str2double(table{i,13});
%     currParams(4) = str2double(table{i,17});
%     currParams(5) = str2double(table{i,21});
%     currParams(6) = str2double(table{i,25});
%     currParams(7) = str2double(table{i,29});
%     
%     currErrors(1) = str2double(table{i,7});
%     currErrors(2) = str2double(table{i,11});
%     currErrors(3) = str2double(table{i,15});
%     currErrors(4) = str2double(table{i,19});
%     currErrors(5) = str2double(table{i,23});
%     currErrors(6) = str2double(table{i,27});
%     currErrors(6) = str2double(table{i,31});
    
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

%     t1Slope = str2double(table{i,5});
%     cpSlope = str2double(table{i,9});
%     cpoSlope = str2double(table{i,13});
%     cc9Slope = str2double(table{i,17});
%     cc3Slope = str2double(table{i,21});
%     icSlope = str2double(table{i,25});

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
            
            scatter(params(i,xI), params(i,yI), 10, [0 0 1], ...
                "filled", 'HandleVisibility', 'off');
            
            text((params(i,xI)*1.01), (params(i,yI)*1.01), names(i), 'FontSize', 8);

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

for i = 1:length(figures)
    figure(figures(i));
    xlim([0, (max(params(:,xIndex(i)))*1.3)]);
    ylim([0 (max(params(:,yIndex(i)))*1.3)]);
    title(titles(i));
    xlabel(xLabels(i));
    ylabel(yLabels(i));
    grid on;
    box on;

    xvals = linspace(0,(max(params(:,xIndex(i)))*2));
    yvals = linspace(0,(max(params(:,yIndex(i)))*2));

    plot(xvals,yvals,'Color', [1 0 0], 'LineWidth', 0.8, 'HandleVisibility', ...
        'off');
    
    folderName = fullfile(pwd, 'Analysis Results', 'Correlation Analysis'); 
    mkdir(folderName);
    fileName = sprintf('%s%s', filenames(i), '.png');
    saveas(figures(i), fullfile(folderName, fileName));
end



