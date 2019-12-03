clear variables;
clear all;

anstisX = [4.02148, 8.94224, 16.2079, 17.3219, 23.249, 28.0508, 31.1738, 31.6387, 38.203, 55.2726, 55.8553];
anstisY = [0.243199, 0.377233, 0.681458, 0.839386, 1.00387, 1.34426, 1.67235, 1.17467 , 2.34074, 4.00559, 3.33797];

folder = '/Users/patrickwilson/Desktop/T1Data';
tfiles = dir('/Users/patrickwilson/Desktop/T1Data');
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








folder = '/Users/patrickwilson/Desktop/CrowdedCenterData';
tfiles = dir('/Users/patrickwilson/Desktop/CrowdedCenterData');
tfilenames={tfiles(:).name}';
tcsvfiles=tfilenames(endsWith(tfilenames,'.csv'));

for i = 1:size(tcsvfiles,1)
    filename = fullfile(folder, string(tcsvfiles(i,1)));
    ccTable = readtable(filename);
    if i == 1
        cctable = ccTable;
    else
        temTable = cctable;
        cctable = [temTable; ccTable];
    end
end

ccT = table2array(cctable);
cc = zeros(1,9);
count = zeros(1,9);

for i = 1:size(ccT,1)
    angle = ccT(i, 2)*2;
    if angle == 0.5
        angle = 1;
    else
        angle = angle + 1;
    end
    cc(1,angle) = cc(1,angle) + ccT(i, 3);
    count(1,angle) = count(1,angle) + 1;
end

cc = cc./count;








folder = '/Users/patrickwilson/Desktop/CrowdedPeripheryData';
tfiles = dir('/Users/patrickwilson/Desktop/CrowdedPeripheryData');
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

cpT = table2array(table);
cp = zeros(1,9);
count = zeros(1,9);

for i = 1:size(cpT,1)
    angle = cpT(i, 2)*2;
    if angle == 0.5
        angle = 1;
    else
        angle = angle + 1;
    end
    cp(1,angle) = cp(1,angle) + cpT(i, 3);
    count(1,angle) = count(1,angle) + 1;
end

cp = cp./count;






folder = '/Users/patrickwilson/Desktop/IsolatedCharacterData';
tfiles = dir('/Users/patrickwilson/Desktop/IsolatedCharacterData');
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

icT = table2array(table);
ic = zeros(1,9);
count = zeros(1,9);

for i = 1:size(icT,1)
    angle = icT(i, 2)*2;
    if angle == 0.5
        angle = 1;
    else
        angle = angle + 1;
    end
    ic(1,angle) = ic(1,angle) + icT(i, 3);
    count(1,angle) = count(1,angle) + 1;
end

ic = ic./count;





legends = [ "", "", "", "", "" ];
lines = [0,0,0,0,0];
txt = "%s : y = %4.2fx + %4.2f";
t1LetterHeights = [ 0.5, 1, 1.5, 2, 2.5, 3, 3.5, 4 ];
letterHeights = [ 0.25, 0.5, 1, 1.5, 2, 2.5, 3, 3.5, 4 ];


hold on
scatter(anstisX(1,:), anstisY(1,:), 15, "k", "filled");
coefficients = polyfit(anstisX(1,:), anstisY(1,:), 1);
coefficients = [0.046,-0.031];
legends(1) = sprintf(txt, "Anstis", coefficients(1,1), coefficients(1,2));
xFit = linspace(min(anstisX(1,:)), max(anstisX(1,:)), 1000);
yFit = polyval(coefficients, xFit);
hold on;
lines(1) = plot(xFit, yFit, "k-", 'LineWidth', 1);
grid on;

hold on
scatter(t1(1,:), t1LetterHeights(1,:), 15, "m", "filled");
coefficients = polyfit(t1(1,:), t1LetterHeights(1,:), 1);
legends(2) = sprintf(txt, "T1", coefficients(1,1), coefficients(1,2));
xFit = linspace(min(t1(1,:)), max(t1(1,:)), 1000);
yFit = polyval(coefficients, xFit);
hold on;
lines(2) = plot(xFit, yFit, "m-", 'LineWidth', 1);
grid on;

hold on
scatter(cc(1,:), letterHeights(1,:), 15, "c", "filled");
coefficients = polyfit(cc(1,:), letterHeights(1,:), 1);
legends(3) = sprintf(txt, "Crowded Center", coefficients(1,1), coefficients(1,2));
xFit = linspace(min(cc(1,:)), max(cc(1,:)), 1000);
yFit = polyval(coefficients, xFit);
hold on;
lines(3) = plot(xFit, yFit, "c-", 'LineWidth', 1);
grid on;

hold on
scatter(cp(1,:), letterHeights(1,:), 15, "b", "filled");
coefficients = polyfit(cp(1,:), letterHeights(1,:), 1);
legends(4) = sprintf(txt, "Crowded Periphery", coefficients(1,1), coefficients(1,2));
xFit = linspace(min(cp(1,:)), max(cp(1,:)), 1000);
yFit = polyval(coefficients, xFit);
hold on;
lines(4) = plot(xFit, yFit, "b-", 'LineWidth', 1);
grid on;

hold on
scatter(ic(1,:), letterHeights(1,:), 15, "r", "filled");
coefficients = polyfit(ic(1,:), letterHeights(1,:), 1);
legends(5) = sprintf(txt, "Isolated Character", coefficients(1,1), coefficients(1,2));
xFit = linspace(min(ic(1,:)), max(ic(1,:)), 1000);
yFit = polyval(coefficients, xFit);
hold on;
lines(5) = plot(xFit, yFit, "r-", 'LineWidth', 1);
grid on;

xlim([0 inf]);
ylim([0 4.5]);
xlabel("Eccentricity (degrees)");
ylabel("Letter Height (degrees)");
title("Letter Height vs. Retinal Eccentricity");

legend([lines(1), lines(2), lines(3), lines(4), lines(5)], {legends(1), legends(2), legends(3), legends(4), legends(5)}, 'Location', 'best');