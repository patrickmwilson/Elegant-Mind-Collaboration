function avgData = averageData(data, discreteCol)

    avgCol = 3-discreteCol;

    if discreteCol == 2
        data(:,2) = round(data(:,2),2);
    end
    
    avgData(:,discreteCol) = unique(data(:,discreteCol));
    
    for i = 1:size(avgData,1)
        
        indices = find(data(:,discreteCol) == avgData(i,discreteCol));
        
        values = zeros(1,length(indices));
        
        for j = 1:length(indices)
            
            index = indices(j,1);
            
            values(j) = data(index,avgCol);
            
        end
        
        avgData(i,avgCol) = mean(values);
        
        avgData(i,3) = std(values);
        avgData(i,4) = length(values);
        
    end
end