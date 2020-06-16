% pointSlope
%
% Creates a scatterplot with a regression line. Accepts a data matrix, fit
% parameters, protocol name, color, the error bar direction, and a figure
% handle as input arguments. Scatters the data, the first column as x
% values and the second as y values.
function pointSlope(data,params,info,fig)

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
    
    if slope > 0
        % Create values for the regression line
        xfit = linspace(0, max((data(:,1))'));
    else
        xfit = linspace(min(data(:,1)'), 0);
    end
    
    yfit = (xfit*slope)+intercept;
    
    % Plot error bars
    hold on;
    if(~strcmp(info.name,'Anstis'))
        errorbar(data(:,1), data(:,2), data(:,3), info.errorBarDirection,'.', ...
            'HandleVisibility', 'off', 'Color', [0.43 0.43 0.43], ...
            'CapSize', 0);
    end
    
    % Plot fit line
    if intercept == 0
        plot(xfit, yfit, 'Color', info.color, 'LineWidth', 1, 'DisplayName', ...
            sprintf(txt, info.name, abs(slope)));
    else
        plot(xfit, yfit, 'Color', info.color, 'LineWidth', 1, 'DisplayName', ...
            sprintf(txt, info.name, abs(slope), intercept));
    end
    
    % Scatter data
    scatter(data(:,1),data(:,2),30,info.color,'filled','HandleVisibility','off');
end