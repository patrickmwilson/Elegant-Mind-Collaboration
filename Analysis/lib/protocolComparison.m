close all; 

% Suppress warnings about modified csv headers & directory existing
warning('off','MATLAB:MKDIR:DirectoryExists');

% Add helper functions to path
libPath = fullfile(pwd, 'lib'); addpath(libPath); 

% Struct to store information about each protocol, including name, color,
% csv name, and which column holds the independent variable
infoCsv = fullfile(pwd,'lib','struct_templates','protocol_info.csv');
info = table2struct(readtable(infoCsv));

resultCsv = fullfile(pwd,'lib','struct_templates', ...
        'protocol_comparison_struct.csv');
resultStruct = table2struct(readtable(resultCsv));
resultStruct = repmat(resultStruct,1,(length(info)-1));

lrCsv = fullfile(pwd,'lib','struct_templates', ...
        'left_vs_right_struct.csv');
lrStruct = table2struct(readtable(lrCsv));

lrStruct.type = 'All';
lrStruct.name = 'Averaged';

structIdx = 1;
for i=1:length(info)
    
    if strcmp(info(i).id,'a')
        continue;
    end
    
    [~,data,~] = readCsv(info(i).csvName, info(i).id, 'All', "Averaged", ...
        true, 'both');
    
    % Extract data from left eccentricities
    [~,lData, ~] = readCsv(info(i).csvName,  info(i).id, ...
        'All', "Averaged", true, 'left');
    
    % Extract data from right eccentricities
    [~, rData, ~] = readCsv(info(i).csvName,  info(i).id, ...
        'All', "Averaged", true, 'right');
    
    lrStruct.(strcat(info(i).id,'_left_better')) = ...
        ranksum(lData(:,2), rData(:,2), 'tail', 'left');
    
    lrStruct.(info(i).id) = ...
        ranksum(lData(:,2), rData(:,2));
    
    lrStruct.(strcat(info(i).id,'_right_better')) = ...
        ranksum(lData(:,2), rData(:,2), 'tail', 'right');
    
    resultStruct(structIdx).protocol = info(i).id;
    
    for j=1:length(info)
        if i == j || strcmp(info(j).id,'a')
            continue;
        end
        
        [~,comparisonData,~] = readCsv(info(j).csvName, info(j).id, ...
            'All', "Averaged", true, 'both');
        
        resultStruct(structIdx).(strcat(info(j).id, '_worse')) = ...
            ranksum(data(:,2), comparisonData(:,2), 'tail', 'left');

        resultStruct(structIdx).(info(j).id) = ...
            ranksum(data(:,2), comparisonData(:,2));

        resultStruct(structIdx).(strcat(info(j).id, '_better')) = ...
            ranksum(data(:,2), comparisonData(:,2), 'tail', 'right');
        
        structIdx = structIdx + 1;

    end

end

fileName = fullfile(pwd, 'Parameters', 'protocol_comparison.csv');
results = struct2table(resultStruct);
writetable(results,fileName,'WriteRowNames',true);

fileName = fullfile(pwd, 'Parameters', 'left_vs_right.csv');
results = struct2table(lrStruct);
if(exist(fileName, 'file') ~= 2) % If file does not exist, print column names
    writetable(results,fileName,'WriteRowNames',true);
else
    writetable(results,fileName,'WriteRowNames',false, ...
        'WriteMode', 'Append')
end


