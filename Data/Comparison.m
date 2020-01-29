clear variables;
clear all;

global CHECKBOXES;
ButtonUI();

angles = [0, 5, 10, 15, 20, 25, 30, 35, 40];

%T1 
if CHECKBOXES(1)
    table = readCsv('T1');
    t1 = zeros(1,16);
    count = zeros(1,16);
    count(1) = 1;
    for i = 1:size(table,1)
        angle = table(i, 4);
        if(angle == 0.23)
            angle = 2;
        elseif(angle <= 4)
            angle = (angle * 2) + 2;
        else
            angle = angle + 6;
        end
        t1(1,angle) = t1(1,angle) + table(i, 3);
        count(1,angle) = count(1,angle) + 1;
    end
    t1 = t1./count;
    t1LetterHeights = [0, 0.23,0.5,1,1.5,2,2.5,3,3.5,4,5,6,7,8,9,10];
    graphLine(t1, t1LetterHeights, "T1", [1 0 0]);
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
    table = readCsv('Isolated Character');
    ic = zeros(1,9);
    count = zeros(1,9);
    for i = 1:size(table,1)
        angle = (table(i,3)/5)+1;
        ic(1,angle) = ic(1,angle) + table(i, 2);
        count(1,angle) = count(1,angle) + 1;
    end
    ic = ic./count;
    graphLine(angles, ic, "Isolated Character", [1 0 0.68]);
end
%ANSTIS
if CHECKBOXES(12)
    anstisX = [0, 4.02148, 8.94224, 16.2079, 17.3219, 23.249, 28.0508, 31.1738, 31.6387, 38.203, 55.2726, 55.8553];
    anstisY = [0, 0.243199, 0.377233, 0.681458, 0.839386, 1.00387, 1.34426, 1.67235, 1.17467 , 2.34074, 4.00559, 3.33797];
    graphLine(anstisX, anstisY, "Anstis", [0 0 0]);
    %coefficients = [0.046,-0.031];
end

xlim([0 inf]);
ylim([0 inf]);
xlabel("Eccentricity (degrees)");
ylabel("Letter Height (degrees)");
title("Letter Height vs. Retinal Eccentricity");
legend('show', 'Location', 'northwest');
grid on;