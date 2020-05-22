function dividedFig(data, avg, sd, N, name, color, fig)

    figure(fig);
    txt = "%s: Mean: %4.3f, Sigma: %5.4f, N = %4.2f";
    
    yvals = ones(length(data(:,1))).*avg;
    
    % Plotting best fit line for normalized data
    hold on;
    plot(data(:,1),yvals, 'Color', color, 'LineWidth', 1, 'DisplayName', ...
    sprintf(txt, name, avg, sd, N));
    
    % Scattering data with scaled dot sizes (see scaledScatter.m)
    scaledScatter(fig, data, color, 10, 5);
    grid on; box on;
    
    cutoff = (2.5*sd);
    yline((avg+cutoff), 'LineWidth', 1, 'Color', 'r', 'LineStyle', '--', ...
            'HandleVisibility', 'off');
        
    formatFigure(fig, [-inf inf], [-inf inf], ...
        "Eccentricity (degrees)",  ...
        "Letter Height (degrees)/Eccentricity (degrees)", ...
        "Letter Height/Eccentricity vs. Eccentricity", false)
end