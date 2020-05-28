% readCSV
%
% Extracts data from csv files. Normalizes the eccentricity values by
% retinal eccentricity and recursively removes outliers greater than +/-
% 2.5 sigma from the mean of the normalized distribution. Accepts the
% csvName, csvId, data type, subject name, and a boolean indicating whether
% to remove small eccentricity values from crowded center as input
% arguments. Returns the raw data, truncated data, and any outliers.
function [rawData,data,outliers] = readCsv(name,id,type,subjectName,trimCC)
    
    % Suppress warning about modified csv headers
    warning('off','MATLAB:table:ModifiedAndSavedVarnames');
    
    % Sets the directories to search for csv files
    if(strcmp(id,'a'))
        baseFolders = [string(fullfile(pwd, 'Data', 'Anstis'))];
    elseif(strcmp(type,'All'))
        baseFolders = [string(fullfile(pwd, 'Data', 'Study')), ...
            string(fullfile(pwd, 'Data', 'Mock')), ...
            string(fullfile(pwd, 'Data', 'Pilot'))];
    else
        baseFolders = [string(fullfile(pwd, 'Data', type))];
    end
    
    % Creates filepaths to all the subfolders within each base folder
    folderPaths = [];
    for i=1:length(baseFolders)
        baseFolder = baseFolders(i);
        
        if(strcmp(id,'a'))
            folderPaths = [baseFolder];
            break; % Anstis data is stored directly within the base folder
        end
        
        folders = dir(baseFolder);
        folderNames={folders(:).name}';
        for j=1:size(folderNames,1)
            folderName = string(folderNames{j,1});
            
            if(startsWith(folderName,"."))
                continue; % Skips folders such as .DS_STORE
            end
            
            % If a subject was specified, skip any folders which do not
            % match the subject code
            if(~strcmp(subjectName,'Averaged'))
                if(~strcmp(subjectName,folderName))
                    continue;
                end
            end
            
            % Create the new file path and append it to the array
            folderPath = string(fullfile(baseFolder, folderName));
            folderPaths = [folderPaths folderPath];  
        end
    end
    
    rawData = []; data = []; outliers = [];
    for i=1:length(folderPaths)
        folder = folderPaths(i);
        
        % Get the names of all the csv files within the folder
        files = dir(folder);
        fileNames={files(:).name}';
        csvFiles=fileNames(endsWith(fileNames,'.csv'));
        
        % Loop over every csv file, extracting data from files which match
        % the search conditions
        for j=1:size(csvFiles,1)
            file = char(csvFiles{j,1});
            
            % csv file names follow this convention:
            % SUBJECT_DATE_PROTOCOLNAME.csv
            if(~strcmp(id,'a'))
                underscores = find(file == '_'); % Find indices of undersc
                period = find(file == '.'); % Find the period
                
                % Extract the portion of the csv file name between the last
                % underscore and the period
                protocolName = string(extractBetween(file, (underscores(end)+1), (period-1)));
                if(~strcmp(protocolName, name))
                    continue; % Skip csv files from other protocols
                end
            end
            
            thisData = []; thisFitData = []; theseOutliers = [];
            
            % Extract the data from the csv into an array
            filename = fullfile(folder, string(csvFiles(j,1)));
            thisData = table2array(readtable(filename));
        
            % Creates a 2 column matrix of the data. Eccentricity is placed in
            % column 1, letter height in column 2. 
            thisData(:,1) = thisData(:,3);
            % T1 data is stored differently, letter height is in column 4 of
            % the csv rather than column 2
            thisData(:,2) = thisData(:,(2 + 2*(strcmp(id,'fc'))));
            
            % Sets the eccentricity values which are to be excluded from
            % the data
            if(strcmp(id,'cc3') && trimCC)
                exclusions = [0,5,10];
            elseif(strcmp(id,'cc9') && trimCC)
                exclusions = [0, 5, 10, 15];
            else
                exclusions = [0];
            end

            % Removes all rows from the data matrix which contain a zero,
            % or contain an eccentricity value that is included in the
            % exclusions array
            k = 1;
            while(k <= size(thisData,1))
                if(ismember(thisData (k, 1), exclusions) || thisData(k,2) == 0)
                    thisData(k,:) = [];
                    continue;
                end
                k = k + 1;
            end

            % Normalize letter height observations by retinal eccentricity 
            thisData(:,2) = thisData(:,2)./thisData(:,1);
    
            % Recursively removing outliers more than 2.5 standard 
            % deviations (99% confidence interval) from the normalized 
            % distribution (see removeOutliers.m)
            [thisFitData,theseOutliers] = removeOutliers(thisData, [], 2.5, 2);

            % Concatenate these values with accumulated values
            rawData = [rawData; thisData];
            data = [data; thisFitData];
            outliers = [outliers; theseOutliers];
        end
    end
end