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

points = zeros(5, 8);
counters = zeros(5, 8);

for i = 1:size(T,1)
    height = ((T(i, 1))*2);
    angle = ((T(i,2)/5)+1);
    correct = T(i,6);
    time = T(i,5);
    if correct
        points(angle,height) = points(angle,height) + time;
        counters(angle,height) = counters(angle,height) + 1;
    end
end

averaged = points./counters;

colors = [ "r", "b", "g", "c", "k" ];
txt = "%s° : y = %4.2fx + %4.2f";

legends = [ "", "", "", "", "" ];
lines = [0,0,0,0,0];

for i = 1:5
    hold on
    scatter(letterHeights(1,:), averaged(i,:), 15, colors(i), "filled");
    coefficients = polyfit(letterHeights(1,:), averaged(i,:), 1);
    legends(i) = sprintf(txt, num2str((i-1)*5), coefficients(1,1), coefficients(1,2));
    xFit = linspace(min(letterHeights(1,:)), max(letterHeights(1,:)), 1000);
    yFit = polyval(coefficients, xFit);
    hold on;
    lines(i) = plot(xFit, yFit, strcat(colors(i), '-'), 'LineWidth', 1);
    grid on;
end

xticklabels({'0.5° (20/120)','1° (20/240)','1.5° (20/360)', '2° (20/480)', '2.5° (20/600)', '3° (20/720)', '3.5° (20/840)', '4° (20/960)',})
xtickangle(15);

xlabel("Letter Height (degrees) and Visual Acuity (Snellen Units)");
ylabel("Reaction Time (ms)");
title("Reaction Time vs. Letter Height");

legend([lines(1), lines(2), lines(3), lines(4), lines(5)], {legends(1), legends(2), legends(3), legends(4), legends(5)}, 'Location', 'best');
title(legend,'Eccentricity (degrees)')
