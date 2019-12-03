%T1
%Created by Patrick Wilson on 6/25/2019
%Github.com/patrickmwilson
%Created for the Elegant Mind Collaboration at UCLA under Professor Katsushi Arisaka
%Copyright � 2019 Elegant Mind Collaboration. All rights reserved.

% Clear the workspace and the screen
close all hidden;
clear variables;
clear mex;
sca;
Screen('Preference', 'SkipSyncTests', 0);

trials=3;

%HARDCODED TEXT SIZES
%13 = 0.5, 26 = 1, 39 = 1.5, 51 = 2, 64 = 2.5, 78 = 3, 91 = 3.5, 103 = 4 (degrees)
tS = [6, 13, 26, 39, 51, 64, 78, 91, 103, 130, 155, 181, 208, 235, 260];
cols = [200, 150, 151, 99, 76, 60, 51, 43, 38, 30, 25, 22, 19, 17, 15];
center = [7582, 5092, 4513, 1969, 1209, 775, 556, 427, 340, 208, 148, 108, 73, 66, 76];
charactersPerSize = [15074, 9966, 8850, 3850, 2400, 1500, 1050, 800, 625, 375, 259, 206, 151, 125, 127];
letters = 'EPB';


%HARDCODED TEXT ARRAY DISPLAY COORDINATES
arrayHorizontalStart = [850, 601, -4, -8, -30, -31, -46, -32, -66, -70, -7, -115, -43, -60, -20];
arrayVerticalStart = [500, 296, -24, -7, -27, -24, -31, -66, -66, -13, 2, 63, 174, 102, -224]; 

%MEASUREMENTS IN CENTIMETERS FOR TEXT SIZES
distToScreen = 50; %centimeters
letterHeight = [0.2, 0.44, 0.89, 1.31, 1.75, 2.18, 2.62, 3.06, 3.5, 4.39, 5.255, 6.14, 7.03, 7.92, 8.79];
distPerCharH = [0.3, 0.41, 0.8, 1.22, 1.6, 2.02, 2.48, 2.9, 3.26, 4.15, 4.85, 5.65, 6.5, 7.4, 8.2];
distPerCharV = [0.3, 0.6, 1.22, 1.82, 2.4, 3.02, 3.68, 4.3, 4.88, 6.15, 7.3, 8.6, 9.8, 11.1, 12.4];

%HARDCODED COORDINATES FOR CENTER MASKING RECTANGLE
centerRectXStart = [0, 1276, 1270, 1268, 1260, 1258, 1256, 1254, 1252, 1243, 1239, 1224, 1210, 1200, 1210];
centerRectYStart = [0, 715, 710, 705, 700, 695, 690, 685, 680, 670, 660, 650, 640, 630, 620];
centerRectXEnd = [0, 1286, 1290, 1290, 1294, 1302, 1310, 1318, 1323, 1330, 1330, 1340, 1350, 1360, 1355];
centerRectYEnd = [0, 728, 730, 735, 740, 745, 750, 755, 760, 770, 780, 790, 800, 810, 825];

%HARDCODED DOT SIZES AND DISPLAY COORDINATES
dotSizePix = [5, 8, 12, 13, 15, 17, 18, 19, 20, 22, 22, 22, 22, 22, 22];
dotXPos = [1280, 1280, 1280, 1280, 1280, 1280, 1280, 1280, 1280, 1280, 1280, 1280, 1280, 1280, 1280];
dotYPos = [720, 720, 720, 720, 720, 720, 720, 720, 720, 720, 720, 720, 720, 720, 720];

%HARDCODED DIRECTION INDICATOR SIZES AND DISPLAY COORDINATES
dirText = '><^v';
dirTS = [7, 10, 13, 15, 17, 19, 20, 20, 20, 20, 20, 20, 20, 20, 20];
dirTextXPos = [1278, 1277, 1275, 1275, 1274, 1274, 1274, 1274, 1274, 1274, 1274, 1274, 1274, 1274, 1274];
dirTextYPos = [722, 724, 725, 725, 727, 727, 727, 727, 727, 727, 727, 727, 727, 727, 727];

%Y/N INPUT DIALOGUE FOR DATA RECORDING
recordData = true;
dataAnswer = questdlg('Record Data?', '', 'Yes', 'No', 'Cancel', 'Yes');
if(char(dataAnswer(1)) == 'N')
    recordData = false;
end

