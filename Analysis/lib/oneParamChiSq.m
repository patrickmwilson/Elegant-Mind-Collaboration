function [slope, oneParamOutput] = oneParamChiSq(data,name,id,color,oneParamOutput,fig)

    xvals = data(:,1)';
    yvals = data(:,2)';
    
    stdev = data(:,3)';
    stdev(stdev == 0) = 0.1;
    
    variance = (data(:,3)').^2;
    
    variance(variance == 0) = 0.000001;
    
    % Weights are assumed to be 1/standard error, normalized to 0-1
    w = 1./variance;
    
    % Chi^2 equation to be minimized
    f = @(x,xvals,yvals,w)sum((w.*((yvals-(xvals.*x))).^2));
    fun = @(x)f(x,xvals,yvals,w);
    
    options = optimset('Display','iter');
    approx = mean(yvals./xvals);
    [slope, chi_sq] = fminbnd(fun,(approx*0.5),(approx*1.5),options);
    
    reduced_chi_sq = chi_sq/(length(xvals)-1);
    
    oneParamOutput.(strcat(id, '_slope')) = slope;
    oneParamOutput.(strcat(id, '_chi_sq')) = chi_sq;
    oneParamOutput.(strcat(id, '_reduced_chi_sq')) = reduced_chi_sq;
    
    target = chi_sq+1;
    
    evals = linspace(slope*0.5, slope, 100000);
    chi = cellfun(fun,num2cell(evals));
    chi = abs(target-chi);
    negChi = min(chi);
    negError = evals(find(chi == min(chi)));
    
    oneParamOutput.(strcat(id, '_neg_error')) = negError;
    
    evals = linspace(slope, slope*1.5, 1000000);
    chi = cellfun(fun,num2cell(evals));
    chi = abs(chi - target);
    posChi = min(chi);
    posError = evals(find(chi == min(chi)));
    
    oneParamOutput.(strcat(id, '_pos_error')) = posError;
    
    evals = linspace((slope*0.5), (slope*1.5));
    chi = cellfun(fun,num2cell(evals));
    
    %Plotting Chi^2 vs. Slope parameter
    figure(fig);
    hold on; 
    txt = "Chi^2 min: %4.3f, Reduced Chi^2: %4.3f, Slope: %4.3f";
    
    plot(evals, chi, 'Color', color, 'LineWidth', 1, 'DisplayName', ...
        sprintf(txt, chi_sq, reduced_chi_sq, slope));
    
    yline = ones(length(evals)).*target;
    plot(evals, yline, 'Color', [1 0 0], 'LineWidth', 1, ...
        'HandleVisibility', 'off');
    
    titleText = sprintf('%s %s', name, "Chi^2 vs. Slope Parameter (y = ax)");
    
    formatFigure(fig, [0 max(evals)], [0 (target*1.3)], "Slope",  "Chi^2", ...
        titleText, false);
    
end