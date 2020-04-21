function [csvOutput, rawCsvOutput] = makeFigs(data, name, csvOutput, rawCsvOutput, tableIndex, color, divLim, pointSlopeGraph, logPlot, llogPlot, combinedDist, logCombinedDist)
    
    warning('off','MATLAB:MKDIR:DirectoryExists');
    
    % Setting direction of error bars. T1's independent variable is letter
    % height, while in all other experiments the independent variable is
    % eccentricity
    if (strcmp(name,'T1'))
        errorBarDirection = 'Horizontal';
    else
        errorBarDirection = 'Vertical';
    end
    
    % Normalizing letter height values via dividing by eccentricity,
    % resulting in a normal distribution.
    data(:,2) = data(:,2)./data(:,1);
    
    % Recursively removing outliers more than 2.5 standard deviations (99%
    % confidence interval) from this distribution (see removeOutliers.m)
    outliers = [];
    [fitData,outliers] = removeOutliers(data, [], 2.5, 2);
    
    % Calculate useful statistics from this truncated distribution for
    % fitting
    sd = std(fitData(:,2));
    avg = (mean(fitData(:,2)));
    N = size(fitData,1);
    sError = (sd/(sqrt(N-1)));
    
    if(~strcmp(name,'Anstis'))
        
        divided = figure();
        dividedFig(data, fitData, avg, sd, N, csvOutput, name, color, divLim, divided);
        
        distribution = figure();
        histFig(data, name, csvOutput, color, divLim, distribution, 0, 0);
        
        histFig(data, name, csvOutput, color, divLim, combinedDist, 1, 0);
        
        histFig(data, name, csvOutput, color, divLim, logCombinedDist, 1, 1);
       
    end

    % Converting letter heights back from letter height/eccentricity to
    % real values
    data(:,2) = data(:,2).*data(:,1);
    fitData(:,2) = fitData(:,2).*fitData(:,1);
    
    % Adding values for error bars. Error bars represent one standard
    % deviation from the mean, multiplied by their corresponding
    % eccentricity value. Higher eccentricity values have higher error.
    data(:,3) = sd.*data(:,1);
        
    pointSlope(data, avg, name, color, errorBarDirection, pointSlopeGraph);
    
    logfit = logLogFig(data, fitData, name, errorBarDirection, color, logPlot);
    
    if(~strcmp(name,'Anstis'))
        residualHist = figure();
        residualPlot = figure();
        residualFigs(fitData,outliers,([avg 0]),name,color,csvOutput,residualPlot,residualHist,0);
        
        logResidualHist = figure();
        logResidualPlot = figure();
        residualFigs(fitData,outliers,logfit,name,color,csvOutput,logResidualPlot,logResidualHist,1);
        
    end
    
    if(strcmp(name,'Anstis') == 0)
        if(size(rawCsvOutput,2) > 4)
            rawCsvOutput((size(rawCsvOutput,1)+1),:) = rawCsvOutput((size(rawCsvOutput,1)),:);
        end
        rawCsvOutput{(size(rawCsvOutput,1)),5} = name;
        rawCsvOutput{(size(rawCsvOutput,1)),6} = avg;
        rawCsvOutput{(size(rawCsvOutput,1)),7} = sd;
        rawCsvOutput{(size(rawCsvOutput,1)),8} = sError;
        
        csvOutput{1,tableIndex} = avg;
        csvOutput{1,(tableIndex+1)} = sd;
        csvOutput{1,(tableIndex+2)} = sError;
        
        % Save divided and distribution figures to a folder titled with the
        % subject code
        fFolderName = strcat(string(csvOutput{1,3}), "_", string(csvOutput{1,4}));
        folderName = fullfile(pwd, 'Analysis Results', 'Plots', string(csvOutput{1,2}), ...
            fFolderName);
        mkdir(folderName);
        
        fileName = sprintf('%s%s%s%s', string(csvOutput{1,3}), '_', name, ...
            '_divided.png');
        saveas(divided, fullfile(folderName, fileName));
        
        fileName = sprintf('%s%s%s%s', string(csvOutput{1,3}), '_', name, ...
            '_distribution.png');
        saveas(distribution, fullfile(folderName, fileName));
        
        fileName = sprintf('%s%s%s%s', string(csvOutput{1,3}), '_', name, ...
            '_residual_distribution.png');
        saveas(residualHist, fullfile(folderName, fileName));
        
        fileName = sprintf('%s%s%s%s', string(csvOutput{1,3}), '_', name, ...
            '_residual_plot.png');
        saveas(residualPlot, fullfile(folderName, fileName));
        
        fileName = sprintf('%s%s%s%s', string(csvOutput{1,3}), '_', name, ...
            '_log_residual_distribution.png');
        saveas(logResidualHist, fullfile(folderName, fileName));
        
        fileName = sprintf('%s%s%s%s', string(csvOutput{1,3}), '_', name, ...
            '_log_residual_plot.png');
        saveas(logResidualPlot, fullfile(folderName, fileName));
    end