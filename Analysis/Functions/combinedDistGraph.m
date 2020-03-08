function combinedDistGraph(data, avg, N, name, color, combinedDist)

    figure(combinedDist);
        
    hold on;
    % Optimum bin number for distribution 
    optN = ceil((sqrt(N))*1.5);
    % Plot histogram of letter height/eccentricity distribution
    histogram(log10(data(:,2)), optN, 'HandleVisibility', 'off',  ...
        'FaceColor', color, 'Normalization', 'probability');
    % Calculate appropriate height of gaussian fit - discretize splits the
    % data into bins, m becomes the mode (bin with most data points), and
    % gaussHeight becomes the number of points in this bin.
    [Y,~] = discretize(data(:,2),optN);
    m = mode(Y);
    gaussHeight = (length(find(Y == m))/N);
        
    logavg = mean(log10(data(:,2)));
    logsd = std(log10(data(:,2)));
    % Gaussian start/end are mean +/- sigma*5
    gaussMin = floor(1e4*(logavg - (5*logsd)))/1e4;
    gaussMax = round(1e4*(logavg + (5*logsd)))/1e4;
    gaussX = linspace(gaussMin, gaussMax);
    
    % Generate normpdf values and rescale them to the height of the
    % histogram
    gaussY = normpdf(gaussX,logavg,logsd);
    gaussY = rescale(gaussY, 0, (gaussHeight*1.1));
    hold on;
    plot(gaussX,gaussY, 'LineWidth', 0.75, 'Color', color, 'DisplayName',  ...
            sprintf("%s Peak: %5.4f", name, avg));
    
    % Plotting vertical red lines at +/-2.5 standard deviations to
    % demarcate the truncated data from the removed outliers
    cutoff = (2.5*logsd);
    line([(logavg+cutoff), (logavg+cutoff)], ylim, 'LineStyle', '--', ...
            'LineWidth', 1, 'Color', color, 'HandleVisibility', 'off');
    line([(logavg-cutoff), (logavg-cutoff)], ylim, 'LineStyle', '--',  ...
            'LineWidth', 1, 'Color', color, 'HandleVisibility', 'off');
    
end