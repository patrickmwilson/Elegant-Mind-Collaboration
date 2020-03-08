function dividedFig(data, fitData, avg, sd, N, csvOutput, name, color, divided)

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
    yline((avg+cutoff), 'LineWidth', 1, 'Color', 'r', 'LineStyle', '--', ...
            'HandleVisibility', 'off');
    
    % Setting axis limits based on experiment to facilitate visual 
    % comparison between subjects
%     xlim([0 divLim(1,1)]);
%     ylim([0 divLim(1,2)]);
    xlim([-inf inf]);
    ylim([-inf inf]);
    
    % Axis labels and title
    xlabel("Eccentricity (degrees)", 'FontSize', 12);
    ylabel("Letter Height (degrees)/Eccentricity (degrees)", 'FontSize', 12);
    title(sprintf("Letter Height/Eccentricity vs. Eccentricity (%s %s) (%s)", ...
         name, char(csvOutput{1,3}), char(csvOutput{1,4})), 'FontSize', 12);
    legend('show', 'Location', 'best');
 

end