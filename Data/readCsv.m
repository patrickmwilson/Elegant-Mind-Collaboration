% readCSV
% Created by Patrick Wilson on 1/20/2020
% Github.com/patrickmwilson
% Created for the Elegant Mind Collaboration at UCLA under Professor Katsushi Arisaka
% Copyright © 2020 Elegant Mind Collaboration. All rights reserved.

% Given a folder name that resides within the current directory, copies data
% from all '.csv' folders within that directory into an array.

function table = readCsv(folder)
    
    % Suppress warning about modified csv headers
    warning('off','MATLAB:table:ModifiedAndSavedVarnames');

    folder = fullfile(pwd, 'Data', folder);
    
    % Create list of names of all files within directory that end in '.csv'
    files = dir(folder);
    filenames={files(:).name}';
    csvfiles=filenames(endsWith(filenames,'.csv'));
    
    % Read csv into table, concatenates additional csv files
    table =[];
    for i = 1:size(csvfiles,1)
        filename = fullfile(folder, string(csvfiles(i,1)));
        table = [table; readtable(filename)];
    end
    
    % Convert the table to an array
    table = table2array(table);

end