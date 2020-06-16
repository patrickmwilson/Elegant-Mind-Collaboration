function [info,oneParamOutput,leftVsRight,twoParamOutput] = makeStructs(options)
   
    % Struct to contain y=ax fit parameters, including slope, Chi^2, reduced
    % Chi^2, and error of the slope parameter for csv output
    fileName = fullfile(pwd,'lib','struct_templates', ...
        'one_param_struct.csv');
    oneParamOutput = table2struct(readtable(fileName));
    
    oneParamOutput.type = options.type;
    oneParamOutput.name = options.subjectName;
    
    fileName = fullfile(pwd,'lib','struct_templates', ...
        'left_vs_right_struct.csv');
    leftVsRight = table2struct(readtable(fileName));
    
    leftVsRight.type = options.type;
    leftVsRight.name = options.subjectName;
    
    % Struct to contain y=ax+b fit parameters, including slope, intercept,
    % Chi^2, reduced Chi^2, error of the slope and intercept parameter for csv 
    % output
    fileName = fullfile(pwd,'lib','struct_templates', ...
        'two_param_struct.csv');
    twoParamOutput = table2struct(readtable(fileName));
    
    twoParamOutput.type = options.type;
    twoParamOutput.name = options.subjectName;
    
    % Struct to store information about each protocol, including name, color,
    % csv name, and which column holds the independent variable
    infoCsv = fullfile(pwd,'lib','struct_templates','protocol_info.csv');
    info = table2struct(readtable(infoCsv));
    
    % Input UI to select which protocols to include data from
    global CHECKBOXES;
    ButtonUI(info);

    for i=1:length(info)
        info(i).include = CHECKBOXES(i);
        info(i).color = str2num(info(i).color);
    end
end