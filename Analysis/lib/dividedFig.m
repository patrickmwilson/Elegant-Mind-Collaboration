% dividedFig
%
% Takes the matrix of raw data and the matrix with removed outliers (both
% normalized by eccentricity), the mean, standard deviation, and N of the
% truncated y/x distribution, the plot color, and a figure handle as
% arguments. Plots a scatter plot of the normalized letter height
% observations vs. eccentricity.
function dividedFig(data, rawData, avg, sd, N, name, color, fig)

    figure(fig);
    txt = "%s: Mean: %4.3f, Sigma: %5.4f, N = %4.2f";
    hold on;
    
    % Calculating a 0 degree linear regression best fit line for the normalized,
    % truncated distribution with (becomes y = avg of distribution).
    p = polyfit(data(:,1),data(:,2),0);
    poly = polyval(p,data(:,1));
    
    % Plotting the line of best fit
    plot(data(:,1),poly, 'Color', color, 'LineWidth', 1, 'DisplayName', ...
        sprintf(txt, name, avg, sd, N));
    
    % Scattering data with scaled dot sizes (see scaledScatter.m)
    scaledScatter(fig, rawData, color, 10, 5);
    grid on; box on;
    
    % Plot a dashed red line at a distance of +2.5 sigma from the mean, to
    % demarcate outliers which have been truncated from the distribution
    cutoff = (2.5*sd);
    yline((avg+cutoff), 'LineWidth', 1, 'Color', 'r', 'LineStyle', '--', ...
            'HandleVisibility', 'off');
    
    % Formatting figure (see formatFigure.m)
    formatFigure(fig, [-inf inf], [-inf inf], ...
        "Eccentricity (degrees)",  ...
        "Letter Height (degrees)/Eccentricity (degrees)", ...
        "Letter Height/Eccentricity vs. Eccentricity", false);
end