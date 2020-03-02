function csvOutput = makeFigs(data, name, csvOutput, tableIndex, color, divLim, pointSlope, logPlot)
    divided = figure();
    distribution = figure();
    
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
    fitData = removeOutliers(data, 2.5, 2);
    
    % Calculate useful statistics from this truncated distribution for
    % fitting
    sd = std(fitData(:,2));
    avg = mean(fitData(:,2));
    N = size(fitData,1);
    sError = (sd/(sqrt(N)));
    
    % DIVIDED FIGURE ------------------------------------------------
    figure(divided);
    txt = "%s: y = %4.3f Mean: %4.3f, Sigma: %5.4f, N = %4.2f";
    
    % Calculating a 0 degree linear regression best fit line for the normalized,
    % truncated distribution with (becomes y = avg of distribution).
    p = polyfit(fitData(:,1),fitData(:,2),0);
    poly = polyval(p,fitData(:,1));
    
    % Plotting error bars (one standard deviation from mean)
    data(:,3) = sd;
    hold on;
    errorbar(data(:,1), data(:,2), data(:,3), 'vertical','.', ...
        'HandleVisibility', 'off', 'Color', [0.43 0.43 0.43], 'CapSize', 0);
    
    % Plotting best fit line for normalized data
    hold on;
    plot(fitData(:,1),poly, 'Color', color, 'LineWidth', 1, 'DisplayName', ...
        sprintf(txt, name, p(1,1), avg, sd, N));
    
    % Scattering data with scaled dot sizes (see scaledScatter.m)
    scaledScatter(divided, data, color, 10, 5);
    grid on; box on;
    
    cutoff = (2.5*sd);
    yline((avg+cutoff), 'LineWidth', 1, 'Color', 'r', ...
        'HandleVisibility', 'off');
    
    % Setting axis limits based on experiment to facilitate visual 
    % comparison between subjects
    xlim([0 divLim(1,1)]);
    ylim([0 divLim(1,2)]);
    
    % Axis labels and title
    xlabel("Eccentricity (degrees)", 'FontSize', 12);
    ylabel("Letter Height (degrees)/Eccentricity (degrees)", 'FontSize', 12);
    title(sprintf("Letter Height/Eccentricity vs. Eccentricity (%s %s) (%s)", ...
        name, char(csvOutput{1,3}), char(csvOutput{1,4})), 'FontSize', 12);
    legend('show', 'Location', 'best');
    
    
    % DISTRIBUTION FIGURE ------------------------------------------------
    figure(distribution);
    
    hold on;
%     histogram(data(:,2), 'BinEdges', edges);
    histogram(data(:,2), 100);
%     histfit(data(:,2),100);
    
    % Plotting vertical red lines at +/-2.5 standard deviations to
    % demarcate the truncated data from the removed outliers
    cutoff = (2.5*sd);
    line([(avg+cutoff), (avg+cutoff)], ylim, 'LineWidth', 1, 'Color', 'r');
    line([(avg-cutoff), (avg-cutoff)], ylim, 'LineWidth', 1, 'Color', 'r');
    
