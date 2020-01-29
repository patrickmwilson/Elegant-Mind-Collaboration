function table = readCsv(folder)
basefolder = pwd;
folder = fullfile(basefolder, folder);
files = dir(folder);
filenames={files(:).name}';
csvfiles=filenames(endsWith(filenames,'.csv'));

for i = 1:size(csvfiles,1)
    filename = fullfile(folder, string(csvfiles(i,1)));
    iTable = readtable(filename);
    oTable =[];
    if i == 1
        oTable = iTable;
    else
        temTable = oTable;
        oTable = [temTable; iTable];
    end
end

table = table2array(oTable);

end