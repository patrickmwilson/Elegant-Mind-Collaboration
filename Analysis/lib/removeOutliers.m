% removeOutliers
% Created by Patrick Wilson on 1/20/2020
% Github.com/patrickmwilson
% Created for the Elegant Mind Collaboration at UCLA 
% with Professor Katsushi Arisaka
% Copyright � 2020 Elegant Mind Collaboration. All rights reserved.

% Accepts a matrix, a cutoff Z-score, and the column of interest as input. 
% Recursively computes the Z-score of the column of interest and removes 
% row elements that have a Z-score higher than the cutoff. 

function [newData,outliers] = removeOutliers(data, outliers, cutOff, columnOfInterest)
    
    % Compute Z-score of the column of interest and store it in a new
    % column
    clear newData;
    newData = data;
    z = zscore(newData(:,columnOfInterest));
    newData(:,(size(data,2)+1)) = z(:,1);
    
    % Remove any rows which contain a Z-score higher than the cutoff
    i = 1;
    while(i <= size(newData,1))
        if(abs(newData(i,(size(data,2)+1))) > cutOff)
            outliers = [outliers; newData(i,:)];
            newData(i,:) = [];
            continue;
        end
        i = i+1;
    end
    
    % Remove the column storing the Z-scores
    newData(:,(size(data,2)+1)) = [];
    
    % If elements were removed, function is called again with the modified
    % data
    if(size(newData,1) ~= size(data,1))
        [newData,outliers] = removeOutliers(newData, outliers, cutOff, columnOfInterest);
    end
    
end
