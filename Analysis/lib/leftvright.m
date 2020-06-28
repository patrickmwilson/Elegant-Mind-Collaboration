function leftvright(subject)
    % Struct to store information about each protocol, including name, color,
    % csv name, and which column holds the independent variable
    infoCsv = fullfile(pwd,'lib','struct_templates','protocol_info.csv');
    info = table2struct(readtable(infoCsv));
    
    if strcmp(subject.type, 'All')
        % Struct to store the results of the significance tests
        csvName = fullfile(pwd,'lib','struct_templates', ...
            'left_vs_right_struct.csv');
        resultStruct = table2struct(readtable(csvName));
        resultStruct = repmat(resultStruct,1,(length(info)-1));
    end
    
    % If data was averaged, save the plots to Plots/Averaged/<type> 
    % otherwise in Plots/<type>/<subjectName>
    if(strcmp(subject.name,'Averaged'))
        folderName = fullfile(pwd, 'Plots', 'Averaged', ...
            string(subject.type));
    else
        folderName = fullfile(pwd, 'Plots', string(subject.type), ...
            string(subject.name));
    end
    
    mkdir(folderName);
    
    % Structs containing protocol name and color for left vs. right graphs
    leftInfo = struct('name', NaN, 'color', [0 1 0]);  
    rightInfo = struct('name', NaN, 'color', [1 0 0]);
    
    % Loop through each protocol and conduct a significance test for left
    % vs right eccentricity data
    structIdx = 1;
    for i=1:length(info)
        if strcmp(info(i).id,'a')
            continue; % Skip anstis data
        end
        
        % Extract data from left eccentricities
        [lRawData,lData, ~] = readCsv(info(i).csvName,  info(i).id, ...
            subject.type, subject.name, 'left');
    
        % Extract data from right eccentricities
        [rRawData, rData, ~] = readCsv(info(i).csvName,  info(i).id, ...
            subject.type, subject.name, 'right');
        
        if isempty(lData) || isempty(rData)
            continue; % Skip if there is no data matching the search terms
        end
        
        % Create a histogram of the y/x distribution split between left and
        % right
        lvr = figure();
        % Update the leftInfo protocol name
        leftInfo.name = strcat(info(i).name, ' (left)');
        histFig(lRawData, mean(lData(:,2)), std(lData(:,2)),  ...
            size(lRawData,1), leftInfo, lvr); % Graph the left distribution
        
        % Update the rightInfo protocol name
        rightInfo.name = strcat(info(i).name, ' (right)');
        histFig(rRawData, mean(rData(:,2)), std(rData(:,2)), ...
            size(lRawData,1), rightInfo, lvr); % Graph the right distribution
        
        % Save and close the figure
        fileName = sprintf('%s%s', string(subject.name), ...
                strcat('_', info(i).name, '_left_vs_right.png'));
        saveas(lvr, fullfile(folderName, fileName));
        close(lvr);
        
        if strcmp(subject.type,'All')
            
            resultStruct(structIdx).Protocol = info(i).name;
            
             % Conduct a one sided Wilcoxun rank sum test. The 'tail, left'
            % argument returns a p-value indicating whether a point from
            % the left data distribution is likely to have a smaller value than
            % a point from the right data distribution, indicating
            % that the left data distribution has a better visual acuity
            resultStruct(structIdx).left_better = ...
                ranksum(lData(:,2), rData(:,2), 'tail', 'left');

            % Conduct a two sided Wilcoxun rank sum test. Returns a p-value
            % indicating the likelihood that the left and right data
            % distributions are identical
            resultStruct(structIdx).two_tail = ...
                ranksum(lData(:,2), rData(:,2));

            % Conduct a one sided Wilcoxun rank sum test. The 'tail, right'
            % argument returns a p-value indicating whether a point from
            % the right data distribution is likely to have a smaller value than
            % a point from the left data distribution, indicating
            % that the right data distribution has a better visual acuity
            resultStruct(structIdx).right_better = ...
                ranksum(lData(:,2), rData(:,2), 'tail', 'right');
            
            structIdx = structIdx + 1;
        end
    end
    
    if strcmp(subject.type,'All')
        % Output the resulting p-values to the left_vs_right csv file within
        % the Parameters subfolder
        fileName = fullfile(pwd, 'Parameters', 'left_vs_right.csv');
        results = struct2table(resultStruct);
        writetable(results,fileName,'WriteRowNames',true);
    end
end