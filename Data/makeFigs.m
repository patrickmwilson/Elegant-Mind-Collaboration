function makeFigs(x, y, fitx, fity, avg, delta, name, subjectCode, color, pointSlope, logPlot)
    divided = figure();
    distribution = figure();
    divy = y./x;
    
    figure(divided);
    txt = "%s: y = %4.3f Mean: %4.3f, Sigma: %5.4f, N = %4.2f";
    sd = std(fity);
    N = length(fitx);
    p = polyfit(fitx,fity,0);
    poly = polyval(p,fitx);
    hold on;
    plot(fitx,poly, 'Color', color, 'LineWidth', 1, 'DisplayName', sprintf(txt, name, p(1,1), avg, sd, N));
    scaledScatter(divided, x, divy, color, 10);
    grid on;
    xlim([0 inf]);
    ylim([0 inf]);
    titleText = "Letter Height/Eccentricity vs. Eccentricity (%s %s)";
    xlabel("Eccentricity (degrees)", 'FontSize', 12);
    ylabel("Letter Height (degrees)/Eccentricity (degrees)", 'FontSize', 12);

    title(sprintf(titleText, name, subjectCode), 'FontSize', 14);
    legend('show', 'Location', 'best');
    
    figure(distribution);
    edges = [];
    binWidth = (max(divy)/25);
    upperEdge = (max(divy)*1.2)/binWidth;
    for i = 1:upperEdge
        edges(i) = (i-1)*binWidth;
    end
    histogram(divy, 'BinEdges', edges);
    cutoff = (2.5*sd);
    hold on;
    line([(avg+cutoff), (avg+cutoff)], ylim, 'LineWidth', 1, 'Color', 'r');
    hold on;
    line([(avg-cutoff), (avg-cutoff)], ylim, 'LineWidth', 1, 'Color', 'r');
    hold on;

    titleText = "Distribution of Letter Height/Eccentricity (%s %s)";
    xlabel("Letter Height (degrees)/Eccentricity (degrees)", 'FontSize', 12);
    ylabel("Number of occurences", 'FontSize', 12);
    title(sprintf(titleText, name, subjectCode), 'FontSize', 14);
    
    figure(pointSlope);
    txt = "%s : y = %4.3fx";
    xfit = linspace(0, max(x));
    yfit = xfit*avg;
    hold on;
    if (strcmp(name,'T1'))
        %errorbar(x,y,delta,'both','.', 'HandleVisibility', 'off', 'Color', [0.6 0.6 0.6], 'CapSize', 0);
    else
        %errorbar(x,y,delta,'vertical','.', 'HandleVisibility', 'off', 'Color', [0.6 0.6 0.6], 'CapSize', 0);
    end
    scaledScatter(pointSlope, x, y, color, 10);
    hold on;
    plot(xfit, yfit, 'Color', color, 'LineWidth', 1, 'DisplayName', sprintf(txt, name, avg));
    grid on;
    
    figure(logPlot);
    hold on;
    txt = "%s : y = %5.4fx + %5.4fx";
    x = log10(x);
    y = log10(y);
    fity = fity.*fitx;
    fitx = log10(fitx);
    fity = log10(fity);
    delta = abs(log10(delta));
    logfit = polyfit(fitx(1,:), fity(1,:), 1);
    yfit = polyval(logfit,x);
    
%     residuals = y-((logfit(1,1).*x)+logfit(1,2));
    hold on
    if (strcmp(name,'T1'))
        %errorbar(x,y,delta,'both','.', 'HandleVisibility', 'off', 'Color', [0.6 0.6 0.6], 'CapSize', 0);
    else
        %errorbar(x,y,delta,'vertical','.', 'HandleVisibility', 'off', 'Color', [0.6 0.6 0.6], 'CapSize', 0);
    end
    plot(x,yfit, 'Color', color, 'LineWidth', 1, 'DisplayName', sprintf(txt, name, logfit(1,1), logfit(1,2)));
    scaledScatter(logPlot, x, y, color, 10);
    
    csvName = fullfile(pwd, 'Analysis_Summary.csv');

    fileID = fopen(csvName, 'a');
    if(exist(csvName, 'file') ~= 2)
        fprintf(fileID, '%s, %s, %s, %s, %s\n', 'Subject', 'Protocol', 'Truncated Mean', 'Truncated SD', 'Truncated N');
    end
    fileID = fopen(csvName, 'a');
    fprintf(fileID, '%s, %s, %5.4f, %5.4f, %d\n', subjectCode, name, avg, sd, N);
    
    folderName = fullfile(pwd, 'Subject_Data', subjectCode);
    mkdir(folderName);
    fileName = sprintf('%s%s%s%s', subjectCode, '_', name, '_divided.png');
    saveas(divided, fullfile(folderName, fileName));
    fileName = sprintf('%s%s%s%s', subjectCode, '_', name, '_distribution.png');
    saveas(distribution, fullfile(folderName, fileName));
end