%OPEN NEW FOLDER, SET CSV NAME
if(recordData)
    %y/N INPUT PROMPT FOR EYETRACKING
    eyetracking = true;
    eyetrackingAnswer = questdlg('Eye Tracking?', '', 'Yes', 'No', 'Cancel', 'No');
    if(char(dataAnswer(1)) == 'N')
        eyetracking = false;
    end
    
    %INPUT PROMPT FOR PARTICIPANT NAME
    prompt = {'Enter participant name:' };
    dlgtitle = 'Input';
    dims = [1 35];
    answer = inputdlg(prompt,dlgtitle,dims);
    coordinatorName = char(answer(1,1));
    
    %GET DATE, SET VARIABLES FOR OUTPUT FILE NAME
    c = clock;
    month = num2str(c(2));
    day = num2str(c(3));
    year = num2str(c(1));
    minute = num2str(c(5));
    dash = '-';
    underscore = '_';
    
    %MAKE DIRECTORY, CREATE EYETRACKING AND DATA CSV
    folderName = 'Data';
    innerFolderName = [coordinatorName underscore month dash day dash minute];
    mkdir(folderName);
    cd(folderName);
    mkdir(innerFolderName);
    csvName = fullfile(innerFolderName, 'Data.csv');
    printHeader = true;
    if(exist(csvName, 'file') == 2)
        printHeader = false;
    end
    fileID = fopen(csvName, 'a');
    if(printHeader)
        fileID = fopen(csvName, 'a');
        fprintf(fileID, '%s, %s, %s, %s\n', 'Direction', 'Characters Read', 'Eccentricity (degrees)', 'Letter Height (degrees)');
    end
    
end


%DEFAULT SETTINGS FOR PSYCHTOOLBOX
PsychDefaultSetup(2);
%GET SCREEN NUMBERS, SELECT TV SCREEN (1 = monitor, 2 = tv)
screens = Screen('Screens');
screenNumber = 2;
%DEFINE BLACK AND WHITE
black = BlackIndex(screenNumber);
white = WhiteIndex(screenNumber);

%OPEN WHITE ON-SCREEN WINDOW
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, white);
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
%ANTI-ALIASING
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
%SET TEXT FONT
Screen('TextFont', window, 'Helvetica');

%GET SIZE OF WINDOW IN PIXELS
[screenXpixels, screenYpixels] = Screen('WindowSize', window);
%COORDINATES OF THE CENTER OF SCREEN
halfX = 0.5 * screenXpixels;
halfY = 0.5 * screenYpixels;

%CAMERA SETUP AND TRIGGER
if eyetracking
    %CREATE EYETRACKING OUTPUT CSV
    eyetrackingCsvName = fullfile(innerFolderName, 'EyetrackingFrames.csv');
    fileID = fopen(eyetrackingCsvName, 'a');
    fprintf(fileID, '%s, %s, %s\n', 'Start Frame', 'End Frame', 'Usable');
    
    %CREATE EYETRACKING CALIBRATION OUTPUT CSV
    calibrationCsvName = fullfile(innerFolderName, 'Calibration.csv');
    fileID = fopen(calibrationCsvName, 'a');
    fprintf(fileID, '%s, %s\n', 'Angle', 'Frame');
    
    %INITIALIZE CAMERA SETTINGS
    imaqreset;
    imaqmex('feature','-limitPhysicalMemoryUsage',false);
    vid = videoinput('gentl', 1, 'Mono8');
    src = getselectedsource(vid);
    vid.FramesPerTrigger = inf;
    vid.LoggingMode = 'disk';
    videoFileName = fullfile(innerFolderName, 'Eyetracking.avi');
    diskLogger = VideoWriter(videoFileName, 'Grayscale AVI');
    vid.DiskLogger = diskLogger;
    triggerconfig(vid, 'manual');
    vid.ROIPosition = [0 0 640 480];
    src.ExposureTime = 1700.003;
    src.Gain = 10;
    
    %TRIGGER CAMERA
    start(vid);
    trigger(vid);
    pause(1);
end

%HARDCODED COORDINATES FOR EYETRACKING CALIBRATION
calibrationAngles = [ -20, -15, -10, -5, 0, 5, 10, 15, 20 ];
calibrationXCoords = [ 896, 997, 1095, 1189, 1280, 1371, 1466, 1564, 1665 ];
instructionText = 'Focus your eyes on the green dot and press any key once you have done so. Press any key to begin.';

