function [info,oneParamOutput,twoParamOutput] = makeStructs(subject)
   
    % Struct to contain y=ax fit parameters, including slope, Chi^2, reduced
    % Chi^2, and error of the slope parameter for csv output
    fileName = fullfile(pwd,'lib','struct_templates', ...
        'one_param_struct.csv');
    oneParamOutput = table2struct(readtable(fileName));
    
    oneParamOutput.type = subject.type;
    oneParamOutput.name = subject.name;
    
    % Struct to contain y=ax+b fit parameters, including slope, intercept,
    % Chi^2, reduced Chi^2, error of the slope and intercept parameter for csv 
    % output
    fileName = fullfile(pwd,'lib','struct_templates', ...
        'two_param_struct.csv');
    twoParamOutput = table2struct(readtable(fileName));
    
    twoParamOutput.type = subject.type;
    twoParamOutput.name = subject.name;
    
    % Struct to store information about each protocol, including name, color,
    % csv name, and which column holds the independent variable
    infoCsv = fullfile(pwd,'lib','struct_templates','protocol_info.csv');
    info = table2struct(readtable(infoCsv));
    
    % Input UI to select which protocols to include data from
    if ~subject.includeAll
        global CHECKBOXES;
        ButtonUI(info);
        for i=1:length(info)
            info(i).include = CHECKBOXES(i);
        end
    end
    for i=1:length(info)
        info(i).color = str2num(info(i).color);
    end
end