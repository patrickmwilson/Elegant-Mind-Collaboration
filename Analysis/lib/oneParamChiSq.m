function [slope, oneParamOutput] = oneParamChiSq(data,name,id,color,oneParamOutput,fig)

    xvals = data(:,1)';
    yvals = data(:,2)';
    
    stdev = data(:,3)';
    stdev(stdev == 0) = 0.1;
    
    variance = (data(:,4)').^2;
    
    variance(variance == 0) = 0.000001;
    
    % Weights are assumed to be 1/standard error, normalized to 0-1
    w = 1./variance;
    
    % Chi^2 equation to be minimized
    f = @(x,xvals,yvals,w)sum((w.*((yvals-(xvals.*x))).^2));
    fun = @(x)f(x,xvals,yvals,w);
    
    approx = mean(yvals./xvals);
    [slope, chi_sq] = fminbnd(fun,(approx*0.5),(approx*1.5));
    
    reduced_chi_sq = chi_sq/(length(xvals)-1);
    
    oneParamOutput.(strcat(id, '_slope')) = slope;
    oneParamOutput.(strcat(id, '_chi_sq')) = chi_sq;
    oneParamOutput.(strcat(id, '_reduced_chi_sq')) = reduced_chi_sq;
    
    target = chi_sq+1;
    
    negError = slope;
    mult = 0.5;
    increment = 0.1;
    while negError == slope
        if mult > 1
            break;
        end
        evals = linspace(slope*mult, slope, 100000);
        chi = cellfun(fun,num2cell(evals));
        chi = abs(target-chi);
        slopeIdx = find(chi == min(chi));
        negError = evals(slopeIdx(1));
        
        if mult >= 0.9
            increment = 0.01;
        elseif mult >= 0.95
            increment = 0.001;
        end
        
        mult = mult + increment;
    end
    
    oneParamOutput.(strcat(id, '_neg_error')) = negError;
    
    posError = slope;
    mult = 1.5;
    increment = 0.1;
    while posError == slope
        if mult < 1
            break;
        end
        
        evals = linspace(slope*mult, slope, 100000);
        chi = cellfun(fun,num2cell(evals));
        chi = abs(target-chi);
        slopeIdx = find(chi == min(chi));
        posError = evals(slopeIdx(1));
        
        if mult <= 1.1
            increment = 0.01;
        elseif mult <= 1.05
            increment = 0.001;
        end
        
        mult = mult - increment;
    end
    
    oneParamOutput.(strcat(id, '_pos_error')) = posError;
    
    evals = linspace((slope*0.5), (slope*1.5));
    chi = cellfun(fun,num2cell(evals));
    
    %Plotting Chi^2 vs. Slope parameter
    figure(fig);
    hold on; 
    chisqtext = "\chi^{2}";
    redchisqtext = "\chi^{2}_{v}";
    txt = "%s min: %4.3f, %s: %4.3f, Slope: %4.3f";
    
    plot(evals, chi, 'Color', color, 'LineWidth', 1, 'DisplayName', ...
        sprintf(txt, chisqtext, chi_sq, redchisqtext, reduced_chi_sq, slope));
    
    yline = ones(length(evals)).*target;
    plot(evals, yline, 'Color', [1 0 0], 'LineWidth', 1, ...
        'HandleVisibility', 'off');
    
    titleText = sprintf('%s %s %s', name, chisqtext, "vs. Slope Parameter (y = ax)");
    
    formatFigure(fig, [0 (max(evals)+min(evals))], [0 (target*2)], "Slope", ...
        chisqtext, titleText, false);
    
end