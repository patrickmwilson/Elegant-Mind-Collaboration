% twoParamChiSq
%
% Optimizes the slope and intercept parameters of the y = ax + b fit to 
% minimize Chi^2. Plots Chi^2 vs. slope and intercept parameters as both a
% surface plot and colormap. Takes the data matrix, name, id, color of the 
% protocol, the parameter output struct, and a figure handle as input 
% arguments.
function [params,twoParamOutput] = twoParamChiSq(data,name,id,approx,twoParamOutput,surfFig,colorFig)
    
    % Extract x & y values from data matrix
    xvals = data(:,1)'; yvals = data(:,2)';
    
    % Variance is estimated as the standard error, then squared
    variance = (data(:,4)').^2;
    
    % Slight data shift to avoid division by zero
    variance(variance == 0) = 0.000001;
    
    % Weights are the inverse of (standard error)^2
    w = 1./variance;
    
    % Chi^2 function to be minimized
    f = @(x,xvals,yvals,w)sum(w.*((yvals-((xvals.*x(1))+x(2))).^2));
    fun = @(x)f(x,xvals,yvals,w);
    
    % MultiStart with the fmincon algorithm and 50 start points used to
    % locate a global minimum of the Chi^2 function. 
    ms = MultiStart;
    problem = createOptimProblem('fmincon','x0',approx, ...
        'objective',fun,'lb',[0,-1],'ub',[1,1]);
    params = run(ms,problem,50);
    chi_sq = fun(params);
    
    slope = params(1);
    intercept = params(2);
    
    % Reduced Chi^2 = Chi^2/(Degrees of Freedom)
    reduced_chi_sq = chi_sq/(length(xvals)-2);
    
    % Storing parameters in output struct
    twoParamOutput.(strcat(id, '_slope')) = slope;
    twoParamOutput.(strcat(id, '_intercept')) = intercept;
    twoParamOutput.(strcat(id, '_chi_sq')) = chi_sq;
    twoParamOutput.(strcat(id, '_reduced_chi_sq')) = reduced_chi_sq;
    
    % The standard error of the parameters is estimated as the parameter
    % value in both the + and - directions which results in a Chi^2 of + 1,
    % with the other parameter held constant (at its minimum value). 
    % fminbnd used to optimize this parameter, and the results are saved to 
    % the output struct
    target = chi_sq+1;
    f = @(x,intercept,xvals,yvals,w)abs(target-sum(w.*((yvals-((xvals.*x)+intercept)).^2)));
    
    % Targeting slope parameter
    fun = @(x)f(x,intercept,xvals,yvals,w);
    negSlopeError = fminbnd(fun,(slope*0.5),slope);
    posSlopeError = fminbnd(fun,slope,(slope*1.5));
    twoParamOutput.(strcat(id, '_slope_neg_error')) = negSlopeError;
    twoParamOutput.(strcat(id, '_slope_pos_error')) = posSlopeError;
    
    % Targeting intercept parameter
    f = @(slope,intercept,xvals,yvals,w)abs(target-sum(w.*((yvals-((xvals.*slope)+intercept)).^2)));
    fun = @(intercept)f(slope,intercept,xvals,yvals,w);
    negInterceptError = fminbnd(fun,-1,intercept);
    posInterceptError = fminbnd(fun,intercept,1);
    twoParamOutput.(strcat(id, '_intercept_neg_error')) = negInterceptError;
    twoParamOutput.(strcat(id, '_intercept_pos_error')) = posInterceptError;
    
%     target = chi_sq+2;
%     
%     f = @(x,intercept,xvals,yvals,w)abs(target-sum(w.*((yvals-((xvals.*x)+intercept)).^2)));
%     fun = @(x)f(x,intercept,xvals,yvals,w);
%     
%     slopeMin = fminbnd(fun,(slope*0.5),slope,options);
%     slopeMax = fminbnd(fun,slope,(slope*1.5),options);
%     
%     fun = @(intercept)f(slope,intercept,xvals,yvals,w);
%     
%     intMin = fminbnd(fun,-1,intercept,options);
%     intMax = fminbnd(fun,intercept,1,options);
%     
%     f = @(x,int,xvals,yvals,w)sum(w.*((yvals-((xvals.*x)+int)).^2));
%     fun = @(x,int)f(x,int,xvals,yvals,w);
%     
%     target = chi_sq+4;
    
    f = @(slope,intercept,xvals,yvals,w)sum(w.*((yvals-((xvals.*slope)+intercept)).^2));
    fun = @(slope,intercept)f(slope,intercept,xvals,yvals,w);

    % Initial range of slope and intercept values for the figures
    slope_range = [negSlopeError posSlopeError];
    int_range = [negInterceptError posInterceptError];
    
    % Generate a grid of slope, intercept, and Chi^2 values to be plotted
    complete = false;
    while(~complete)
        % Generate the grids
        [slope_grid, int_grid] = meshgrid(...
            linspace(slope_range(1), slope_range(2)), ...
            linspace(int_range(1), int_range(2)));
        chi_grid = cellfun(fun, num2cell(slope_grid), num2cell(int_grid));
        
        % Check the grid to ensure that the edges of the Chi^2 grid are all
        % greater than the minimum + 4
        [slope_range,int_range,complete] = checkGrid(chi_grid, ...
            slope_range, int_range, (chi_sq+4));
    end

    % -------- Plot Chi^2 vs. slope and intercept as 3d surface ----------
    figure(surfFig);
    
    chisqtext = "\chi^{2}"; redchisqtext = "\chi^{2}_{v}";
    txt = "Minimum at\nSlope: %4.2f\nIntercept: %4.2f\n%s: %4.2f\n%s: %4.2f";
    
    % Surface plot
    surf(slope_grid,int_grid,chi_grid,'FaceAlpha',0.6, ...
        'EdgeColor','none', 'HandleVisibility', 'off');
    
    % Reverse z axis
    set(gca, 'Zdir', 'reverse'); hold on;
    
    % Plot a countour line on the surface plot at a value of Chi^2+1
    contour3(slope_grid,int_grid,chi_grid,[(chi_sq+1) (chi_sq+1)], ...
        'ShowText','off', 'LineColor', 'k', 'LineWidth', 1.5, ...
        'HandleVisibility', 'off');
    
    % Plot invisible line for legend display
    line(nan, nan, 'Linestyle', 'none', 'Marker', 'none', 'Color', 'none', ...
        'DisplayName', ...
        sprintf(txt,slope,intercept,chisqtext,chi_sq,redchisqtext,reduced_chi_sq));
    
    cb = colorbar;
    
    axisPos = get(gca,'position');
    cbPos = [0.87 0.25 0.015 0.5]; % Shrink colorbar
    set(cb,'Position',cbPos); set(gca,'position', axisPos);
    set(cb, 'YDir', 'reverse'); % Reverse colorbar gradient direction
    
    cb.Label.String = chisqtext;
    pos = get(cb.Label,'Position');
    cb.Label.Position = [pos(1)*1.5 pos(2) 0]; % Move label outward
    cb.Label.Rotation = 0; % Rotate label 90° 
    cb.Label.FontSize = 12;
    
    title(sprintf('%s %s %s %s', "     ", name, chisqtext, ...
        "vs. Slope and Intercept Parameters (y = ax + b)"));
    
    xlabel("Slope"); ylabel("Intercept"); zlabel(chisqtext);
    
    grid on; box on;
    
    % Show legend with transparent background and no border at custom pos
    legend('show', 'Position', [0.14 0.35 0.1 0.2], 'EdgeColor', 'none', ...
        'Color', 'none');
       
    % -------- Plot Chi^2 vs. slope and intercept as colormap -------------
    figure(colorFig);
    
    % Surface plot
    ax = axes('Parent',colorFig);
    h = surf(slope_grid,int_grid,chi_grid,'Parent',ax,'edgecolor','none');
    
    hold on;
    
    % Plot a countour line on the surface plot at a value of Chi^2+1
    contour3(slope_grid,int_grid,chi_grid,[(chi_sq+1) (chi_sq+1)], ...
        'ShowText','off', 'LineColor', 'w', 'LineWidth', 1.2, ...
        'HandleVisibility', 'off');
    
    % Rotate figure view so surface plot becomes 2d
    set(h, 'edgecolor','none');
    view(ax,[0,90]);
    colormap(parula);
    
    ccb = colorbar;
    ccb.Label.String = chisqtext;
    pos = get(ccb.Label,'Position');
    ccb.Label.Position = [pos(1)*1.3 pos(2) 0]; % Move label outward
    ccb.Label.Rotation = 0; % Rotate label 90°
    ccb.Label.FontSize = 12;
    
    title(sprintf('%s %s %s %s', "     ", name, chisqtext, ...
        "vs. Slope and Intercept Parameters (y = ax + b)"));
    xlabel("Slope"); ylabel("Intercept");
    
    xlim(slope_range); ylim(int_range);
end