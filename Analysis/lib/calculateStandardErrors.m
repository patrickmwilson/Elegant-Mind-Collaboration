function outputData = calculateStandardErrors(info, trimCC, outputData)

    csvName = info.csvName;
    id = info.id;
    if(strcmp(id,'a'))
        return;
    end
    discreteCol = info.discreteCol;
    
    [~,data,~] = readCsv(csvName,id,'All','Averaged',trimCC);

    data(:,2) = data(:,2).*data(:,1);
    avgData = averageData(data,discreteCol);
    
    for i=1:length(outputData)
        measurement = outputData(i,discreteCol);
        idx = find(avgData(:,discreteCol) == measurement);
        outputData(i,4) = avgData(idx(1),3);
    end
end