%     % minimum value = mean - 5 signma
%     x_min = floor(1e4*(avg - (5*sd)))/1e4;
%     % maximum value = mean + 5 signma
%     x_max = round(1e4*(avg + (5*sd)))/1e4;
%     % create the x-values, in the range from +5 sigma to - 5 sigma
%     x_values = x_min:1e-6:x_max;
%     % create y-values for normal distribution
%     y_values = normpdf(x_values,avg,sd);
%     hold on;
%     plot(x_values,y_values/10, 'LineWidth', 1, 'Color', [1 0 0], 'HandleVisibility', 'off');
%     box on;
    
    % Setting axis limits based on experiment to facilitate visual 
    % comparison between subjects
    xlim([0 divLim(1,2)]);
    ylim([0 inf]);
    
    % Axis labels and title
    titleText = "Distribution of Letter Height/Eccentricity (%s %s) (%s)";
    xlabel("Letter Height (degrees)/Eccentricity (degrees)", 'FontSize', 10);
    ylabel("Number of occurences", 'FontSize', 10);
    title(sprintf(titleText, name, char(csvOutput{1,3}),  ...
        char(csvOutput{1,4})), 'FontSize', 12);
    
    
    % POINT SLOPE FIGURE ------------------------------------------------
    figure(pointSlope);
    txt = "%s : y = %4.3fx";
    
    % Chi-squared minimization for fit line was completed by previous
    % normalization of letter height/eccentricity. y = avg*x
    xfit = linspace(0, max((data(:,1))'));
    yfit = xfit*avg;
    
    % Converting letter heights back from letter height/eccentricity to
    % real values
    data(:,2) = data(:,2).*data(:,1);
    
    % Adding values for error bars. Error bars represent one standard
    % deviation from the mean, multiplied by their corresponding
    % eccentricity value. Higher eccentricity values have higher error.
    data(:,3) = data(:,1).*sd;
    
    % Plotting error bars
    hold on;
    errorbar(data(:,1), data(:,2), data(:,3), errorBarDirection,'.', ...
        'HandleVisibility', 'off', 'Color', [0.43 0.43 0.43], 'CapSize', 0);
    
    % Plotting fit line
    hold on;
    plot(xfit, yfit, 'Color', color, 'LineWidth', 1, 'DisplayName', ...
        sprintf(txt, name, avg));
    
    % Scattering data with scaled dot sizes (see scaledScatter.m)
    scaledScatter(pointSlope, data, color, 10, 5);
    grid on; box on;
    
    
    % LOG-LOG FIGURE ------------------------------------------------
    figure(logPlot);
    txt = "%s : y = %3.2fx + %3.2fx";
    
    % Logarithmic error bars -> delta(z) = 0.434 * (delta(y))/y 
    % see https://faculty.washington.edu/stuve/log_error.pdf
    data(:,3) = data(:,3)./data(:,2);
    data(:,3) = data(:,3).*0.434;
    
    % Multiplying letter height by eccentricity to get real values for the
    % log-log polyfit
    fitData(:,2) = fitData(:,2).*fitData(:,1);
    
    % Least-squares regression best fit for log10/log10 data
    logfit = polyfit(log10(fitData(:,1)), log10(fitData(:,2)), 1);
    yfit = polyval(logfit,log10(data(:,1)));
    
    % Plotting error bars first
    hold on; 
    errorbar(log10(data(:,1)),log10(data(:,2)),data(:,3), ...
        errorBarDirection,'.', 'HandleVisibility', 'off', 'Color', ...
        [0.43 0.43 0.43], 'CapSize', 0);

    % Plotting best fit line over all log10(x) values
    plot(log10(data(:,1)),yfit, 'Color', color, 'LineWidth', 1, 'DisplayName', ...
        sprintf(txt, name, logfit(1,1), logfit(1,2)));
    
    % Scattering data with scaled dot size
    scaledScatter(logPlot, log10(data), color, 10, 5);
    grid on; box on;
    
    % SAVING FIGURES, CSV OUTPUT ------------------------------------------------
    if(strcmp(name,'Anstis') == 0)
        mkdir(fullfile(pwd, 'Analysis Results'));
        % If the csv doesn't exist, create it and print a header
        rawCsvName = fullfile(pwd, 'Analysis Results', 'Analysis_Summary_Raw.csv');
        if(exist(rawCsvName, 'file') ~= 2)
            fileID = fopen(rawCsvName, 'a');
            fprintf(fileID, '%s, %s, %s, %s, %s, %s, %s, %s\n', ...
                'Session Index', ...
                'Type', ...
                'Subject Code', ...
                'Date', ...
                'Protocol', ...
                'Mean', ...
                'Standard Deviation', ...
                'Standard Error');
            fclose(fileID);
        end
        
        % Print statistics for each subject, for each experiment to csv
        fileID = fopen(rawCsvName, 'a');
        fprintf(fileID, '%s, %s, %s, %s, %s, %5.4f, %5.4f, %7.6f\n', ...
            char(csvOutput{1,1}), ...
            char(csvOutput{1,2}), ...
            char(csvOutput{1,3}), ...
            char(csvOutput{1,4}), ...
            name, ...
            avg, ...
            sd, ...
            sError);
        fclose(fileID);
        
        csvName = fullfile(pwd, 'Analysis Results', 'Compiled_Paramaters.csv');
        if(exist(csvName, 'file') ~= 2)
            fileID = fopen(csvName, 'a');
            formatSpec = '%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s\n';
            fprintf(fileID, formatSpec, ...
                '', ...
                '', ...
                '', ...
                '', ...
                'T1', ...
                'T1', ...
                'T1', ...
                '', ...
                'CP', ...
                'CP', ...
                'CP', ...
                '', ...
                'CPO', ...
                'CPO', ...
                'CPO', ...
                '', ...
                'CC 9x9', ...
                'CC 9x9', ...
                'CC 9x9', ...
                '', ...
                'CC 3x3', ...
                'CC 3x3', ...
                'CC 3x3', ...
                '', ...
                'IC', ...
                'IC', ...
                'IC');
            fprintf(fileID, formatSpec, ...
                'Session Index', ...
                'Type', ...
                'Subject Code', ...
                'Date', ...
                'Mean', ...
                'Standard Deviation', ...
                'Standard Error', ...
                '', ...
                'Mean', ...
                'Standard Deviation', ...
                'Standard Error', ...
                '', ...
                'Mean', ...
                'Standard Deviation', ...
                'Standard Error', ...
                '', ...
                'Mean', ...
                'Standard Deviation', ...
                'Standard Error', ...
                '', ...
                'Mean', ...
                'Standard Deviation', ...
                'Standard Error', ...
                '', ...
                'Mean', ...
                'Standard Deviation', ...
                'Standard Error');
            fclose(fileID);
        end
        
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
end