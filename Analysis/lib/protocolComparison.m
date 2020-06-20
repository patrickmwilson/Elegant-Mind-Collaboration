
function protocolComparison(type, name)
    % Struct to store information about each protocol, including name, color,
    % csv name, and which column holds the independent variable
    infoCsv = fullfile(pwd,'lib','struct_templates','protocol_info.csv');
    info = table2struct(readtable(infoCsv));
    
    % Struct to store the results of the significance tests
    resultCsv = fullfile(pwd,'lib','struct_templates', ...
            'protocol_comparison_struct.csv');
    resultStruct = table2struct(readtable(resultCsv));
    resultStruct = repmat(resultStruct,1,(length(info)-1));
    
    % Loop through every protocol and compare each to every other protocol
    structIdx = 1;
    for i=1:length(info)

        if strcmp(info(i).id,'a')
            continue; % Skip anstis
        end
        
        % Specify the current protocol for csv output
        resultStruct(structIdx).protocol = info(i).id;
        
        % Get data matrix for the first protocol
        [~,data,~] = readCsv(info(i).csvName, info(i).id, type, name, ...
            true, 'both');
        
        if isempty(data)
            continue; % Skip if there is no data matching the search terms
        end
        
        % Loop through the protocols again, comparing the first protocol to
        % every other protocol
        for j=1:length(info)
            if i == j || strcmp(info(j).id,'a')
                continue; % Skip anstis
            end
            
            % Get data matrix for the second protocol
            [~,comparisonData,~] = readCsv(info(j).csvName, info(j).id, ...
                type, name, true, 'both');
            
            if isempty(comparisonData)
                structIdx = structIdx + 1;
                continue; % Skip if there is no data matching the search terms
            end
            
            % Conduct a one sided Wilcoxun rank sum test. The 'tail, left'
            % argument returns a p-value indicating whether a point from
            % the data distribution is likely to have a smaller value than
            % a point from the comparison data distribution, indicating
            % that the data distribution has a better visual acuity
            resultStruct(structIdx).(strcat(info(j).id, '_worse')) = ...
                ranksum(data(:,2), comparisonData(:,2), 'tail', 'left');
            
            % Conduct a two sided Wilcoxun rank sum test. Returns a p-value
            % indicating the likelihood that the data and comparison data
            % distributions are identical.
            resultStruct(structIdx).(info(j).id) = ...
                ranksum(data(:,2), comparisonData(:,2));
            
            % Conduct a one sided Wilcoxun rank sum test. The 'tail, right'
            % argument returns a p-value indicating whether a point from
            % the data distribution is likely to have a larger value than
            % a point from the comparison data distribution, indicating
            % that the comparison data distribution has a better visual 
            % acuity
            resultStruct(structIdx).(strcat(info(j).id, '_better')) = ...
                ranksum(data(:,2), comparisonData(:,2), 'tail', 'right');

            structIdx = structIdx + 1;
        end
    end
    
    % P-values are saved as a csv. If 'All' and 'Averaged' are the input
    % arguments it is saved within the Parameters subfolder. If a type is
    % specified and the subject is 'Averaged', it is saved within the
    % Plots/Averaged/<type> subfolder. If a single subject is specified, it
    % is saved within the Plots/<type>/<name> subfolder
    if strcmp(type,'All')
        fileName = fullfile(pwd, 'Parameters', 'protocol_comparison.csv');
    elseif strcmp(name,'Averaged')
        fileName = fullfile(pwd, 'Plots', 'Averaged', type, ...
            strcat(type, '_protocol_comparison.csv'));
    else
        fileName = fullfile(pwd, 'Plots', type, name, ...
            strcat(name, '_protocol_comparison.csv'));
    end
    
    % Write the results to csv
    results = struct2table(resultStruct);
    writetable(results,fileName,'WriteRowNames',true);
end

