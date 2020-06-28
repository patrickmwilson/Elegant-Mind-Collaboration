function subjects = getSubjects()

    subjects = struct('type', "All", 'name', "Averaged", ...
        'includeAll', true);
    subjects(2) = struct('type', "Study", 'name', "Averaged", ...
        'includeAll', true);
    subjects(3) = struct('type', "Pilot", 'name', "Averaged", ...
        'includeAll', true);
        
    types = ["Study", "Pilot"];
        
    for i=1:length(types)
        type = types(i);
        base = fullfile(pwd, 'Data', type);
        
        folders = dir(base);
        
        folderNames={folders(:).name}';
        
        for j=1:size(folderNames,1)
            folderName = string(folderNames{j,1});
            
            if(startsWith(folderName,"."))
                continue; % Skips folders such as .DS_STORE
            end
            subjects(end+1) = struct('type', type, ...
                'name', folderName, 'includeAll', true);
        end
    end
end