% readCSV
% Created by Patrick Wilson on 1/20/2020
% Github.com/patrickmwilson
% Created for the Elegant Mind Collaboration at UCLA under 
% Professor Katsushi Arisaka
% Copyright � 2020 Elegant Mind Collaboration. All rights reserved.

% Given a folder name that resides within the current directory, copies data
% from all '.csv' folders within that directory that contain the sequence 
% specified by name into an array.

function table = readCsv(name, allData)
    
    % Suppress warning about modified csv headers
    warning('off','MATLAB:table:ModifiedAndSavedVarnames');
    
    if(strcmp(name,'Anstis'))
        folder = fullfile(pwd, 'Active_Data', 'Anstis');
    elseif(strcmp(name,'Compiled'))
        folder = fullfile(pwd, 'Analysis_Results');
    else
        if allData
            folder = fullfile(pwd,'Active_Data','All');
        else
            folder = fullfile(pwd, 'Active_Data');
        end
    end
    
    % Create list of names of all files within directory that end in '.csv'
    files = dir(folder);
    filenames={files(:).name}';
    csvfiles=filenames(endsWith(filenames,'.csv'));
    
    % Read csv into table, concatenates additional csv files
    table =[];
    for i = 1:size(csvfiles,1)
        % Only reads csv files that contain the experiment name
        file = char(csvfiles{i,1});
        if(contains(file,name))
            filename = fullfile(folder, string(csvfiles(i,1)));
            table = [table; readtable(filename)];
        end
    end
    
    % Convert the table to an array
    if ~strcmp(name,'Compiled')
        table = table2array(table);
    end

end