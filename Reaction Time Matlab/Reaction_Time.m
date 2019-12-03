% Clear the workspace and the screen
close all hidden;
clear mex;
clearvars;
sca;
Screen('Preference', 'SkipSyncTests', 0);

%EXPERIMENTAL VARIABLES
letters = 'EPB';
correctLetter = letters(randi(length(letters)));
trials = 50;

dataAnswer = questdlg('Record Data?', '', 'Yes', 'No', 'Cancel', 'Yes');
recordData =(char(dataAnswer(1)) == 'Y')

if(recordData)
    prompt = {'Enter subject name:'};
    dlgtitle = 'Input';
    dims = [1 35];
    answer = inputdlg(prompt,dlgtitle,dims);
    subjectName = char(answer(1,1));

    %GET DATE, SET VARIABLES FOR OUTPUT FILE NAME
    c = clock;
    month = num2str(c(2));
    day = num2str(c(3));
    dash = '-';
    underscore = '_';

    experimentFolderName = 'Data';
    mkdir(experimentFolderName);
    experimentRecordFilename = fullfile(experimentFolderName, [subjectName underscore month dash day '.csv']);

    fileID = fopen(experimentRecordFilename, 'a');
    if(exist(experimentRecordFilename, 'file') ~= 2)
        fileID = fopen(experimentRecordFilename, 'a');
        fprintf(fileID, '%s, %s\n', 'Letter Height (degrees)', 'Reaction Time (ms)');
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
%SET BLEND FUNCTION
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
% Query the frame duration
%ifi = Screen('GetFlipInterval', window);
%SET UP ANTI-ALIASING
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
%SET TEXT FONT
Screen('TextFont', window, 'Helvetica');

%SIZE OF WINDOW IN PIXELS
[screenXpixels, screenYpixels] = Screen('WindowSize', window);
%COORDINATES OF THE CENTER OF SCREEN
halfX = 0.5 * screenXpixels;
halfY = 0.5 * screenYpixels;

%tS = [13, 26, 39, 51, 64, 78];
dispX = [1271, 1261, 1251, 1241, 1231, 1221, 1211, 1201, 1191, 1181, 1171, 1161, 1151, 1141];
dispY = [730, 738, 748, 758, 768, 778, 788, 798, 808, 818, 828, 838, 848, 858];
tS = [26, 51, 78, 103, 130, 155, 181, 208, 235, 260, 288, 314, 342, 370];

Screen('TextSize', window, 103);
DrawFormattedText(window, correctLetter, 1241, 758, [1 0 0]);
DrawFormattedText(window, 'Press Spacebar as fast as you can if the character displayed matches this character\nPress any key to begin', 900, 300, [0 0 0]);
Screen('Flip', window);
KbWait();

for trialNum = 1:trials
    size = randi(14);
    txtSize = tS(size);
    Screen('TextSize', window, txtSize);
    Screen('DrawDots', window, [halfX halfY], 20, [0 255 0], [], 2);
    Screen('Flip', window);
    
    breakMult = randi(5);
    breakTime = 4/breakMult;
    
    letter = letters(randi(length(letters)));
    
    WaitSecs(breakTime);
    
    Screen('DrawDots', window, [halfX halfY], 20, [0 255 0], [], 2);
    DrawFormattedText(window, letter, dispX(size), dispY(size), black);
    Screen('Flip', window);
    startTime = GetSecs;
    
    TC = char(letter);
    CC = char(correctLetter);
    key = 'Z';
    reactionTime = 0;
    
    elapsedTime = GetSecs - startTime;

    printData = 0;
    while(elapsedTime < 1)
        s = GetSecs();
        elapsedTime = s - startTime;
        if elapsedTime > 0.5
            Screen('DrawDots', window, [halfX halfY], 20, [0 255 0], [], 2);
            Screen('Flip',window);
        end
        [keyIsDown, secs, keyCode, deltaSecs] = KbCheck(-1);
        if keyCode(27) == 1
            sca;
            return;
        end
        if(keyIsDown == 0)
            continue;
        end
        s = GetSecs();
        elapsedTime = s - startTime;

        if (CC == TC && recordData)
            reactionTime = ((secs - startTime)*1000);
            fprintf(fileID, '%i, %4.2f\n', size, reactionTime);
        end
    end
end

Screen('TextSize', window, 25);
DrawFormattedText(window, 'DONE!', 1260, 720, black);
Screen('Flip', window);
WaitSecs(5);
sca;
return;
