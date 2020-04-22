function dividedFig(data, fitData, avg, sd, N, name, color, divLim, fig)

    figure(fig);
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
    scaledScatter(fig, data, color, 10, 5);
    grid on; box on;
    
    cutoff = (2.5*sd);
    yline((avg+cutoff), 'LineWidth', 1, 'Color', 'r', 'LineStyle', '--', ...
            'HandleVisibility', 'off');
        
    formatFigure(fig, [-inf divLim(1,1)], [-inf divLim(1,2)], ...
        "Eccentricity (degrees)",  ...
        "Letter Height (degrees)/Eccentricity (degrees)", ...
        "Letter Height/Eccentricity vs. Eccentricity", false)
end