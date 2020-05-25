function p = polyfitter(data,name,color,errorBarDirection,fig)

    figure(fig);
    
    if(~strcmp(name,'Anstis'))
        data(:,3) = data(:,3)./sqrt(data(:,4));
    end
    
    p = polyfit(data(:,1)',data(:,2)',1);
    xfit = linspace(0, max((data(:,1))'));
    yfit = polyval(p,xfit);
    
    if p(1,2) >= 0
        txt = "%s: y = %4.3fx + %4.3f";
    else
        txt = "%s: y = %4.3fx %4.3f";
    end
    
    % Plotting error bars
    hold on;
    errorbar(data(:,1), data(:,2), data(:,3), errorBarDirection,'.', ...
        'HandleVisibility', 'off', 'Color', [0.43 0.43 0.43], 'CapSize', 0);
    
    % Plotting fit line
    hold on;
    plot(xfit, yfit, 'Color', color, 'LineWidth', 1, 'DisplayName', ...
        sprintf(txt, name, p(1,1), p(1,2)));
    
    scatter(data(:,1),data(:,2),30,color,'filled', ...
        'HandleVisibility','off');
    legend('show', 'Location', 'best');
end