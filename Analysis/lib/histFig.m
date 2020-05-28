% histFig
%
% Plots a histogram of the normalized letter height observations (column 2
% of the data matrix). Takes the data matrix, the average, standard 
% deviation, and N of the distribution, the protocol name, color, and the
% figure handle as arguments.
function histFig(data, avg, sd, N, name, color, fig)
    figure(fig); hold on;
    
    % Calculate optimum bin number for distribution 
    optN = ceil((sqrt(N))*1.5);
    
    % Plot histogram of letter height/eccentricity distribution
    histogram(data(:,2), optN, 'HandleVisibility', 'off', 'FaceColor', color, ...
            'Normalization', 'probability');
        
    % Calculate appropriate height of gaussian fit - discretize splits the
    % data into bins, m becomes the mode (bin with most data points), and
    % gaussHeight becomes the number of points in this bin.
    [Y,~] = discretize(data(:,2),optN);
    m = mode(Y);
    gaussHeight = (length(find(Y == m))/size(data,1));
    
    % Gaussian start/end are mean +/- sigma*5
    gaussMin = floor(1e4*(avg - (5*sd)))/1e4;
    gaussMax = round(1e4*(avg + (5*sd)))/1e4;
    gaussX = linspace(gaussMin, gaussMax);
    
    % Generate normpdf values and rescale them to the height of the
    % histogram
    gaussY = normpdf(gaussX,avg,sd);
    gaussY = rescale(gaussY, 0, (gaussHeight*1.1));
    hold on;
    plot(gaussX,gaussY, 'LineWidth', 0.75, 'Color', color, 'DisplayName',  ...
            sprintf("%s Average: %5.4f", name, avg));
    
    % Plot vertical dashed red lines at a distance of +/-2.5 sigma from 
    % the mean, to demarcate outliers which have been truncated from the 
    % distribution
    cutoff = (2.5*sd);
    line([(avg+cutoff), (avg+cutoff)], ylim, 'LineStyle', '--', ...
            'LineWidth', 1, 'Color', color, 'HandleVisibility', 'off');
    line([(avg-cutoff), (avg-cutoff)], ylim, 'LineStyle', '--',  ...
            'LineWidth', 1, 'Color', color, 'HandleVisibility', 'off');
    box on;

    % Formatting figure (see formatFigure.m)
    formatFigure(fig, [gaussMin gaussMax], [0 gaussHeight*1.2], ...
        "Letter Height (deg)/Eccentricity (deg)", ...
        "Number of Occurences (Normalized to Probability)", ...
        "Distribution of Letter Height/Eccentricity", false);
end