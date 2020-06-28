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
function [oneParamOutput,twoParamOutput] = analyzeData(data, rawData, info, oneParamOutput, twoParamOutput, oneParamGraph, twoParamGraph, subject)
    
    % For all data except anstis, produce y/x vs. x graphs and y/x
    % histograms
    if(~strcmp(info.id,'a'))
        
        avg = mean(data(:,2)); sd = std(data(:,2)); N = size(data,1);
        
        % y/x vs. x plot
        divided = figure();
        dividedFig(data, rawData, avg, sd, N, info, divided);
        
        % y/x histogram
        distribution = figure();
        histFig(rawData, avg, sd, N, info, distribution);
    end
    
    % Convert the normalized data back to the linear scale by multiplying
    % each value by its respective eccentricity value
    data(:,2) = data(:,2).*data(:,1);

    if(strcmp(info.id,'a'))
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
        avgData = averageData(data, info.discreteCol);
        
        % Estimate the standard errors of each observation for the Chi^2
        % minimization as the standard error of the distribution of all
        % observations ever recorded at that discrete measurement, across
        % all subjects
        avgData = calculateStandardErrors(info, avgData);
        
        % Minimize Chi^2 for y = ax and produce a plot of Chi^2 vs. a
        oneParamChiGraph = figure();
        [slope,oneParamOutput] = oneParamChiSq(avgData, info, ...
            oneParamOutput, oneParamChiGraph);
        
        % Minimize Chi^2 for y = ax + b and produce both a surface plot and
        % a colormap of Chi^2 vs. a and b.
        twoParamChiSurf = figure(); 
        twoParamChiColor = figure();
        [params,twoParamOutput] = twoParamChiSq(avgData, info, ...
            [slope 0], twoParamOutput, twoParamChiSurf, twoParamChiColor);
    end
    
    % Graph linear y = ax data with optimized fit
    pointSlope(avgData, slope, info, oneParamGraph);
    
    % Graph linear y = ax + b data with optimized fit
    pointSlope(avgData, params, info, twoParamGraph);
    
    % Save plots unless they are based on anstis data
    if(~strcmp(info.name,'Anstis')) && (subject.savePlots)
        % If data was averaged, save the plots to Plots/Averaged/<type> 
        % otherwise in Plots/<type>/<subjectName>
        if(strcmp(subject.name,'Averaged'))
            folderName = fullfile(pwd, 'Plots', 'Averaged', ...
                string(subject.type));
        else
            folderName = fullfile(pwd, 'Plots', string(subject.type), ...
                string(subject.name));
        end
        
        mkdir(folderName);
        
        figNames = [" one param chi^2.png", "two param chi^2 surf.png", ...
            " two param chi^2 colormap.png", " divided.png", ...
            " distribution.png"];
        
        figs = [oneParamChiGraph, twoParamChiSurf, twoParamChiColor, ...
            divided, distribution];
        
        % Loop through each figure and save them with as a .png
        for i = 1:length(figs) 
            fileName = sprintf('%s%s%s%s', string(subject.name), ...
                ' ', info.name, figNames(i));
            saveas(figs(i), fullfile(folderName, fileName));
            close(figs(i));
        end
    end