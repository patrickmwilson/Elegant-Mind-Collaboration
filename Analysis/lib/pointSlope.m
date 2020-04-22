function pointSlope(data,avg,name,color,averageOver,errorBarDirection,fig)

    figure(fig);
    txt = "%s : y = %4.3fx";
    
    % Chi-squared minimization for fit line was completed by previous
    % normalization of letter height/eccentricity. y = avg*x
    xfit = linspace(0, max((data(:,1))'));
    yfit = xfit*avg;
    
    % Plotting error bars
    hold on;
    errorbar(data(:,1), data(:,2), data(:,3), errorBarDirection,'.', ...
        'HandleVisibility', 'off', 'Color', [0.43 0.43 0.43], 'CapSize', 0);
    
    % Plotting fit line
    hold on;
    plot(xfit, yfit, 'Color', color, 'LineWidth', 1, 'DisplayName', ...
        sprintf(txt, name, avg));
    
    if averageOver
        scatter(data(:,1),data(:,2),20,color,'filled','HandleVisibility','off');
    else    
        % Scattering data with scaled dot sizes
        scaledScatter(fig, data, color, 10, 5);
    end
end