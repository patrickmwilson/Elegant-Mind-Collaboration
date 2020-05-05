% readCSV
% Created by Patrick Wilson on 1/20/2020
% Github.com/patrickmwilson
% Created for the Elegant Mind Collaboration at UCLA under 
% Professor Katsushi Arisaka
% Copyright � 2020 Elegant Mind Collaboration. All rights reserved.

% Given a folder name that resides within the current directory, copies data
% from all '.csv' folders within that directory that contain the sequence 
% specified by name into an array.

function [data, fitData, outliers] = readCsv(name, id, allData, trimCC)
    
    % Suppress warning about modified csv headers
    warning('off','MATLAB:table:ModifiedAndSavedVarnames');


    clear folder;
    if(strcmp(name,"Anstis"))
        folder = fullfile(pwd, 'Active_Data', 'All', 'A');
    else
        if allData
            folder = fullfile(pwd, 'Active_Data','All', id);
        else
            folder = fullfile(pwd, 'Active_Data');
        end
    end
    
    clear files;
    clear filenames;
    clear csvfiles;
    % Create list of names of all files within directory that end in '.csv'
    files = dir(folder);
    filenames={files(:).name}';
    csvfiles=filenames(endsWith(filenames,'.csv'));
    
    % Read csv into table, concatenates additional csv files
    clear data;
    clear fitData;
    clear outliers;
    data = [];
    fitData = [];
    outliers = [];
    for i = 1:size(csvfiles,1)
        % Only reads csv files that contain the experiment name
        file = char(csvfiles{i,1});

        if(~strcmp(name,'Anstis'))
            underscores = find(file == '_');
            period = find(file == '.');
            protocolName = string(extractBetween(file, (underscores(end)+1), (period-1)));
            if(~strcmp(protocolName, name))
                continue;
            end
        end
        
        filename = fullfile(folder, string(csvfiles(i,1)));
        clear thisData;
        thisData = table2array(readtable(filename));
        
        % Creates a 2 column matrix of the data. Eccentricity is placed in
        % column 1, letter height in column 2. 
        thisData(:,1) = thisData(:,3);
        % T1 data is stored differently, letter height is in column 4 of
        % the csv rather than column 2
        thisData(:,2) = thisData(:,(2 + 2*(strcmp(name,'T1'))));

        if(strcmp(id,'CC3') && trimCC)
            exclusions = [0,5,10];
        elseif(strcmp(id,'CC9') && trimCC)
            exclusions = [0, 5, 10, 15];
        else 
            exclusions = [0];
        end

        % Removes all rows from the data matrix which contain a zero.
        j = 1;
        while(j <= size(thisData,1))
            if(ismember(thisData (j, 1), exclusions) || thisData(j,2) == 0)
                thisData(j,:) = [];
                continue;
            end
            j = j + 1;
        end

        % Normalize by y/x
        thisData(:,2) = thisData(:,2)./thisData(:,1);
    
        % Recursively removing outliers more than 2.5 standard deviations (99%
        % confidence interval) from this distribution (see removeOutliers.m)
        clear thisFitData;
        clear theseOutliers;
        [thisFitData,theseOutliers] = removeOutliers(thisData, [], 2.5, 2);

        % Concatenate these values with accumulated values
        data = [data; thisData];
        fitData = [fitData; thisFitData];
        outliers = [outliers; theseOutliers];
    end

end