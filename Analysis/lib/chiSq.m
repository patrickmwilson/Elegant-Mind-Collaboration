function [chiSq,chiSqReduced,neg,pos] = chiSq(slope,intercept,data,fig)

    figure(fig);

    %Extracting x, y, and variance vectors
    xvals = data(:,1)';
    yvals = data(:,2)';
    variance = (data(:,3)').^2;
    
    %To avoid error caused by dividing by zero
    variance(variance == 0) = 0.000001;
    
    %Variances for chi^2 minimization
    w = 1./variance;
    
    %Chi square function
    f = @(x,xvals,yvals,w)sum(w.*((yvals-( (xvals.*x)+intercept )).^2));
    fun = @(x)f(x,xvals,yvals,w);
    
    %Range of 1000 slope parameters from slope/2 to slope*2 for evaluation
    evals = [(linspace((slope/2),(slope-0.00001),100000)), slope, ...
        (linspace((slope+0.00001), (slope*2), 100000))];
    center = 100001;
    
    %Applying Chi^2 function to all evals
    chi = cellfun(fun,num2cell(evals));
    chiSq = fun(slope);
    
    if intercept == 0
        dof = length(w) - 1;
    else
        dof = length(w) - 2;
    end
    chiSqReduced = chiSq/dof;
    
    %Plotting Chi^2 vs. Slope parameter
    txt = "Min: %4.3f = %4.3f";
    plot(evals, chi, 'Color', [0 0 0], 'LineWidth', 1, 'DisplayName', ...
        sprintf(txt, slope, chiSq));
    
    hold on; grid on; box on;
    
    %Chi^2 target for error of slope parameter
    target = chiSq+1;
  
    %Plot a red line at a height of Chi^2+1
    %linevals = ones(length(evals)).*target;
    xline = linspace(min(evals),max(evals));
    yline = ones(length(xline)).*target;
    plot(xline, yline, 'Color', [1 0 0], 'LineWidth', 1, ...
        'HandleVisibility', 'off');
    
    %Struct to hold slope values at +1 Chi^2
    left = struct('slope', slope, 'chi', 0, 'dif', inf);
    right = struct('slope', slope, 'chi', 0, 'dif', inf);
    for i=1:length(chi)
        this_slope = evals(i);
        this_chi = chi(i);
        dif = abs(target-this_chi);
        
        if i < center
            if dif < left.dif && left.slope ~= this_slope
                left.slope = this_slope;
                left.chi = this_chi;
                left.dif = dif;
            end
        elseif i > center
            if dif < right.dif && right.slope ~= this_slope
                right.slope = this_slope;
                right.chi = this_chi;
                right.dif = dif;
            end
        end
    end
    
    disp('ChiSq');
    disp(chiSq);
    disp('Left Side');
    disp(left);
    disp('Center');
    disp(slope);
    disp('Right Side');
    disp(right);
    
    neg = left.slope;
    pos = right.slope;
    
    if intercept == 0
        titleText = "Chi^2 vs. Slope Parameter (y = ax)";
    else
        titleText = "Chi^2 vs. Slope Parameter (y = ax + b)";
    end
    
    formatFigure(fig, [-inf inf], [0 (target*2)], "Slope",  "Chi^2", ...
        titleText, false);
    
end