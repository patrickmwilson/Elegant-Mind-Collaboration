function residualFigs(fitData,outliers,fitVals,name,color,csvOutput,plotFig,hist,log)
    figure(hist);
    
    if log
        fitData = log10(fitData);
        outliers = log10(outliers);
        title(sprintf("Log-Log Residuals (%s %s) (%s)", ...
            char(csvOutput{1,3}), name, char(csvOutput{1,4})), 'FontSize', 12);
    else
        title(sprintf("Residuals (%s %s) (%s)", ...
            char(csvOutput{1,3}), name, char(csvOutput{1,4})), 'FontSize', 12);
    end
    
    totalSquares = sum((fitData(:,2)-mean(fitData(:,2))).^2);
    
    fitData(:,3) = ((fitData(:,1).*fitVals(1))+fitVals(2));
    fitData(:,2) = (fitData(:,2))-fitData(:,3);
    if size(outliers,1) > 0
       outliers(:,3) = ((outliers(:,1)*fitVals(1))+fitVals(2));
       outliers(:,2) = (outliers(:,2))-outliers(:,3);
    end
    
    residualSquares = sum(fitData(:,2).^2);
    
    coeffDet = (1 - (residualSquares/totalSquares));
    
    hold on;
    N = size(fitData,1);
    optN = ceil((sqrt(N))*1.5);
    % Plot histogram of letter height/eccentricity distribution
    histogram(fitData(:,2), optN, 'HandleVisibility', 'off',  ...
        'FaceColor', color, 'Normalization', 'probability');
    
    xlabel("Residuals");
    ylabel("Number of Occurences (Normalized to Probability)");
    grid on; box on;
    
    % Calculate appropriate height of gaussian fit - discretize splits the
    % data into bins, m becomes the mode (bin with most data points), and
    % gaussHeight becomes the number of points in this bin.
    [Y,~] = discretize(fitData(:,2),optN);
    m = mode(Y);
    gaussHeight = (length(find(Y == m))/size(fitData,1));
    
    % Gaussian start/end are mean +/- sigma*5
    avg = mean(fitData(:,2));
    sd = std(fitData(:,2));
    gaussMin = floor(1e4*(avg - (5*sd)))/1e4;
    gaussMax = round(1e4*(avg + (5*sd)))/1e4;
    gaussX = linspace(gaussMin, gaussMax);
    
    % Generate normpdf values and rescale them to the height of the
    % histogram
    gaussY = normpdf(gaussX,avg,sd);
    gaussY = rescale(gaussY, 0, (gaussHeight*1.1));
    hold on;
    plot(gaussX,gaussY, 'LineWidth', 0.75, 'Color', color, 'DisplayName',  ...
            sprintf("%s Average: %5.4f Standard Deviation: %5.4f R^2: %2.3f", ...
            name, avg, sd, coeffDet));
    
    xlim([(min(gaussX)) (max(gaussX))]);
    ylim([0 (gaussHeight*1.5)]);
    
    legend('show', 'Location', 'best');
    
    
    figure(plotFig);
    hold on;
    
    scaledScatter(plotFig,fitData,color,20,10);
    if(size(outliers,1) > 0)
        scaledScatter(plotFig,outliers,[0 0 0],20,10);
    end
    
    if log
        title(sprintf("Log-Log Residuals (%s %s) (%s)", ...
            char(csvOutput{1,3}), name, char(csvOutput{1,4})), 'FontSize', 12);
    else
        title(sprintf("Residuals (%s %s) (%s)", ...
            char(csvOutput{1,3}), name, char(csvOutput{1,4})), 'FontSize', 12);
    end
    xlim([-inf inf]);
    ylim([-inf inf]);
    
    ax = gca;
    ax.XAxisLocation = 'origin';
    ax.YAxisLocation = 'origin';
    
    xlabel("Eccentricity (degrees)");
    ylabel("Residuals (degrees)");

end