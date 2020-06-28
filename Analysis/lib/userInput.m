function subject = userInput()
    subject = struct('name', NaN, 'type', NaN, 'averageOver', NaN, ...
        'savePlots', NaN, 'saveParams', NaN);
    
    %Input dialogue for data type
    subject.type = string(inputdlg({'Type (All/Study/Pilot)'}, ...
        'Session Info', [1 70], {'All'}));

    if(strcmp(subject.type,'All'))
        subject.averageOver = true;
    else
        % Input dialogue: average all data of the given type?
        dataAnswer = questdlg('Combine all subjects?', 'Data Selection', 'Yes', ...
            'No', 'Cancel', 'Yes');
        subject.averageOver = strcmp(char(dataAnswer(1)),'Y');
        if strcmp(char(dataAnswer(1)),'C')
            return;
        end
    end

    if(subject.averageOver)
        subject.name = "Averaged";
    else
        % Input dialogue: subject name
        subject.name = string(inputdlg({'Subject name (all caps)'}, ...
            'Session Info', [1 70], {''}));
    end
    
end