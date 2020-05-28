% pointSlope
%
% Creates a scatterplot with a regression line. Accepts a data matrix, fit
% parameters, protocol name, color, the error bar direction, and a figure
% handle as input arguments. Scatters the data, the first column as x
% values and the second as y values.
function pointSlope(data,params,name,color,errorBarDirection,fig)

    figure(fig);
    
    % Extract slope and intercept values from the params array, set the
    % legend text based upon whether or not an intercept was given
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
    
    % Create values for the regression line
    xfit = linspace(0, max((data(:,1))'));
    yfit = (xfit*slope)+intercept;
    
    % Plot error bars
    hold on;
    if(~strcmp(name,'Anstis'))
        errorbar(data(:,1), data(:,2), data(:,3), errorBarDirection,'.', ...
            'HandleVisibility', 'off', 'Color', [0.43 0.43 0.43], ...
            'CapSize', 0);
    end
    
    % Plot fit line
    if intercept == 0
        plot(xfit, yfit, 'Color', color, 'LineWidth', 1, 'DisplayName', ...
            sprintf(txt, name, slope));
    else
        plot(xfit, yfit, 'Color', color, 'LineWidth', 1, 'DisplayName', ...
            sprintf(txt, name, slope, intercept));
    end
    
    % Scatter data
    scatter(data(:,1),data(:,2),30,color,'filled','HandleVisibility','off');
end