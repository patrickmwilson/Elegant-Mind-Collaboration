clearvars;
prompt = {'Enter Subject Name:', 'Month Data Was Taken (eg. November = 11):', 'Day Data Was Taken (eg. 09):'};
dlgtitle = 'Input (Check CSV Name for Values';
dims = [1 60];
answer = inputdlg(prompt,dlgtitle,dims);
subjectName = char(answer(1,1));
month = char(answer(2,1));
day = char(answer(3,1));
dash = '-';
underscore = '_';

experimentFolderName = 'Data';

fileName = fullfile(experimentFolderName, [subjectName underscore month dash day '.csv']);

if(exist(fileName, 'file') == 0)
    msg = 'Error: File not found.';
    error(msg);
end

fid = fopen(fileName);
data = csvread(fileName, 1, 1);

centerCounter = 0;
centerSum = 0;
peripheryCounter = 0;
peripherySum = 0;

dimensions = size(data);
rows = dimensions(1);

for i = 1:rows
    eccentricity = data(i,2);
    reactionTime = data(i,3);
    
    if(eccentricity > 0)
        peripherySum = peripherySum + reactionTime;
        peripheryCounter = peripheryCounter + 1;
    end
    if(eccentricity == 0)
        centerSum = centerSum + reactionTime;
        centerCounter = centerCounter + 1;
    end
    
end

peripheryAverage = peripherySum/peripheryCounter;
centerAverage = centerSum/centerCounter;

xVals = [0, 13];
yVals = [centerAverage, peripheryAverage];

hold on

scatter(xVals, yVals, 25, 'c', 'filled');
p = polyfit(xVals, yVals, 1);
xFit = linspace(min(xVals), max(xVals), 1000);
yFit = polyval(p, xFit);
hold on;
plot(xFit, yFit, 'c-', 'LineWidth', 1);
grid on;
clear title;
title('Eccentricity vs. Average Reaction Time (0.5 degree Letter Height)')
clear ylable;
ylabel('Average Reaction Time (ms)')
clear xlabel;
xlabel('Eccentricity (degrees)')

return;