%EYETRACKING CALIBRATION
if eyetracking
    
    %DISPLAY CALIBRATION INSTRUCTIONS
    Screen('TextSize', window, 25);
    DrawFormattedText(window, instructionText, 800, halfY, black);
    Screen('Flip', window);
    KbWait();
    WaitSecs(1);
    %LOOP THROUGH EACH ANGLE FOR CALIBRATION
    for i = 1:9
        Screen('DrawDots', window, [calibrationXCoords(i) 720], 20, [0 255 0], [], 2);
        Screen('Flip',window);
        %WAIT FOR KEYPRESS
        [secs, keyCode, deltaSecs] = KbWait();
        %STORE FRAME CORRESPONDING TO KEYPRESS
        frame = vid.FramesAcquired;
        if keyCode(27) == 1 % ESC 
            sca; %CLEAR SCREEN IF ESC IS PRESSED
            if eyetracking
                stop(vid);
                %PAUSE EXECUTION UNTIL VIDEO IS FULLY WRITTEN TO DISK
                while(vid.FramesAcquired ~= vid.DiskLoggerFrameCount)
                    pause(.1);
                end
                delete(vid);
            end
            return;
        end
        %CALIBRATION DATA OUTPUT
        angle = calibrationAngles(i);
        fileID = fopen(calibrationCsvName, 'a');
        fprintf(fileID, '%i, %i\n', angle, frame);
        WaitSecs(1);
    end
    
    DrawFormattedText(window, 'Eyetracking Calibration complete', 800, halfY, black);
    Screen('Flip', window);
    WaitSecs(5);
end

