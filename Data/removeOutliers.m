function [newdata, newpair] = removeOutliers(data, pair)
    Z = zscore(data);
    outliers = 0;
    i = 1;
    while(i <= length(data))
        if(abs(Z(i)) > 2.5)
            data(i) = [];
            pair(i) = [];
            Z(i) = [];
            outliers = 1;
        else
            i = i+1;
        end
    end
    
    if outliers == 0
        newdata = data;
        newpair = pair;
    else
        [newdata, newpair] = removeOutliers(data, pair);
    end
end
