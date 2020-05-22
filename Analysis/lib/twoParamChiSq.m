function [params,twoParamOutput] = twoParamChiSq(data,name,id,twoParamOutput,fig)

    xvals = data(:,1)';
    yvals = data(:,2)';
    
    variance = (data(:,3)').^2;
    
    variance(variance == 0) = 0.000001;
    
    % Weights are assumed to be 1/standard error, normalized to 0-1
    w = 1./variance;
    
    %Estimate parameters
    approx = polyfit(xvals,yvals,1);
    
    %Chi square function
    f = @(x,xvals,yvals,w)sum(w.*((yvals-((xvals.*x(1))+x(2))).^2));
    fun = @(x)f(x,xvals,yvals,w);
    
    [params,chi_sq] = fminsearch(fun,approx); 
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
    
    evals = linspace(slope*0.5, slope, 100000);
    chi = cellfun(fun,num2cell(evals));
    chi = abs(chi - target);
    negChi = min(chi);
    negError = evals(find(chi == min(chi)));
    
    twoParamOutput.(strcat(id, '_neg_error')) = negError;
    
    evals = linspace(slope, slope*1.5, 100000);
    chi = cellfun(fun,num2cell(evals));
    chi = abs(chi - target);
    posChi = min(chi);
    posError = evals(find(chi == min(chi)));
    
    twoParamOutput.(strcat(id, '_pos_error')) = posError;
    
    slope_evals = linspace((slope*0.5),(slope*1.5));
    int_evals = linspace((intercept*0.5),(intercept*1.5));
    
    [slope_grid, int_grid] = meshgrid(slope_evals,int_evals);
    
    f = @(x,int,xvals,yvals,w)sum(w.*((yvals-((xvals.*x)+int)).^2));
    fun = @(x,int)f(x,int,xvals,yvals,w);
    
    chi_grid = cellfun(fun,num2cell(slope_grid),num2cell(int_grid));
    
    figure(fig);
    hold on; grid on;
    
    mesh(slope_grid,int_grid,chi_grid);
    
    colormap(winter);
    
    titleText = sprintf('%s %s', name, "Chi^2 vs. a and b Parameters (y=ax+b)");
    title(titleText);
    xlabel("Slope");
    ylabel("Intercept");
    zlabel("Chi^2");
    
end