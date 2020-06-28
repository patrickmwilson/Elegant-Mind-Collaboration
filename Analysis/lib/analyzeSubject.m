function analyzeSubject(subject)

    [info, oneParamOutput, twoParamOutput] = makeStructs(subject);

    % Creating y = ax and y = ax+b figures
    oneParamGraph = figure(); 
    twoParamGraph = figure();

    % Loop through info and analyze each protocol individually
    for i = 1:(length(info))
        if ~info(i).include
            continue; % Skip if it was not selected in the UI pop-up
        end

        % Extract data from csv files, returning the raw data and the data 
        % with outliers > +/-2.5 sigma from the mean removed
        [rawData, data, ~] = readCsv(info(i).csvName,  info(i).id, ...
            subject.type, subject.name, 'both');
        
        if isempty(data)
            continue;
        end
        
        % Pass the data along to the fitting function for Chi^2 
        % minimization and generation of graphs and parameter output
        [oneParamOutput, twoParamOutput] = analyzeData(data, rawData, ...
            info(i), oneParamOutput, twoParamOutput, oneParamGraph, ...
            twoParamGraph, subject);
        
        leftvright(subject);
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
    
    if subject.savePlots
        % If data was averaged, save the plots to Plots/Averaged/<type> 
        % otherwise in Plots/<type>/<subjectName>
        if(strcmp(subject.name,'Averaged'))
            folderName = fullfile(pwd, 'Plots', 'Averaged', ...
                string(subject.type));
        else
            folderName = fullfile(pwd, 'Plots', ...
                string(subject.type), ...
                string(subject.name));
        end
        
        for i=1:length(figs)
            fileName = sprintf('%s%s', string(subject.name), ...
                figNames(i));
            saveas(figs(i), fullfile(folderName, fileName));
        end
    end
    
    for i=1:length(figs)
        close(figs(i));
    end
    
    % Converts the parameter output structs into tables and writes them to csv
    % files within the present working directory
    if subject.saveParams
        oneParam = struct2table(oneParamOutput);
        fileName = fullfile(pwd, 'Parameters', ...
            'one_parameter_statistics.csv');
        if(exist(fileName, 'file') ~= 2) % If file does not exist, print column names
            writetable(oneParam,fileName,'WriteRowNames',true);
        else
            writetable(oneParam,fileName,'WriteRowNames',false, ...
                'WriteMode', 'Append')
        end
    
        twoParam = struct2table(twoParamOutput);
        fileName = fullfile(pwd, 'Parameters', ...
            'two_parameter_statistics.csv');
        if(exist(fileName, 'file') ~= 2) % If file does not exist, print column names
            writetable(twoParam,fileName,'WriteRowNames',true);
        else
            writetable(twoParam,fileName,'WriteRowNames',false, ...
                'WriteMode', 'Append')
        end
    end
end