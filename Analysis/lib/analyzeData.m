% analyzeData
%
% Minimizes Chi^2 for y = ax and y = ax+b fits, produces plots of Chi^2 vs
% these parameters, produces a scatterplot of normalized letter height vs.
% eccentricity and a histogram of that distribution. Fills parameter output
% structs. Accepts the data and rawData matrices, protocol info struct,
% parameter output structs, figure handles for the y = ax and y = ax+b
% linear plots, and booleans indicating whether to save plots, and whether
% the data is averaged over and small eccentricity observations have been
% excluded from crowded center.
function [oneParamOutput,twoParamOutput] = analyzeData(data,rawData,info,oneParamOutput,twoParamOutput,oneParamGraph,twoParamGraph,savePlots,trimCC,averageOver)
    
    % Extract protocol information from the info struct
    name = info.name; id = info.id;
    color = info.color; discreteCol = info.discreteCol;
    
    % For all data except anstis, produce y/x vs. x graphs and y/x
    % histograms
    if(~strcmp(id,'a'))
        
        avg = mean(data(:,2));
        sd = std(data(:,2));
        N = size(data,1);
        
        % y/x vs. x plot
        divided = figure();
        dividedFig(data, rawData, avg, sd, N, name, color, divided);
        
        % y/x histogram
        distribution = figure();
        histFig(rawData, avg, sd, N, name, color, distribution);
    end
    
    % Convert the normalized data back to the linear scale by multiplying
    % each value by its respective eccentricity value
    data(:,2) = data(:,2).*data(:,1);
    
    % Setting direction of error bars. Fully Crowded and Three Lines' 
    % independent variable is letter height, while in all other experiments 
    % the independent variable is eccentricity
    if(strcmp(id,'fc') || strcmp(id,'l3'))
        errorBarDirection = 'Horizontal';
    else
        errorBarDirection = 'Vertical';
    end

    
    if(strcmp(id,'a'))
        % For Anstis data, do not perform the Chi^2 minimization or produce
        % graphs. Define the slope for the y=ax graph as the average of the 
        % y/x distribution and estimate the parameters for y=ax+b with
        % polyfit, as the standard error is unknown
        avgData = data;
        slope = mean(data(:,2)./data(:,1));
        params = polyfit(data(:,1),data(:,2),1);
    else
        % Average all observations made at each discrete measurement point
        % for plotting.
        avgData = averageData(data, discreteCol);
        
        % Estimate the standard errors of each observation for the Chi^2
        % minimization as the standard error of the distribution of all
        % observations ever recorded at that discrete measurement, across
        % all subjects
        avgData = calculateStandardErrors(info, trimCC, avgData);
        
        % Minimize Chi^2 for y = ax and produce a plot of Chi^2 vs. a
        oneParamChiGraph = figure();
        [slope,oneParamOutput] = oneParamChiSq(avgData, name, id, color, ...
            oneParamOutput, oneParamChiGraph);
        
        % Provide the slope parameter that minimized the Chi^2 of the y=ax
        % fit as a starting guess for the y=ax+b minimization algorithm
        approx = [oneParamOutput.(strcat(id, '_slope')) 0];
        
        % Minimize Chi^2 for y = ax + b and produce both a surface plot and
        % a colormap of Chi^2 vs. a and b.
        twoParamChiSurf = figure();
        twoParamChiColor = figure();
        [params,twoParamOutput] = twoParamChiSq(avgData, name, id, ...
            approx, twoParamOutput, twoParamChiSurf, twoParamChiColor);
    end
    
    % Graph linear y = ax data with optimized fit
    pointSlope(avgData, slope, name, color, errorBarDirection, ...
        oneParamGraph);
    
    % Graph linear y = ax + b data with optimized fit
    pointSlope(avgData, params, name, color, errorBarDirection, ...
        twoParamGraph);
    
    if(~strcmp(name,'Anstis')) && (savePlots)
        % If data was averaged, save the plots to Plots/Averaged/<type> 
        % otherwise in Plots/<type>/<subjectName>
        if(averageOver)
            folderName = fullfile(pwd, 'Plots', 'Averaged', ...
                string(oneParamOutput.type));
        else
            folderName = fullfile(pwd, 'Plots', string(oneParamOutput.type), ...
                string(oneParamOutput.name));
        end
        
        mkdir(folderName);
        
        figNames = ["_one_param_chi_sq.png", "_two_param_chi_sq_surf.png", ...
            "_two_param_chi_sq_color.png", "_divided.png", ...
            "_distribution.png"];
        
        figs = [oneParamChiGraph, twoParamChiSurf, twoParamChiColor, ...
            divided, distribution];
        
        % Loop through each figure and save them with as a .png
        for i = 1:length(figs) 
            fig = figs(i);
            figName = figNames(i);
            fileName = sprintf('%s%s%s%s', string(oneParamOutput.name), ...
                '_', name, figName);
            saveas(fig, fullfile(folderName, fileName));
        end
    end