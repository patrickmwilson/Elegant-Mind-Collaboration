function [avgData, wssAvg] = wss(data,name,avg)
    % Average replicate observations at discrete values
    clear avgData;
    clear wssAvg;
    clear('averageData');
    avgData = averageData(data,(1+(strcmp(name,'T1'))));

    if(strcmp(name,'Anstis'))
        avgData(:,3) = 0;
        wssAvg = 0.52;
        return;
    end
    
    clear xvals;
    clear yvals;
    xvals = avgData(:,1)';
    yvals = avgData(:,2)';
    
    standard_error = (avgData(:,3)').^2;
    
    %To avoid error caused by dividing by zero
    standard_error(standard_error == 0) = 0.000001;
    
    % Weights are assumed to be 1/standard error
    w = 1./standard_error;
    
    % Weighted least sum of squares equation to be minimized
    f = @(x,xvals,yvals,w)sum(w.*((yvals-(xvals.*x)).^2));
        
    % fminbnd iteratively searches for the slope parameter which
    % minimizes the WLSS equation
    fun = @(x)f(x,xvals,yvals,w);
    xMin = avg*0.5;
    xMax = avg*1.5;
    wssAvg = fminbnd(fun,xMin,xMax);
end