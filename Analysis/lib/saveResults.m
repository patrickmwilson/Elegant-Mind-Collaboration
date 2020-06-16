function saveResults(savePlots, saveParams, figs, figNames, oneParamOutput, leftVsRight, twoParamOutput)
    if savePlots
        % If data was averaged, save the plots to Plots/Averaged/<type> 
        % otherwise in Plots/<type>/<subjectName>
        if(strcmp(oneParamOutput.name,'Averaged'))
            folderName = fullfile(pwd, 'Plots', 'Averaged', ...
                string(oneParamOutput.type));
        else
            folderName = fullfile(pwd, 'Plots', ...
                string(oneParamOutput.type), ...
                string(oneParamOutput.name));
        end
        
        for i=1:length(figs)
            fileName = sprintf('%s%s', string(oneParamOutput.name), ...
                figNames(i));
            saveas(figs(i), fullfile(folderName, fileName));
            close(figs(i));
        end
    end
    
    % Converts the parameter output structs into tables and writes them to csv
    % files within the present working directory
    if saveParams
        oneParam = struct2table(oneParamOutput);
        fileName = fullfile(pwd, 'Parameters', ...
            'one_parameter_statistics.csv');
        if(exist(fileName, 'file') ~= 2) % If file does not exist, print column names
            writetable(oneParam,fileName,'WriteRowNames',true);
        else
            writetable(oneParam,fileName,'WriteRowNames',false, ...
                'WriteMode', 'Append')
        end
        
        lvr = struct2table(leftVsRight);
        fileName = fullfile(pwd, 'Parameters', 'left_vs_right.csv');
        if(exist(fileName, 'file') ~= 2) % If file does not exist, print column names
            writetable(lvr,fileName,'WriteRowNames',true);
        else
            writetable(lvr,fileName,'WriteRowNames',false, ...
                'WriteMode', 'Append')
        end
    
        twoParam = struct2table(twoParamOutput);
        fileName = fullfile(pwd, 'Parameters', ...
            'two_parameter_statistics.csv');
        if(exist(fileName, 'file') ~= 2) % If file does not exist, print column names
            writetable(twoParam,fileName,'WriteRowNames',true);
        else
            writetable(twoParam,fileName,'WriteRowNames',false, ...
                'WriteMode', 'Append')
        end
    end
end