clear variables;
clear all;

files = dir('/Data');
filenames = {files(:).name}';
csvfiles = filenames(endsWith(filenames,'.csv'));

for i = 1:size(csvfiles,1)
    filename = fullfile(folder, string(csvfiles(i,1)));
    iTable = readtable(filename);
    if i == 1
        table = iTable;
    else
        temTable = table;
        table = [temTable; iTable];
    end
end

T = table2array(table);

letterHeights = [ 0.5, 1, 1.5, 2, 2.5, 3, 3.5, 4 ];
angles = [ 0, 5, 10, 15, 20 ];

points = zeros(8, 5);
counters = zeros(8, 5);

for i = 1:size(T,1)
    height = ((T(i, 1))*2);
    angle = ((T(i,2)/5)+1);
    correct = T(i,6);
    time = T(i,5);
    if correct
        points(height, angle) = points(height, angle) + time;
        counters(height, angle) = counters(height, angle) + 1;
    end
end

averaged = points./counters;

txt = "%s° (20/%s) : y = %4.2fx + %4.2f";
colors = [ "r", "b", "g", "c", "y", "m", "k", "r" ];

lines = [0, 0, 0, 0, 0, 0, 0, 0];
legends = [ "", "", "", "", "", "", "", "" ];

for i = 1:8
    hold on
    scatter(angles(1,:), averaged(i,:), 15, colors(i), "filled");
    coefficients = polyfit(angles(1,:), averaged(i,:), 1);
    legends(i) = sprintf(txt, num2str(i/2), num2str(i*120), coefficients(1,1), coefficients(1,2));
    xFit = linspace(min(angles(1,:)), max(angles(1,:)), 1000);
    yFit = polyval(coefficients, xFit);
    hold on;
    lines(i) = plot(xFit, yFit, strcat(colors(i), '-'), 'LineWidth', 1);
    grid on;
end

xlabel("Eccentricity (degrees)");
ylabel("Reaction Time (ms)");
title("Reaction Time vs. Eccentricity");

legend([lines(1), lines(2), lines(3), lines(4), lines(5), lines(6), lines(7), lines(8)], {legends(1), legends(2), legends(3), legends(4), legends(5), legends(6), legends(7), legends(8)}, 'Location', 'best');
title(legend,'Letter Height (degrees) and VA (Snellen)')
