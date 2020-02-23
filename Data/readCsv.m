function table = readCsv(folder)
basefolder = pwd;
folder = fullfile(basefolder, folder);
files = dir(folder);
filenames={files(:).name}';
csvfiles=filenames(endsWith(filenames,'.csv'));

table =[];
for i = 1:size(csvfiles,1)
    filename = fullfile(folder, string(csvfiles(i,1)));
    table = [table; readtable(filename)];
end

table = table2array(table);

end