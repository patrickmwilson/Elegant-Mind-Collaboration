function [csvOutput,rawCsvOutput] = makeFigs(data,fitData,outliers,name,csvOutput,rawCsvOutput,tableIndex,color,divLim,wlssPointSlopeGraph,avgPointSlopeGraph,pointSlopeGraph,logPlot,combinedDist,logCombinedDist,saveOutput)
    
    % Setting direction of error bars. T1's independent variable is letter
    % height, while in all other experiments the independent variable is
    % eccentricity
    if (strcmp(name,'T1'))
        errorBarDirection = 'Horizontal';
    else
        errorBarDirection = 'Vertical';
    end
    
    % Calculate useful statistics from this truncated distribution for
    % fitting - Standard deviation, Mean, Standard error
    sd = std(fitData(:,2));
    avg = mean(fitData(:,2));
    N = size(fitData,1);
    sError = (sd/(sqrt(N-1)));
    
    % For all data except anstis, produce y/x vs. x graphs and y/x
    % histograms
    if(~strcmp(name,'Anstis'))
        % y/x vs. x plot
        divided = figure();
        dividedFig(data, fitData, avg, sd, N, name, color, ...
            divLim, divided);
        
        % y/x histogram
        distribution = figure();
        histFig(data, name, csvOutput, color, divLim, distribution, ...
            false, false);
        
        % combined y/x histogram - all protocols graphed
        histFig(data, name, csvOutput, color, divLim, combinedDist, ...
            true, false);
        
        % combined log10(y/x) histogram - all protocols graphed
        histFig(data, name, csvOutput, color, divLim, logCombinedDist, ...
            true, true);
    end

    % Converting letter heights back from letter height/eccentricity to
    % real values
    data(:,2) = data(:,2).*data(:,1);
    fitData(:,2) = fitData(:,2).*fitData(:,1);
    
    % Adding values for error bars. Error bars represent one standard
    % deviation from the mean, multiplied by their corresponding
    % eccentricity value. Higher eccentricity values have higher error.
    data(:,3) = sd.*data(:,1);
    
    % Weighted least sum of squares calculation
    clear('wss');
    [avgData, wssAvg] = wss(fitData,name, avg);

    if(strcmp(name,'Anstis'))
        avgData = data;
        wssAvg = avg;
    end
        
    % Graph linear point-slope with averaged data & wss slope
    pointSlope(avgData, wssAvg, name, color, true, ...
            errorBarDirection, wlssPointSlopeGraph);

    % Graph linear point-slope with averaged data 
    pointSlope(avgData, avg, name, color, true, ...
            errorBarDirection, avgPointSlopeGraph);
    
    % Graph linear point-slope without averaging data
    pointSlope(data, avg, name, color, false, ...
            errorBarDirection, pointSlopeGraph);
    
    % Graph log-log plot, get fit parameters
    logfit = logLogFig(data, fitData, name, errorBarDirection, color, ...
        logPlot);
    
    % Residual plots and histograms, csv output, and saving figures
    if(~strcmp(name,'Anstis')) && (saveOutput)
        
        residualHist = figure();
        residualPlot = figure();
        residualFigs(fitData,outliers,([avg 0]),name,color,csvOutput, ...
            residualPlot,residualHist,false);
        
        logResidualHist = figure();
        logResidualPlot = figure();
        residualFigs(fitData,outliers,logfit,name,color,csvOutput, ...
            logResidualPlot,logResidualHist,true);
        
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
        folderName = fullfile(pwd, 'Analysis_Results', 'Plots', string(csvOutput{1,2}), ...
            fFolderName);
        mkdir(folderName);
        
        figNames = ["_divided.png", "_distribution.png", ...
            "_residual_distribution.png", "_residual_plot.png", ...
            "_log_residual_distribution.png", "_log_residual_plot.png"];
        
        figs = [divided, distribution, residualHist, residualPlot, ...
            logResidualHist, logResidualPlot];
        
        for i = 1:length(figs) 
            fig = figs(i);
            figName = figNames(i);
            fileName = sprintf('%s%s%s%s', string(csvOutput{1,3}), '_', name, ...
                figName);
            saveas(fig, fullfile(folderName, fileName));
        end
    end