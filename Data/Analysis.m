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
names = ['T1','Three Lines','Crowded Periphery 11x11','Crowded Periphery 7x7', ...
        'Crowded Periphery 5x5', 'Crowded Periphery Cross', 'Crowded Periphery Inner', ...
        'Crowded Periphery Outer', 'Crowded Center 9x9', 'Crowded Center 3x3',  ... 
        'Isolated Character', 'Anstis'];

angles = [0, 5, 10, 15, 20, 25, 30, 35, 40];

for p = 1:length(checkboxes)
    name = names(p);
    if STRCMP(name, 'T1') ~= 0
        divided = figure('Name','Eccentricity/Letter Height vs Letter Height');
        angleIndex = 3;
        heightIndex = 4;
    else
        divided = figure('Name','Letter Height/Eccentricity vs Eccentricity');
        angleIndex = 3;
        heightIndex = 2;
    end
        
    
end

%T1 
if CHECKBOXES(1)
    t1Divided = figure('Name','Letter Height/Eccentricity vs Eccentricity');
    t1Distribution = figure('Name','Distribution of Letter Height/Eccentricity');
    table = readCsv('T1');
    x = [];
    y = [];
    dir = [];
    count = 1;
    for i = 1:size(table,1)
        if table(i,3) ~= 0
            x(count) = table(i, 3);
            y(count) = table(i, 4);
            dir(count) = table (i, 1);
            count = count+1;
        end
    end
    y = y./x;
    [fity, fitx, fitdir, avg] = removeOutliers(y, x, dir);
    delta = abs(y-avg);
    delta = delta.*x;
    y = y.*x;
    
    graphLine(x, y, dir, fitx, fity, fitdir, avg, delta, "T1", subjectCode, [1 0 0], t1Divided, t1Distribution, pointSlope);
end
%Three Lines
if CHECKBOXES(2)
    table = readCsv('Three Lines');
    threeL = zeros(1,9);
    count = zeros(1,9);
    for i = 1:size(table,1)
        height = table(i, 2);
        height = (height * 2) + 1;
        threeL(1,height) = threeL(1,height) + table(i, 3);
        count(1,height) = count(1,height) + 1;
    end
    threeLLetterHeights = [0,0.5,1,1.5,2,2.5,3,3.5,4];
    graphLine(threeL, threeLLetterHeights, "Three Lines", [0.83 0.31 0.08]);
end
%CROWDED PERIPHERY 11x11
if CHECKBOXES(3)
    table = readCsv('Crowded Periphery 11x11');
    cpeleven = zeros(1,9);
    count = zeros(1,9);
    for i = 1:size(table,1)
        angle = (table(i,3)/5)+1;
        cpeleven(1,angle) = cpeleven(1,angle) + table(i, 2);
        count(1,angle) = count(1,angle) + 1;
    end
    cpeleven = cpeleven./count;
    graphLine(angles, cpeleven, "Crowded Periphery 11x11", [1 0.5 0]);
end
%CROWDED PERIPHERY 7x7
if CHECKBOXES(4)
    table = readCsv('Crowded Periphery 7x7');
    cpseven = zeros(1,9);
    count = zeros(1,9);
    for i = 1:size(table,1)
        angle = (table(i,3)/5)+1;
        cpseven(1,angle) = cpseven(1,angle) + table(i, 2);
        count(1,angle) = count(1,angle) + 1;
    end
    cpseven = cpseven./count;
    graphLine(angles, cpseven, "Crowded Periphery 7x7", [1 0.84 0]);
end
%CROWDED PERIPHERY 5x5
if CHECKBOXES(5)
    table = readCsv('Crowded Periphery 5x5');
    cpfive = zeros(1,9);
    count = zeros(1,9);
    for i = 1:size(table,1)
        angle = (table(i,3)/5)+1;
        cpfive(1,angle) = cpfive(1,angle) + table(i, 2);
        count(1,angle) = count(1,angle) + 1;
    end
    cpfive = cpfive./count;
    graphLine(angles, cpfive, "Crowded Periphery 5x5", [1 1 0]);
end
%CROWDED PERIPHERY CROSS
if CHECKBOXES(6)
    table = readCsv('Crowded Periphery');
    cp = zeros(1,9);
    count = zeros(1,9);
    for i = 1:size(table,1)
        angle = (table(i,3)/5)+1;
        cp(1,angle) = cp(1,angle) + table(i, 2);
        count(1,angle) = count(1,angle) + 1;
    end
    cp = cp./count;
    graphLine(angles, cp, "Crowded Periphery Cross", [0.33 1 0]);
end
%CROWDED PERIPHERY INNER
if CHECKBOXES(7)
    table = readCsv('Crowded Periphery Inner');
    cpinner = zeros(1,9);
    count = zeros(1,9);
    count(1) = 1;
    for i = 1:size(table,1)
        angle = (table(i,3)/5)+1;
        cpinner(1,angle) = cpinner(1,angle) + table(i, 2);
        count(1,angle) = count(1,angle) + 1;
    end
    cpinner = cpinner./count;
    cpIOAngles = [0, 5, 10, 15, 20, 25, 30, 35, 40];
    graphLine(cpIOAngles, cpinner, "Crowded Periphery Inner", [0 0.69 0.125]);
