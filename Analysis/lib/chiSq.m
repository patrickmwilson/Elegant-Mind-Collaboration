function [chiSq,neg,pos] = chiSq(slope,intercept,data,fig)

    figure(fig);

    xvals = data(:,1)';
    yvals = data(:,2)';

    variance = (data(:,3)').^2;
    
    %To avoid error caused by dividing by zero
    variance(variance == 0) = 0.000001;
    
    w = 1./variance;
    f = @(x,xvals,yvals,w)sum(w.*((yvals-( (xvals.*x)+intercept )).^2));
    fun = @(x)f(x,xvals,yvals,w);
    
    evals = linspace(slope*0.5,slope*1.5,1001);
    
    center = 501;
    evals(center) = slope;
    chiSq = fun(slope);
    
    chi = cellfun(fun,num2cell(evals));
    
    txt = "Min: %4.3f = %4.3f";
    
    plot(evals, chi, 'Color', [0 0 0], 'LineWidth', 1, 'DisplayName', ...
        sprintf(txt, evals(center(1)), chiSq));
    
    hold on;
    grid on;
    box on;
    
    target = chiSq+1;
    
    linevals = ones(1,1001).*target;
    
    plot(evals, linevals, 'Color', [1 0 0], 'LineWidth', 1, ...
        'HandleVisibility', 'off');
    
    left = [];
    right = [];
    
    l = 1;
    r = 1;
    for i=1:length(chi)
        if i < center(1)
            dif = chi(i) - target;
            left(l,1) = dif;
            left(l,2) = evals(i);
            l = l + 1;
        elseif i > center(1)
            dif = chi(i) - target;
            right(r,1) = dif;
            right(r,2) = evals(i);
            r = r + 1;
        end
    end
    
    negIdx = find(left(:,1) == min(left(:,1)'));
    posIdx = find(right(:,1) == min(right(:,1)'));
    
    neg = left(negIdx(1),2);
    pos = right(posIdx(1),2);
    
    disp("chiSq");
    disp(chiSq);
    disp("neg");
    disp(neg);
    disp("min");
    disp(slope);
    disp("pos");
    disp(pos);
    
    formatFigure(fig, [-inf inf], [0 (chiSq*2)], ...
        "Slope",  ...
        "Chi^2", ...
        "Chi^2 vs. Slope Parameter", false);
    
end