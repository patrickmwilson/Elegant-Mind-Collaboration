% correlationAnalysis

close all; 

% Suppress warnings about modified csv headers & directory existing
warning('off','MATLAB:table:ModifiedAndSavedVarnames');
warning('off','MATLAB:MKDIR:DirectoryExists');

% Add helper functions to path
libPath = fullfile(pwd, 'lib');
addpath(libPath); 

% Input dialogue: Plot subject names?
dataAnswer = questdlg('Add subject names?', '', 'Yes', 'No', 'Cancel', 'Yes');
graphNames = (char(dataAnswer(1)) == 'Y');

% Read in fit parameters to struct, make output folder
fileName = fullfile(pwd, 'one_parameter_statistics.csv');
subjects = table2struct(readtable(fileName));
folderName = fullfile(pwd, 'Plots', 'Correlation'); 
mkdir(folderName);

fc = figure();
cp = figure();
cc = figure();
l3 = figure();

% Struct to store info about each figure
figInfo = struct('fig', NaN, 'title', NaN, 'xlab', NaN, 'ylab', NaN, ...
    'filename', NaN, 'xlim', NaN, 'ylim', NaN);
figInfo = repmat(figInfo, 1, 4);

figInfo(1).fig = fc;
figInfo(1).title = "Fully Crowded vs. Isolated Character";
figInfo(1).xlab = "Isolated Character Slope";
figInfo(1).ylab = "Fully Crowded Slope";
figInfo(1).filename = "FCvIC.png";
figInfo(1).xlim = 0;
figInfo(1).ylim = 0;

figInfo(2).fig = l3;
figInfo(2).title = "Three Lines vs. Isolated Character";
figInfo(2).xlab = "Isolated Character Slope";
figInfo(2).ylab = "Three Lines Slope";
figInfo(2).filename = "3LvIC.png";
figInfo(2).xlim = 0;
figInfo(2).ylim = 0;

figInfo(3).fig = cp;
figInfo(3).title = "Crowded Periphery vs. Isolated Character";
figInfo(3).xlab = "Isolated Character Slope";
figInfo(3).ylab = "Crowded Periphery Slope";
figInfo(3).filename = "CPvIC.png";
figInfo(3).xlim = 0;
figInfo(3).ylim = 0;

figInfo(4).fig = cc;
figInfo(4).title = "Crowded Center vs. Isolated Character";
figInfo(4).xlab = "Isolated Character Slope";
figInfo(4).ylab = "Crowded Center Slope";
figInfo(4).filename = "CCvIC.png";
figInfo(4).xlim = 0;
figInfo(4).ylim = 0;

% Struct to hold info about each protocol
info = struct('name', NaN, 'color', NaN, 'yIndex', NaN, 'figInfoIdx', NaN);
info = repmat(info, 1, 9);

info(1).name = "Fully Crowded";
info(1).color = [0 0.8 0.8];
info(1).xName = 'ic';
info(1).yName = 'fc';
info(1).figInfoIdx = 1;

info(2).name = "Three Lines";
info(2).color = [0.86 0.27 0.07]; %!!
info(2).xName = 'ic';
info(2).yName = 'l3';
info(2).figInfoIdx = 2;

info(3).name = "Crowded Periphery 9x9";
info(3).color = [0.83 0.86 .035];
info(3).xName = 'ic';
info(3).yName = 'cp9';
info(3).figInfoIdx = 3;

info(4).name = "Crowded Periphery 7x7";
info(4).color = [0.69 0.57 .41]; 
info(4).xName = 'ic';
info(4).yName = 'cp7';
info(4).figInfoIdx = 3;

info(5).name = "Crowded Periphery 5x5";
info(5).color = [0 0.8 0.8]; 
info(5).xName = 'ic';
info(5).yName = 'cp5';
info(5).figInfoIdx = 3;

info(6).name = "Crowded Periphery";
info(6).color = [0.9 0.3 0.9];
info(6).xName = 'ic';
info(6).yName = 'cp';
info(6).figInfoIdx = 3;

info(7).name = "Crowded Periphery Outer";
info(7).color = [0.5 0 0.9];
info(7).xName = 'ic';
info(7).yName = 'cpo';
info(7).figInfoIdx = 3;

