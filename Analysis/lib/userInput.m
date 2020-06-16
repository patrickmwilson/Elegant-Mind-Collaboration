function options = userInput()
    options = struct('subjectName', NaN, 'type', NaN, 'averageOver', NaN, ...
        'savePlots', NaN, 'saveParams', NaN);
    
    %Input dialogue for data type
    options.type = string(inputdlg({'Type (All/Study/Mock/Pilot)'}, ...
        'Session Info', [1 70], {'All'}));

    if(strcmp(options.type,'All'))
        options.averageOver = true;
    else
        % Input dialogue: average all data of the given type?
        dataAnswer = questdlg('Combine all subjects?', 'Data Selection', 'Yes', ...
            'No', 'Cancel', 'Yes');
        options.averageOver = strcmp(char(dataAnswer(1)),'Y');
        if strcmp(char(dataAnswer(1)),'C')
            return;
        end
    end

    if(options.averageOver)
        options.subjectName = "Averaged";
    else
        % Input dialogue: subject name
        options.subjectName = string(inputdlg({'Subject name (all caps)'}, ...
            'Session Info', [1 70], {''}));
    end
    
    % Input dialogue: save plots?
    dataAnswer = questdlg('Save plots?', 'Plot Output', 'Yes', 'No', 'Cancel', ...
        'Yes');
    options.savePlots = (char(dataAnswer(1)) == 'Y');
    if strcmp(char(dataAnswer(1)),'C')
        return;
    end

    % Input dialogue: save parameters?
    dataAnswer = questdlg('Save parameters to csv?', 'Parameter Output', 'Yes', ...
        'No', 'Cancel', 'Yes');
    options.saveParams = (char(dataAnswer(1)) == 'Y');
    if strcmp(char(dataAnswer(1)),'C')
        return;
    end
end