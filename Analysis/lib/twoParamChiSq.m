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
    
    f = @(x,intercept,xvals,yvals,w)sum(w.*((yvals-((xvals.*x)+intercept)).^2));
    fun = @(x)f(x,intercept,xvals,yvals,w);
    
    target = chi_sq+1;
    
    negSlopeError = slope;
    mult = 0.5;
    increment = 0.1;
    while negSlopeError == slope
        if mult > 1
            break;
        end
        
        evals = linspace(slope*mult, slope, 100000);
        chi = cellfun(fun,num2cell(evals));
        chi = abs(target-chi);
        slopeIdx = find(chi == min(chi));
        negSlopeError = evals(slopeIdx(1));
        
        if mult >= 0.9
            increment = 0.01;
        elseif mult >= 0.95
            increment = 0.001;
        end
        
        mult = mult + increment;
    end
    
    twoParamOutput.(strcat(id, '_slope_neg_error')) = negSlopeError;
    
    posSlopeError = slope;
    mult = 1.5;
    increment = 0.1;
    while posSlopeError == slope
        if mult < 1
            break;
        end
        evals = linspace(slope*mult, slope, 100000);
        chi = cellfun(fun,num2cell(evals));
        chi = abs(target-chi);
        slopeIdx = find(chi == min(chi));
        posSlopeError = evals(slopeIdx(1));
        
        if mult <= 1.1
            increment = 0.01;
        elseif mult <= 1.05
            increment = 0.001;
        end
        
        mult = mult - increment;
    end
    
    twoParamOutput.(strcat(id, '_slope_pos_error')) = posSlopeError;
    
    f = @(slope,intercept,xvals,yvals,w)sum(w.*((yvals-((xvals.*slope)+intercept)).^2));
    fun = @(intercept)f(slope,intercept,xvals,yvals,w);
    
    negInterceptError = intercept;
    mult = 0.5;
    increment = 0.1;
    while negInterceptError == intercept
        if mult > 1
            break;
        end
        
        evals = linspace(intercept*mult, intercept, 100000);
        chi = cellfun(fun,num2cell(evals));
        chi = abs(target-chi);
        intIdx = find(chi == min(chi));
        negInterceptError = evals(intIdx(1));
        
        if mult >= 0.9
            increment = 0.01;
        elseif mult >= 0.95
            increment = 0.001;
        end
        
        mult = mult + increment;
    end
    
    posInterceptError = intercept;
    mult = 1.5;
    increment = 0.1;
    while posInterceptError == intercept
        if mult < 1
            break;
        end
        evals = linspace(intercept*mult, intercept, 100000);
        chi = cellfun(fun,num2cell(evals));
        chi = abs(target-chi);
        intIdx = find(chi == min(chi));
        posInterceptError = evals(intIdx(1));
        
        if mult <= 1.1
            increment = 0.01;
        elseif mult <= 1.05
            increment = 0.001;
        end
        
        mult = mult - increment;
    end
    
    if negInterceptError > posInterceptError
        temp = negInterceptError;
        negInterceptError = posInterceptError;
        posInterceptError = temp;
    end
    
    twoParamOutput.(strcat(id, '_intercept_neg_error')) = negInterceptError;
    twoParamOutput.(strcat(id, '_intercept_pos_error')) = posInterceptError;
    
    posSlopeDist = (posSlopeError-slope)*2;
    negSlopeDist = (slope-negSlopeError)*2;
    
    slope_evals = linspace((slope-negSlopeDist),(slope+posSlopeDist));
    
    posIntDist = (posInterceptError-intercept)*4;
    negIntDist = (intercept-negInterceptError)*4;
    
    int_evals = linspace((intercept-negIntDist),(intercept+posIntDist));
    
    [slope_grid, int_grid] = meshgrid(slope_evals,int_evals);
    
    f = @(x,int,xvals,yvals,w)sum(w.*((yvals-((xvals.*x)+int)).^2));
    fun = @(x,int)f(x,int,xvals,yvals,w);
    
    chi_grid = cellfun(fun,num2cell(slope_grid),num2cell(int_grid));
    
    figure(surfFig);
    
    chisqtext = "\chi^{2}";
    redchisqtext = "\chi^{2}_{v}";
    txt = "Minimum at\nSlope: %4.2f\nIntercept: %4.2f\n%s: %4.2f\n%s: %4.2f";
    
    surf(slope_grid,int_grid,chi_grid,'FaceAlpha',0.4, ...
        'EdgeColor','none', 'HandleVisibility', 'off');
    
    hold on;
    
    cb = colorbar;
    
    axisPos = get(gca,'position');
    cbPos = get(cb,'Position');
    
    cbPos(1) = 0.87;
    cbPos(2) = 0.25;
    cbPos(3) = 0.015;
    cbPos(4) = 0.5;
    
    set(cb,'Position',cbPos);
    set(gca,'position', axisPos);
    
    line(nan, nan, 'Linestyle', 'none', 'Marker', 'none', 'Color', 'none', ...
        'DisplayName', ...
        sprintf(txt,slope,intercept,chisqtext,chi_sq,redchisqtext,reduced_chi_sq));
    
    titleText = sprintf('%s %s %s %s', "     ", name, chisqtext, ...
        "vs. Slope and Intercept Parameters (y = ax + b)");
    
    title(titleText);
    xlabel("Slope");
    ylabel("Intercept");
    zlabel(chisqtext);

    legend('show', 'Position', [0.2 0.6 0.1 0.2], 'EdgeColor', 'none', ...
        'Color', 'none');
    grid on;
    
    figure(colorFig);

    posSlopeDist = (posSlopeError-slope)*1.05;
    negSlopeDist = (slope-negSlopeError)*1.05;
    
    slope_evals = linspace((slope-negSlopeDist),(slope+posSlopeDist));
    
    posIntDist = (posInterceptError-intercept)*1.5;
    negIntDist = (intercept-negInterceptError)*1.5;
    
    int_evals = linspace((intercept-negIntDist),(intercept+posIntDist));
    
    [slope_grid, int_grid] = meshgrid(slope_evals,int_evals);
    
    chi_grid = cellfun(fun,num2cell(slope_grid),num2cell(int_grid));
    
    ax = axes('Parent',colorFig);
    h = surf(slope_grid,int_grid,chi_grid,'Parent',ax);
    hold on;
    set(h, 'edgecolor','none');
    view(ax,[0,90]);
    colormap(jet);
    ccb = colorbar;
    
    ccb.Label.String = chisqtext;
    
    pos = get(ccb.Label,'Position');
    ccb.Label.Position = [pos(1)*1.3 pos(2) 0]; % to change its position
    ccb.Label.Rotation = 0; % to rotate the text
    ccb.Label.FontSize = 12;
    
    title(titleText);
    xlabel("Slope");
    ylabel("Intercept");
    
    xlim([min(slope_evals) max(slope_evals)]);
    ylim([min(int_evals) max(int_evals)]);
    
end