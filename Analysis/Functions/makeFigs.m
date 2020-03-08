function [csvOutput, rawCsvOutput] = makeFigs(data, name, csvOutput, rawCsvOutput, tableIndex, color, divLim, pointSlopeGraph, logpointSlopeGraph, logPlot, combinedDist)
    
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
    
    fitData = removeOutliers(data, 2.5, 2);
    [h,~,stats] = chi2gof(fitData(:,2))
    logfit = logLogPlot(data, fitData, name, errorBarDirection, color, logPlot);
    
    sd = std(fitData(:,2));
    avg = (mean(fitData(:,2)));
    N = size(fitData,1);
    sError = (sd/(sqrt(N-1)));
    
    fitData(:,2) = fitData(:,2).*fitData(:,1);
    fitExpected = (fitData(:,1).*avg);
    fitDiff = (fitData(:,2)-fitExpected(:,1));
    fitSquares = fitDiff.^3;
    fitsum = sum(fitSquares);
    
    ldata = data;
    ldata(:,2) = log(ldata(:,2));
%     ldata(:,2) = ldata(:,2)./ldata(:,1);
    
    % Recursively removing outliers more than 2.5 standard deviations (99%
    % confidence interval) from this distribution (see removeOutliers.m)
    logfitData = removeOutliers(ldata, 2.5, 2);
    
    % Calculate useful statistics from this truncated distribution for
    % fitting
%     logsd = std(fitData(:,2));
    logavg = (mean(logfitData(:,2)));
    N = size(logfitData,1);
%     sError = (sd/(sqrt(N-1)));

    logfitData(:,2) = logfitData(:,2).*logfitData(:,1);
    logfitExpected = (logfitData(:,1).*logavg);
    logfitDiff = (logfitData(:,2)-logfitExpected(:,1));
    logfitSquares = logfitDiff.^3;
    logfitsum = sum(logfitSquares);
    
    if(~strcmp(name,'Anstis'))
        
        divided = figure();
%         
%         dividedFig(data, fitData, avg, sd, N, csvOutput, name, color, divided);
%         
        distribution = figure();
%         
%         histFig(data, avg, N, name, csvOutput, color, distribution, combined);
%         
%         normalizedGraphs(data, fitData, avg, sd, N, csvOutput, name, ...
%             color, divLim, divided, distribution, 0);
        
%         combinedDistGraph(data, avg, N, name, color, combinedDist);
    end
    logavg = 10^(logavg);
    % Converting letter heights back from letter height/eccentricity to
    % real values
    ldata(:,2) = 10.^(ldata(:,2));
    ldata(:,2) = ldata(:,2).*ldata(:,1);
    data(:,2) = data(:,2).*data(:,1);
    
    % Adding values for error bars. Error bars represent one standard
    % deviation from the mean, multiplied by their corresponding
    % eccentricity value. Higher eccentricity values have higher error.
    data(:,3) = sd.*(2.^(data(:,2)./data(:,1)));
    ldata(:,3) = sd.*(2.^(ldata(:,2)./ldata(:,1)));

%     data(:,3) = sError;
%     data(:,3) = 10.^data(:,3);
%     data(:,3) = data(:,3).*data(:,1);

%     data(:,3) = ((data(:,2)./data(:,1)).*(10^sd));
    
    sqrtPlot = figure();
    sqrtData = data;
    sqrtData(:,1) = sqrt(sqrtData(:,1));
    sqrtData(:,2) = sqrt(sqrtData(:,2));
    scaledScatter(sqrtPlot, sqrtData, color, 10, 5);
    figure(sqrtPlot);
    title("sqrt");
    
    invPlot = figure();
    invData = data;
    invData(:,2) = 1./(invData(:,2));
    scaledScatter(invPlot, invData, color, 10, 5);
    figure(invPlot);
    title("inv");
    
    lnPlot = figure();
    lnData = data;
    lnData(:,2) = log(lnData(:,2));
    scaledScatter(lnPlot, lnData, color, 10, 5);
    figure(lnPlot);
    title("ln");
        
    pointSlope(data, avg, name, color, errorBarDirection, pointSlopeGraph, fitsum);
    pointSlope(ldata, logavg, name, color, errorBarDirection, logpointSlopeGraph, logfitsum);
    
    
    
    logfittedPlot = figure();
    figure(logfittedPlot);
    scaledScatter(logfittedPlot, data, color, 10, 5);
    xfit = linspace(0, max((data(:,1))'));
    slope = 0.3467;
    exponent = 0.93;
    yfit = (xfit.^exponent).*slope;
    plot(xfit, yfit, 'Color', color, 'LineWidth', 1);
    
    
    
    if(~strcmp(name,'Anstis'))
        
%         logResidualDist = figure();
%         logResiduals(data, logfit, N, name, color, csvOutput, logResidualDist);
        
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
    end