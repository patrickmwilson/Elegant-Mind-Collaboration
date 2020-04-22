function [avgData, wssAvg] = wss(data,name,avg)
    % Average replicate observations at discrete values
    avgData = averageData(data,(1+(strcmp(name,'T1'))));
       
    xvals = avgData(:,1)';
    yvals = avgData(:,2)';
    
    standard_error = (avgData(:,3)').^2;
    
    %To avoid error caused by dividing by zero
    standard_error(standard_error == 0) = 0.000001;
    
    % Weights are assumed to be 1/standard error
    w = 1./standard_error;
    
    % Weighted least sum of squares equation to be minimized
    f = @(x,xvals,yvals,w)sum(w.*((yvals-(xvals.*x)).^2));
        
    % fminsearch iteratively searches for the slope parameter which
    % minimizes the WLSS equation
    fun = @(x)f(x,xvals,yvals,w);
    %options = optimset('MaxIter',max,'MaxFunEvals',max);
    
    x_min = avg*0.5;
    x_max = avg*2;
    options = optimset('Display','iter');
    wssAvg = fminbnd(fun,0,1,options);
    %wssAvg = fminsearch(fun,x0,options);
end