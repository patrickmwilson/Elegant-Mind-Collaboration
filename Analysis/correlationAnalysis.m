% Correlation Analysis
% Created by Patrick Wilson on 1/20/2020
% Github.com/patrickmwilson
% Created for the Elegant Mind Collaboration at UCLA 
% with Professor Katsushi Arisaka
% Copyright � 2020 Elegant Mind Collaboration. All rights reserved.

close all; 

% Suppress warnings about modified csv headers & directory existing
warning('off','MATLAB:table:ModifiedAndSavedVarnames');
warning('off','MATLAB:MKDIR:DirectoryExists');

% Add helper functions to path
libPath = fullfile(pwd, 'lib');
addpath(libPath); 

dataAnswer = questdlg('Add subject names?', '', 'Yes', 'No', 'Cancel', 'Yes');
graphNames = (char(dataAnswer(1)) == 'Y');

fileName = fullfile(pwd, 'Analysis_Results', 'Compiled_Parameters.csv');
table = readtable(fileName);

subjects = cleanTable(table);

folderName = fullfile(pwd, 'Analysis_Results', 'Correlation_Analysis'); 
mkdir(folderName);

fc = figure();
cp = figure();
cc = figure();

figInfo = struct('fig', NaN, 'title', NaN, 'xlab', NaN, 'ylab', NaN, ...
    'filename', NaN, 'xlim', NaN, 'ylim', NaN);
figInfo = repmat(figInfo, 1, 3);

figInfo(1).fig = fc;
figInfo(1).title = "Fully Crowded vs. Isolated Character";
figInfo(1).xlab = "Isolated Character Slope";
figInfo(1).ylab = "Fully Crowded Slope";
figInfo(1).filename = "FCvIC.png";
figInfo(1).xlim = 0;
figInfo(1).ylim = 0;

figInfo(2).fig = cp;
figInfo(2).title = "Crowded Periphery vs. Isolated Character";
figInfo(2).xlab = "Isolated Character Slope";
figInfo(2).ylab = "Crowded Periphery Slope";
figInfo(2).filename = "CPvIC.png";
figInfo(2).xlim = 0;
figInfo(2).ylim = 0;

figInfo(3).fig = cc;
figInfo(3).title = "Crowded Center vs. Isolated Character";
figInfo(3).xlab = "Isolated Character Slope";
figInfo(3).ylab = "Crowded Center Slope";
figInfo(3).filename = "CCvIC.png";
figInfo(3).xlim = 0;
figInfo(3).ylim = 0;

info = struct('name', NaN, 'color', NaN, 'yIndex', NaN, 'figInfoIdx', NaN);
info = repmat(info, 1, 6);

info(1).name = "Fully Crowded";
info(1).color = [0 0.8 0.8];
info(1).xName = 'ic';
info(1).yName = 'fc';
info(1).figInfoIdx = 1;

info(2).name = "Crowded Periphery 9x9";
info(2).color = [0.83 0.86 .035];
info(2).xName = 'ic';
info(2).yName = 'cp9';
info(2).figInfoIdx = 2;

info(3).name = "Crowded Periphery";
info(3).color = [0.9 0.3 0.9];
info(3).xName = 'ic';
info(3).yName = 'cp';
info(3).figInfoIdx = 2;

info(4).name = "Crowded Periphery Outer";
info(4).color = [0.5 0 0.9];
info(4).xName = 'ic';
info(4).yName = 'cpo';
info(4).figInfoIdx = 2;

info(5).name = "Crowded Center 9x9";
info(5).color = [0 0.1 1];
info(5).xName = 'ic';
info(5).yName = 'cc9';
info(5).figInfoIdx = 3;

info(6).name = "Crowded Center 3x3";
info(6).color = [0.4 0.8 0.5];
info(6).xName = 'ic';
info(6).yName = 'cc3';
info(6).figInfoIdx = 3;

txt = '%s: y = %4.2fx, R = %4.2f';

for i = 1:length(info)
    name = info(i).name;
    color = info(i).color;
    xId = info(i).xName;
    yId = info(i).yName;
    figIdx = info(i).figInfoIdx;
    fig = figInfo(figIdx).fig;
    
    data = []; subject_names = [];
    
    for j = 1:length(subjects)
        subject_name = subjects(j).name;
        x = subjects(j).(strcat(xId,'_slope'));
        y = subjects(j).(strcat(yId,'_slope'));
        
        if(isnan(x) || isnan(y))
            continue;
        end
        
        xerr = subjects(j).(strcat(xId,'_error'));
        yerr = subjects(j).(strcat(yId,'_error'));
        vals = [x;y;xerr;yerr];
        
        data = [data vals];
        subject_names = [subject_names subject_name];
    end
    
    if ~isempty(data)
        figure(fig);
        hold on;
        
        errorbar(data(1,:), data(2,:), data(3,:), 'horizontal','.', ...
            'HandleVisibility', 'off', 'Color', [0.43 0.43 0.43], ...
            'CapSize', 0);
        
        errorbar(data(1,:), data(2,:), data(4,:), 'vertical','.', ...
            'HandleVisibility', 'off', 'Color', [0.43 0.43 0.43], ...
            'CapSize', 0);
        
        scatter(data(1,:), data(2,:), 25, color, "filled", ...
            'HandleVisibility', 'off');
        
        if graphNames
            text((data(1,:).*1.01), (data(2,:).*1.01), subject_names, ...
                'FontSize', 8);
        end
        
        x_mu = mean(data(1,:));
        y_mu = mean(data(2,:));
        
        slope = y_mu/x_mu;
        R = corr2(data(1,:),data(2,:));
        
        xlin = linspace(0,(max(data(1,:))*2));
        ylin = xlin.*slope;
        
        plot(xlin,ylin,'Color', color, 'LineWidth', 0.8, 'DisplayName', ...
            sprintf(txt,name,slope,R));
        
        xlimit = max(data(1,:))*1.3;
        ylimit = max(data(2,:))*1.3;
        if xlimit > figInfo(figIdx).xlim
            figInfo(figIdx).xlim = xlimit;
        end
        if ylimit > figInfo(figIdx).ylim
            figInfo(figIdx).ylim = ylimit;
        end
    end
    
end

for i=1:size(figInfo,2)
    formatFigure(figInfo(i).fig, [0 figInfo(i).xlim], [0 figInfo(i).ylim], ...
        figInfo(i).xlab, figInfo(i).ylab, figInfo(i).title, false);
    saveas(figInfo(i).fig, fullfile(folderName, figInfo(i).filename));
end

