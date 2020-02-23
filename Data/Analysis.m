clear variables;
clear all;

prompt = {'Enter subject code:' };
dlgtitle = 'Input';
dims = [1 35];
answer = inputdlg(prompt,dlgtitle,dims);
subjectCode = char(answer(1,1));

global CHECKBOXES;
ButtonUI();

pointSlope = figure('Name','Point Slope');
logPlot = figure();
names = ["T1","Three Lines","Crowded Periphery 11x11","Crowded Periphery 7x7", ...
        "Crowded Periphery 5x5", "Crowded Periphery", "Crowded Periphery Inner", ...
        "Crowded Periphery Outer", "Crowded Center 9x9", "Crowded Center 3x3",  ... 
        "Isolated Character", "Anstis"];
    
colors = [0 0.8 0.8; 0 0 0; 0 0 0; 0 0 0; 0 0 0; 0 0 0; 0 0 0; ...
          0.9 0.3 0.9; 0.5 0 0.9; 0 0.1 1; 0.4 0.8 0.5; 0 0 0];

for p = 1:length(CHECKBOXES)
    if(CHECKBOXES(p))
        name = names(p);
        table = readCsv(name);
        heightIndex = (2 + 2*(strcmp(name,'T1')));
        x = [];
        y = [];
        count = 1;
        for i = 1:size(table,1)
            if(table(i,3) ~= 0 && table (i, heightIndex) ~= 0)
                x(count) = table(i, 3);
                y(count) = table(i, heightIndex);
                count = count+1;
            end
        end
        y = y./x;
        [fity, fitx, avg] = removeOutliers(y, x);
        delta = abs(y-avg);
        delta = delta.*x;
        y = y.*x;
        color = [colors(p,1) colors(p,2) colors(p,3)];
        makeFigs(x, y, fitx, fity, avg, delta, name, subjectCode, color, pointSlope, logPlot);

    end
end

figure(pointSlope);
xlim([0 inf]);
ylim([0 inf]);
xlabel("Eccentricity (degrees)");
ylabel("Letter Height (degrees)");
titleText = "Letter Height vs. Retinal Eccentricity (%s)";
title(sprintf(titleText, subjectCode));
legend('show', 'Location', 'best');

figure(logPlot);
xlim([-inf inf]);
ylim([-inf 1.5]);
xlabel("Log of Eccentricity (degrees)");
ylabel("Log of Letter Height (degrees)");
title("Log of Letter Height vs. Log of Retinal Eccentricity");
legend('show', 'Location', 'best');
ax = gca;
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';

folderName = fullfile(pwd, 'Subject_Data', subjectCode);
fileName = sprintf('%s%s', subjectCode, '_point_slope.png');
saveas(pointSlope, fullfile(folderName, fileName));
fileName = sprintf('%s%s', subjectCode, '_log_log_plot.png');
saveas(logPlot, fullfile(folderName, fileName));