for trialNum = 1:trials
    
    %GENERATE RANDOMIZED SIZE ARRAY
    sizes = randperm(15,15);
    
    %LOOP THROUGH RANDOMIZED SIZE ARRAY
    for sizeIndex = 1:15
        %SET SIZE
        size = sizes(sizeIndex);
        
        %SET NUM OF CHARACTERS & CENTER MASKING RECTANGLE COORDINATES
        characters = charactersPerSize(size);
        centerRect = SetRect(centerRectXStart(size),centerRectYStart(size),centerRectXEnd(size),centerRectYEnd(size));
        
        %GENERATE RANDOMIZED DIRECTION ARRAY
        directions = randperm(4,4);
        directionIndex = 1;
        
        %LOOP THROUGH RANDOMIZED DIRECTION ARRAY
        while(directionIndex <= 4)
            numCorrect = 0;
            
            %SET DIRECTION
            direction = directions(directionIndex);
            
            %SET SPACER, OUTPUT TEXT, AND DISTANCE BASED ON DIRECTION
            if(direction == 1)
                dir = 'Right';
                distPerChar = distPerCharH(size);
                spacer = 1;
            end
            if(direction == 2)
                dir = 'Left';
                distPerChar = distPerCharH(size);
                spacer = -1;
            end
            if(direction == 3)
                dir = 'Up';
                distPerChar = distPerCharV(size);
                spacer = -(cols(size)+2);
            end
            if(direction == 4)
                dir = 'Down';
                distPerChar = distPerCharV(size);
                spacer = cols(size)+2;
            end
            
            %GENERATE RANDOM ARRAY OF 'EPB'
            textArray = blanks(characters);
            for i = 1:characters    
                q = letters(randi(length(letters)));
                if(mod(i,cols(size)+1)==0)
                    textArray = strcat(textArray,'\n');
                else
                    textArray = strcat(textArray,q);
                end
            end
            
            %Set start position in text array
            pos = center(size)+spacer;
            
            %LOOP UNTIL INCORRECT KEYPRESS
            while(1)
                %DRAW TEXT ARRAY
                wrappedString=WrapString(textArray,500);
                Screen('TextSize', window, tS(size));
                DrawFormattedText(window, wrappedString, arrayHorizontalStart(size), arrayVerticalStart(size), black);
                %DRAW CENTER MASKING RECTANGLE
                Screen('FillRect', window, [], centerRect);
                %DRAW CENTER DOT
                Screen('DrawDots', window, [dotXPos(size) dotYPos(size)], dotSizePix(size), [0 255 0], [], 2);
                %DRAW DIRECTION INDICATOR
                Screen('TextSize', window, dirTS(size));
                DrawFormattedText(window, dirText(direction), dirTextXPos(size), dirTextYPos(size), black);
                Screen('Flip', window);
                
                %OUTPUT FRAME NUMBER CORRESPONDING TO START OF TRIAL
                if eyetracking
                    if numCorrect == 0
                        startFrame = vid.FramesAcquired;
                    end
                end
                
                %WAIT FOR KEYPRESS
                [secs, keyCode, deltaSecs] = KbWait();
                if eyetracking
                    %STORE FRAME OF LAST KEYPRESS
                    endFrame = vid.FramesAcquired;
                end
                %DISPLAY GREEN DOT TO INDICATE 0.5 SECOND WAIT PERIOD BEFORE
                %NEXT KEYPRESS
                wrappedString=WrapString(textArray,500);
                Screen('TextSize', window, tS(size));
                DrawFormattedText(window, wrappedString, arrayHorizontalStart(size), arrayVerticalStart(size), black);
                Screen('FillRect', window, [], centerRect);
                Screen('DrawDots', window, [dotXPos(size) dotYPos(size)], dotSizePix(size), [255 0 0], [], 2);
                Screen('TextSize', window, dirTS(size));
                DrawFormattedText(window, dirText(direction), dirTextXPos(size), dirTextYPos(size), black);
                Screen('Flip', window);
                WaitSecs(0.5);
                
                %CHECK KEYBOARD INPUT
                if keyCode(66) == 1 % B
                    key = 'B';
                elseif keyCode(69) == 1 % E 
                    key = 'E';
                elseif keyCode(80) == 1 % P
                    key = 'P';
                elseif keyCode(27) == 1 % ESC 
                    sca; %CLEAR SCREEN IF ESC IS PRESSED
                    if eyetracking
                        stop(vid);
                        %PAUSE EXECUTION UNTIL VIDEO IS FULLY WRITTEN TO DISK
                        while(vid.FramesAcquired ~= vid.DiskLoggerFrameCount)
                            pause(.1);
                        end
                        delete(vid);
                    end
                    return; 
                else
                    key = 'Q';
                end
                
                %CONVERT TEXTARRAY TO CHAR, INDEX CURRENT CHAR
                T = char(textArray);
                currentChar = T(pos);
                
                correct = true;
                %IF KEY IS CORRECT, MOVE POS & CONTINUE
                if key == currentChar
                    pos = pos+spacer;
                    if(pos < 0 || pos > characters)
                        correct = false;
                    end
                end
                %IF KEY IS INCORRECT, OUTPUT, ADVANCE DIRECTION, & BREAK
                if key ~= currentChar
                    correct = false;
                end
                
                if(correct)
                    numCorrect = numCorrect + 1;
                    continue;
                end
                
                if(~correct)
                    %ECCENTRICITY CALCULATION & OUTPUT
                    eccentricity = atand((numCorrect*distPerChar)/(distToScreen));
                    letterHeightDeg = atand((letterHeight(size))/(distToScreen));
                    %DATA OUTPUT
                    if(recordData)
                        fileID = fopen(csvName, 'a');
                        fprintf(fileID, '%s, %d, %4.2f, %4.2f\n', dir, numCorrect, eccentricity, letterHeightDeg);
                    end
                    %EYETRACKING FRAME OUTPUT
                    if eyetracking
                        fileID = fopen(eyetrackingCsvName, 'a');
                        fprintf(fileID, '%i, %i, %i\n', startFrame, endFrame, 1);
                    end
                    directionIndex = directionIndex + 1;
                    break;
                end
            end    
        end
        %5 SECOND BREAK BETWEEN TEXT SIZES
        if(sizeIndex ~= 8)
            Screen('TextSize', window, 25);
            DrawFormattedText(window, '5 Second Break', halfX, halfY, black);
            Screen('Flip', window);
            WaitSecs(5);
        end
    end
    %BREAK UNTIL KEYPRESS BETWEEN TRIALS
    if(trialNum ~= trials)
        Screen('TextSize', window, 25);
        DrawFormattedText(window, 'Break (Press Any Key to Continue)', halfX, halfY, black);
        Screen('Flip', window);
        [secs, keyCode, deltaSecs] = KbWait();
        WaitSecs(2);
    end
end

%END, WAIT 5 SECONDS BEFORE CLEARING SCREEN
Screen('TextSize', window, 25);
DrawFormattedText(window, 'DONE!', halfX, halfY, black);
Screen('Flip', window);
WaitSecs(5);

%TURN OFF CAMERA
if eyetracking
    stop(vid);
    %PAUSE EXECUTION UNTIL VIDEO IS FULLY WRITTEN TO DISK
    while(vid.FramesAcquired ~= vid.DiskLoggerFrameCount)
        pause(.1);
    end
    delete(vid);
end

sca;
return;
