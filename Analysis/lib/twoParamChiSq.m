function [params,twoParamOutput] = twoParamChiSq(data,name,id,approx,twoParamOutput,surfFig,colorFig)

    xvals = data(:,1)';
    yvals = data(:,2)';
    
    variance = (data(:,4)').^2;
    
    variance(variance == 0) = 0.000001;
    
    % Weights are assumed to be 1/standard error, normalized to 0-1
    w = 1./variance;
    
    %Chi square function
    f = @(x,xvals,yvals,w)sum(w.*((yvals-((xvals.*x(1))+x(2))).^2));
    fun = @(x)f(x,xvals,yvals,w);
    
    ms = MultiStart;
    problem = createOptimProblem('fmincon','x0',approx, ...
        'objective',fun,'lb',[0,-1],'ub',[1,1]);
    params = run(ms,problem,50);
    chi_sq = fun(params);
    
    slope = params(1);
    intercept = params(2);
    reduced_chi_sq = chi_sq/(length(xvals)-2);
    
    twoParamOutput.(strcat(id, '_slope')) = slope;
    twoParamOutput.(strcat(id, '_intercept')) = intercept;
    twoParamOutput.(strcat(id, '_chi_sq')) = chi_sq;
    twoParamOutput.(strcat(id, '_reduced_chi_sq')) = reduced_chi_sq;
    
    target = chi_sq+1;
    
    f = @(x,intercept,xvals,yvals,w)abs(target-sum(w.*((yvals-((xvals.*x)+intercept)).^2)));
    fun = @(x)f(x,intercept,xvals,yvals,w);
    
    options = optimset('Display','iter');
    negSlopeError = fminbnd(fun,(slope*0.5),slope,options);
    posSlopeError = fminbnd(fun,slope,(slope*1.5),options);
    
    twoParamOutput.(strcat(id, '_slope_neg_error')) = negSlopeError;
    twoParamOutput.(strcat(id, '_slope_pos_error')) = posSlopeError;
    
    target = chi_sq+2;
    
    f = @(x,intercept,xvals,yvals,w)abs(target-sum(w.*((yvals-((xvals.*x)+intercept)).^2)));
    fun = @(x)f(x,intercept,xvals,yvals,w);
    
    slopeMin = fminbnd(fun,(slope*0.5),slope,options);
    slopeMax = fminbnd(fun,slope,(slope*1.5),options);
    
    target = chi_sq+1;
    
    f = @(slope,intercept,xvals,yvals,w)abs(target-sum(w.*((yvals-((xvals.*slope)+intercept)).^2)));
    fun = @(intercept)f(slope,intercept,xvals,yvals,w);
    
    negInterceptError = fminbnd(fun,-1,intercept,options);
    posInterceptError = fminbnd(fun,intercept,1,options);
    
    twoParamOutput.(strcat(id, '_intercept_neg_error')) = negInterceptError;
    twoParamOutput.(strcat(id, '_intercept_pos_error')) = posInterceptError;
    
    target = chi_sq+2;
    
    f = @(slope,intercept,xvals,yvals,w)abs(target-sum(w.*((yvals-((xvals.*slope)+intercept)).^2)));
    fun = @(intercept)f(slope,intercept,xvals,yvals,w);
    
    intMin = fminbnd(fun,-1,intercept,options);
    intMax = fminbnd(fun,intercept,1,options);
    
%     slope_evals = linspace((slopeMin-(abs(slopeMin)*0.2)), ...
%         slopeMax+(abs(slopeMax)*0.2));
%     
%     int_evals = linspace((intMin-(abs(intMin)*0.2)), ...
%         (slopeMin+(abs(intMax)*0.2)));
%     
%     [slope_grid, int_grid] = meshgrid(slope_evals,int_evals);
%     
    f = @(x,int,xvals,yvals,w)sum(w.*((yvals-((xvals.*x)+int)).^2));
    fun = @(x,int)f(x,int,xvals,yvals,w);
    
    target = chi_sq+4;
    
    slope_range = [slopeMin slopeMax];
    int_range = [intMin intMax];
    
    complete = false;
    while(~complete)
        [slope_grid, int_grid] = meshgrid(...
            linspace(slope_range(1), slope_range(2)), ...
            linspace(int_range(1), int_range(2)));
        
        chi_grid = cellfun(fun, num2cell(slope_grid), num2cell(int_grid));
        
        [slope_range,int_range,complete] = checkGrid(chi_grid, ...
            slope_range, int_range, target);
    end
    
    figure(surfFig);
    
    chisqtext = "\chi^{2}";
    redchisqtext = "\chi^{2}_{v}";
    txt = "Minimum at\nSlope: %4.2f\nIntercept: %4.2f\n%s: %4.2f\n%s: %4.2f";
    
    surf(slope_grid,int_grid,chi_grid,'FaceAlpha',0.6, ...
        'EdgeColor','none', 'HandleVisibility', 'off');
    
    set(gca, 'Zdir', 'reverse');
    
    hold on;
    
    contour3(slope_grid,int_grid,chi_grid,[(chi_sq+1) (chi_sq+1)], ...
        'ShowText','off', 'LineColor', 'k', 'LineWidth', 1.5, ...
        'HandleVisibility', 'off');
    
    line(nan, nan, 'Linestyle', 'none', 'Marker', 'none', 'Color', 'none', ...
        'DisplayName', ...
        sprintf(txt,slope,intercept,chisqtext,chi_sq,redchisqtext,reduced_chi_sq));
    
    cb = colorbar;
    
    axisPos = get(gca,'position');
%     cbPos = get(cb,'Position');
    cbPos = [0.87 0.25 0.015 0.5];
%     cbPos(1) = 0.87;
%     cbPos(2) = 0.25;
%     cbPos(3) = 0.015;
%     cbPos(4) = 0.5;
    set(cb,'Position',cbPos);
    set(gca,'position', axisPos);
    set(cb, 'YDir', 'reverse');
    
    cb.Label.String = chisqtext;
    
    pos = get(cb.Label,'Position');
    cb.Label.Position = [pos(1)*1.5 pos(2) 0]; 
    cb.Label.Rotation = 0; 
    cb.Label.FontSize = 12;
    
    title(sprintf('%s %s %s %s', "     ", name, chisqtext, ...
        "vs. Slope and Intercept Parameters (y = ax + b)"));
    xlabel("Slope");
    ylabel("Intercept");
    zlabel(chisqtext);
    grid on; box on;

    legend('show', 'Position', [0.14 0.35 0.1 0.2], 'EdgeColor', 'none', ...
        'Color', 'none');
    
    figure(colorFig);
    
    ax = axes('Parent',colorFig);
    h = surf(slope_grid,int_grid,chi_grid,'Parent',ax,'edgecolor','none');
    hold on;
    contour3(slope_grid,int_grid,chi_grid,[(chi_sq+1) (chi_sq+1)], ...
        'ShowText','off', 'LineColor', 'w', 'LineWidth', 1.2, ...
        'HandleVisibility', 'off');
    set(h, 'edgecolor','none');
    view(ax,[0,90]);
    colormap(jet);
    ccb = colorbar;
    
    ccb.Label.String = chisqtext;
    
    pos = get(ccb.Label,'Position');
    ccb.Label.Position = [pos(1)*1.3 pos(2) 0]; 
    ccb.Label.Rotation = 0; 
    ccb.Label.FontSize = 12;
    
    title(sprintf('%s %s %s %s', "     ", name, chisqtext, ...
        "vs. Slope and Intercept Parameters (y = ax + b)"));
    xlabel("Slope");
    ylabel("Intercept");
    
    xlim(slope_range);
    ylim(int_range);
    
end