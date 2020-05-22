function pointSlope(data,params,name,color,errorBarDirection,fig)

    figure(fig);
    if length(params) == 1
        slope = params(1);
        intercept = 0;
        txt = "%s : y = %4.3fx";
    else
        slope = params(1);
        intercept = params(2);
        if intercept > 0
            txt = "%s : y = %4.3fx + %4.3f";
        else
            txt = "%s : y = %4.3fx %4.3f";
        end
    end
    
    % Chi-squared minimization for fit line was completed by previous
    % normalization of letter height/eccentricity. y = avg*x
    xfit = linspace(0, max((data(:,1))'));
    yfit = (xfit*slope)+intercept;
    
    % Plotting error bars
    hold on;
    if(~strcmp(name,'Anstis'))
        errorbar(data(:,1), data(:,2), data(:,3), errorBarDirection,'.', ...
            'HandleVisibility', 'off', 'Color', [0.43 0.43 0.43], ...
            'CapSize', 0);
    end
    
    % Plotting fit line
    hold on;
    if intercept == 0
        plot(xfit, yfit, 'Color', color, 'LineWidth', 1, 'DisplayName', ...
            sprintf(txt, name, slope));
    else
        plot(xfit, yfit, 'Color', color, 'LineWidth', 1, 'DisplayName', ...
            sprintf(txt, name, slope, intercept));
    end
    
    scatter(data(:,1),data(:,2),30,color,'filled','HandleVisibility','off');
    
end