info(8).name = "Crowded Center 9x9";
info(8).color = [0 0.1 1];
info(8).xName = 'ic';
info(8).yName = 'cc9';
info(8).figInfoIdx = 4;

info(9).name = "Crowded Center 3x3";
info(9).color = [0.4 0.8 0.5];
info(9).xName = 'ic';
info(9).yName = 'cc3';
info(9).figInfoIdx = 4;

txt = '%s: y = %4.2fx, R = %4.2f';

for i = 1:length(info)
    name = info(i).name;
    color = info(i).color;
    xId = info(i).xName;
    yId = info(i).yName;
    figIdx = info(i).figInfoIdx;
    fig = figInfo(figIdx).fig;
    
    data = []; subject_names = []; yerr = []; xerr = [];
    
    for j = 1:length(subjects)
        subject_name = subjects(j).name;
        if(strcmp(subject_name,'Averaged'))
            continue;
        end
        
        x = subjects(j).(strcat(xId,'_slope'));
        y = subjects(j).(strcat(yId,'_slope'));
        
        if(isnan(x) || isnan(y))
            continue;
        end
        
        xchi = subjects(j).(strcat(xId,'_reduced_chi_sq'));
        ychi = subjects(j).(strcat(yId,'_reduced_chi_sq'));
        
        negxerr = x - subjects(j).(strcat(xId,'_neg_error'));
        posxerr = subjects(j).(strcat(xId,'_pos_error')) - x;
        err = [negxerr posxerr];
        xerr = [xerr; err];
        
        negyerr = y - subjects(j).(strcat(yId,'_neg_error'));
        posyerr = subjects(j).(strcat(yId,'_pos_error')) - y;
        err = [negyerr posyerr];
        yerr = [yerr; err];
        
        vals = [x y xchi ychi];
        
        data = [data; vals];
        subject_names = [subject_names subject_name];
    end
    
    if ~isempty(data)
        figure(fig);
        hold on;
        
        errorbar(data(:,1),data(:,2), ...
            yerr(:,1),yerr(:,2), ...
            xerr(:,1),xerr(:,2), ...
            '.', 'HandleVisibility', 'off', ...
            'Color', [0.43 0.43 0.43], ...
            'CapSize', 0);
        
        scatter(data(:,1), data(:,2), 25, color, "filled", ...
            'HandleVisibility', 'off');
        
        if graphNames
            text((data(1,:).*1.01), (data(2,:).*1.01), subject_names, ...
                'FontSize', 8);
        end
        
        % Extract x & y values from data matrix
        xvals = data(:,1)'; yvals = data(:,2)';
    
        % Variance is estimated as the standard error, then squared
        variance = (data(:,3)' + data(:,4)')./2;
        variance = variance.^2;
    
        % Slight data shift to avoid division by zero
        variance(variance == 0) = 0.000001;
    
        % Weights are the inverse of (standard error)^2
        w = 1./variance;
    
        % Chi^2 equation to be minimized
        f = @(x,xvals,yvals,w)sum((w.*((yvals-(xvals.*x))).^2));
        fun = @(x)f(x,xvals,yvals,w);
        
        options = optimset('Display','iter');
        
        [slope, chi_sq] = fminbnd(fun,0,15,options);

        R = corr2(data(:,1),data(:,2));
        
        xlin = linspace(0,(max(data(:,1))*2));
        ylin = xlin.*slope;
        
        plot(xlin,ylin,'Color', color, 'LineWidth', 0.8, 'DisplayName', ...
            sprintf(txt,name,slope,R));
        
        xlimit = max(data(:,1))*1.3;
        ylimit = max(data(:,2))*1.3;
        if xlimit > figInfo(figIdx).xlim
            figInfo(figIdx).xlim = xlimit;
        end
        if ylimit > figInfo(figIdx).ylim
            figInfo(figIdx).ylim = ylimit;
        end
    end
    
end

% Format and save each figure
for i=1:size(figInfo,2)
    formatFigure(figInfo(i).fig, ...
        [0 figInfo(i).xlim], ...
        [0 figInfo(i).ylim], ...
        figInfo(i).xlab, ...
        figInfo(i).ylab, ...
        figInfo(i).title, ...
        false);
    
    saveas(figInfo(i).fig, fullfile(folderName, figInfo(i).filename));
end

