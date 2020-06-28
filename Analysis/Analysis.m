% Analysis
%
% Analyzes and produces plots and statistics from visual acuity data
% specified by the user through input dialogues

% Add helper functions to path
addpath(fullfile(pwd, 'lib')); 

% Supress directory warnings
warning('off','MATLAB:MKDIR:DirectoryExists');

mkdir(fullfile(pwd,'Parameters'));

% Reset workspace and close figures
clear variables; close all; 

dataAnswer = questdlg('Select the type of analysis', ...
    'Analysis selection', 'Chi^2', 'Correlation', ...
    'Protocol significance tests', 'Chi^2');

if strcmp(dataAnswer,'Chi^2')
    dataAnswer = questdlg('Run every subject (long)?', ...
        'Data Selection', 'Yes', 'No', 'Cancel', 'Yes');
    if strcmp(dataAnswer,'Cancel')
        return;
    end
    
    everySubject = strcmp(dataAnswer, 'Yes');
    
    % Input dialogue: save plots?
    dataAnswer = questdlg('Save plots?', 'Plot Output', 'Yes', 'No', 'Cancel', ...
        'Yes');
    savePlots = strcmp(dataAnswer, 'Yes');
    if strcmp(dataAnswer, 'Cancel')
        return;
    end

    % Input dialogue: save parameters?
    dataAnswer = questdlg('Save parameters to csv?', 'Parameter Output', 'Yes', ...
        'No', 'Cancel', 'Yes');
    saveParams = strcmp(dataAnswer, 'Yes');
    if strcmp(dataAnswer, 'Cancel')
        return;
    end
    
    if everySubject
        subjects = getSubjects();
        for i=1:length(subjects)
            subject = subjects(i);
            subject.saveParams = saveParams;
            subject.savePlots = savePlots;
            analyzeSubject(subject);
        end
    else
        subject = userInput();
        subject.saveParams = saveParams;
        subject.savePlots = savePlots;
        
        % Input dialogue: save parameters?
        dataAnswer = questdlg('All protocols?', 'Protocols', 'Yes', ...
            'No', 'Cancel', 'Yes');
        subject.includeAll = strcmp(dataAnswer, 'Yes');
        if strcmp(dataAnswer, 'Cancel')
            return;
        end
        analyzeSubject(subject);
    end
    
elseif strcmp(dataAnswer,'Correlation')
    correlationAnalysis();
else
    resultStruct = protocolComparison();
end
