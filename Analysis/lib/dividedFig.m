function dividedFig(data, rawData, avg, sd, N, name, color, fig)

    figure(fig);
    txt = "%s: Mean: %4.3f, Sigma: %5.4f, N = %4.2f";
    
%     yvals = ones(length(data(:,1))).*avg;
    
    % Plotting best fit line for normalized data
    hold on;
%     plot(data(:,1),yvals, 'Color', color, 'LineWidth', 1, 'DisplayName', ...
%         sprintf(txt, name, avg, sd, N));
    
    % Calculating a 0 degree linear regression best fit line for the normalized,
    % truncated distribution with (becomes y = avg of distribution).
    p = polyfit(data(:,1),data(:,2),0);
    poly = polyval(p,data(:,1));
    
    plot(data(:,1),poly, 'Color', color, 'LineWidth', 1, 'DisplayName', ...
        sprintf(txt, name, avg, sd, N));
    
    % Scattering data with scaled dot sizes (see scaledScatter.m)
    scaledScatter(fig, rawData, color, 10, 5);
    grid on; box on;
    
    cutoff = (2.5*sd);
    yline((avg+cutoff), 'LineWidth', 1, 'Color', 'r', 'LineStyle', '--', ...
            'HandleVisibility', 'off');
        
    formatFigure(fig, [-inf inf], [-inf inf], ...
        "Eccentricity (degrees)",  ...
        "Letter Height (degrees)/Eccentricity (degrees)", ...
        "Letter Height/Eccentricity vs. Eccentricity", false)
end