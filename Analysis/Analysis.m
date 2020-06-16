% Analysis
%
% Analyzes and produces plots and statistics from visual acuity data
% specified by the user through input dialogues

% Add helper functions to path
addpath(fullfile(pwd, 'lib')); 

% Supress directory warnings
warning('off','MATLAB:MKDIR:DirectoryExists');

% Reset workspace and close figures
clear variables; close all; 

dataAnswer = questdlg('Select the type of analysis', ...
    'Analysis selection', 'Chi^2', 'Correlation', ...
    'Significance tests', 'Chi^2');

if strcmp(dataAnswer,'Chi^2')
    dataAnswer = questdlg('Run every subject (long)?', ...
        'Data Selection', 'Yes', 'No', 'Cancel', 'Yes');
    if strcmp(dataAnswer,'Cancel')
        return;
    end
    
    everySubject = strcmp(dataAnswer, 'Yes');
    
    analyze(everySubject);
    
elseif strcmp(dataAnswer,'Correlation')
    correlationAnalysis();
else
    dataAnswer = questdlg('Select the significance tests', ...
        'Analysis selection', 'Protocol comparisons', ...
        'Left/Right comparisons', 'Cancel', 'Protocol comparisons');
    if strcmp(dataAnswer,'Cancel')
        return;
    end
    
    if strcmp(dataAnswer,'Protocol comparisons')
        protocolComparisons();
    else
        % Separate L/R comparisons into own script
    end
end
