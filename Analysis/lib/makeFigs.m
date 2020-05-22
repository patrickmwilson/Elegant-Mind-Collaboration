function [oneParamOutput, twoParamOutput] = makeFigs(data,rawData,name,id,color,oneParamOutput,twoParamOutput,oneParamGraph,twoParamGraph,savePlots)
    
    % For all data except anstis, produce y/x vs. x graphs and y/x
    % histograms
    if(~strcmp(id,'a'))
        
        avg = mean(data(:,2));
        sd = std(data(:,2));
        N = size(data,1);
        
        % y/x vs. x plot
        divided = figure();
        %dividedFig(rawData, avg, sd, N, name, color, divided);
        
        % y/x histogram
        distribution = figure();
        histFig(rawData, avg, sd, N, name, color, distribution);
    end

    data(:,2) = data(:,2).*data(:,1);
    
    % Setting direction of error bars. T1's independent variable is letter
    % height, while in all other experiments the independent variable is
    % eccentricity
    if (strcmp(id,'fc'))
        errorBarDirection = 'Horizontal';
        discreteCol = 2;
    else
        errorBarDirection = 'Vertical';
        discreteCol = 1;
    end

    if(strcmp(id,'a'))
        slope = mean(data(:,2)./data(:,1));
        params = polyfit(data(:,1),data(:,2),1);
        avgData = data;
    else
        avgData = averageData(data,discreteCol);
        
        oneParamChiGraph = figure();
        [slope,oneParamOutput] = oneParamChiSq(avgData, name, id, color, ...
            oneParamOutput, oneParamChiGraph);
        
        twoParamChiGraph = figure();
        [params,twoParamOutput] = twoParamChiSq(avgData, name, id, ...
            twoParamOutput, twoParamChiGraph);
    end
    
    % Graph linear point-slope with averaged data & wss slope
    pointSlope(avgData, slope, name, color, errorBarDirection, ...
        oneParamGraph);
    
    pointSlope(avgData, params, name, color, errorBarDirection, ...
        twoParamGraph);
    
    % Residual plots and histograms, csv output, and saving figures
    if(~strcmp(name,'Anstis')) && (savePlots)
        
        % Save divided and distribution figures to a folder titled with the
        % subject code
        folderName = fullfile(pwd, 'Analysis_Results', 'Plots', ...
            string(oneParamOutput.type), string(oneParamOutput.name));
        mkdir(folderName);
        
        figNames = ["_one_param_chi_sq.png", "_two_param_chi_sq.png", ...
            "_divided.png", "_distribution.png"];
        
        figs = [oneParamChiGraph, twoParamChiGraph, divided, distribution];
        
        for i = 1:length(figs) 
            fig = figs(i);
            figName = figNames(i);
            fileName = sprintf('%s%s%s%s', string(oneParamOutput.name), ...
                '_', name, figName);
            saveas(fig, fullfile(folderName, fileName));
        end
    end