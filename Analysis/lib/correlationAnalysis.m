% correlationAnalysis
%
% Produces plots assessing the correlation between a subject's performance
% on different protocols. The parameters used are extracted from the
% 'one_parameter_statistics.csv' spreadsheet.

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
fileName = fullfile(pwd, 'Parameters', 'one_parameter_statistics.csv');
subjects = table2struct(readtable(fileName));
folderName = fullfile(pwd, 'Plots', 'Correlation'); 
mkdir(folderName);

fc = figure();
cp = figure();
cc = figure();

% Struct to store info about each figure
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
info(2).figInfoIdx = 1;

info(3).name = "Crowded Periphery 9x9";
info(3).color = [0.83 0.86 .035];
info(3).xName = 'ic';
info(3).yName = 'cp9';
info(3).figInfoIdx = 2;

info(4).name = "Crowded Periphery 7x7";
info(4).color = [0.69 0.57 .41]; 
info(4).xName = 'ic';
info(4).yName = 'cp7';
info(4).figInfoIdx = 2;

info(5).name = "Crowded Periphery 5x5";
info(5).color = [0 0.8 0.8]; 
info(5).xName = 'ic';
info(5).yName = 'cp5';
info(5).figInfoIdx = 2;

info(6).name = "Crowded Periphery Center";
info(6).color = [0.9 0.3 0.9];
info(6).xName = 'ic';
info(6).yName = 'cp';
info(6).figInfoIdx = 2;

info(7).name = "Crowded Periphery Inner";
info(7).color = [0.86 0.27 0.07];
info(7).xName = 'ic';
info(7).yName = 'cpi';
info(7).figInfoIdx = 2;

info(8).name = "Crowded Periphery Outer";
info(8).color = [0.5 0 0.9];
info(8).xName = 'ic';
info(8).yName = 'cpo';
info(8).figInfoIdx = 2;

info(9).name = "Crowded Center 9x9";
info(9).color = [0 0.1 1];
info(9).xName = 'ic';
info(9).yName = 'cc9';
info(9).figInfoIdx = 3;

info(10).name = "Crowded Center 3x3";
info(10).color = [0.4 0.8 0.5];
info(10).xName = 'ic';
info(10).yName = 'cc3';
info(10).figInfoIdx = 3;

txt = '%s: y = %4.2fx, R = %4.2f';

% Loop through each protocol separately
for i = 1:length(info)
    name = info(i).name; % protocol name
    color = info(i).color; % plot color
    xId = info(i).xName; % x-axis data id
    yId = info(i).yName; % y-axis data id
    figIdx = info(i).figInfoIdx; % figure to be plotted on
    fig = figInfo(figIdx).fig;
    
    data = []; subject_names = []; yerr = []; xerr = [];
    
    % Loop through each subject to see if they have parameters for both
    % protocols currently being plotted
    for j = 1:length(subjects)
        % Extract subject id
        subject_name = subjects(j).name;
        if(strcmp(subject_name,'Averaged'))
            continue; % Skip averaged sets of data
        end
        
        % Extract slope parameters
        x = subjects(j).(strcat(xId,'_slope'));
        y = subjects(j).(strcat(yId,'_slope'));
        
        if(isnan(x) || isnan(y))
            continue; % Skip if the subject doesn't have a slope parameter for both protocols
        end
        
        % Extract reduced Chi^2 for weighting of least squares
        xchi = subjects(j).(strcat(xId,'_reduced_chi_sq'));
        ychi = subjects(j).(strcat(yId,'_reduced_chi_sq'));
        
        % Extract error of slope parameter for error bar
        negxerr = x - subjects(j).(strcat(xId,'_neg_error'));
        posxerr = subjects(j).(strcat(xId,'_pos_error')) - x;
        err = [negxerr posxerr];
        xerr = [xerr; err]; % Append x error data
        
        negyerr = y - subjects(j).(strcat(yId,'_neg_error'));
        posyerr = subjects(j).(strcat(yId,'_pos_error')) - y;
        err = [negyerr posyerr];
        yerr = [yerr; err]; % Append y error data
        
        % Append slope and reduced Chi^2 to accumulated matrix
        vals = [x y xchi ychi];
        data = [data; vals];
        subject_names = [subject_names string(subject_name)];
    end
    
    % Skip plotting unless there is data to plot
    if ~isempty(data)
        figure(fig);
        hold on;
        
        % Plot error bars 
        errorbar(data(:,1),data(:,2), ...
            yerr(:,1),yerr(:,2), ...
            xerr(:,1),xerr(:,2), ...
            '.', 'HandleVisibility', 'off', ...
            'Color', [0.43 0.43 0.43], ...
            'CapSize', 0);
        
        % Scatter slope parameters
        scatter(data(:,1), data(:,2), 25, color, "filled", ...
            'HandleVisibility', 'off');
        
        % Add subject names as text to the graph
        if graphNames
            text((data(:,1).*1.01), (data(:,2).*1.01), subject_names, ...
                'FontSize', 8);
        end
        
        % Extract x & y values from data matrix
        xvals = data(:,1)'; yvals = data(:,2)';
    
        % Reduced Chi^2 are used as weights for linear regression
        w = (data(:,3)' + data(:,4)')./2;
        w = w.^2;
    
        % Slight data shift to avoid division by zero
        w(w == 0) = 0.000001;
        w = 1./w;
    
        % Weighted least sum of squares equation to be minimized
        f = @(x,xvals,yvals,w)sum((w.*((yvals-(xvals.*x))).^2));
        fun = @(x)f(x,xvals,yvals,w);
        
        % fminbnd optimizes the slope parameter to minimize the sum of the
        % WLSS equation
        options = optimset('Display','iter');
        [slope, chi_sq] = fminbnd(fun,0,15,options);
        
        % Calculate correlation coefficient for the x and y data
        R = corr2(data(:,1),data(:,2));
        
        % Generate plottable line from slope parameter
        xlin = linspace(0,(max(data(:,1))*2));
        ylin = xlin.*slope;
        
        % Plot regression line
        plot(xlin,ylin,'Color', color, 'LineWidth', 0.8, 'DisplayName', ...
            sprintf(txt,name,slope,R));
        
        % Calculate the x and y-lim for the figure as 1.3* the maximum
        % value plotted for either. Set the figure's limit to this value if
        % it is greater than the current limit stored in the info struct
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
        false, ...
        'best');
    
    saveas(figInfo(i).fig, fullfile(folderName, figInfo(i).filename));
end

