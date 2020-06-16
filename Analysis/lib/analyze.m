function analyze(opts)

    [info, oneParamOutput, leftVsRight, twoParamOutput] = makeStructs(options);

    % Creating y = ax and y = ax+b figures
    oneParamGraph = figure(); twoParamGraph = figure();

    % Loop through info and analyze each protocol individually
    for i = 1:(length(info))
        if ~info(i).include
            continue; % Skip if it was not selected in the UI pop-up
        end

        % Extract data from csv files, returning the raw data and the data 
        % with outliers > +/-2.5 sigma from the mean removed
        [rawData, data, ~] = readCsv(info(i).csvName,  info(i).id, ...
            oneParamOutput.type, oneParamOutput.name, options.trimCC, ...
            'both');
    
        % Extract data from left eccentricities
        [lRawData, lData, ~] = readCsv(info(i).csvName,  info(i).id, ...
            oneParamOutput.type, oneParamOutput.name, options.trimCC, ...
            'left');
    
        % Extract data from right eccentricities
        [rRawData, rData, ~] = readCsv(info(i).csvName,  info(i).id, ...
            oneParamOutput.type, oneParamOutput.name, options.trimCC, ...
            'right');
    
        % Pass the data along to the fitting function for Chi^2 
        % minimization and generation of graphs and parameter output
        [oneParamOutput, leftVsRight, twoParamOutput] = analyzeData(...
            data, rawData, lData, lRawData, rData, rRawData, info, ...
            oneParamOutput, leftVsRight, twoParamOutput, oneParamGraph, ...
            twoParamGraph, options);
    end

    % Axes and text formatting for y = ax plot
    formatFigure(oneParamGraph, [0 45], [0 11], "Eccentricity (deg)", ...
        "Letter Height (deg)", "Letter Height vs. Retinal Eccentricity", ...
        false, 'best');

    % Axes and text formatting for y = ax + b plot
    formatFigure(twoParamGraph, [0 45], [0 11], "Eccentricity (deg)", ...
        "Letter Height (deg)", "Letter Height vs. Retinal Eccentricity", ...
        false, 'best');

    figs = [oneParamGraph, twoParamGraph];
    figNames = [" one param.png", " two param.png"];

    saveResults(savePlots, saveParams, figs, figNames, oneParamOutput, ...
        lOneParamOutput, rOneParamOutput, twoParamOutput);
end