function [newdata, newpair, newpair2, avg] = removeOutliers(data, pair, pair2)
    Z = zscore(data);
    outliers = 0;
    i = 1;
    while(i <= length(data))
        if(abs(Z(i)) > 2.5)
            data(i) = [];
            pair(i) = [];
            pair2(i) = [];
            Z(i) = [];
            outliers = 1;
        else
            i = i+1;
        end
    end
    
    if outliers == 0
        avg = mean(data);
        newdata = data;
        newpair = pair;
        newpair2 = pair2;
    else
        [newdata, newpair, newpair2, avg] = removeOutliers(data, pair, pair2);
    end
end
