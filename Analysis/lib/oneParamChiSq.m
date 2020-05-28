% oneParamChiSq
%
% Optimizes the slope parameter of the y = ax fit to minimize Chi^2.
% Plots Chi^2 vs. slope parameter. Takes the data matrix, name, id, color
% of the protocol, the parameter output struct, and a figure handle as
% input arguments.
function [slope, oneParamOutput] = oneParamChiSq(data,name,id,color,oneParamOutput,fig)
    
    % Extract x & y values from data matrix
    xvals = data(:,1)'; yvals = data(:,2)';
    
    % Variance is estimated as the standard error, then squared
    variance = (data(:,4)').^2;
    
    % Slight data shift to avoid division by zero
    variance(variance == 0) = 0.000001;
    
    % Weights are the inverse of (standard error)^2
    w = 1./variance;
    
    % Chi^2 equation to be minimized
    f = @(x,xvals,yvals,w)sum((w.*((yvals-(xvals.*x))).^2));
    fun = @(x)f(x,xvals,yvals,w);
    
%     % Minimization algorithm to optimize slope parameter. Bounds are 
%     approx = mean(yvals./xvals);
%     [slope, chi_sq] = fminbnd(fun,(approx*0.5),(approx*1.5));

    % Minimization algorithm that searches for the optimal slope value in
    % the range of 0 -> 1. Returns slope and Chi^2
    [slope, chi_sq] = fminbnd(fun,0,1);
    
    % Reduced Chi^2 = Chi^2/(Degrees of Freedom)
    reduced_chi_sq = chi_sq/(length(xvals)-1);
    
    % Store parameters in output struct
    oneParamOutput.(strcat(id, '_slope')) = slope;
    oneParamOutput.(strcat(id, '_chi_sq')) = chi_sq;
    oneParamOutput.(strcat(id, '_reduced_chi_sq')) = reduced_chi_sq;
    
    %Plotting Chi^2 vs. Slope parameter
    figure(fig); hold on; 
    
    chisqtext = "\chi^{2}"; redchisqtext = "\chi^{2}_{v}";
    
    % Evalate the Chi^2 for slope values in the range of the optimum value
    % *0.5 -> *1.5, and plot these values vs. the slope values
    evals = linspace((slope*0.5), (slope*1.5));
    chi = cellfun(fun,num2cell(evals));
    txt = "%s min: %4.3f, %s: %4.3f, Slope: %4.3f";
    plot(evals, chi, 'Color', color, 'LineWidth', 1, 'DisplayName', ...
        sprintf(txt, chisqtext, chi_sq, redchisqtext, reduced_chi_sq, slope));
    
    % Plot a horizontal red line at a value of Chi^2 + 1
    yline = ones(length(evals)).*(chi_sq+1);
    plot(evals, yline, 'Color', [1 0 0], 'LineWidth', 1, ...
        'HandleVisibility', 'off');
    
    titleText = sprintf('%s %s %s', name, chisqtext, "vs. Slope Parameter (y = ax)");
    
    % The standard error of the slope parameter is calculated as the slope
    % value in both the + and - directions which results in a Chi^2 of + 1.
    % fminbnd is again used to optimize this parameter, and the results are
    % saved to the output struct
    target = chi_sq+1;
    f = @(x,xvals,yvals,w)abs(target-sum((w.*((yvals-(xvals.*x))).^2)));
    fun = @(x)f(x,xvals,yvals,w);
    
    negError = fminbnd(fun,(slope*0.5),slope);
    posError = fminbnd(fun,slope,(slope*1.5));
    
    oneParamOutput.(strcat(id, '_neg_error')) = negError;
    oneParamOutput.(strcat(id, '_pos_error')) = posError;
    
    formatFigure(fig, [0 (max(evals)+min(evals))], [0 (target*2)], "Slope", ...
        chisqtext, titleText, false);
end