end
%CROWDED PERIPHERY OUTER
if CHECKBOXES(8)
    table = readCsv('Crowded Periphery Outer');
    cpouter = zeros(1,9);
    count = zeros(1,9);
    for i = 1:size(table,1)
        angle = (table(i,3)/5)+1;
        cpouter(1,angle) = cpouter(1,angle) + table(i, 2);
        count(1,angle) = count(1,angle) + 1;
    end
    cpouter = cpouter./count;
    cpIOAngles = [0, 5, 10, 15, 20, 25, 30, 35, 40];
    graphLine(cpIOAngles, cpouter, "Crowded Periphery Outer", [0 0 1]);
end
%CROWDED CENTER 9x9
if CHECKBOXES(9)
    table = readCsv('Crowded Center 9x9');
    ccnine = zeros(1,7);
    count = zeros(1,7);
    count(1) = 1;
    for i = 1:size(table,1)
        angle = (table(i, 3)/5)-1;
        ccnine(1,angle) = ccnine(1,angle) + table(i, 2);
        count(1,angle) = count(1,angle) + 1;
    end
    ccnine = ccnine./count;
    ccNineAngles = [0, 15, 20, 25, 30, 35, 40];
    graphLine(ccNineAngles, ccnine, "Crowded Center 9x9", [0 0.85 1]);
end
%CROWDED CENTER 3x3
if CHECKBOXES(10)
    table = readCsv('Crowded Center 3x3');
    cc = zeros(1,8);
    count = zeros(1,8);
    count(1) = 1;
    for i = 1:size(table,1)
        angle = (table(i, 3)/5);
        cc(1,angle) = cc(1,angle) + table(i, 2);
        count(1,angle) = count(1,angle) + 1;
    end
    cc = cc./count;
    ccThreeAngles = [0, 10, 15, 20, 25, 30, 35, 40];
    graphLine(ccThreeAngles, cc, "Crowded Center 3x3", [0.72 0 0.92]);
end
%ISOLATED CHARACTER
if CHECKBOXES(11)
    icDivided = figure('Name','Letter Height/Eccentricity vs Eccentricity');
    icDistribution = figure('Name','Distribution of Letter Height/Eccentricity');
    table = readCsv('Isolated Character');
    x = [];
    y = [];
    dir = [];
    count = 1;
    for i = 1:size(table,1)
        if table(i,3) ~= 0
            x(count) = table(i,3);
            y(count) = table(i,2);
            dir(count) = table(i,1);
            count = count+1;
        end
    end
    y = y./x;
    [fity, fitx, fitdir, avg] = removeOutliers(y, x, dir);
    delta = abs(y-avg);
    delta = delta.*x;
    y = y.*x;
    
    graphLine(x, y, dir, fitx, fity, fitdir, avg, delta, "Isolated Character", subjectCode, [0 0 1], icDivided, icDistribution, pointSlope);
end
%ANSTIS
if CHECKBOXES(12)
    anstisX = [0, 4.02148, 8.94224, 16.2079, 17.3219, 23.249, 28.0508, 31.1738, 31.6387, 38.203, 55.2726, 55.8553 ...
        0, 4.02148, 8.94224, 16.2079, 17.3219, 23.249, 28.0508, 31.1738, 31.6387, 38.203, 55.2726, 55.8553];
    anstisY = [0, 0.243199, 0.377233, 0.681458, 0.839386, 1.00387, 1.34426, 1.67235, 1.17467 , 2.34074, 4.00559, 3.33797 ...
        0, 0.243199, 0.377233, 0.681458, 0.839386, 1.00387, 1.34426, 1.67235, 1.17467 , 2.34074, 4.00559, 3.33797];
    dir = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3];
    graphLine(pointSlope, fixedOrigin, logPlot, anstisX, anstisY, dir, "Anstis", [0 0 0], [0 0 0]);
    %coefficients = [0.046,-0.031];
end

figure(pointSlope);
xlim([0 inf]);
ylim([0 inf]);
xlabel("Eccentricity (degrees)", 'FontSize', 12);
ylabel("Letter Height (degrees)", 'FontSize', 12);
titleText = "Letter Height vs. Retinal Eccentricity (%s)";
title(sprintf(titleText, subjectCode), 'FontSize', 14);
legend('show', 'Location', 'best');
% ax = gca;
% ax.XAxisLocation = 'origin';
% ax.YAxisLocation = 'origin';

% figure(divided);
% xlim([0 inf]);
% ylim([0 inf]);
% xlabel("Eccentricity (degrees)", 'FontSize', 18);
% ylabel("Letter Height (degrees)/Eccentricity (degrees)", 'FontSize', 18);
% title("Letter Height/Retinal Eccentricity vs. Retinal Eccentricity", 'FontSize', 24);
% legend('show', 'Location', 'best');
% ax = gca;
% ax.XAxisLocation = 'origin';
% ax.YAxisLocation = 'origin';

% figure(distribution);
% xlabel("Letter Height (degrees)/Eccentricity (degrees)", 'FontSize', 18);
% ylabel("Number of occurences", 'FontSize', 18);
% title("Distribution of Letter Height (degrees)/Eccentricity (degrees)", 'FontSize', 24);

% figure(logPlot);
% xlim([-inf inf]);
% ylim([-inf inf]);
% xlabel("Log of Eccentricity (degrees)");
% ylabel("Log of Letter Height (degrees)");
% title("Log of Letter Height vs. Log of Retinal Eccentricity");
% legend('show', 'Location', 'best');
% ax = gca;
% ax.XAxisLocation = 'origin';
% ax.YAxisLocation = 'origin';
