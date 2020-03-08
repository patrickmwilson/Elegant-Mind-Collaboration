function logfit = logLogPlot(data, fitData, name, errorBarDirection, color, logPlot)

    % LOG-LOG FIGURE ------------------------------------------------
    figure(logPlot);
    txt = "%s : y = %3.2fx %3.2fx";
    
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
%     data(:,1) = log10(data(:,1));
    % Scattering data with scaled dot size
    scaledScatter(logPlot, log10(data), color, 10, 5);
    grid on; box on;
    
end