clear variables;
clear all;

folder = '/Users/patrickwilson/Desktop/R/Elegant-Mind-Collaboration/T1/Data';
tfiles = dir('/Users/patrickwilson/Desktop/R/Elegant-Mind-Collaboration/T1/Data');
tfilenames={tfiles(:).name}';
tcsvfiles=tfilenames(endsWith(tfilenames,'.csv'));

for i = 1:size(tcsvfiles,1)
    filename = fullfile(folder, string(tcsvfiles(i,1)));
    tTable = readtable(filename);
    if i == 1
        table = tTable;
    else
        temTable = table;
        table = [temTable; tTable];
    end
end

tT = table2array(table);
t1 = zeros(1,8);
count = zeros(1,8);

for i = 1:size(tT,1)
    angle = tT(i, 4)*2;

    t1(1,angle) = t1(1,angle) + tT(i, 3);
    count(1,angle) = count(1,angle) + 1;
end

t1 = t1./count;

folder = '/Users/patrickwilson/Desktop/R/Elegant-Mind-Collaboration/Isolated Character/Data';
files = dir('/Users/patrickwilson/Desktop/R/Elegant-Mind-Collaboration/Isolated Character/Data');
filenames={files(:).name}';
csvfiles=filenames(endsWith(filenames,'.csv'));

for i = 1:size(csvfiles,1)
    filename = fullfile(folder, string(csvfiles(i,1)));
    thisTable = readtable(filename);
    if i == 1
        table = thisTable;
    else
        tempTable = table;
        table = [tempTable; thisTable];
    end
end

T = table2array(table);

anstisX = [4.02148, 8.94224, 16.2079, 17.3219, 23.249, 28.0508, 31.1738, 31.6387, 38.203, 55.2726, 55.8553];
anstisY = [0.243199, 0.377233, 0.681458, 0.839386, 1.00387, 1.34426, 1.67235, 1.17467 , 2.34074, 4.00559, 3.33797];

letterHeights = [ 0.25, 0.5, 1, 1.5, 2, 2.5, 3, 3.5, 4 ];
t1LetterHeights = [ 0.5, 1, 1.5, 2, 2.5, 3, 3.5, 4 ];
angles = zeros(4,9);
counters = zeros(4,9);

for i = 1:size(T,1)
    angle = T(i, 2)*2;
    if angle == 0.5
        angle = 1;
    else
        angle = angle + 1;
    end
    dir = T(i,1);
    
    angles(dir,angle) = angles(dir,angle) + T(i, 3);
    counters(dir,angle) = counters(dir,angle) + 1;
end

averaged = angles./counters;

colors = [ "r", "b", "g", "c" ];
txt = "%s : y = %4.2fx + %4.2f";
directions = [ "Right", "Down", "Left", "Up" ];

legends = [ "", "", "", "", "", "" ];
lines = [0,0,0,0,0,0];

for i = 1:4
    hold on
    scatter(averaged(i,:), letterHeights(1,:), 15, colors(i), "filled");
    coefficients = polyfit(averaged(i,:), letterHeights(1,:), 1);
    legends(i) = sprintf(txt, directions(i), coefficients(1,1), coefficients(1,2));
    xFit = linspace(min(averaged(i,:)), max(averaged(i,:)), 1000);
    yFit = polyval(coefficients, xFit);
    hold on;
    lines(i) = plot(xFit, yFit, strcat(colors(i), '-'), 'LineWidth', 1);
    grid on;
end

hold on
scatter(anstisX(1,:), anstisY(1,:), 15, "k", "filled");
coefficients = polyfit(anstisX(1,:), anstisY(1,:), 1);
legends(5) = sprintf(txt, "Anstis", coefficients(1,1), coefficients(1,2));
xFit = linspace(min(anstisX(1,:)), max(anstisX(1,:)), 1000);
yFit = polyval(coefficients, xFit);
hold on;
lines(5) = plot(xFit, yFit, "k-", 'LineWidth', 1);
grid on;

hold on
scatter(t1(1,:), t1LetterHeights(1,:), 15, "m", "filled");
coefficients = polyfit(t1(1,:), t1LetterHeights(1,:), 1);
legends(6) = sprintf(txt, "T1", coefficients(1,1), coefficients(1,2));
xFit = linspace(min(t1(1,:)), max(t1(1,:)), 1000);
yFit = polyval(coefficients, xFit);
hold on;
lines(6) = plot(xFit, yFit, "m-", 'LineWidth', 1);
grid on;

xlim([0 inf]);
ylim([0 4.5]);
xlabel("Eccentricity (degrees)");
ylabel("Letter Height (degrees)");
title("Letter Height vs. Retinal Eccentricity (Isolated Character)");

legend([lines(1), lines(2), lines(3), lines(4), lines(5), lines(6)], {legends(1), legends(2), legends(3), legends(4), legends(5), legends(6)}, 'Location', 'best');
%title(legend,'Directions')