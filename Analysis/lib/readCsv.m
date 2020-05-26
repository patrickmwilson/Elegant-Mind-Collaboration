% readCSV
% Created by Patrick Wilson on 1/20/2020
% Github.com/patrickmwilson
% Created for the Elegant Mind Collaboration at UCLA under 
% Professor Katsushi Arisaka
% Copyright � 2020 Elegant Mind Collaboration. All rights reserved.

% Given a folder name that resides within the current directory, copies data
% from all '.csv' folders within that directory that contain the sequence 
% specified by name into an array.

function [rawData,data,outliers] = readCsv(name,id,type,subjectName,trimCC)
    
    % Suppress warning about modified csv headers
    warning('off','MATLAB:table:ModifiedAndSavedVarnames');
    
    if(strcmp(id,'a'))
        baseFolders = [string(fullfile(pwd, 'Data', 'Anstis'))];
    elseif(strcmp(type,'All'))
        baseFolders = [string(fullfile(pwd, 'Data', 'Study')), ...
            string(fullfile(pwd, 'Data', 'Mock')), ...
            string(fullfile(pwd, 'Data', 'Pilot'))];
    else
        baseFolders = [string(fullfile(pwd, 'Data', type))];
    end
    
    
    folderPaths = [];
    for i=1:length(baseFolders)
        baseFolder = baseFolders(i);
        
        if(strcmp(id,'a'))
            folderPaths = [baseFolder];
            break;
        end
        
        folders = dir(baseFolder);
        
        folderNames={folders(:).name}';
        
        for j=1:size(folderNames,1)
            folderName = string(folderNames{j,1});
            
            if(startsWith(folderName,"."))
                continue;
            end
            
            if(~strcmp(subjectName,'Averaged'))
                if(~strcmp(subjectName,folderName))
                    continue;
                end
            end
            
            folderPath = string(fullfile(baseFolder, folderName));
            folderPaths = [folderPaths folderPath];
            
        end
    end
    
    rawData = []; data = []; outliers = [];
    
    for i=1:length(folderPaths)
        folder = folderPaths(i);
        
        files = dir(folder);
        fileNames={files(:).name}';
        csvFiles=fileNames(endsWith(fileNames,'.csv'));
        
        for j=1:size(csvFiles,1)
            file = char(csvFiles{j,1});
            
            if(~strcmp(id,'a'))
                underscores = find(file == '_');
                period = find(file == '.');
                protocolName = string(extractBetween(file, (underscores(end)+1), (period-1)));
                if(~strcmp(protocolName, name))
                    continue;
                end
            end
            
            thisData = []; thisFitData = []; theseOutliers = [];
            
            filename = fullfile(folder, string(csvFiles(j,1)));
            thisData = table2array(readtable(filename));
        
            % Creates a 2 column matrix of the data. Eccentricity is placed in
            % column 1, letter height in column 2. 
            thisData(:,1) = thisData(:,3);
            % T1 data is stored differently, letter height is in column 4 of
            % the csv rather than column 2
            thisData(:,2) = thisData(:,(2 + 2*(strcmp(id,'fc'))));

            if(strcmp(id,'cc3') && trimCC)
                exclusions = [0,5,10];
            elseif(strcmp(id,'cc9') && trimCC)
                exclusions = [0, 5, 10, 15];
            else
                exclusions = [0];
            end

            % Removes all rows from the data matrix which contain a zero.
            k = 1;
            while(k <= size(thisData,1))
                if(ismember(thisData (k, 1), exclusions) || thisData(k,2) == 0)
                    thisData(k,:) = [];
                    continue;
                end
                k = k + 1;
            end

            % Normalize by y/x
            thisData(:,2) = thisData(:,2)./thisData(:,1);
    
            % Recursively removing outliers more than 2.5 standard deviations (99%
            % confidence interval) from this distribution (see removeOutliers.m)
            [thisFitData,theseOutliers] = removeOutliers(thisData, [], 2.5, 2);

            % Concatenate these values with accumulated values
            rawData = [rawData; thisData];
            data = [data; thisFitData];
            outliers = [outliers; theseOutliers];
        end
    end
end